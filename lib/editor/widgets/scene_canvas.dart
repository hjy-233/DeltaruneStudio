import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(previewControllerProvider);
    final world = preview.world;
    final builtIns = ref.watch(builtInAssetLibraryProvider).valueOrNull;
    final useRuntime = preview.isPlaying;
    final scene = useRuntime
        ? world?.scene ?? widget.ready.currentScene
        : widget.ready.currentScene;
    final objects = useRuntime ? world?.objects : null;
    final hideDebug = preview.cleanPreview;
    final selectedMove = _selectedMoveEvent(widget.ready);
    final previewMove = _previewMoveEvent(selectedMove);
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
            final scenePoint = _toScene(details.localPosition);
            final nodeHit = _hitTestPathNode(selectedMove, scenePoint);
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
            ref.read(studioControllerProvider.notifier).selectObject(hit);
          },
          onPanStart: (details) {
            final scenePoint = _toScene(details.localPosition);
            _resizeCorner = _hitTestResizeHandle(
              scene.objects,
              widget.ready.selectedObjectId,
              scenePoint,
            );
            if (_resizeCorner != null) {
              _resizeObjectId = widget.ready.selectedObjectId;
              _resizeStartTransform = _objectById(
                scene.objects,
                _resizeObjectId,
              )?.objectTransform;
              _dragDelta = Offset.zero;
              return;
            }
            _dragNode = _hitTestPathNode(selectedMove, scenePoint);
            if (_dragNode != null) {
              ref.read(studioControllerProvider.notifier).select(_dragNode);
              _dragNodeStart = _nodeById(selectedMove, _dragNode!.nodeId);
              _dragDelta = Offset.zero;
              return;
            }
            _dragObjectId = _hitTest(scene.objects, scenePoint);
            ref
                .read(studioControllerProvider.notifier)
                .selectObject(_dragObjectId);
            _dragObjectStartTransform = _objectById(
              scene.objects,
              _dragObjectId,
            )?.objectTransform;
            _dragDelta = Offset.zero;
          },
          onPanUpdate: (details) {
            if (preview.isPlaying) {
              return;
            }
            final resizeId = _resizeObjectId;
            final resizeCorner = _resizeCorner;
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
            final controller = ref.read(studioControllerProvider.notifier);
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
            });
          },
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final effectivePan = useRuntime && world != null
                    ? _runtimePan(world, size)
                    : _pan;
                return Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: Colors.black),
                    ),
                    Positioned.fill(
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
                    Positioned.fill(
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
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ScenePainter(
                          scene: scene,
                          runtimeObjects: objects,
                          selectedObjectId: widget.ready.selectedObjectId,
                          selectedMove: previewMove,
                          previewTransforms: previewTransforms,
                          selection: widget.ready.selection,
                          activeMoveEventId: useRuntime
                              ? world?.activeMoveEventId
                              : null,
                          activeMoveProgress: useRuntime
                              ? world?.activeMoveProgress ?? 0
                              : 0,
                          triggerLinkLabel: l10n.triggerLinkLabel,
                          pan: effectivePan,
                          scale: _scale,
                          fadeOpacity: useRuntime ? world?.fadeOpacity ?? 0 : 0,
                          currentTime: useRuntime ? world?.currentTime ?? 0 : 0,
                          ready: widget.ready,
                          hideDebug: hideDebug,
                        ),
                      ),
                    ),
                    if (useRuntime && world?.dialogue != null)
                      Positioned.fill(
                        child: _DialogueOverlay(
                          ready: widget.ready,
                          dialogue: world!.dialogue!,
                          builtIns: builtIns,
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

  Offset _runtimePan(RuntimeWorld world, Size viewportSize) {
    final target = _cameraTarget(world);
    if (target == null) {
      return _pan;
    }
    return Offset(
      viewportSize.width / 2 - target.dx * _scale,
      viewportSize.height / 2 - target.dy * _scale,
    );
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

  PathNode? _nodeById(SelectedMoveEvent? selectedMove, String nodeId) {
    if (selectedMove == null) {
      return null;
    }
    for (final node in selectedMove.event.path.nodes) {
      if (node.id == nodeId) {
        return node;
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
    SelectedMoveEvent? selectedMove,
    Offset point,
  ) {
    if (selectedMove == null) {
      return null;
    }
    for (final node in selectedMove.event.path.nodes.reversed) {
      final rect = Rect.fromCircle(center: Offset(node.x, node.y), radius: 9);
      if (rect.contains(point)) {
        return PathNodeSelection(
          selectedMove.chainId,
          selectedMove.event.id,
          node.id,
        );
      }
    }
    return null;
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
    if (projectDirectory == null) {
      return const SizedBox.shrink();
    }
    final children = <Widget>[];
    for (final object in scene.objects) {
      final isForeground =
          object is CharacterInstanceObject || object is PropSceneObject;
      if (foreground != isForeground) {
        continue;
      }
      final runtimeObject = runtimeObjects?[object.objectId];
      final assetId = _imageAssetIdForObject(object, runtimeObject);
      final asset = ready.assetById(assetId);
      if (asset == null || asset.kind == AssetKind.audio) {
        continue;
      }
      final transform =
          runtimeObject?.transform ??
          previewTransforms[object.objectId] ??
          object.objectTransform;
      final file = File(p.join(projectDirectory.path, asset.relativePath));
      if (!file.existsSync()) {
        continue;
      }
      children.add(
        Positioned(
          left: transform.x,
          top: transform.y,
          width: transform.width * transform.scale,
          height: transform.height * transform.scale,
          child: Image.file(
            file,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
            isAntiAlias: false,
          ),
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

  String? _imageAssetIdForObject(
    SceneObject object,
    RuntimeObject? runtimeObject,
  ) {
    return object.maybeMap(
      prop: (value) => value.assetId,
      background: (value) => value.assetId,
      characterInstance: (value) {
        final character = ready.characterById(value.characterId);
        if (character == null || character.animations.isEmpty) {
          return null;
        }
        final facing = runtimeObject?.facing ?? value.facing;
        final facingFrames = character.animations
            .where((animation) => animation.direction == facing)
            .toList();
        final neutralFrames = character.animations
            .where((animation) => animation.direction == null)
            .toList();
        final frames = facingFrames.isNotEmpty
            ? facingFrames
            : neutralFrames.isNotEmpty
            ? neutralFrames
            : character.animations;
        if (frames.length == 1) {
          return frames.first.assetId;
        }
        final frameIndex = ((currentTime / 0.22).floor()) % frames.length;
        return frames[frameIndex].assetId;
      },
      orElse: () => null,
    );
  }
}

class _DialogueOverlay extends StatelessWidget {
  const _DialogueOverlay({
    required this.ready,
    required this.dialogue,
    required this.builtIns,
  });

  final StudioReady ready;
  final DialogueBoxState dialogue;
  final BuiltInAssetLibrary? builtIns;

  @override
  Widget build(BuildContext context) {
    final portraitFile = _portraitFile();
    final borderAssets = _DialogueBorderAssets.fromBuiltIns(builtIns);
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math
              .min(760.0, constraints.maxWidth - 96)
              .clamp(320.0, 760.0);
          const height = 148.0;
          final hasPortrait = portraitFile != null;
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _DialogueBorder(
                        style: dialogue.style,
                        assets: borderAssets,
                      ),
                    ),
                    if (hasPortrait)
                      Positioned(
                        left: 28,
                        top: 32,
                        width: 72,
                        height: 76,
                        child: Image.file(
                          portraitFile,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          isAntiAlias: false,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                    Positioned(
                      left: hasPortrait ? 124 : 32,
                      top: 28,
                      right: 28,
                      bottom: 24,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
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
                        child: Text(
                          '* ${dialogue.text}',
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    if (dialogue.speaker.trim().isNotEmpty)
                      Positioned(
                        left: hasPortrait ? 124 : 32,
                        bottom: 14,
                        child: Text(
                          dialogue.speaker,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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

class _DialogueBorder extends StatefulWidget {
  const _DialogueBorder({required this.style, required this.assets});

  final DialogueStyle style;
  final _DialogueBorderAssets? assets;

  @override
  State<_DialogueBorder> createState() => _DialogueBorderState();
}

class _DialogueBorderState extends State<_DialogueBorder> {
  _LoadedDialogueBorder? _loaded;
  Timer? _timer;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.style == DialogueStyle.darkWorld) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant _DialogueBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assets != widget.assets) {
      _load();
    }
    if (oldWidget.style != widget.style) {
      if (widget.style == DialogueStyle.darkWorld) {
        _startTimer();
      } else {
        _timer?.cancel();
        _timer = null;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(milliseconds: 125), (_) {
      if (mounted) {
        setState(() => _frame += 1);
      }
    });
  }

  Future<void> _load() async {
    final assets = widget.assets;
    if (assets == null) {
      setState(() => _loaded = null);
      return;
    }
    final top = await _decodeFile(assets.topPath);
    final left = await _decodeFile(assets.leftPath);
    final corners = <ui.Image>[];
    for (final path in assets.cornerPaths) {
      corners.add(await _decodeFile(path));
    }
    if (!mounted) {
      return;
    }
    setState(
      () => _loaded = _LoadedDialogueBorder(
        top: top,
        left: left,
        corners: corners,
      ),
    );
  }

  Future<ui.Image> _decodeFile(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DialogueBorderPainter(
        style: widget.style,
        loaded: _loaded,
        frame: _frame,
      ),
    );
  }
}

final class _DialogueBorderAssets {
  const _DialogueBorderAssets({
    required this.topPath,
    required this.leftPath,
    required this.cornerPaths,
  });

  final String topPath;
  final String leftPath;
  final List<String> cornerPaths;

  static _DialogueBorderAssets? fromBuiltIns(BuiltInAssetLibrary? library) {
    if (library == null) {
      return null;
    }
    String? pathFor(String sourcePath) {
      for (final asset in library.assets) {
        if (asset.sourcePath == sourcePath) {
          return asset.resolvedPath;
        }
      }
      return null;
    }

    final top = pathFor('UI/HUD/Ch1/Text Box/spr_textbox_top_0.png');
    final left = pathFor('UI/HUD/Ch1/Text Box/spr_textbox_left_0.png');
    final corners = [
      for (var index = 0; index < 8; index += 1)
        pathFor('UI/HUD/Ch1/Text Box/spr_textbox_topleft_$index.png'),
    ];
    if (top == null || left == null || corners.any((path) => path == null)) {
      return null;
    }
    return _DialogueBorderAssets(
      topPath: top,
      leftPath: left,
      cornerPaths: corners.cast<String>(),
    );
  }
}

final class _LoadedDialogueBorder {
  const _LoadedDialogueBorder({
    required this.top,
    required this.left,
    required this.corners,
  });

  final ui.Image top;
  final ui.Image left;
  final List<ui.Image> corners;
}

class _DialogueBorderPainter extends CustomPainter {
  const _DialogueBorderPainter({
    required this.style,
    required this.loaded,
    required this.frame,
  });

  final DialogueStyle style;
  final _LoadedDialogueBorder? loaded;
  final int frame;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.black);
    if (style == DialogueStyle.darkWorld && loaded != null) {
      _drawDarkWorld(canvas, size, loaded!);
      return;
    }
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..isAntiAlias = false;
    canvas.drawRect(
      Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
      paint,
    );
  }

  void _drawDarkWorld(Canvas canvas, Size size, _LoadedDialogueBorder border) {
    final cornerFrame = (frame % border.corners.length).clamp(
      0,
      border.corners.length - 1,
    );
    final corner = border.corners[cornerFrame];
    const cornerSize = 32.0;
    const edgeSize = 32.0;
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;

    for (var x = cornerSize; x < size.width - cornerSize; x += 2) {
      _drawImage(canvas, border.top, Rect.fromLTWH(x, 0, 2, edgeSize), paint);
      _drawImageFlipped(
        canvas,
        border.top,
        Rect.fromLTWH(x, size.height - edgeSize, 2, edgeSize),
        flipY: true,
        paint: paint,
      );
    }
    for (var y = cornerSize; y < size.height - cornerSize; y += 2) {
      _drawImage(canvas, border.left, Rect.fromLTWH(0, y, edgeSize, 2), paint);
      _drawImageFlipped(
        canvas,
        border.left,
        Rect.fromLTWH(size.width - edgeSize, y, edgeSize, 2),
        flipX: true,
        paint: paint,
      );
    }

    _drawImage(canvas, corner, const Rect.fromLTWH(0, 0, 32, 32), paint);
    _drawImageFlipped(
      canvas,
      corner,
      Rect.fromLTWH(size.width - cornerSize, 0, cornerSize, cornerSize),
      flipX: true,
      paint: paint,
    );
    _drawImageFlipped(
      canvas,
      corner,
      Rect.fromLTWH(0, size.height - cornerSize, cornerSize, cornerSize),
      flipY: true,
      paint: paint,
    );
    _drawImageFlipped(
      canvas,
      corner,
      Rect.fromLTWH(
        size.width - cornerSize,
        size.height - cornerSize,
        cornerSize,
        cornerSize,
      ),
      flipX: true,
      flipY: true,
      paint: paint,
    );
  }

  void _drawImage(Canvas canvas, ui.Image image, Rect dst, Paint paint) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      dst,
      paint,
    );
  }

  void _drawImageFlipped(
    Canvas canvas,
    ui.Image image,
    Rect dst, {
    bool flipX = false,
    bool flipY = false,
    required Paint paint,
  }) {
    canvas.save();
    canvas.translate(dst.left + (flipX ? dst.width : 0), dst.top);
    canvas.scale(flipX ? -1 : 1, flipY ? -1 : 1);
    final localDst = Rect.fromLTWH(
      0,
      flipY ? -dst.height : 0,
      dst.width,
      dst.height,
    );
    _drawImage(canvas, image, localDst, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DialogueBorderPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.loaded != loaded ||
        oldDelegate.frame != frame;
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({
    required this.scene,
    required this.runtimeObjects,
    required this.selectedObjectId,
    required this.selectedMove,
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
  final SelectedMoveEvent? selectedMove;
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
      _drawSelectedPath(canvas);
    }
    for (final object in scene.objects) {
      if (object is BackgroundObject) {
        continue;
      }
      final runtimeObject = runtimeObjects?[object.objectId];
      _drawObject(canvas, object, runtimeObject);
    }
    canvas.restore();

    if (fadeOpacity > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black.withValues(alpha: fadeOpacity),
      );
    }
  }

  void _drawSelectedPath(Canvas canvas) {
    final move = selectedMove;
    if (move == null || move.event.path.nodes.isEmpty) {
      return;
    }
    final nodes = move.event.path.nodes;
    final activePreview = activeMoveEventId == move.event.id;
    final progressIndex = activePreview
        ? activeMoveProgress * math.max(1, nodes.length - 1)
        : 0.0;
    final linePaint = Paint()
      ..color = const Color(0xfff2c14e)
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
        Paint()..color = selected ? Colors.white : const Color(0xfff2c14e),
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
    final isSelected = selectedObjectId == object.objectId;

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
      if (object is BackgroundObject || object is CharacterInstanceObject) {
        _drawResizeHandles(canvas, rect);
      }
    }
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
    final assetId =
        _AssetImageLayer(
          ready: ready,
          scene: scene,
          runtimeObjects: runtimeObjects,
          currentTime: currentTime,
          pan: pan,
          scale: scale,
          foreground: true,
          previewTransforms: previewTransforms,
        )._imageAssetIdForObject(
          SceneObject.characterInstance(
            id: value.id,
            name: value.name,
            characterId: value.characterId,
            transform: value.transform,
            facing: value.facing,
            initialExpression: value.initialExpression,
            activity: value.activity,
          ),
          runtimeObject,
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
        oldDelegate.selectedMove != selectedMove ||
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
