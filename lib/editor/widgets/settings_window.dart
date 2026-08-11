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
    final settings = ready.project.settings;

    void update(EditorSettings next) {
      controller.updateEditorSettings(next);
    }

    return Padding(
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
