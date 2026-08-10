import 'package:deltarune_studio/editor/studio_workspace.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:flutter/material.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeltaruneStudioApp extends ConsumerWidget {
  const DeltaruneStudioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
