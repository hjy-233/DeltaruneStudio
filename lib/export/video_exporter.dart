import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:deltarune_studio/shared_render/studio_rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

final class VideoExporter {
  VideoExporter({this.width = 640, this.height = 480, this.fps = 30});

  final int width;
  final int height;
  final int fps;
  final Map<String, ui.Image> _imageCache = {};

  Future<void> export({
    required StudioReady ready,
    required String outputPath,
    BuiltInAssetLibrary? builtIns,
    void Function(String message)? onProgress,
  }) async {
    if (kIsWeb) {
      throw const VideoExportException('Web 端暂不支持导出视频。');
    }
    final ffmpeg = await _findFfmpeg();
    if (ffmpeg == null) {
      throw const VideoExportException(
        '没有找到 ffmpeg。请先安装 ffmpeg，例如：brew install ffmpeg。',
      );
    }

    final chain = ready.activeChain;
    if (chain == null) {
      throw const VideoExportException('请先选择一个事件链再导出。');
    }
    final plan = TimelinePlan(
      project: ready.project,
      scene: ready.currentScene,
      chain: chain,
    );
    final duration = math.max(plan.duration, 0.1);
    final tempDir = await Directory.systemTemp.createTemp('drs_export_');
    try {
      final frameCount = math.max(1, (duration * fps).ceil());
      for (var frame = 0; frame < frameCount; frame += 1) {
        final time = math.min(frame / fps, duration);
        final world = plan.evaluate(time);
        final png = await _renderFrame(ready, world, time);
        final file = File(p.join(tempDir.path, _frameName(frame)));
        await file.writeAsBytes(png, flush: false);
        if (frame % fps == 0 || frame == frameCount - 1) {
          onProgress?.call('正在渲染帧 ${frame + 1} / $frameCount');
          await Future<void>.delayed(Duration.zero);
        }
      }

      onProgress?.call('正在合成视频...');
      final args = await _ffmpegArgs(
        ready: ready,
        builtIns: builtIns,
        plan: plan,
        framePattern: p.join(tempDir.path, 'frame_%06d.png'),
        outputPath: outputPath,
        tempDir: tempDir,
      );
      final result = await Process.run(ffmpeg, args);
      if (result.exitCode != 0) {
        throw VideoExportException(
          'ffmpeg 导出失败：${result.stderr}\n${result.stdout}',
        );
      }
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  Future<String?> _findFfmpeg() async {
    try {
      final direct = await Process.run('ffmpeg', const ['-version']);
      if (direct.exitCode == 0) {
        return 'ffmpeg';
      }
    } on Object {
      // Fall back to common install locations below.
    }
    for (final candidate in const [
      '/opt/homebrew/bin/ffmpeg',
      '/usr/local/bin/ffmpeg',
      '/usr/bin/ffmpeg',
    ]) {
      if (await File(candidate).exists()) {
        return candidate;
      }
    }
    return null;
  }

  Future<List<String>> _ffmpegArgs({
    required StudioReady ready,
    required BuiltInAssetLibrary? builtIns,
    required TimelinePlan plan,
    required String framePattern,
    required String outputPath,
    required Directory tempDir,
  }) async {
    final args = <String>['-y', '-framerate', '$fps', '-i', framePattern];
    final videoEvents = plan.spans
        .where((span) => span.event is VideoPlayEvent)
        .toList(growable: false);
    final audioCues = _exportAudioCues(plan);
    final videoInputs = <_TimedVideoInput>[];
    final audioInputs = <_TimedAudioInput>[];

    for (final span in videoEvents) {
      final event = span.event as VideoPlayEvent;
      final file = await _assetFile(
        ready,
        builtIns,
        event.assetId,
        AssetKind.video,
        tempDir,
      );
      if (file == null) {
        continue;
      }
      final index = 1 + videoInputs.length + audioInputs.length;
      args.addAll(['-i', file.path]);
      videoInputs.add(_TimedVideoInput(index, span.start, span.end));
    }

    for (final cue in audioCues) {
      final file = await _assetFile(
        ready,
        builtIns,
        cue.assetId,
        AssetKind.audio,
        tempDir,
      );
      if (file == null) {
        continue;
      }
      if (cue.isBgm) {
        args.addAll(['-stream_loop', '-1']);
      }
      final index = 1 + videoInputs.length + audioInputs.length;
      args.addAll(['-i', file.path]);
      audioInputs.add(_TimedAudioInput(index, cue.time));
    }

    final filter = _filterGraph(
      duration: plan.duration,
      videoInputs: videoInputs,
      audioInputs: audioInputs,
    );
    args.addAll(['-filter_complex', filter, '-map', '[vout]']);
    if (audioInputs.isNotEmpty) {
      args.addAll(['-map', '[aout]']);
    }
    args.addAll([
      '-c:v',
      'libx264',
      '-pix_fmt',
      'yuv420p',
      '-movflags',
      '+faststart',
      if (audioInputs.isNotEmpty) ...['-c:a', 'aac', '-b:a', '192k'],
      '-r',
      '$fps',
      '-t',
      plan.duration.toStringAsFixed(3),
      outputPath,
    ]);
    return args;
  }

  List<_ExportAudioCue> _exportAudioCues(TimelinePlan plan) {
    final cues = <_ExportAudioCue>[];
    for (final cue in plan.audioCues) {
      switch (cue.event) {
        case AudioPlayBgmEvent(:final assetId):
          cues.add(
            _ExportAudioCue(assetId: assetId, time: cue.time, isBgm: true),
          );
        case AudioPlaySoundEvent(:final assetId):
          cues.add(_ExportAudioCue(assetId: assetId, time: cue.time));
        default:
          break;
      }
    }
    for (final cue in plan.dialogueTypeCues) {
      cues.add(_ExportAudioCue(assetId: cue.assetId, time: cue.time));
    }
    cues.sort((a, b) => a.time.compareTo(b.time));
    return cues;
  }

  String _filterGraph({
    required double duration,
    required List<_TimedVideoInput> videoInputs,
    required List<_TimedAudioInput> audioInputs,
  }) {
    final graph = StringBuffer('[0:v]format=rgba[base0];');
    var currentVideo = 'base0';
    for (var index = 0; index < videoInputs.length; index += 1) {
      final input = videoInputs[index];
      final prepared = 'video$index';
      final next = 'base${index + 1}';
      graph.write(
        '[${input.inputIndex}:v]'
        'setpts=PTS-STARTPTS,'
        'scale=$width:$height:force_original_aspect_ratio=decrease,'
        'pad=$width:$height:(ow-iw)/2:(oh-ih)/2:black,'
        'format=rgba,setpts=PTS+${input.start.toStringAsFixed(3)}/TB'
        '[$prepared];',
      );
      graph.write(
        '[$currentVideo][$prepared]overlay=0:0:'
        "enable='between(t,${input.start.toStringAsFixed(3)},"
        "${input.end.toStringAsFixed(3)})'[$next];",
      );
      currentVideo = next;
    }
    graph.write('[$currentVideo]format=yuv420p[vout]');

    if (audioInputs.isEmpty) {
      return graph.toString();
    }
    graph.write(';');
    for (var index = 0; index < audioInputs.length; index += 1) {
      final input = audioInputs[index];
      final remaining = math.max(0.1, duration - input.start);
      graph.write(
        '[${input.inputIndex}:a]'
        'atrim=0:${remaining.toStringAsFixed(3)},'
        'asetpts=PTS-STARTPTS,'
        'adelay=${(input.start * 1000).round()}:all=1'
        '[audio$index];',
      );
    }
    for (var index = 0; index < audioInputs.length; index += 1) {
      graph.write('[audio$index]');
    }
    graph.write(
      'amix=inputs=${audioInputs.length}:duration=longest:'
      'dropout_transition=0,atrim=0:${duration.toStringAsFixed(3)}[aout]',
    );
    return graph.toString();
  }

  Future<File?> _assetFile(
    StudioReady ready,
    BuiltInAssetLibrary? builtIns,
    String assetId,
    AssetKind kind,
    Directory tempDir,
  ) async {
    if (assetId.isEmpty) {
      return null;
    }
    final asset = ready.assetById(assetId);
    if (asset != null && asset.kind == kind) {
      final dataUri = asset.dataUri;
      if (dataUri != null && dataUri.isNotEmpty) {
        final bytes = _bytesFromDataUri(dataUri);
        final file = File(
          p.join(
            tempDir.path,
            'asset_$assetId${_extension(asset.originalName)}',
          ),
        );
        await file.writeAsBytes(bytes);
        return file;
      }
      final directory = ready.projectDirectory;
      if (directory != null) {
        final file = File(p.join(directory.path, asset.relativePath));
        if (await file.exists()) {
          return file;
        }
      }
    }
    final builtIn = builtIns?.assets
        .where((candidate) => candidate.id == assetId && candidate.kind == kind)
        .firstOrNull;
    if (builtIn == null) {
      return null;
    }
    final file = File(builtIn.resolvedPath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<Uint8List> _renderFrame(
    StudioReady ready,
    RuntimeWorld world,
    double time,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width.toDouble(), height.toDouble());
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);

    final cameraOrigin = _cameraOrigin(world, size);
    canvas.save();
    canvas.translate(-cameraOrigin.dx, -cameraOrigin.dy);
    for (final object in world.scene.objects) {
      final runtimeObject = world.objects[object.objectId];
      await _drawObject(canvas, ready, object, runtimeObject, time);
    }
    canvas.restore();

    if (world.activeVideo != null) {
      canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    }
    if (world.dialogue != null) {
      await _drawDialogue(canvas, ready, world.dialogue!, size);
    }
    if (world.fadeOpacity > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black.withValues(alpha: world.fadeOpacity),
      );
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    return data!.buffer.asUint8List();
  }

  Offset _cameraOrigin(RuntimeWorld world, Size size) {
    final target = _cameraTarget(world);
    if (target == null) {
      return Offset.zero;
    }
    return Offset(target.dx - size.width / 2, target.dy - size.height / 2);
  }

  Offset? _cameraTarget(RuntimeWorld world) {
    final focus = world.cameraFocusTarget;
    if (focus != null) {
      return focus.map(
        object: (value) => _objectCenter(world.objects[value.objectId]),
        point: (value) => Offset(value.x, value.y),
      );
    }
    return _objectCenter(world.objects[world.cameraFollowObjectId]);
  }

  Offset? _objectCenter(RuntimeObject? object) {
    if (object == null) {
      return null;
    }
    final transform = object.transform;
    return Offset(
      transform.x + transform.width * transform.scale / 2,
      transform.y + transform.height * transform.scale / 2,
    );
  }

  Future<void> _drawObject(
    Canvas canvas,
    StudioReady ready,
    SceneObject object,
    RuntimeObject? runtimeObject,
    double time,
  ) async {
    final assetId = imageAssetIdForObject(
      ready: ready,
      object: object,
      runtimeObject: runtimeObject,
      currentTime: time,
    );
    if (assetId == null) {
      return;
    }
    final asset = ready.assetById(assetId);
    if (asset == null ||
        asset.kind == AssetKind.audio ||
        asset.kind == AssetKind.video) {
      return;
    }
    final image = await _imageForAsset(ready, asset);
    if (image == null) {
      return;
    }
    final transform = runtimeObject?.transform ?? object.objectTransform;
    final dst = Rect.fromLTWH(
      transform.x,
      transform.y,
      transform.width * transform.scale,
      transform.height * transform.scale,
    );
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.none,
    );
  }

  Future<void> _drawDialogue(
    Canvas canvas,
    StudioReady ready,
    DialogueBoxState dialogue,
    Size size,
  ) async {
    final template = dialogueTemplateForStyle(dialogue.style);
    final templateImage = await _bundleImage(template.assetPath);
    if (templateImage == null) {
      return;
    }
    final boxWidth = math.max(280.0, size.width - 28);
    final scale = boxWidth / template.width;
    final boxHeight = template.height * scale;
    final boxRect = Rect.fromLTWH(
      (size.width - boxWidth) / 2,
      size.height - boxHeight - math.max(18, 20 * scale),
      boxWidth,
      boxHeight,
    );
    canvas.drawImageRect(
      templateImage,
      Rect.fromLTWH(
        0,
        0,
        templateImage.width.toDouble(),
        templateImage.height.toDouble(),
      ),
      boxRect,
      Paint()..filterQuality = FilterQuality.none,
    );

    final portrait = await _portraitImage(ready, dialogue.portraitAssetId);
    final hasPortrait = portrait != null;
    if (portrait != null) {
      final portraitRect = Rect.fromLTWH(
        boxRect.left + 28 * scale + 10 * scale,
        boxRect.top + 26 * scale + 10 * scale,
        88 * scale,
        88 * scale,
      );
      canvas.drawImageRect(
        portrait,
        Rect.fromLTWH(
          0,
          0,
          portrait.width.toDouble(),
          portrait.height.toDouble(),
        ),
        portraitRect,
        Paint()..filterQuality = FilterQuality.none,
      );
    }

    final visibleCharacters =
        dialogue.visibleCharacters ?? dialogue.text.length;
    final visibleText = dialogue.text.substring(
      0,
      visibleCharacters.clamp(0, dialogue.text.length),
    );
    final paragraphStyle = ui.ParagraphStyle(
      fontFamily: 'PhoenixPixel',
      fontSize: 24 * scale,
      height: 1.35,
      textDirection: TextDirection.ltr,
    );
    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(
        ui.TextStyle(
          color: Colors.white,
          fontFamily: 'PhoenixPixel',
          fontSize: 24 * scale,
          height: 1.35,
        ),
      )
      ..addText(_dialogueText(visibleText));
    final paragraph = builder.build();
    final textLeft = boxRect.left + (hasPortrait ? 146 : 42) * scale;
    final textTop = boxRect.top + 36 * scale;
    final textWidth = boxRect.right - textLeft - 42 * scale;
    paragraph.layout(ui.ParagraphConstraints(width: textWidth));
    canvas.drawParagraph(paragraph, Offset(textLeft, textTop));
  }

  String _dialogueText(String text) {
    final lines = text.split('\n');
    return [for (final line in lines) '* $line'].join('\n');
  }

  Future<ui.Image?> _portraitImage(StudioReady ready, String? assetId) async {
    final asset = ready.assetById(assetId);
    if (asset == null) {
      return null;
    }
    return _imageForAsset(ready, asset);
  }

  Future<ui.Image?> _imageForAsset(StudioReady ready, AssetRef asset) async {
    final cached = _imageCache[asset.id];
    if (cached != null) {
      return cached;
    }
    Uint8List? bytes;
    final dataUri = asset.dataUri;
    if (dataUri != null && dataUri.isNotEmpty) {
      bytes = _bytesFromDataUri(dataUri);
    } else {
      final directory = ready.projectDirectory;
      if (directory != null) {
        final file = File(p.join(directory.path, asset.relativePath));
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      }
    }
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    final image = await _decodeImage(bytes);
    _imageCache[asset.id] = image;
    return image;
  }

  Future<ui.Image?> _bundleImage(String assetPath) async {
    final cached = _imageCache[assetPath];
    if (cached != null) {
      return cached;
    }
    final data = await rootBundle.load(assetPath);
    final image = await _decodeImage(data.buffer.asUint8List());
    _imageCache[assetPath] = image;
    return image;
  }

  Future<ui.Image> _decodeImage(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  Uint8List _bytesFromDataUri(String dataUri) {
    final comma = dataUri.indexOf(',');
    if (comma < 0) {
      return Uint8List(0);
    }
    return base64Decode(dataUri.substring(comma + 1));
  }

  String _extension(String name) {
    final extension = p.extension(name);
    return extension.isEmpty ? '.bin' : extension;
  }

  String _frameName(int index) =>
      'frame_${index.toString().padLeft(6, '0')}.png';
}

final class VideoExportException implements Exception {
  const VideoExportException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class _TimedVideoInput {
  const _TimedVideoInput(this.inputIndex, this.start, this.end);

  final int inputIndex;
  final double start;
  final double end;
}

final class _TimedAudioInput {
  const _TimedAudioInput(this.inputIndex, this.start);

  final int inputIndex;
  final double start;
}

final class _ExportAudioCue {
  const _ExportAudioCue({
    required this.assetId,
    required this.time,
    this.isBgm = false,
  });

  final String assetId;
  final double time;
  final bool isBgm;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
