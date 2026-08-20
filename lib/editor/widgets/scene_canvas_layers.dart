part of 'scene_canvas.dart';

final class SelectedMoveEvent {
  const SelectedMoveEvent({required this.chainId, required this.event});

  final String chainId;
  final CharacterMoveEvent event;
}

enum _ResizeCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  Offset offsetFor(Rect rect) {
    return switch (this) {
      _ResizeCorner.topLeft => rect.topLeft,
      _ResizeCorner.topRight => rect.topRight,
      _ResizeCorner.bottomLeft => rect.bottomLeft,
      _ResizeCorner.bottomRight => rect.bottomRight,
    };
  }
}

class _AssetImageLayer extends StatelessWidget {
  const _AssetImageLayer({
    required this.ready,
    required this.scene,
    required this.runtimeObjects,
    required this.previewTransforms,
    required this.currentTime,
    required this.pan,
    required this.scale,
    required this.pixelRendering,
  });

  final StudioReady ready;
  final Scene scene;
  final Map<String, RuntimeObject>? runtimeObjects;
  final Map<String, Transform2D> previewTransforms;
  final double currentTime;
  final Offset pan;
  final double scale;
  final bool pixelRendering;

  @override
  Widget build(BuildContext context) {
    final projectDirectory = ready.projectDirectory;
    final children = <Widget>[];
    for (final object in scene.objects) {
      final runtimeObject = runtimeObjects?[object.objectId];
      final assetId = imageAssetIdForObject(
        ready: ready,
        object: object,
        runtimeObject: runtimeObject,
        currentTime: currentTime,
      );
      final asset = ready.assetById(assetId);
      if (asset == null ||
          asset.kind == AssetKind.audio ||
          asset.kind == AssetKind.video) {
        continue;
      }
      final transform =
          runtimeObject?.transform ??
          previewTransforms[object.objectId] ??
          object.objectTransform;
      final image = _imageForAsset(asset, projectDirectory);
      if (image == null) {
        continue;
      }
      children.add(
        Positioned(
          left: transform.x,
          top: transform.y,
          width: transform.width * transform.scale,
          height: transform.height * transform.scale,
          child: image,
        ),
      );
    }
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: Transform(
        alignment: Alignment.topLeft,
        transform: Matrix4.identity()
          ..translateByDouble(pan.dx, pan.dy, 0, 1)
          ..scaleByDouble(scale, scale, 1, 1),
        child: SizedBox(
          width: 10000,
          height: 10000,
          child: Stack(clipBehavior: Clip.none, children: children),
        ),
      ),
    );
  }

  Widget? _imageForAsset(AssetRef asset, Directory? projectDirectory) {
    if (asset.kind == AssetKind.audio || asset.kind == AssetKind.video) {
      return null;
    }
    final dataUri = asset.dataUri;
    if (dataUri != null && dataUri.isNotEmpty) {
      return Image.memory(
        _bytesFromDataUri(dataUri),
        fit: BoxFit.contain,
        filterQuality: pixelRendering
            ? FilterQuality.none
            : FilterQuality.medium,
        isAntiAlias: pixelRendering ? false : true,
        gaplessPlayback: true,
      );
    }
    if (projectDirectory == null) {
      return null;
    }
    final file = File(p.join(projectDirectory.path, asset.relativePath));
    if (!file.existsSync()) {
      return null;
    }
    return Image.file(
      file,
      fit: BoxFit.contain,
      filterQuality: pixelRendering ? FilterQuality.none : FilterQuality.medium,
      isAntiAlias: pixelRendering ? false : true,
      gaplessPlayback: true,
    );
  }
}

class _DialogueOverlay extends StatelessWidget {
  const _DialogueOverlay({required this.ready, required this.dialogue});

  final StudioReady ready;
  final DialogueBoxState dialogue;

  @override
  Widget build(BuildContext context) {
    final portraitFile = _portraitFile();
    final portraitAsset = ready.assetById(dialogue.portraitAssetId);
    final template = dialogueTemplateForStyle(dialogue.style);
    final visibleText = visibleDialogueText(dialogue);
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ratio = ready.project.settings.cameraAspectRatio.value;
          final cameraWidth = math.min(
            constraints.maxWidth,
            constraints.maxHeight * ratio,
          );
          final cameraHeight = cameraWidth / ratio;
          final cameraLeft = (constraints.maxWidth - cameraWidth) / 2;
          final cameraTop = (constraints.maxHeight - cameraHeight) / 2;
          final boxWidth = math.max(
            dialogueMinBoxWidth,
            cameraWidth - dialogueCameraHorizontalInset,
          );
          final scale = boxWidth / template.width;
          final boxHeight = template.height * scale;
          final hasPortrait =
              portraitFile != null || portraitAsset?.dataUri != null;
          return Stack(
            children: [
              Positioned(
                left: cameraLeft + (cameraWidth - boxWidth) / 2,
                top:
                    cameraTop +
                    cameraHeight -
                    boxHeight -
                    math.max(
                      dialogueBottomInset,
                      dialogueScaledBottomInset * scale,
                    ),
                width: boxWidth,
                height: boxHeight,
                child: SizedBox(
                  width: boxWidth,
                  height: boxHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          template.assetPath,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.none,
                          isAntiAlias: false,
                        ),
                      ),
                      if (hasPortrait)
                        Positioned(
                          left: dialoguePortraitOuterLeft * scale,
                          top: dialoguePortraitOuterTop * scale,
                          width: dialoguePortraitOuterSize * scale,
                          height: dialoguePortraitOuterSize * scale,
                          child: ClipRect(
                            child: Center(
                              child: SizedBox(
                                width: dialoguePortraitInnerSize * scale,
                                height: dialoguePortraitInnerSize * scale,
                                child: _PortraitImage(
                                  file: portraitFile,
                                  dataUri: portraitAsset?.dataUri,
                                  pixelRendering:
                                      ready.project.settings.pixelRendering,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left:
                            (hasPortrait
                                ? dialogueTextLeftWithPortrait
                                : dialogueTextLeftWithoutPortrait) *
                            scale,
                        top: dialogueTextTop * scale,
                        right: dialogueTextRight * scale,
                        bottom: dialogueTextBottom * scale,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'PhoenixPixel',
                            fontSize: dialogueFontSize * scale,
                            height: dialogueLineHeight,
                            letterSpacing: 0,
                            shadows: dialogue.style == DialogueStyle.darkWorld
                                ? const [
                                    Shadow(
                                      color: Color(0xff6666d9),
                                      offset: Offset(2, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text.rich(
                            _dialogueTextSpan(visibleText),
                            softWrap: true,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  TextSpan _dialogueTextSpan(String text) =>
      TextSpan(text: dialogueTextWithLineBullets(text));

  File? _portraitFile() {
    final asset = ready.assetById(dialogue.portraitAssetId);
    final directory = ready.projectDirectory;
    if (asset == null || directory == null) {
      return null;
    }
    final file = File(p.join(directory.path, asset.relativePath));
    return file.existsSync() ? file : null;
  }
}

class _VideoOverlay extends StatefulWidget {
  const _VideoOverlay({
    required this.ready,
    required this.video,
    required this.isPlaying,
    required this.onCompleted,
  });

  final StudioReady ready;
  final VideoPlaybackState video;
  final bool isPlaying;
  final VoidCallback? onCompleted;

  @override
  State<_VideoOverlay> createState() => _VideoOverlayState();
}

class _VideoOverlayState extends State<_VideoOverlay> {
  late final Player _player;
  late final VideoController _controller;
  StreamSubscription<bool>? _completedSubscription;
  String? _openedSource;
  double? _lastSeekSeconds;
  bool _sentCompleted = false;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    unawaited(_player.setPlaylistMode(PlaylistMode.none));
    _completedSubscription = _player.stream.completed.listen((completed) {
      if (!completed || _sentCompleted) {
        return;
      }
      _sentCompleted = true;
      widget.onCompleted?.call();
    });
    _syncVideo();
  }

  @override
  void didUpdateWidget(covariant _VideoOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncVideo();
  }

  @override
  void dispose() {
    unawaited(_completedSubscription?.cancel());
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ratio = widget.ready.project.settings.cameraAspectRatio.value;
          final cameraWidth = math.min(
            constraints.maxWidth,
            constraints.maxHeight * ratio,
          );
          final cameraHeight = cameraWidth / ratio;
          final cameraLeft = (constraints.maxWidth - cameraWidth) / 2;
          final cameraTop = (constraints.maxHeight - cameraHeight) / 2;
          final source = _videoSource();
          return Stack(
            children: [
              Positioned(
                left: cameraLeft,
                top: cameraTop,
                width: cameraWidth,
                height: cameraHeight,
                child: ColoredBox(
                  color: Colors.black,
                  child: source == null
                      ? const Center(child: Icon(Icons.movie))
                      : Video(
                          controller: _controller,
                          fit: BoxFit.contain,
                          controls: NoVideoControls,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _syncVideo() {
    final source = _videoSource();
    if (source == null) {
      _openedSource = null;
      unawaited(_player.stop());
      return;
    }
    if (_openedSource != source) {
      _openedSource = source;
      _lastSeekSeconds = null;
      _sentCompleted = false;
      unawaited(_player.open(Media(source), play: widget.isPlaying));
    }
    final shouldSeek =
        !widget.isPlaying ||
        _lastSeekSeconds == null ||
        (widget.video.localTime - _lastSeekSeconds!).abs() > 0.35;
    if (shouldSeek) {
      _lastSeekSeconds = widget.video.localTime;
      unawaited(
        _player.seek(
          Duration(milliseconds: (widget.video.localTime * 1000).round()),
        ),
      );
    }
    if (widget.isPlaying) {
      unawaited(_player.play());
    } else {
      unawaited(_player.pause());
    }
  }

  String? _videoSource() {
    final asset = widget.ready.assetById(widget.video.assetId);
    if (asset == null) {
      return null;
    }
    final dataUri = asset.dataUri;
    if (dataUri != null && dataUri.isNotEmpty) {
      return dataUri;
    }
    final directory = widget.ready.projectDirectory;
    if (directory == null) {
      return null;
    }
    final file = File(p.join(directory.path, asset.relativePath));
    if (!file.existsSync()) {
      return null;
    }
    return file.path;
  }
}

class _PortraitImage extends StatelessWidget {
  const _PortraitImage({
    required this.file,
    required this.dataUri,
    required this.pixelRendering,
  });

  final File? file;
  final String? dataUri;
  final bool pixelRendering;

  @override
  Widget build(BuildContext context) {
    final uri = dataUri;
    if (uri != null && uri.isNotEmpty) {
      return Image.memory(
        _bytesFromDataUri(uri),
        fit: BoxFit.contain,
        filterQuality: pixelRendering
            ? FilterQuality.none
            : FilterQuality.medium,
        isAntiAlias: false,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }
    final localFile = file;
    if (localFile == null) {
      return const SizedBox.shrink();
    }
    return Image.file(
      localFile,
      fit: BoxFit.contain,
      filterQuality: pixelRendering ? FilterQuality.none : FilterQuality.medium,
      isAntiAlias: false,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

Uint8List _bytesFromDataUri(String dataUri) {
  final comma = dataUri.indexOf(',');
  if (comma < 0) {
    return Uint8List(0);
  }
  return base64Decode(dataUri.substring(comma + 1));
}

class _MarqueePainter extends CustomPainter {
  const _MarqueePainter({required this.start, required this.end});

  final Offset start;
  final Offset end;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(start, end);
    canvas.drawRect(rect, Paint()..color = const Color(0x33ffaaa0));
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xffffaaa0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _MarqueePainter oldDelegate) {
    return start != oldDelegate.start || end != oldDelegate.end;
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({
    required this.scene,
    required this.runtimeObjects,
    required this.selectedObjectId,
    required this.selectedMoves,
    required this.previewTransforms,
    required this.selection,
    required this.activeMoveEventId,
    required this.activeMoveProgress,
    required this.triggerLinkLabel,
    required this.pan,
    required this.scale,
    required this.fadeOpacity,
    required this.currentTime,
    required this.ready,
    required this.hideDebug,
    required this.showGrid,
    required this.cameraAspectRatio,
  });

  final Scene scene;
  final Map<String, RuntimeObject>? runtimeObjects;
  final String? selectedObjectId;
  final List<SelectedMoveEvent> selectedMoves;
  final Map<String, Transform2D> previewTransforms;
  final EditorSelection? selection;
  final String? activeMoveEventId;
  final double activeMoveProgress;
  final String triggerLinkLabel;
  final Offset pan;
  final double scale;
  final double fadeOpacity;
  final double currentTime;
  final StudioReady ready;
  final bool hideDebug;
  final bool showGrid;
  final CameraAspectRatio cameraAspectRatio;

  bool get isPreviewing => runtimeObjects != null;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);
    if (showGrid && !hideDebug) {
      _drawGrid(canvas, size);
    }
    for (final object in scene.objects) {
      if (object is! BackgroundObject) {
        continue;
      }
      final runtimeObject = runtimeObjects?[object.objectId];
      _drawObject(canvas, object, runtimeObject);
    }
    if (!hideDebug) {
      _drawSelectedPaths(canvas);
    }
    for (final object in scene.objects) {
      if (object is BackgroundObject) {
        continue;
      }
      final runtimeObject = runtimeObjects?[object.objectId];
      _drawObject(canvas, object, runtimeObject);
    }
    canvas.restore();

    _drawCameraFrame(canvas, size);

    if (fadeOpacity > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black.withValues(alpha: fadeOpacity),
      );
    }
  }

  void _drawCameraFrame(Canvas canvas, Size size) {
    final width = math.min(size.width, size.height * cameraAspectRatio.value);
    final height = width / cameraAspectRatio.value;
    final rect = Rect.fromLTWH(
      (size.width - width) / 2,
      (size.height - height) / 2,
      width,
      height,
    );
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(rect);
    if (hideDebug) {
      _drawWarningStripes(canvas, outside, size);
    } else {
      canvas.drawPath(
        outside,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.28)
          ..style = PaintingStyle.fill,
      );
    }
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0x99ffffff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRect(
      rect.deflate(1),
      Paint()
        ..color = const Color(0x66000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x221f2530)
      ..strokeWidth = 1;
    const step = 16.0;
    final left = -pan.dx / scale;
    final top = -pan.dy / scale;
    final right = left + size.width / scale;
    final bottom = top + size.height / scale;
    for (var x = (left / step).floor() * step; x <= right; x += step) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
    for (var y = (top / step).floor() * step; y <= bottom; y += step) {
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    }
  }

  void _drawWarningStripes(Canvas canvas, Path outside, Size size) {
    canvas.save();
    canvas.clipPath(outside);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    final paint = Paint()
      ..color = const Color(0xffffcf24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    for (var x = -size.height; x < size.width + size.height; x += 36) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
    canvas.restore();
  }

  void _drawSelectedPaths(Canvas canvas) {
    for (var moveIndex = 0; moveIndex < selectedMoves.length; moveIndex += 1) {
      final move = selectedMoves[moveIndex];
      if (move.event.path.nodes.isEmpty) {
        continue;
      }
      _drawSelectedPath(canvas, move, _pathColor(moveIndex));
    }
  }

  Color _pathColor(int index) {
    const colors = [
      Color(0xfff2c14e),
      Color(0xff69d2e7),
      Color(0xffa7db8d),
      Color(0xffff8f7a),
      Color(0xffc792ea),
      Color(0xffffd166),
    ];
    return colors[index % colors.length];
  }

  void _drawSelectedPath(Canvas canvas, SelectedMoveEvent move, Color color) {
    final nodes = move.event.path.nodes;
    final activePreview = activeMoveEventId == move.event.id;
    final progressIndex = activePreview
        ? activeMoveProgress * math.max(1, nodes.length - 1)
        : 0.0;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    var startPoint = Offset(nodes.first.x, nodes.first.y);
    for (var index = 0; index < nodes.length - 1; index += 1) {
      if (activePreview && index + 1 <= progressIndex) {
        startPoint = _movementTarget(
          startPoint,
          nodes[index + 1],
          move.event.path.mode,
        );
        continue;
      }
      final endPoint = _movementTarget(
        startPoint,
        nodes[index + 1],
        move.event.path.mode,
      );
      canvas.drawLine(
        activePreview && progressIndex > index
            ? Offset.lerp(startPoint, endPoint, progressIndex - index)!
            : startPoint,
        endPoint,
        linePaint,
      );
      startPoint = endPoint;
    }
    for (final node in nodes) {
      final nodeIndex = nodes.indexOf(node);
      if (activePreview && nodeIndex < progressIndex.floor()) {
        continue;
      }
      final selected = selection.selectsPathNode(node);
      canvas.drawCircle(
        Offset(node.x, node.y),
        selected ? 8 : 6,
        Paint()..color = selected ? Colors.white : color,
      );
      canvas.drawCircle(
        Offset(node.x, node.y),
        selected ? 8 : 6,
        Paint()
          ..color = const Color(0xff111111)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      if (node.triggerId != null) {
        _drawText(
          canvas,
          triggerLinkLabel,
          Offset(node.x + 10, node.y - 20),
          const Color(0xffff7676),
        );
      }
    }
  }

  Offset _movementTarget(Offset start, PathNode target, MovementMode mode) {
    final result = movementTarget(start.dx, start.dy, target, mode);
    return Offset(result.x, result.y);
  }

  void _drawObject(
    Canvas canvas,
    SceneObject object,
    RuntimeObject? runtimeObject,
  ) {
    final transform =
        runtimeObject?.transform ??
        previewTransforms[object.objectId] ??
        object.objectTransform;
    final rect = Rect.fromLTWH(
      transform.x,
      transform.y,
      transform.width * transform.scale,
      transform.height * transform.scale,
    );
    final isSelected = selection.objectIds.contains(object.objectId);

    object.map(
      characterInstance: (value) {
        final facing = runtimeObject?.facing ?? value.facing;
        if (!_hasDrawableImageAsset(value, runtimeObject)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(6)),
            Paint()..color = const Color(0xff2f6fed),
          );
          canvas.drawCircle(
            Offset(rect.center.dx, rect.top + 18),
            10,
            Paint()..color = const Color(0xfff4f1ff),
          );
        }
        if (!hideDebug) {
          _drawFacing(canvas, rect, facing);
          _drawText(canvas, value.name, Offset(rect.left, rect.bottom + 4));
        }
      },
      background: (value) {
        final hasAsset = value.assetId.isNotEmpty;
        if (!hasAsset) {
          canvas.drawRect(rect, Paint()..color = const Color(0xff1a1a20));
          final floorPaint = Paint()
            ..color = const Color(0xff2a2a34)
            ..strokeWidth = 1;
          for (var y = rect.top + 24; y < rect.bottom; y += 24) {
            canvas.drawLine(
              Offset(rect.left, y),
              Offset(rect.right, y),
              floorPaint,
            );
          }
          for (var x = rect.left + 24; x < rect.right; x += 24) {
            canvas.drawLine(
              Offset(x, rect.top),
              Offset(x, rect.bottom),
              floorPaint,
            );
          }
        }
        if (!hideDebug) {
          canvas.drawRect(
            rect,
            Paint()
              ..color = value.locked
                  ? const Color(0xff444444)
                  : const Color(0xff777777)
              ..style = PaintingStyle.stroke
              ..strokeWidth = value.locked ? 1 : 1.5,
          );
          _drawText(canvas, value.name, Offset(rect.left, rect.bottom + 4));
        }
      },
      prop: (value) {
        final hasDrawableAsset = ready.assetById(value.assetId) != null;
        if (!hasDrawableAsset) {
          canvas.drawRect(rect, Paint()..color = const Color(0xff8b7f52));
        }
        if (!hideDebug) {
          canvas.drawRect(
            rect,
            Paint()
              ..color = const Color(0xffd8c782)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
          _drawText(canvas, value.name, Offset(rect.left, rect.bottom + 4));
        }
      },
      triggerPoint: (value) {
        if (!hideDebug) {
          final center = rect.center;
          canvas.drawCircle(
            center,
            10,
            Paint()..color = const Color(0xffe24d3d),
          );
          canvas.drawCircle(
            center,
            14,
            Paint()
              ..color = const Color(0xffe24d3d)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          _drawText(canvas, value.name, Offset(center.dx + 14, center.dy - 8));
        }
      },
      triggerArea: (value) {
        if (!hideDebug) {
          canvas.drawRect(rect, Paint()..color = const Color(0x33e24d3d));
          canvas.drawRect(
            rect,
            Paint()
              ..color = const Color(0xffe24d3d)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
          _drawText(canvas, value.name, Offset(rect.left, rect.top - 16));
        }
      },
    );

    if (isSelected && !hideDebug) {
      canvas.drawRect(
        rect.inflate(4),
        Paint()
          ..color = const Color(0xffffffff)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      if (!_isObjectLocked(object) &&
          (object is BackgroundObject || object is CharacterInstanceObject)) {
        _drawResizeHandles(canvas, rect);
      }
    }
  }

  bool _isObjectLocked(SceneObject object) {
    return object.map(
      characterInstance: (value) => value.locked,
      prop: (value) => value.locked,
      background: (value) => value.locked,
      triggerPoint: (value) => value.locked,
      triggerArea: (value) => value.locked,
    );
  }

  void _drawResizeHandles(Canvas canvas, Rect rect) {
    final paint = Paint()..color = Colors.white;
    final strokePaint = Paint()
      ..color = const Color(0xff111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final corner in _ResizeCorner.values) {
      final handleRect = Rect.fromCenter(
        center: corner.offsetFor(rect),
        width: 8,
        height: 8,
      );
      canvas.drawRect(handleRect, paint);
      canvas.drawRect(handleRect, strokePaint);
    }
  }

  bool _hasDrawableImageAsset(
    CharacterInstanceObject value,
    RuntimeObject? runtimeObject,
  ) {
    final character = ready.characterById(value.characterId);
    if (character == null || character.animations.isEmpty) {
      return false;
    }
    final assetId = imageAssetIdForObject(
      ready: ready,
      object: SceneObject.characterInstance(
        id: value.id,
        name: value.name,
        characterId: value.characterId,
        transform: value.transform,
        facing: value.facing,
        initialExpression: value.initialExpression,
        activity: value.activity,
      ),
      runtimeObject: runtimeObject,
      currentTime: currentTime,
    );
    final asset = ready.assetById(assetId);
    final directory = ready.projectDirectory;
    if (asset == null || directory == null) {
      return false;
    }
    return File(p.join(directory.path, asset.relativePath)).existsSync();
  }

  void _drawFacing(Canvas canvas, Rect rect, Direction facing) {
    final center = rect.center;
    final target = switch (facing) {
      Direction.up => Offset(center.dx, rect.top + 6),
      Direction.down => Offset(center.dx, rect.bottom - 6),
      Direction.left => Offset(rect.left + 6, center.dy),
      Direction.right => Offset(rect.right - 6, center.dy),
    };
    canvas.drawLine(
      center,
      target,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, [
    Color color = Colors.white,
    double fontSize = 11,
  ]) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 320);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) {
    return oldDelegate.scene != scene ||
        oldDelegate.runtimeObjects != runtimeObjects ||
        oldDelegate.selectedObjectId != selectedObjectId ||
        oldDelegate.selectedMoves != selectedMoves ||
        oldDelegate.previewTransforms != previewTransforms ||
        oldDelegate.selection != selection ||
        oldDelegate.activeMoveEventId != activeMoveEventId ||
        oldDelegate.activeMoveProgress != activeMoveProgress ||
        oldDelegate.pan != pan ||
        oldDelegate.scale != scale ||
        oldDelegate.fadeOpacity != fadeOpacity ||
        oldDelegate.currentTime != currentTime ||
        oldDelegate.hideDebug != hideDebug ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.cameraAspectRatio != cameraAspectRatio ||
        oldDelegate.triggerLinkLabel != triggerLinkLabel ||
        oldDelegate.ready != ready;
  }
}
