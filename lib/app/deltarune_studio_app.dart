import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_shell.dart';
import 'package:flutter/material.dart';

class DeltaruneStudioApp extends StatelessWidget {
  const DeltaruneStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.dark(useMaterial3: true),
      home: const ProjectShell(),
    );
  }
}
