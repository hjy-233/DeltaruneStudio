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
  String get runtimeConsole => 'Runtime console';

  @override
  String runtimeExited(int code) {
    return 'Runtime exited with code $code.';
  }

  @override
  String get clear => 'Clear';

  @override
  String get stopRuntime => 'Stop runtime';

  @override
  String get exportGame => 'Export game';

  @override
  String get exportTarget => 'Export target';

  @override
  String get exportMacOS => 'macOS (.zip)';

  @override
  String get exportWindows => 'Windows (.exe)';

  @override
  String get exportLinux => 'Linux (.x86_64)';

  @override
  String exportCompleted(String path) {
    return 'Exported game to $path';
  }

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
  String get portraitResources => 'Portrait';

  @override
  String get propResources => 'Prop';

  @override
  String get audioResources => 'Audio';

  @override
  String get videoResources => 'Video';

  @override
  String get selectObject => 'Select an object to edit its properties.';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get newFolder => 'New folder';

  @override
  String get importHere => 'Import here';

  @override
  String get renameFolder => 'Rename folder';

  @override
  String get renameResource => 'Rename resource';

  @override
  String get renameRoom => 'Rename room';

  @override
  String get resourceRenamed => 'Resource renamed.';

  @override
  String get resourceDeleted => 'Resource deleted.';

  @override
  String get folderCreated => 'Folder created.';

  @override
  String get folderRenamed => 'Folder renamed.';

  @override
  String get folderDeleted => 'Folder deleted.';

  @override
  String get roomRenamed => 'Room renamed.';

  @override
  String get roomDeleted => 'Room deleted.';

  @override
  String deleteQuestion(Object name) {
    return 'Delete $name?';
  }

  @override
  String get resourceProperties => 'Resource properties';

  @override
  String get roomProperties => 'Room properties';

  @override
  String get name => 'Name';

  @override
  String get type => 'Type';

  @override
  String get path => 'Path';

  @override
  String get none => 'None';

  @override
  String get objectCount => 'Object count';

  @override
  String get newCharacter => 'New character';

  @override
  String get noCharacters => 'No characters yet.';

  @override
  String characterCreated(Object name) {
    return 'Created character $name.';
  }

  @override
  String get characterSaved => 'Character saved.';

  @override
  String get characterDeleted => 'Character deleted.';

  @override
  String get characterProperties => 'Character properties';

  @override
  String get characterId => 'Character ID';

  @override
  String get defaultSize => 'Default size';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get moveSpeed => 'Move speed';

  @override
  String get collisionBox => 'Collision box';

  @override
  String get animations => 'Animations';

  @override
  String get animationPreview => 'Animation preview';

  @override
  String get playPreview => 'Play preview';

  @override
  String get pausePreview => 'Pause preview';

  @override
  String get addAnimation => 'Add animation';

  @override
  String get deleteAnimation => 'Delete animation';

  @override
  String get direction => 'Direction';

  @override
  String get directionUp => 'Up';

  @override
  String get directionDown => 'Down';

  @override
  String get directionLeft => 'Left';

  @override
  String get directionRight => 'Right';

  @override
  String get framesPerSecond => 'Frames per second';

  @override
  String get loop => 'Loop';

  @override
  String get addFrame => 'Add frame';

  @override
  String get characterDefinition => 'Character definition';

  @override
  String get characterDefaultName => 'Character';

  @override
  String get addBackground => 'Add background';

  @override
  String get addCharacter => 'Add character';

  @override
  String get addProp => 'Add prop';

  @override
  String get addCollision => 'Add collision';

  @override
  String get addSpawn => 'Add spawn point';

  @override
  String get addDoor => 'Add door';

  @override
  String get addSavePoint => 'Add save point';

  @override
  String get layers => 'Layers';

  @override
  String get newLayer => 'New layer';

  @override
  String get layer => 'Layer';

  @override
  String get visible => 'Visible';

  @override
  String get locked => 'Locked';

  @override
  String get collisionRegion => 'Collision region';

  @override
  String get spawnPoint => 'Spawn point';

  @override
  String get doorConnection => 'Door connection';

  @override
  String get savePoint => 'Save point';

  @override
  String get saveSlot => 'Save slot';

  @override
  String get transitionColor => 'Transition color';

  @override
  String get fadeOutSeconds => 'Fade-out seconds';

  @override
  String get fadeInSeconds => 'Fade-in seconds';

  @override
  String get targetRoom => 'Target room';

  @override
  String get targetSpawn => 'Target spawn point';

  @override
  String get defaultSpawn => 'Default spawn point';

  @override
  String get spawnFacing => 'Spawn facing';

  @override
  String get noSpawnPoints => 'No spawn points in this room';

  @override
  String get resource => 'Resource';

  @override
  String get assetPath => 'Asset path';

  @override
  String get order => 'Order';

  @override
  String get entryScript => 'Entry script';

  @override
  String get ok => 'OK';
}
