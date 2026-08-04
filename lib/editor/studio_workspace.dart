import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/widgets/event_chain_panel.dart';
import 'package:deltarune_studio/editor/widgets/inspector_panel.dart';
import 'package:deltarune_studio/editor/widgets/scene_canvas.dart';
import 'package:deltarune_studio/editor/widgets/scene_sidebar.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StudioWorkspace extends ConsumerWidget {
  const StudioWorkspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioState = ref.watch(studioControllerProvider);

    return Scaffold(
      body: switch (studioState) {
        StudioLoading() => const Center(child: CircularProgressIndicator()),
        final StudioReady ready => _WorkspaceBody(ready: ready),
      },
    );
  }
}

class _WorkspaceBody extends ConsumerStatefulWidget {
  const _WorkspaceBody({required this.ready});

  final StudioReady ready;

  @override
  ConsumerState<_WorkspaceBody> createState() => _WorkspaceBodyState();
}

class _WorkspaceBodyState extends ConsumerState<_WorkspaceBody> {
  double _leftWidth = 220;
  double _rightWidth = 280;
  double _bottomHeight = 300;

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready;
    final isPreviewPlaying = ref.watch(
      previewControllerProvider.select((preview) => preview.isPlaying),
    );
    final controller = ref.read(studioControllerProvider.notifier);
    final previewController = ref.read(previewControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final projectPath = ready.projectDirectory?.path ?? l10n.scratchProject;
    final statusText = ready.statusMessage ?? l10n.noActiveEvent;

    return Column(
      children: [
        Material(
          elevation: 1,
          child: SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 20),
                  FilledButton.tonalIcon(
                    onPressed: controller.newProject,
                    icon: const Icon(Icons.note_add),
                    label: Text(l10n.newProject),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: controller.openProject,
                    icon: const Icon(Icons.folder_open),
                    label: Text(l10n.open),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: controller.saveProject,
                    icon: const Icon(Icons.save),
                    label: Text(ready.isDirty ? l10n.saveDirty : l10n.save),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: controller.saveProjectAs,
                    icon: const Icon(Icons.save_as),
                    label: Text(l10n.saveAs),
                  ),
                  const SizedBox(width: 28),
                  Text(
                    l10n.mainCanvas,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      final cursor = ref.watch(canvasCursorProvider);
                      final text = cursor == null
                          ? 'x -, y -'
                          : 'x ${cursor.dx.toStringAsFixed(0)}, y ${cursor.dy.toStringAsFixed(0)}';
                      return Text(
                        text,
                        style: Theme.of(context).textTheme.labelMedium,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: isPreviewPlaying
                        ? previewController.stop
                        : () => previewController.play(
                            ready,
                            fromStart: true,
                            cleanPreview: true,
                          ),
                    icon: Icon(
                      isPreviewPlaying ? Icons.stop : Icons.play_arrow,
                    ),
                    label: Text(isPreviewPlaying ? l10n.stop : l10n.play),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxSideWidth = constraints.maxWidth * 0.45;
              double bounded(double value, double preferredMin, double max) {
                final upper = max < 0 ? 0.0 : max;
                final lower = upper < preferredMin ? upper : preferredMin;
                return value.clamp(lower, upper).toDouble();
              }

              _leftWidth = bounded(_leftWidth, 160, maxSideWidth);
              _rightWidth = bounded(_rightWidth, 220, maxSideWidth);
              _bottomHeight = bounded(
                _bottomHeight,
                180,
                constraints.maxHeight * 0.65,
              );
              return Row(
                children: [
                  SizedBox(
                    width: _leftWidth,
                    child: SceneSidebar(ready: ready),
                  ),
                  _ResizeHandle(
                    axis: Axis.horizontal,
                    onDrag: (delta) {
                      setState(() {
                        _leftWidth = bounded(
                          _leftWidth + delta,
                          160,
                          maxSideWidth,
                        );
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: SceneCanvas(ready: ready)),
                        _ResizeHandle(
                          axis: Axis.vertical,
                          onDrag: (delta) {
                            setState(() {
                              _bottomHeight = bounded(
                                _bottomHeight - delta,
                                180,
                                constraints.maxHeight * 0.65,
                              );
                            });
                          },
                        ),
                        SizedBox(
                          height: _bottomHeight,
                          child: EventChainPanel(
                            ready: ready,
                            sampleCharacterId:
                                ready.currentScene.objects.firstOrNullObjectId,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ResizeHandle(
                    axis: Axis.horizontal,
                    onDrag: (delta) {
                      setState(() {
                        _rightWidth = bounded(
                          _rightWidth - delta,
                          220,
                          maxSideWidth,
                        );
                      });
                    },
                  ),
                  SizedBox(
                    width: _rightWidth,
                    child: InspectorPanel(ready: ready),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            '$projectPath  |  $statusText',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.axis, required this.onDrag});

  final Axis axis;
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final isHorizontal = axis == Axis.horizontal;
    return MouseRegion(
      cursor: isHorizontal
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          onDrag(isHorizontal ? details.delta.dx : details.delta.dy);
        },
        child: SizedBox(
          width: isHorizontal ? 8 : double.infinity,
          height: isHorizontal ? double.infinity : 8,
          child: Center(
            child: ColoredBox(
              color: Theme.of(context).dividerColor,
              child: SizedBox(
                width: isHorizontal ? 1 : double.infinity,
                height: isHorizontal ? double.infinity : 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on List<SceneObject> {
  String? get firstOrNullObjectId {
    for (final object in this) {
      if (object is CharacterInstanceObject) {
        return object.id;
      }
    }
    return isEmpty ? null : first.objectId;
  }
}

StudioEvent defaultMoveEvent(String? objectId) {
  return StudioEvent.characterMove(
    id: StudioIds.event(),
    characterObjectId: objectId ?? '',
    path: MovementPath(
      nodes: [
        const PathNode(id: 'path_a', name: 'Start', x: 120, y: 180),
        const PathNode(id: 'path_b', name: 'Node 2', x: 240, y: 180),
        const PathNode(id: 'path_c', name: 'Node 3', x: 240, y: 120),
      ],
      speed: 320,
      shake: 12,
    ),
  );
}
