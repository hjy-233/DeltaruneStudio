// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Deltarune Studio';

  @override
  String get newProject => 'New Project';

  @override
  String get openProject => 'Open Project';

  @override
  String get saveProject => 'Save Project';

  @override
  String get projectName => 'Project name';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get noProject => 'No project is open.';

  @override
  String projectCreated(Object path) {
    return 'Created project at $path';
  }

  @override
  String projectOpened(Object name) {
    return 'Opened project $name';
  }

  @override
  String get projectSaved => 'Project saved.';

  @override
  String get projectStructure => 'Project structure';
}
