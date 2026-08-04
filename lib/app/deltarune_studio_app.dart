import 'package:deltarune_studio/editor/studio_workspace.dart';
import 'package:flutter/material.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';

class DeltaruneStudioApp extends StatelessWidget {
  const DeltaruneStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deltarune Studio',
      debugShowCheckedModeBanner: false,
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
