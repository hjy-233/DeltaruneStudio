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

  @override
  String get buildAndRun => 'Build and run in Godot';

  @override
  String get godotStarted => 'Godot runtime started.';

  @override
  String get newRoom => 'New Room';

  @override
  String roomCreated(Object name) {
    return 'Created room $name.';
  }

  @override
  String get projectTab => 'Project';

  @override
  String get resourcesTab => 'Resources';

  @override
  String get charactersTab => 'Characters';

  @override
  String get roomsTab => 'Rooms';

  @override
  String get projectPath => 'Project path';

  @override
  String get sceneFolder => 'Main room';

  @override
  String get resourceBrowserNextStep =>
      'Resource browser will be connected here.';

  @override
  String get noResources => 'No resources in this category.';

  @override
  String get searchResources => 'Search resources';

  @override
  String get importResource => 'Import resource';

  @override
  String get selectResourceType => 'Select resource type';

  @override
  String resourceImported(Object name) {
    return 'Imported $name.';
  }

  @override
  String get backgroundResources => 'Background';

  @override
  String get characterResources => 'Character';

  @override
  String get propResources => 'Prop';

  @override
  String get audioResources => 'Audio';

  @override
  String get videoResources => 'Video';

  @override
  String get selectObject => 'Select an object to edit its properties.';
}
