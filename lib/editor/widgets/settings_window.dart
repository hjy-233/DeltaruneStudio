import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showStudioSettingsWindow(
  BuildContext context, {
  required StudioReady ready,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: _SettingsWindow(ready: ready),
      ),
    ),
  );
}

class _SettingsWindow extends ConsumerWidget {
  const _SettingsWindow({required this.ready});

  final StudioReady ready;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(studioControllerProvider.notifier);
    final settings = ref.watch(
      studioControllerProvider.select(
        (state) => state.asReady?.project.settings ?? ready.project.settings,
      ),
    );

    void update(EditorSettings next) {
      controller.updateEditorSettings(next);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.settings,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<AppLanguage>(
            initialValue: settings.language,
            decoration: InputDecoration(labelText: l10n.language),
            items: [
              DropdownMenuItem(
                value: AppLanguage.system,
                child: Text(l10n.languageSystem),
              ),
              DropdownMenuItem(
                value: AppLanguage.english,
                child: Text(l10n.languageEnglish),
              ),
              DropdownMenuItem(
                value: AppLanguage.chinese,
                child: Text(l10n.languageChinese),
              ),
            ],
            onChanged: (language) {
              if (language == null) {
                return;
              }
              update(settings.copyWith(language: language));
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<AppThemeColor>(
            initialValue: settings.themeColor,
            decoration: InputDecoration(labelText: l10n.themeColor),
            items: [
              DropdownMenuItem(
                value: AppThemeColor.coral,
                child: Text(l10n.themeColorCoral),
              ),
              DropdownMenuItem(
                value: AppThemeColor.blue,
                child: Text(l10n.themeColorBlue),
              ),
              DropdownMenuItem(
                value: AppThemeColor.cyan,
                child: Text(l10n.themeColorCyan),
              ),
              DropdownMenuItem(
                value: AppThemeColor.green,
                child: Text(l10n.themeColorGreen),
              ),
              DropdownMenuItem(
                value: AppThemeColor.purple,
                child: Text(l10n.themeColorPurple),
              ),
              DropdownMenuItem(
                value: AppThemeColor.amber,
                child: Text(l10n.themeColorAmber),
              ),
            ],
            onChanged: (themeColor) {
              if (themeColor == null) {
                return;
              }
              update(settings.copyWith(themeColor: themeColor));
            },
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.autoSave),
            subtitle: Text(l10n.autoSaveHelp),
            value: settings.autoSaveEnabled,
            onChanged: (value) {
              update(settings.copyWith(autoSaveEnabled: value));
            },
          ),
          DropdownButtonFormField<int>(
            initialValue:
                const [
                  15,
                  30,
                  60,
                  300,
                ].contains(settings.autoSaveIntervalSeconds)
                ? settings.autoSaveIntervalSeconds
                : 60,
            decoration: InputDecoration(labelText: l10n.autoSaveInterval),
            items: [
              DropdownMenuItem(value: 15, child: Text(l10n.seconds(15))),
              DropdownMenuItem(value: 30, child: Text(l10n.seconds(30))),
              DropdownMenuItem(value: 60, child: Text(l10n.seconds(60))),
              DropdownMenuItem(value: 300, child: Text(l10n.seconds(300))),
            ],
            onChanged: settings.autoSaveEnabled
                ? (value) {
                    if (value != null) {
                      update(settings.copyWith(autoSaveIntervalSeconds: value));
                    }
                  }
                : null,
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.showCanvasGrid),
            value: settings.showCanvasGrid,
            onChanged: (value) =>
                update(settings.copyWith(showCanvasGrid: value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.snapToGrid),
            value: settings.snapToGrid,
            onChanged: (value) => update(settings.copyWith(snapToGrid: value)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.pixelRendering),
            subtitle: Text(l10n.pixelRenderingHelp),
            value: settings.pixelRendering,
            onChanged: (value) =>
                update(settings.copyWith(pixelRendering: value)),
          ),
          DropdownButtonFormField<CameraAspectRatio>(
            initialValue: settings.cameraAspectRatio,
            decoration: InputDecoration(labelText: l10n.cameraAspectRatio),
            items: [
              DropdownMenuItem(
                value: CameraAspectRatio.fourThree,
                child: Text(l10n.cameraAspectRatioFourThree),
              ),
              DropdownMenuItem(
                value: CameraAspectRatio.sixteenNine,
                child: Text(l10n.cameraAspectRatioSixteenNine),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                update(settings.copyWith(cameraAspectRatio: value));
              }
            },
          ),
          DropdownButtonFormField<int>(
            initialValue: const [24, 30, 60].contains(settings.exportFrameRate)
                ? settings.exportFrameRate
                : 30,
            decoration: InputDecoration(labelText: l10n.exportFrameRate),
            items: [
              DropdownMenuItem(value: 24, child: Text(l10n.fps(24))),
              DropdownMenuItem(value: 30, child: Text(l10n.fps(30))),
              DropdownMenuItem(value: 60, child: Text(l10n.fps(60))),
            ],
            onChanged: (value) {
              if (value != null) {
                update(settings.copyWith(exportFrameRate: value));
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.restoreLastProject),
            value: settings.restoreLastProject,
            onChanged: (value) =>
                update(settings.copyWith(restoreLastProject: value)),
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.englishDialogueTypewriterByWord),
            subtitle: Text(l10n.englishDialogueTypewriterByWordHelp),
            value: settings.englishDialogueTypewriterByWord,
            onChanged: (value) {
              update(settings.copyWith(englishDialogueTypewriterByWord: value));
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<CharacterLibraryScope>(
            initialValue: settings.characterLibraryScope,
            decoration: InputDecoration(labelText: l10n.characterLibraryScope),
            items: [
              DropdownMenuItem(
                value: CharacterLibraryScope.global,
                child: Text(l10n.characterLibraryGlobal),
              ),
              DropdownMenuItem(
                value: CharacterLibraryScope.project,
                child: Text(l10n.characterLibraryProject),
              ),
            ],
            onChanged: (scope) {
              if (scope == null) {
                return;
              }
              update(settings.copyWith(characterLibraryScope: scope));
            },
          ),
          const SizedBox(height: 4),
          Text(
            settings.characterLibraryScope == CharacterLibraryScope.global
                ? l10n.characterLibraryGlobalHelp
                : l10n.characterLibraryProjectHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
