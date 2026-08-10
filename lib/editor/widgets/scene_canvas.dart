import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:deltarune_studio/shared_render/studio_rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

final canvasCursorProvider = StateProvider<Offset?>((ref) => null);

class SceneCanvas extends ConsumerStatefulWidget {
  const SceneCanvas({required this.ready, super.key});

  final StudioReady ready;

  @override
  ConsumerState<SceneCanvas> createState() => _SceneCanvasState();
}

class _SceneCanvasState extends ConsumerState<SceneCanvas> {
  Offset _pan = const Offset(320, 160);
  double _scale = 1.4;
  String? _dragObjectId;
  String? _resizeObjectId;
  _ResizeCorner? _resizeCorner;
  PathNodeSelection? _dragNode;
  Offset _dragDelta = Offset.zero;
  Transform2D? _dragObjectStartTransform;
  Transform2D? _resizeStartTransform;
  PathNode? _dragNodeStart;
  Offset? _marqueeStart;
  Offset? _marqueeEnd;

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(previewControllerProvider);
    final world = preview.world;
    final useRuntime = world != null;
    final scene = useRuntime ? world.scene : widget.ready.currentScene;
    final objects = useRuntime ? world.objects : null;
    final hideDebug = preview.cleanPreview;
    final selectedMove = _dragNode == null
        ? _selectedMoveEvent(widget.ready)
        : _moveEventForPathSelection(widget.ready, _dragNode!) ??
              _selectedMoveEvent(widget.ready);
    final previewMove = _previewMoveEvent(selectedMove);
    final visibleMoves = _visibleMoveEvents(widget.ready, previewMove);
    final previewTransforms = _previewTransforms();
    final l10n = AppLocalizations.of(context)!;

    return Listener(
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent) {
          setState(() {
            final next = _scale - signal.scrollDelta.dy * 0.001;
            _scale = next.clamp(0.35, 4);
          });
        }
      },
      child: MouseRegion(
        onHover: (event) {
          ref.read(canvasCursorProvider.notifier).state = _toScene(
            event.localPosition,
          );
        },
        onExit: (_) => ref.read(canvasCursorProvider.notifier).state = null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            if (useRuntime || preview.cleanPreview) {
              return;
            }
            final scenePoint = _toScene(details.localPosition);
            final nodeHit = _hitTestPathNode(visibleMoves, scenePoint);
            if (nodeHit != null) {
              ref
                  .read(studioControllerProvider.notifier)
                  .selectPathNode(
                    nodeHit.chainId,
                    nodeHit.eventId,
                    nodeHit.nodeId,
                  );
              return;
            }
            final hit = _hitTest(scene.objects, scenePoint);
            final controller = ref.read(studioControllerProvider.notifier);
            if (hit != null && HardwareKeyboard.instance.isShiftPressed) {
              controller.toggleObjectSelection(hit);
            } else {
              controller.selectObject(hit);
            }
          },
          onPanStart: (details) {
            if (useRuntime || preview.cleanPreview) {
              return;
            }
            final scenePoint = _toScene(details.localPosition);
            final hit = _hitTest(scene.objects, scenePoint);
            if (hit == null && HardwareKeyboard.instance.isShiftPressed) {
              setState(() {
                _marqueeStart = scenePoint;
                _marqueeEnd = scenePoint;
                _dragDelta = Offset.zero;
              });
              return;
            }
            _resizeCorner = _hitTestResizeHandle(
              scene.objects,
              widget.ready.selectedObjectId,
              scenePoint,
            );
            if (_resizeCorner != null) {
              final selectedObject = _objectById(
                scene.objects,
                widget.ready.selectedObjectId,
              );
              if (selectedObject == null || _isObjectLocked(selectedObject)) {
                _resizeCorner = null;
              } else {
                _resizeObjectId = widget.ready.selectedObjectId;
                _resizeStartTransform = selectedObject.objectTransform;
              }
              _dragDelta = Offset.zero;
              return;
            }
            _dragNode = _hitTestPathNode(visibleMoves, scenePoint);
            if (_dragNode != null) {
              ref.read(studioControllerProvider.notifier).select(_dragNode);
              _dragNodeStart = _nodeBySelection(visibleMoves, _dragNode!);
              _dragDelta = Offset.zero;
              return;
            }
            _dragObjectId = hit;
            ref
                .read(studioControllerProvider.notifier)
                .selectObject(_dragObjectId);
            final dragObject = _objectById(scene.objects, _dragObjectId);
            _dragObjectStartTransform =
                dragObject == null || _isObjectLocked(dragObject)
                ? null
                : dragObject.objectTransform;
            _dragDelta = Offset.zero;
          },
          onPanUpdate: (details) {
            if (useRuntime || preview.cleanPreview) {
              return;
            }
            final resizeId = _resizeObjectId;
            final resizeCorner = _resizeCorner;
            if (_marqueeStart != null) {
              setState(() {
                _marqueeEnd = _toScene(details.localPosition);
              });
              return;
            }
            if (resizeId != null && resizeCorner != null) {
              setState(() {
                _dragDelta += details.delta / _scale;
              });
              return;
            }
            final node = _dragNode;
            if (node != null) {
              setState(() {
                _dragDelta += details.delta / _scale;
              });
              return;
            }
            final dragId = _dragObjectId;
            if (dragId == null) {
              setState(() => _pan += details.delta);
              return;
            }
            setState(() {
              _dragDelta += details.delta / _scale;
            });
          },
          onPanEnd: (_) {
            if (useRuntime || preview.cleanPreview) {
              return;
            }
            final controller = ref.read(studioControllerProvider.notifier);
            final marqueeStart = _marqueeStart;
            final marqueeEnd = _marqueeEnd;
            if (marqueeStart != null && marqueeEnd != null) {
              controller.selectObjects(
                _objectsInMarquee(scene.objects, marqueeStart, marqueeEnd),
              );
            }
            final resizeId = _resizeObjectId;
            final resizeCorner = _resizeCorner;
            final resizeStart = _resizeStartTransform;
            if (resizeId != null &&
                resizeCorner != null &&
                resizeStart != null) {
              final next = _resizeTransform(
                resizeStart,
                resizeCorner,
                _dragDelta.dx,
                _dragDelta.dy,
              );
              controller.updateObjectTransformById(resizeId, (_) => next);
            }
            final node = _dragNode;
            if (node != null) {
              final nextNode = _previewNode(selectedMove, node.nodeId);
              if (nextNode != null) {
                controller.updatePathNode(
                  node.chainId,
                  node.eventId,
                  node.nodeId,
                  (_) => nextNode,
                );
              } else {
                controller.movePathNodeById(
                  node.chainId,
                  node.eventId,
                  node.nodeId,
                  _dragDelta.dx,
                  _dragDelta.dy,
                );
              }
              controller.linkPathNodeToNearbyTrigger(
                node.chainId,
                node.eventId,
                node.nodeId,
              );
            }
            final dragId = _dragObjectId;
            if (dragId != null) {
              controller.moveObjectById(dragId, _dragDelta.dx, _dragDelta.dy);
            }
            setState(() {
              _dragObjectId = null;
              _resizeObjectId = null;
              _resizeCorner = null;
              _dragNode = null;
              _dragDelta = Offset.zero;
              _dragObjectStartTransform = null;
              _resizeStartTransform = null;
              _dragNodeStart = null;
              _marqueeStart = null;
              _marqueeEnd = null;
            });
          },
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final effectivePan = useRuntime
                    ? _runtimePan(world, size)
                    : _pan;
                return Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Colors.black),
                    ),
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: _AssetImageLayer(
                          ready: widget.ready,
                          scene: scene,
                          runtimeObjects: objects,
                          previewTransforms: previewTransforms,
                          currentTime: world?.currentTime ?? 0,
                          pan: effectivePan,
                          scale: _scale,
                          foreground: false,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: _AssetImageLayer(
                          ready: widget.ready,
                          scene: scene,
                          runtimeObjects: objects,
                          previewTransforms: previewTransforms,
                          currentTime: world?.currentTime ?? 0,
                          pan: effectivePan,
                          scale: _scale,
                          foreground: true,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _ScenePainter(
                            scene: scene,
                            runtimeObjects: objects,
                            selectedObjectId: widget.ready.selectedObjectId,
                            selectedMoves: visibleMoves,
                            previewTransforms: previewTransforms,
                            selection: widget.ready.selection,
                            activeMoveEventId: useRuntime
                                ? world.activeMoveEventId
                                : null,
                            activeMoveProgress: useRuntime
                                ? world.activeMoveProgress
                                : 0,
                            triggerLinkLabel: l10n.triggerLinkLabel,
                            pan: effectivePan,
                            scale: _scale,
                            fadeOpacity: useRuntime ? world.fadeOpacity : 0,
                            currentTime: useRuntime ? world.currentTime : 0,
                            ready: widget.ready,
                            hideDebug: hideDebug,
                          ),
                        ),
                      ),
                    ),
                    if (useRuntime && world.dialogue != null)
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: _DialogueOverlay(
                            ready: widget.ready,
                            dialogue: world.dialogue!,
                          ),
                        ),
                      ),
                    if (useRuntime && world.activeVideo != null)
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: _VideoOverlay(
                            ready: widget.ready,
                            video: world.activeVideo!,
                            isPlaying: preview.isPlaying,
                            onCompleted: preview.cleanPreview
                                ? () => ref
                                      .read(previewControllerProvider.notifier)
                                      .completeActiveVideo(widget.ready)
                                : null,
                          ),
                        ),
                      ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            l10n.zoomPercent((_scale * 100).round()),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                    if (_marqueeStart != null && _marqueeEnd != null)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _MarqueePainter(
                              start: _toViewport(_marqueeStart!, effectivePan),
                              end: _toViewport(_marqueeEnd!, effectivePan),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Offset _toScene(Offset local) => (local - _pan) / _scale;

  Offset _toViewport(Offset scenePoint, Offset pan) =>
      scenePoint * _scale + pan;

  List<String> _objectsInMarquee(
    List<SceneObject> objects,
    Offset start,
    Offset end,
  ) {
    final rect = Rect.fromPoints(start, end);
    return objects
        .where((object) {
          final transform = object.objectTransform;
          final objectRect = Rect.fromLTWH(
            transform.x,
            transform.y,
            transform.width * transform.scale,
            transform.height * transform.scale,
          );
          return rect.overlaps(objectRect) || rect.contains(objectRect.center);
        })
        .map((object) => object.objectId)
        .toList(growable: false);
  }

  Offset _runtimePan(RuntimeWorld world, Size viewportSize) {
    final target = _cameraTarget(world);
    if (target == null) {
      return _pan;
    }
    final cameraSize = _cameraViewportSize(viewportSize);
    final cameraOrigin = Offset(
      (viewportSize.width - cameraSize.width) / 2,
      (viewportSize.height - cameraSize.height) / 2,
    );
    return Offset(
      cameraOrigin.dx + cameraSize.width / 2 - target.dx * _scale,
      cameraOrigin.dy + cameraSize.height / 2 - target.dy * _scale,
    );
  }

  Size _cameraViewportSize(Size viewportSize) {
    final width = math.min(viewportSize.width, viewportSize.height * 4 / 3);
    return Size(width, width * 3 / 4);
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

  Map<String, Transform2D> _previewTransforms() {
    final transforms = <String, Transform2D>{};
    final dragId = _dragObjectId;
    final dragStart = _dragObjectStartTransform;
    if (dragId != null && dragStart != null) {
      transforms[dragId] = dragStart.copyWith(
        x: dragStart.x + _dragDelta.dx,
        y: dragStart.y + _dragDelta.dy,
      );
    }
    final resizeId = _resizeObjectId;
    final resizeStart = _resizeStartTransform;
    final resizeCorner = _resizeCorner;
    if (resizeId != null && resizeStart != null && resizeCorner != null) {
      transforms[resizeId] = _resizeTransform(
        resizeStart,
        resizeCorner,
        _dragDelta.dx,
        _dragDelta.dy,
      );
    }
    return transforms;
  }

  SelectedMoveEvent? _previewMoveEvent(SelectedMoveEvent? selectedMove) {
    final dragNode = _dragNode;
    final nodeStart = _dragNodeStart;
    if (selectedMove == null || dragNode == null || nodeStart == null) {
      return selectedMove;
    }
    final nextNode = _previewNode(selectedMove, dragNode.nodeId);
    if (nextNode == null) {
      return selectedMove;
    }
    final nodes = _normalizePreviewNodes(
      selectedMove.event.path.nodes.map((node) {
        return node.id == dragNode.nodeId ? nextNode : node;
      }).toList(),
      dragNode.nodeId,
    );
    return SelectedMoveEvent(
      chainId: selectedMove.chainId,
      event: selectedMove.event.copyWith(
        path: selectedMove.event.path.copyWith(nodes: nodes),
      ),
    );
  }

  PathNode? _previewNode(SelectedMoveEvent? selectedMove, String nodeId) {
    final nodeStart = _dragNodeStart;
    if (selectedMove == null || nodeStart == null) {
      return null;
    }
    return nodeStart.copyWith(
      x: nodeStart.x + _dragDelta.dx,
      y: nodeStart.y + _dragDelta.dy,
    );
  }

  List<PathNode> _normalizePreviewNodes(
    List<PathNode> nodes,
    String changedId,
  ) {
    if (nodes.length < 2) {
      return nodes;
    }
    final normalized = [...nodes];
    final index = normalized.indexWhere((node) => node.id == changedId);
    if (index < 0) {
      return normalized;
    }
    if (index > 0) {
      normalized[index] = _snapNodeToOrthogonal(
        anchor: normalized[index - 1],
        node: normalized[index],
      );
    } else {
      normalized[index] = _snapNodeToOrthogonal(
        anchor: normalized[1],
        node: normalized[index],
      );
    }
    if (index + 1 < normalized.length) {
      normalized[index + 1] = _snapNodeToOrthogonal(
        anchor: normalized[index],
        node: normalized[index + 1],
      );
    }
    return normalized;
  }

  PathNode _snapNodeToOrthogonal({
    required PathNode anchor,
    required PathNode node,
  }) {
    final dx = node.x - anchor.x;
    final dy = node.y - anchor.y;
    if (dx.abs() >= dy.abs()) {
      return node.copyWith(y: anchor.y);
    }
    return node.copyWith(x: anchor.x);
  }

  SceneObject? _objectById(List<SceneObject> objects, String? objectId) {
    if (objectId == null) {
      return null;
    }
    for (final object in objects) {
      if (object.objectId == objectId) {
        return object;
      }
    }
    return null;
  }

  PathNode? _nodeBySelection(
    List<SelectedMoveEvent> moves,
    PathNodeSelection selection,
  ) {
    for (final move in moves) {
      if (move.chainId != selection.chainId ||
          move.event.id != selection.eventId) {
        continue;
      }
      for (final node in move.event.path.nodes) {
        if (node.id == selection.nodeId) {
          return node;
        }
      }
    }
    return null;
  }

  String? _hitTest(List<SceneObject> objects, Offset point) {
    for (final object in objects.reversed) {
      final transform = object.objectTransform;
      final rect = Rect.fromLTWH(
        transform.x,
        transform.y,
        transform.width * transform.scale,
        transform.height * transform.scale,
      );
      if (rect.contains(point)) {
        return object.objectId;
      }
    }
    return null;
  }

  PathNodeSelection? _hitTestPathNode(
    List<SelectedMoveEvent> moves,
    Offset point,
  ) {
    for (final move in moves.reversed) {
      for (final node in move.event.path.nodes.reversed) {
        final rect = Rect.fromCircle(center: Offset(node.x, node.y), radius: 9);
        if (rect.contains(point)) {
          return PathNodeSelection(move.chainId, move.event.id, node.id);
        }
      }
    }
    return null;
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

  _ResizeCorner? _hitTestResizeHandle(
    List<SceneObject> objects,
    String? selectedObjectId,
    Offset point,
  ) {
    if (selectedObjectId == null) {
      return null;
    }
    SceneObject? object;
    for (final candidate in objects) {
      if (candidate.objectId == selectedObjectId) {
        object = candidate;
        break;
      }
    }
    if (object == null || !_canResize(object)) {
      return null;
    }
    final rect = _objectRect(object.objectTransform);
    final radius = 10 / _scale;
    for (final corner in _ResizeCorner.values) {
      final handleRect = Rect.fromCircle(
        center: corner.offsetFor(rect),
        radius: radius,
      );
      if (handleRect.contains(point)) {
        return corner;
      }
    }
    return null;
  }

  bool _canResize(SceneObject object) {
    return object is BackgroundObject || object is CharacterInstanceObject;
  }

  Rect _objectRect(Transform2D transform) {
    return Rect.fromLTWH(
      transform.x,
      transform.y,
      transform.width * transform.scale,
      transform.height * transform.scale,
    );
  }

  Transform2D _resizeTransform(
    Transform2D transform,
    _ResizeCorner corner,
    double dx,
    double dy,
  ) {
    const minSize = 16.0;
    final rect = _objectRect(transform);
    var left = rect.left;
    var top = rect.top;
    var right = rect.right;
    var bottom = rect.bottom;
    switch (corner) {
      case _ResizeCorner.topLeft:
        left = math.min(right - minSize, left + dx);
        top = math.min(bottom - minSize, top + dy);
      case _ResizeCorner.topRight:
        right = math.max(left + minSize, right + dx);
        top = math.min(bottom - minSize, top + dy);
      case _ResizeCorner.bottomLeft:
        left = math.min(right - minSize, left + dx);
        bottom = math.max(top + minSize, bottom + dy);
      case _ResizeCorner.bottomRight:
        right = math.max(left + minSize, right + dx);
        bottom = math.max(top + minSize, bottom + dy);
    }
    return transform.copyWith(
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
      scale: 1,
    );
  }

  SelectedMoveEvent? _selectedMoveEvent(StudioReady ready) {
    final selection = ready.selection;
    if (selection is EventSelection || selection is PathNodeSelection) {
      final chainId = selection.chainId;
      final eventId = selection.eventId;
      if (chainId != null && eventId != null) {
        final event = ready.eventById(chainId, eventId);
        if (event is CharacterMoveEvent) {
          return SelectedMoveEvent(chainId: chainId, event: event);
        }
      }
    }
    final chain = ready.activeChain;
    if (chain == null) {
      return null;
    }
    for (final event in chain.events) {
      if (event is CharacterMoveEvent) {
        return SelectedMoveEvent(chainId: chain.id, event: event);
      }
    }
    return null;
  }

  SelectedMoveEvent? _moveEventForPathSelection(
    StudioReady ready,
    PathNodeSelection selection,
  ) {
    final event = ready.eventById(selection.chainId, selection.eventId);
    if (event is! CharacterMoveEvent) {
      return null;
    }
    return SelectedMoveEvent(chainId: selection.chainId, event: event);
  }

  List<SelectedMoveEvent> _visibleMoveEvents(
    StudioReady ready,
    SelectedMoveEvent? previewMove,
  ) {
    final selection = ready.selection;
    if (selection is EventChainSelection) {
      final chain = ready.chainById(selection.chainId);
      if (chain == null) {
        return const [];
      }
      return [
        for (final event in chain.events)
          if (event is CharacterMoveEvent)
            previewMove != null && previewMove.event.id == event.id
                ? previewMove
                : SelectedMoveEvent(chainId: chain.id, event: event),
      ];
    }
    return previewMove == null ? const [] : [previewMove];
  }
}

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
    required this.foreground,
  });

  final StudioReady ready;
  final Scene scene;
  final Map<String, RuntimeObject>? runtimeObjects;
  final Map<String, Transform2D> previewTransforms;
  final double currentTime;
  final Offset pan;
  final double scale;
  final bool foreground;

  @override
  Widget build(BuildContext context) {
    final projectDirectory = ready.projectDirectory;
    final children = <Widget>[];
    for (final object in scene.objects) {
      final isForeground =
          object is CharacterInstanceObject || object is PropSceneObject;
      if (foreground != isForeground) {
        continue;
      }
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
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
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
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
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
    final visibleCharacters =
        dialogue.visibleCharacters ?? dialogue.text.length;
    final visibleText = dialogue.text.substring(
      0,
      visibleCharacters.clamp(0, dialogue.text.length),
    );
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cameraWidth = math.min(
            constraints.maxWidth,
            constraints.maxHeight * 4 / 3,
          );
          final cameraHeight = cameraWidth * 3 / 4;
          final cameraLeft = (constraints.maxWidth - cameraWidth) / 2;
          final cameraTop = (constraints.maxHeight - cameraHeight) / 2;
          final boxWidth = math.max(280.0, cameraWidth - 28);
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
                    math.max(18, 20 * scale),
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
                          left: 28 * scale,
                          top: 26 * scale,
                          width: 108 * scale,
                          height: 108 * scale,
                          child: ClipRect(
                            child: Center(
                              child: SizedBox(
                                width: 88 * scale,
                                height: 88 * scale,
                                child: _PortraitImage(
                                  file: portraitFile,
                                  dataUri: portraitAsset?.dataUri,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        left: (hasPortrait ? 146 : 42) * scale,
                        top: 36 * scale,
                        right: 42 * scale,
                        bottom: 30 * scale,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'PhoenixPixel',
                            fontSize: 24 * scale,
                            height: 1.35,
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

  TextSpan _dialogueTextSpan(String text) {
    final lines = text.split('\n');
    return TextSpan(
      children: [
        for (var index = 0; index < lines.length; index += 1) ...[
          if (index > 0) const TextSpan(text: '\n'),
          TextSpan(text: '* ${lines[index]}'),
        ],
      ],
    );
  }

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
          final cameraWidth = math.min(
            constraints.maxWidth,
            constraints.maxHeight * 4 / 3,
          );
          final cameraHeight = cameraWidth * 3 / 4;
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
  const _PortraitImage({required this.file, required this.dataUri});

  final File? file;
  final String? dataUri;

  @override
  Widget build(BuildContext context) {
    final uri = dataUri;
    if (uri != null && uri.isNotEmpty) {
      return Image.memory(
        _bytesFromDataUri(uri),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
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
      filterQuality: FilterQuality.none,
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

  bool get isPreviewing => runtimeObjects != null;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);
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
    final width = math.min(size.width, size.height * 4 / 3);
    final height = width * 3 / 4;
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
        startPoint = _orthogonalTarget(startPoint, nodes[index + 1]);
        continue;
      }
      final endPoint = _orthogonalTarget(startPoint, nodes[index + 1]);
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

  Offset _orthogonalTarget(Offset start, PathNode target) {
    final dx = target.x - start.dx;
    final dy = target.y - start.dy;
    if (dx.abs() >= dy.abs()) {
      return Offset(target.x, start.dy);
    }
    return Offset(start.dx, target.y);
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
        oldDelegate.triggerLinkLabel != triggerLinkLabel ||
        oldDelegate.ready != ready;
  }
}
