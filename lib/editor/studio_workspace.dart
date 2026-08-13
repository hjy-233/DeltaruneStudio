import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/widgets/event_chain_panel.dart';
import 'package:deltarune_studio/editor/widgets/inspector_panel.dart';
import 'package:deltarune_studio/editor/widgets/scene_canvas.dart';
import 'package:deltarune_studio/editor/widgets/scene_sidebar.dart';
import 'package:deltarune_studio/editor/widgets/settings_window.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/export/video_exporter.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isExportingVideo = false;
  int _exportScale = 1;
  String? _layoutProjectId;

  @override
  void initState() {
    super.initState();
    _applyProjectLayout(widget.ready.project);
  }

  @override
  void didUpdateWidget(covariant _WorkspaceBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ready.project.id != widget.ready.project.id) {
      _applyProjectLayout(widget.ready.project);
    }
  }

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

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) =>
          _handleKeyEvent(event, ready, controller, isPreviewPlaying),
      child: Column(
        children: [
          _buildToolbar(context, ready, controller, previewController, l10n),
          Expanded(child: _buildResizableWorkspace(ready)),
          _buildStatusBar(context, projectPath, statusText),
        ],
      ),
    );
  }

  KeyEventResult _handleKeyEvent(
    KeyEvent event,
    StudioReady ready,
    StudioController controller,
    bool isPreviewPlaying,
  ) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final isModifierPressed =
        HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;
    if (_handleShortcut(event, controller, isModifierPressed)) {
      return KeyEventResult.handled;
    }
    if (isPreviewPlaying) {
      return KeyEventResult.ignored;
    }
    final step = HardwareKeyboard.instance.isShiftPressed ? 10.0 : 1.0;
    final delta = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => Offset(-step, 0),
      LogicalKeyboardKey.arrowRight => Offset(step, 0),
      LogicalKeyboardKey.arrowUp => Offset(0, -step),
      LogicalKeyboardKey.arrowDown => Offset(0, step),
      _ => null,
    };
    if (delta == null) {
      return KeyEventResult.ignored;
    }
    if (ready.selection is PathNodeSelection) {
      controller.moveSelectedPathNode(delta.dx, delta.dy);
    } else {
      controller.moveSelectedObject(delta.dx, delta.dy);
    }
    return KeyEventResult.handled;
  }

  bool _handleShortcut(
    KeyEvent event,
    StudioController controller,
    bool isModifierPressed,
  ) {
    if (!isModifierPressed) {
      return false;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyZ) {
      HardwareKeyboard.instance.isShiftPressed
          ? controller.redo()
          : controller.undo();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyY) {
      controller.redo();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyC) {
      controller.copySelection();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyV) {
      controller.pasteSelection();
      return true;
    }
    return false;
  }

  Widget _buildToolbar(
    BuildContext context,
    StudioReady ready,
    StudioController controller,
    PreviewController previewController,
    AppLocalizations l10n,
  ) {
    final isPreviewPlaying = ref.watch(
      previewControllerProvider.select((preview) => preview.isPlaying),
    );
    return Material(
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
              _toolbarButton(
                controller.newProject,
                Icons.note_add,
                l10n.newProject,
              ),
              _toolbarButton(
                controller.openProject,
                Icons.folder_open,
                l10n.open,
              ),
              _toolbarButton(
                controller.saveProject,
                Icons.save,
                ready.isDirty ? l10n.saveDirty : l10n.save,
              ),
              if (!kIsWeb)
                _toolbarButton(
                  controller.saveProjectAs,
                  Icons.save_as,
                  l10n.saveAs,
                ),
              const SizedBox(width: 28),
              Text(
                l10n.mainCanvas,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 10),
              const _CanvasCursorLabel(),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                tooltip: l10n.settings,
                onPressed: () =>
                    showStudioSettingsWindow(context, ready: ready),
                icon: const Icon(Icons.settings),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: isPreviewPlaying
                    ? previewController.stop
                    : () => previewController.play(
                        ready,
                        fromStart: true,
                        cleanPreview: true,
                      ),
                icon: Icon(isPreviewPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(isPreviewPlaying ? l10n.stop : l10n.play),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: _isExportingVideo
                    ? null
                    : () => _exportVideo(context, ready),
                icon: _isExportingVideo
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.movie_creation_outlined),
                label: Text('${l10n.exportVideo} ${_exportScale}x'),
              ),
              PopupMenuButton<int>(
                tooltip: l10n.exportScale,
                initialValue: _exportScale,
                onSelected: (scale) => setState(() => _exportScale = scale),
                itemBuilder: (context) => [
                  for (final scale in [1, 2, 4, 8, 16])
                    PopupMenuItem(value: scale, child: Text('${scale}x')),
                ],
                icon: const Icon(Icons.expand_more),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbarButton(VoidCallback onPressed, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }

  Widget _buildResizableWorkspace(StudioReady ready) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSideWidth = constraints.maxWidth * 0.45;
        _leftWidth = _bounded(_leftWidth, 160, maxSideWidth);
        _rightWidth = _bounded(_rightWidth, 220, maxSideWidth);
        _bottomHeight = _bounded(
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
            _horizontalResize((delta) {
              _leftWidth = _bounded(_leftWidth + delta, 160, maxSideWidth);
            }),
            Expanded(child: _buildCenterWorkspace(ready, constraints)),
            _horizontalResize((delta) {
              _rightWidth = _bounded(_rightWidth - delta, 220, maxSideWidth);
            }),
            SizedBox(
              width: _rightWidth,
              child: InspectorPanel(ready: ready),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCenterWorkspace(StudioReady ready, BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(child: SceneCanvas(ready: ready)),
        _ResizeHandle(
          axis: Axis.vertical,
          onDrag: (delta) {
            setState(() {
              _bottomHeight = _bounded(
                _bottomHeight - delta,
                180,
                constraints.maxHeight * 0.65,
              );
            });
          },
          onDragEnd: _persistLayout,
        ),
        SizedBox(
          height: _bottomHeight,
          child: EventChainPanel(
            ready: ready,
            sampleCharacterId: ready.currentScene.objects.firstOrNullObjectId,
          ),
        ),
      ],
    );
  }

  Widget _horizontalResize(ValueChanged<double> updateWidth) {
    return _ResizeHandle(
      axis: Axis.horizontal,
      onDrag: (delta) {
        setState(() => updateWidth(delta));
      },
      onDragEnd: _persistLayout,
    );
  }

  double _bounded(double value, double preferredMin, double max) {
    final upper = max < 0 ? 0.0 : max;
    final lower = upper < preferredMin ? upper : preferredMin;
    return value.clamp(lower, upper).toDouble();
  }

  Widget _buildStatusBar(
    BuildContext context,
    String projectPath,
    String statusText,
  ) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        '$projectPath  |  $statusText',
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  Future<void> _exportVideo(BuildContext context, StudioReady ready) async {
    if (kIsWeb) {
      _showMessage(context, 'Web 端暂不支持导出视频。');
      return;
    }
    final chainName = ready.activeChain?.name ?? ready.project.name;
    final location = await getSaveLocation(
      suggestedName: '$chainName.mp4',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Video', extensions: ['mp4', 'mov']),
      ],
    );
    if (location == null) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final scale = _exportScale;
    final outputPath = _videoPathWithExtension(location.path);
    setState(() => _isExportingVideo = true);
    try {
      final builtIns = ref.read(builtInAssetLibraryProvider).valueOrNull;
      await VideoExporter(scale: scale).export(
        ready: ready,
        outputPath: outputPath,
        builtIns: builtIns,
        onProgress: (message) => _showMessage(context, message),
      );
      if (context.mounted) {
        _showMessage(context, '视频已导出到 $outputPath');
      }
    } on Object catch (error) {
      if (context.mounted) {
        _showMessage(context, '$error');
      }
    } finally {
      if (mounted) {
        setState(() => _isExportingVideo = false);
      }
    }
  }

  String _videoPathWithExtension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4') || lower.endsWith('.mov')) {
      return path;
    }
    return '$path.mp4';
  }

  void _showMessage(BuildContext context, String message) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _applyProjectLayout(StudioProject project) {
    final layout = project.editorLayout;
    _layoutProjectId = project.id;
    _leftWidth = layout.leftSidebarWidth;
    _rightWidth = layout.rightSidebarWidth;
    _bottomHeight = layout.bottomPanelHeight;
  }

  void _persistLayout() {
    final ready = widget.ready;
    if (_layoutProjectId != ready.project.id) {
      return;
    }
    ref
        .read(studioControllerProvider.notifier)
        .updateEditorLayout(
          EditorLayout(
            leftSidebarWidth: _leftWidth,
            rightSidebarWidth: _rightWidth,
            bottomPanelHeight: _bottomHeight,
          ),
        );
  }
}

class _CanvasCursorLabel extends ConsumerWidget {
  const _CanvasCursorLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursor = ref.watch(canvasCursorProvider);
    final text = cursor == null
        ? 'x -, y -'
        : 'x ${cursor.dx.toStringAsFixed(0)}, y ${cursor.dy.toStringAsFixed(0)}';
    return Text(text, style: Theme.of(context).textTheme.labelMedium);
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.axis,
    required this.onDrag,
    required this.onDragEnd,
  });

  final Axis axis;
  final ValueChanged<double> onDrag;
  final VoidCallback onDragEnd;

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
        onPanEnd: (_) => onDragEnd(),
        onPanCancel: onDragEnd,
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
