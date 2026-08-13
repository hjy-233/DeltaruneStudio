import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/path_node_tools.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:deltarune_studio/runtime/movement_path_geometry.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:deltarune_studio/shared_render/studio_rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;
part 'scene_canvas_layers.dart';

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
      onPointerSignal: _handlePointerSignal,
      child: MouseRegion(
        onHover: (event) {
          ref.read(canvasCursorProvider.notifier).state = _toScene(
            event.localPosition,
          );
        },
        onExit: (_) => ref.read(canvasCursorProvider.notifier).state = null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _handleTapDown(
            details,
            useRuntime,
            preview.cleanPreview,
            scene,
            visibleMoves,
          ),
          onPanStart: (details) => _handlePanStart(
            details,
            useRuntime,
            preview.cleanPreview,
            scene,
            visibleMoves,
          ),
          onPanUpdate: (details) =>
              _handlePanUpdate(details, useRuntime, preview.cleanPreview),
          onPanEnd: (_) => _handlePanEnd(
            useRuntime,
            preview.cleanPreview,
            scene,
            selectedMove,
          ),
          child: ClipRect(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                if (!useRuntime) {
                  final center = _toScene(size.center(Offset.zero));
                  ref
                      .read(studioControllerProvider.notifier)
                      .setEditorInsertionPoint(center.dx, center.dy);
                }
                final effectivePan = useRuntime
                    ? _runtimePan(world, size)
                    : _pan;
                return _buildCanvasStack(
                  context: context,
                  preview: preview,
                  world: world,
                  scene: scene,
                  runtimeObjects: objects,
                  previewTransforms: previewTransforms,
                  visibleMoves: visibleMoves,
                  effectivePan: effectivePan,
                  useRuntime: useRuntime,
                  hideDebug: hideDebug,
                  triggerLinkLabel: l10n.triggerLinkLabel,
                  zoomLabel: l10n.zoomPercent((_scale * 100).round()),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent signal) {
    if (signal is! PointerScrollEvent) {
      return;
    }
    final cursor = signal.localPosition;
    setState(() {
      final scenePoint = (cursor - _pan) / _scale;
      final next = (_scale - signal.scrollDelta.dy * 0.001)
          .clamp(0.35, 4)
          .toDouble();
      _scale = next;
      _pan = cursor - scenePoint * _scale;
    });
  }

  void _handleTapDown(
    TapDownDetails details,
    bool useRuntime,
    bool cleanPreview,
    Scene scene,
    List<SelectedMoveEvent> visibleMoves,
  ) {
    if (useRuntime || cleanPreview) {
      return;
    }
    final scenePoint = _toScene(details.localPosition);
    final nodeHit = _hitTestPathNode(visibleMoves, scenePoint);
    final controller = ref.read(studioControllerProvider.notifier);
    if (nodeHit != null) {
      controller.selectPathNode(
        nodeHit.chainId,
        nodeHit.eventId,
        nodeHit.nodeId,
      );
      return;
    }
    final hit = _hitTest(scene.objects, scenePoint);
    if (hit != null && HardwareKeyboard.instance.isShiftPressed) {
      controller.toggleObjectSelection(hit);
    } else {
      controller.selectObject(hit);
    }
  }

  void _handlePanStart(
    DragStartDetails details,
    bool useRuntime,
    bool cleanPreview,
    Scene scene,
    List<SelectedMoveEvent> visibleMoves,
  ) {
    if (useRuntime || cleanPreview) {
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
    if (_startResize(scene.objects, scenePoint)) {
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
    ref.read(studioControllerProvider.notifier).selectObject(_dragObjectId);
    final dragObject = _objectById(scene.objects, _dragObjectId);
    _dragObjectStartTransform =
        dragObject == null || _isObjectLocked(dragObject)
        ? null
        : dragObject.objectTransform;
    _dragDelta = Offset.zero;
  }

  bool _startResize(List<SceneObject> objects, Offset scenePoint) {
    _resizeCorner = _hitTestResizeHandle(
      objects,
      widget.ready.selectedObjectId,
      scenePoint,
    );
    if (_resizeCorner == null) {
      return false;
    }
    final selectedObject = _objectById(objects, widget.ready.selectedObjectId);
    if (selectedObject == null || _isObjectLocked(selectedObject)) {
      _resizeCorner = null;
      return false;
    }
    _resizeObjectId = widget.ready.selectedObjectId;
    _resizeStartTransform = selectedObject.objectTransform;
    _dragDelta = Offset.zero;
    return true;
  }

  void _handlePanUpdate(
    DragUpdateDetails details,
    bool useRuntime,
    bool cleanPreview,
  ) {
    if (useRuntime || cleanPreview) {
      return;
    }
    if (_marqueeStart != null) {
      setState(() => _marqueeEnd = _toScene(details.localPosition));
      return;
    }
    if (_dragObjectId == null &&
        _dragNode == null &&
        (_resizeObjectId == null || _resizeCorner == null)) {
      setState(() => _pan += details.delta);
      return;
    }
    setState(() => _dragDelta += details.delta / _scale);
  }

  void _handlePanEnd(
    bool useRuntime,
    bool cleanPreview,
    Scene scene,
    SelectedMoveEvent? selectedMove,
  ) {
    if (useRuntime || cleanPreview) {
      return;
    }
    final controller = ref.read(studioControllerProvider.notifier);
    _finishMarquee(controller, scene.objects);
    _finishResize(controller);
    _finishPathNodeDrag(controller, selectedMove);
    final dragId = _dragObjectId;
    if (dragId != null) {
      controller.moveObjectById(dragId, _dragDelta.dx, _dragDelta.dy);
    }
    _clearDragState();
  }

  void _finishMarquee(StudioController controller, List<SceneObject> objects) {
    final marqueeStart = _marqueeStart;
    final marqueeEnd = _marqueeEnd;
    if (marqueeStart == null || marqueeEnd == null) {
      return;
    }
    controller.selectObjects(
      _objectsInMarquee(objects, marqueeStart, marqueeEnd),
    );
  }

  void _finishResize(StudioController controller) {
    final resizeId = _resizeObjectId;
    final resizeCorner = _resizeCorner;
    final resizeStart = _resizeStartTransform;
    if (resizeId == null || resizeCorner == null || resizeStart == null) {
      return;
    }
    final next = _resizeTransform(
      resizeStart,
      resizeCorner,
      _dragDelta.dx,
      _dragDelta.dy,
    );
    controller.updateObjectTransformById(resizeId, (_) => next);
  }

  void _finishPathNodeDrag(
    StudioController controller,
    SelectedMoveEvent? selectedMove,
  ) {
    final node = _dragNode;
    if (node == null) {
      return;
    }
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

  void _clearDragState() {
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
  }

  Widget _buildCanvasStack({
    required BuildContext context,
    required PreviewState preview,
    required RuntimeWorld? world,
    required Scene scene,
    required Map<String, RuntimeObject>? runtimeObjects,
    required Map<String, Transform2D> previewTransforms,
    required List<SelectedMoveEvent> visibleMoves,
    required Offset effectivePan,
    required bool useRuntime,
    required bool hideDebug,
    required String triggerLinkLabel,
    required String zoomLabel,
  }) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),
        _assetLayer(
          scene,
          runtimeObjects,
          previewTransforms,
          world,
          effectivePan,
          false,
        ),
        _assetLayer(
          scene,
          runtimeObjects,
          previewTransforms,
          world,
          effectivePan,
          true,
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _ScenePainter(
                scene: scene,
                runtimeObjects: runtimeObjects,
                selectedObjectId: widget.ready.selectedObjectId,
                selectedMoves: visibleMoves,
                previewTransforms: previewTransforms,
                selection: widget.ready.selection,
                activeMoveEventId: useRuntime ? world?.activeMoveEventId : null,
                activeMoveProgress: useRuntime
                    ? world?.activeMoveProgress ?? 0
                    : 0,
                triggerLinkLabel: triggerLinkLabel,
                pan: effectivePan,
                scale: _scale,
                fadeOpacity: useRuntime ? world?.fadeOpacity ?? 0 : 0,
                currentTime: useRuntime ? world?.currentTime ?? 0 : 0,
                ready: widget.ready,
                hideDebug: hideDebug,
              ),
            ),
          ),
        ),
        if (useRuntime && world?.dialogue != null)
          Positioned.fill(
            child: RepaintBoundary(
              child: _DialogueOverlay(
                ready: widget.ready,
                dialogue: world!.dialogue!,
              ),
            ),
          ),
        if (useRuntime && world?.activeVideo != null)
          Positioned.fill(
            child: RepaintBoundary(
              child: _VideoOverlay(
                ready: widget.ready,
                video: world!.activeVideo!,
                isPlaying: preview.isPlaying,
                onCompleted: preview.cleanPreview
                    ? () => ref
                          .read(previewControllerProvider.notifier)
                          .completeActiveVideo(widget.ready)
                    : null,
              ),
            ),
          ),
        _zoomBadge(context, zoomLabel),
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
  }

  Widget _assetLayer(
    Scene scene,
    Map<String, RuntimeObject>? runtimeObjects,
    Map<String, Transform2D> previewTransforms,
    RuntimeWorld? world,
    Offset effectivePan,
    bool foreground,
  ) {
    return Positioned.fill(
      child: RepaintBoundary(
        child: _AssetImageLayer(
          ready: widget.ready,
          scene: scene,
          runtimeObjects: runtimeObjects,
          previewTransforms: previewTransforms,
          currentTime: world?.currentTime ?? 0,
          pan: effectivePan,
          scale: _scale,
          foreground: foreground,
        ),
      ),
    );
  }

  Widget _zoomBadge(BuildContext context, String zoomLabel) {
    return Positioned(
      right: 12,
      top: 12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(zoomLabel, style: Theme.of(context).textTheme.bodySmall),
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
    final nodes = normalizeOrthogonalPathNodes(
      selectedMove.event.path.nodes.map((node) {
        return node.id == dragNode.nodeId ? nextNode : node;
      }).toList(),
      dragNode.nodeId,
      selectedMove.event.path.mode,
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
