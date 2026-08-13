import 'package:deltarune_studio/editor/studio_workspace.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:flutter/material.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

class DeltaruneStudioApp extends ConsumerStatefulWidget {
  const DeltaruneStudioApp({super.key});

  @override
  ConsumerState<DeltaruneStudioApp> createState() => _DeltaruneStudioAppState();
}

class _DeltaruneStudioAppState extends ConsumerState<DeltaruneStudioApp>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      windowManager.addListener(this);
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {
    if (kIsWeb) return;
    final state = ref.read(studioControllerProvider);
    if (state.asReady?.isDirty != true) {
      await windowManager.destroy();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final choice = await showDialog<_ExitChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.saveBeforeExit),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _ExitChoice.cancel),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ExitChoice.discard),
            child: Text(l10n.discard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _ExitChoice.save),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    switch (choice) {
      case _ExitChoice.save:
        await ref.read(studioControllerProvider.notifier).saveProject();
        if (ref.read(studioControllerProvider).asReady?.isDirty != true) {
          await windowManager.destroy();
        }
      case _ExitChoice.discard:
        await windowManager.destroy();
      case _ExitChoice.cancel:
      case null:
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(
      studioControllerProvider.select((state) {
        return state.asReady?.project.settings.language ?? AppLanguage.system;
      }),
    );
    return MaterialApp(
      title: 'Deltarune Studio',
      debugShowCheckedModeBanner: false,
      locale: switch (language) {
        AppLanguage.system => null,
        AppLanguage.english => const Locale('en'),
        AppLanguage.chinese => const Locale('zh'),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffe24d3d),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.compact,
      ),
      home: const StudioWorkspace(),
    );
  }
}

enum _ExitChoice { save, discard, cancel }
