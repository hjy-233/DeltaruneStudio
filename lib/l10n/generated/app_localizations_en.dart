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
  String get newProject => 'New';

  @override
  String get open => 'Open';

  @override
  String get save => 'Save';

  @override
  String get saveDirty => 'Save *';

  @override
  String get saveAs => 'Save As';

  @override
  String get room => 'Room';

  @override
  String get importBackgroundShort => 'Import BG';

  @override
  String get audio => 'Audio';

  @override
  String get actor => 'Actor';

  @override
  String get doorTrigger => 'Door Trigger';

  @override
  String get mainCanvas => 'Main Canvas';

  @override
  String get play => 'Play';

  @override
  String get stop => 'Stop';

  @override
  String get timelineFit => 'Fit All';

  @override
  String get timelineZoom => 'Timeline zoom';

  @override
  String get timelineTrackHeight => 'Track height';

  @override
  String get timelineTriggerAlways => 'Always';

  @override
  String get timelineTriggerPoint => 'Trigger point';

  @override
  String get timelineTriggerScheduled => 'Scheduled';

  @override
  String get pause => 'Pause';

  @override
  String get settings => 'Settings';

  @override
  String get close => 'Close';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get saveBeforeExit => 'Save the current project before exiting?';

  @override
  String get discard => 'Discard';

  @override
  String get cancel => 'Cancel';

  @override
  String get exportScale => 'Export scale';

  @override
  String get exportResolution => 'Output resolution';

  @override
  String get exportVideo => 'Export video';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get themeColor => 'Theme color';

  @override
  String get themeColorCoral => 'Coral';

  @override
  String get themeColorBlue => 'Blue';

  @override
  String get themeColorCyan => 'Cyan';

  @override
  String get themeColorGreen => 'Green';

  @override
  String get themeColorPurple => 'Purple';

  @override
  String get themeColorAmber => 'Amber';

  @override
  String get autoSave => 'Auto-save';

  @override
  String get autoSaveHelp =>
      'Only saved project locations are written automatically.';

  @override
  String get autoSaveInterval => 'Auto-save interval';

  @override
  String seconds(Object count) {
    return '$count seconds';
  }

  @override
  String get showCanvasGrid => 'Show canvas grid';

  @override
  String get snapToGrid => 'Snap objects to grid';

  @override
  String get pixelRendering => 'Pixel rendering';

  @override
  String get pixelRenderingHelp =>
      'Use nearest-neighbor scaling for pixel art.';

  @override
  String get cameraAspectRatio => 'Camera aspect ratio';

  @override
  String get cameraAspectRatioFourThree => '4:3';

  @override
  String get cameraAspectRatioSixteenNine => '16:9';

  @override
  String get exportFrameRate => 'Export frame rate';

  @override
  String fps(Object count) {
    return '$count FPS';
  }

  @override
  String get restoreLastProject => 'Restore last project on startup';

  @override
  String get englishDialogueTypewriterByWord =>
      'English dialogue appears by word';

  @override
  String get englishDialogueTypewriterByWordHelp =>
      'When the app language is English and the dialogue text is English, the typewriter reveal advances one word at a time.';

  @override
  String get characterLibraryScope => 'Character library scope';

  @override
  String get characterLibraryGlobal => 'Global character library';

  @override
  String get characterLibraryGlobalHelp =>
      'Character definitions are saved in the app-wide library and available to every project.';

  @override
  String get characterLibraryProject => 'Current project';

  @override
  String get characterLibraryProjectHelp =>
      'Character definitions are saved only in the current .drs project.';

  @override
  String get canvasObjects => 'Canvas Objects';

  @override
  String get trigger => 'Trigger';

  @override
  String get import => 'Import';

  @override
  String get prop => 'Prop';

  @override
  String get assets => 'Assets';

  @override
  String get builtInAssets => 'Built-in Assets';

  @override
  String get searchBuiltIns => 'Search built-ins';

  @override
  String builtInAssetsCount(int shown, int total) {
    return '$shown / $total shown';
  }

  @override
  String get addBuiltInAsset => 'Add built-in asset';

  @override
  String get importAsset => 'Import asset';

  @override
  String get importBackground => 'Import Background';

  @override
  String get importProp => 'Import Prop';

  @override
  String get importCharacterAsset => 'Import Character Asset';

  @override
  String get importAudio => 'Import Audio';

  @override
  String get noImportedAssets => 'No imported assets';

  @override
  String get characters => 'Characters';

  @override
  String expressionsCount(int count) {
    return '$count expressions';
  }

  @override
  String get character => 'Character';

  @override
  String get background => 'Background';

  @override
  String get triggerPoint => 'Trigger Point';

  @override
  String get missing => 'Missing';

  @override
  String get eventChains => 'Event Chains';

  @override
  String get addEventChain => 'Add event chain';

  @override
  String eventsCount(int count) {
    return '$count events';
  }

  @override
  String get createOrSelectChain => 'Create or select a chain.';

  @override
  String get addEvent => 'Add Event';

  @override
  String get addNode => 'Add Node';

  @override
  String get characterMove => 'Character Move';

  @override
  String get wait => 'Wait';

  @override
  String get changeExpression => 'Change Expression';

  @override
  String get dialogue => 'Dialogue';

  @override
  String get fadeOut => 'Fade Out';

  @override
  String get cameraFollow => 'Camera Follow';

  @override
  String get cameraFocus => 'Camera Focus';

  @override
  String get playSound => 'Play Sound';

  @override
  String get playBgm => 'Play BGM';

  @override
  String get playVideo => 'Play Video';

  @override
  String get triggerModeScheduled => 'Scheduled';

  @override
  String get startTime => 'Start time';

  @override
  String get startFollow => 'Start Follow';

  @override
  String get stopFollow => 'Stop Follow';

  @override
  String get expression => 'Expression';

  @override
  String get fade => 'Fade';

  @override
  String get canvasJump => 'Canvas Jump';

  @override
  String get noAssetSelected => 'No asset selected';

  @override
  String get noEvent => 'No event';

  @override
  String get noActiveEvent => 'No active event';

  @override
  String get scratchProject => 'Scratch project';

  @override
  String get inspector => 'Inspector';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addRoom => 'Add Room';

  @override
  String get addActor => 'Add Actor';

  @override
  String get addDoorTrigger => 'Add Door Trigger';

  @override
  String get createEventChain => 'Create Event Chain';

  @override
  String get addMoveEvent => 'Add Move Event';

  @override
  String get selectSomething =>
      'Select a canvas object, path node, event, asset, or character.';

  @override
  String get missingObject => 'Missing object.';

  @override
  String get missingTrigger => 'Missing trigger.';

  @override
  String get missingEventChain => 'Missing event chain.';

  @override
  String get missingEvent => 'Missing event.';

  @override
  String get missingPathNode => 'Missing path node.';

  @override
  String get missingAsset => 'Missing asset.';

  @override
  String get missingCharacter => 'Missing character.';

  @override
  String get characterInstance => 'Character Instance';

  @override
  String get propObject => 'Prop Object';

  @override
  String get backgroundObject => 'Background Object';

  @override
  String get name => 'Name';

  @override
  String get facing => 'Facing';

  @override
  String get initialExpression => 'Initial expression';

  @override
  String get visual => 'Visual';

  @override
  String get builtInRoom => 'Built-in room';

  @override
  String get builtIn => 'Built-in';

  @override
  String get locked => 'Locked';

  @override
  String get interactable => 'Interactable';

  @override
  String get advancedPosition => 'Advanced Position';

  @override
  String get back => 'Back';

  @override
  String get front => 'Front';

  @override
  String get bottom => 'Bottom';

  @override
  String get top => 'Top';

  @override
  String get delete => 'Delete';

  @override
  String get eventChain => 'Event Chain';

  @override
  String get triggerMode => 'Trigger Mode';

  @override
  String get triggerModeTriggerPoint => 'Trigger Point';

  @override
  String get triggerModeAlways => 'Always';

  @override
  String get linkedDoor => 'Linked Door';

  @override
  String get triggerPointHelp =>
      'Path nodes can link directly to this trigger. When the actor reaches the node, this chain runs.';

  @override
  String get pathNode => 'Path Node';

  @override
  String get speed => 'Speed';

  @override
  String get shake => 'Shake';

  @override
  String get addPathNode => 'Add Path Node';

  @override
  String get movementMode => 'Movement mode';

  @override
  String get movementModeFourWay => 'Four-way';

  @override
  String get movementModeEightWay => 'Eight-way';

  @override
  String get movementModeFree => 'Free movement';

  @override
  String get duration => 'Duration';

  @override
  String get speaker => 'Speaker';

  @override
  String get text => 'Text';

  @override
  String get portrait => 'Portrait';

  @override
  String get dialogueStyle => 'Dialogue Style';

  @override
  String get dialogueStyleRegular => 'Classic White';

  @override
  String get dialogueStyleDarkWorld => 'Dark World';

  @override
  String get target => 'Target';

  @override
  String get mode => 'Mode';

  @override
  String get canvasMarker => 'Canvas marker';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String get waitSeconds => 'Wait seconds';

  @override
  String get linkedTrigger => 'Linked Trigger';

  @override
  String get none => 'None';

  @override
  String get deleteNode => 'Delete Node';

  @override
  String get asset => 'Asset';

  @override
  String get missingFile => 'Missing file';

  @override
  String get kind => 'Kind';

  @override
  String get path => 'Path';

  @override
  String get assetInUse => 'Asset In Use';

  @override
  String get deleteAsset => 'Delete Asset';

  @override
  String get characterDefinition => 'Character Definition';

  @override
  String get defaultSpeed => 'Default speed';

  @override
  String get defaultShake => 'Default shake';

  @override
  String get expressions => 'Expressions';

  @override
  String get addExpression => 'Add Expression';

  @override
  String get pointX => 'Point X';

  @override
  String get pointY => 'Point Y';

  @override
  String get width => 'W';

  @override
  String get height => 'H';

  @override
  String get scale => 'Scale';

  @override
  String zoomPercent(int percent) {
    return 'Zoom $percent%';
  }

  @override
  String get triggerLinkLabel => '-> trigger';

  @override
  String moveDescription(int count, double speed, double shake) {
    return '$count nodes, speed $speed, shake $shake';
  }

  @override
  String nodeCoordinates(String x, String y) {
    return 'x $x, y $y';
  }
}
