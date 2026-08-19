import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:deltarune_studio/domain/overlay_models.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class RuntimeOverlayLayer extends StatelessWidget {
  const RuntimeOverlayLayer({
    required this.ready,
    required this.world,
    required this.pan,
    required this.scale,
    this.fullscreenOnly = false,
  }) : super(key: null);

  final StudioReady ready;
  final RuntimeWorld world;
  final Offset pan;
  final double scale;
  final bool fullscreenOnly;

  @override
  Widget build(BuildContext context) {
    final overlays = world.overlays.values.toList()
      ..sort((a, b) => a.event.zIndex.compareTo(b.event.zIndex));
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
          final camera = <Widget>[];
          final fullscreen = <Widget>[];
          final worldWidgets = <Widget>[];
          for (final overlay in overlays) {
            final isFullscreen = overlay.event.space == OverlaySpace.fullscreen;
            if (fullscreenOnly != isFullscreen) {
              continue;
            }
            final child = _overlayChild(overlay);
            if (child == null) {
              continue;
            }
            switch (overlay.event.space) {
              case OverlaySpace.world:
                worldWidgets.add(_worldOverlay(overlay, child));
              case OverlaySpace.camera:
                camera.add(
                  _cameraOverlay(
                    overlay,
                    child,
                    cameraLeft,
                    cameraTop,
                    cameraWidth,
                    cameraHeight,
                  ),
                );
              case OverlaySpace.fullscreen:
                fullscreen.add(
                  Positioned(
                    left: cameraLeft,
                    top: cameraTop,
                    width: cameraWidth,
                    height: cameraHeight,
                    child: child,
                  ),
                );
            }
          }
          return Stack(
            children: [
              if (worldWidgets.isNotEmpty)
                Positioned.fill(
                  child: Stack(clipBehavior: Clip.none, children: worldWidgets),
                ),
              ...camera,
              ...fullscreen,
            ],
          );
        },
      ),
    );
  }

  Positioned _worldOverlay(RuntimeOverlay overlay, Widget child) {
    final transform = overlay.transform;
    return Positioned(
      left: transform.x * scale + pan.dx,
      top: transform.y * scale + pan.dy,
      width: transform.width * transform.scale * scale,
      height: transform.height * transform.scale * scale,
      child: child,
    );
  }

  Positioned _cameraOverlay(
    RuntimeOverlay overlay,
    Widget child,
    double left,
    double top,
    double width,
    double height,
  ) {
    final transform = overlay.transform;
    final size = Size(
      transform.width * transform.scale * width / 640,
      transform.height * transform.scale * width / 640,
    );
    final anchor = _anchorOffset(overlay.event.anchor, width, height, size);
    return Positioned(
      left: left + anchor.dx + transform.x * width / 640,
      top: top + anchor.dy + transform.y * width / 640,
      width: size.width,
      height: size.height,
      child: child,
    );
  }

  Offset _anchorOffset(
    OverlayAnchor anchor,
    double width,
    double height,
    Size size,
  ) {
    final x = switch (anchor) {
      OverlayAnchor.topLeft ||
      OverlayAnchor.centerLeft ||
      OverlayAnchor.bottomLeft => 0,
      OverlayAnchor.topCenter ||
      OverlayAnchor.center ||
      OverlayAnchor.bottomCenter => (width - size.width) / 2,
      OverlayAnchor.topRight ||
      OverlayAnchor.centerRight ||
      OverlayAnchor.bottomRight => width - size.width,
    };
    final y = switch (anchor) {
      OverlayAnchor.topLeft ||
      OverlayAnchor.topCenter ||
      OverlayAnchor.topRight => 0,
      OverlayAnchor.centerLeft ||
      OverlayAnchor.center ||
      OverlayAnchor.centerRight => (height - size.height) / 2,
      OverlayAnchor.bottomLeft ||
      OverlayAnchor.bottomCenter ||
      OverlayAnchor.bottomRight => height - size.height,
    };
    return Offset(x.toDouble(), y.toDouble());
  }

  Widget? _overlayChild(RuntimeOverlay overlay) {
    final event = overlay.event;
    final opacity = overlay.opacity.clamp(0.0, 1.0);
    final child = switch (event.contentKind) {
      OverlayContentKind.color => ColoredBox(
        color: _parseColor(event.color).withValues(alpha: opacity),
      ),
      OverlayContentKind.text => Align(
        alignment: _textAlignment(event.textStyle.alignment),
        child: Text(
          event.text ?? '',
          textAlign: _textAlign(event.textStyle.alignment),
          style: TextStyle(
            color: _parseColor(event.textStyle.color),
            fontFamily: 'PhoenixPixel',
            fontSize: event.textStyle.fontSize,
          ),
        ),
      ),
      OverlayContentKind.image => _assetImage(event.assetId),
      OverlayContentKind.video => null,
    };
    if (child == null || event.contentKind == OverlayContentKind.color) {
      return child;
    }
    return Opacity(opacity: opacity, child: child);
  }

  Widget? _assetImage(String? assetId) {
    final asset = ready.assetById(assetId);
    if (asset == null ||
        asset.kind == AssetKind.video ||
        asset.kind == AssetKind.audio) {
      return null;
    }
    if (asset.dataUri?.isNotEmpty == true) {
      return Image.memory(
        _bytesFromDataUri(asset.dataUri!),
        fit: BoxFit.fill,
        filterQuality: ready.project.settings.pixelRendering
            ? FilterQuality.none
            : FilterQuality.medium,
      );
    }
    final directory = ready.projectDirectory;
    if (directory == null) {
      return null;
    }
    final file = File(p.join(directory.path, asset.relativePath));
    return file.existsSync()
        ? Image.file(
            file,
            fit: BoxFit.fill,
            filterQuality: ready.project.settings.pixelRendering
                ? FilterQuality.none
                : FilterQuality.medium,
          )
        : null;
  }

  Alignment _textAlignment(OverlayTextAlignment alignment) =>
      switch (alignment) {
        OverlayTextAlignment.left => Alignment.centerLeft,
        OverlayTextAlignment.center => Alignment.center,
        OverlayTextAlignment.right => Alignment.centerRight,
      };

  TextAlign _textAlign(OverlayTextAlignment alignment) => switch (alignment) {
    OverlayTextAlignment.left => TextAlign.left,
    OverlayTextAlignment.center => TextAlign.center,
    OverlayTextAlignment.right => TextAlign.right,
  };

  Color _parseColor(String value) {
    final normalized = value.replaceFirst('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? Colors.white : Color(parsed);
  }

  Uint8List _bytesFromDataUri(String dataUri) {
    final comma = dataUri.indexOf(',');
    return comma < 0
        ? Uint8List(0)
        : base64Decode(dataUri.substring(comma + 1));
  }
}
