import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Deltarune Studio'**
  String get appTitle;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newProject;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveDirty.
  ///
  /// In en, this message translates to:
  /// **'Save *'**
  String get saveDirty;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save As'**
  String get saveAs;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @importBackgroundShort.
  ///
  /// In en, this message translates to:
  /// **'Import BG'**
  String get importBackgroundShort;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @actor.
  ///
  /// In en, this message translates to:
  /// **'Actor'**
  String get actor;

  /// No description provided for @doorTrigger.
  ///
  /// In en, this message translates to:
  /// **'Door Trigger'**
  String get doorTrigger;

  /// No description provided for @mainCanvas.
  ///
  /// In en, this message translates to:
  /// **'Main Canvas'**
  String get mainCanvas;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @englishDialogueTypewriterByWord.
  ///
  /// In en, this message translates to:
  /// **'English dialogue appears by word'**
  String get englishDialogueTypewriterByWord;

  /// No description provided for @englishDialogueTypewriterByWordHelp.
  ///
  /// In en, this message translates to:
  /// **'When the app language is English and the dialogue text is English, the typewriter reveal advances one word at a time.'**
  String get englishDialogueTypewriterByWordHelp;

  /// No description provided for @canvasObjects.
  ///
  /// In en, this message translates to:
  /// **'Canvas Objects'**
  String get canvasObjects;

  /// No description provided for @trigger.
  ///
  /// In en, this message translates to:
  /// **'Trigger'**
  String get trigger;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @prop.
  ///
  /// In en, this message translates to:
  /// **'Prop'**
  String get prop;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @builtInAssets.
  ///
  /// In en, this message translates to:
  /// **'Built-in Assets'**
  String get builtInAssets;

  /// No description provided for @searchBuiltIns.
  ///
  /// In en, this message translates to:
  /// **'Search built-ins'**
  String get searchBuiltIns;

  /// No description provided for @builtInAssetsCount.
  ///
  /// In en, this message translates to:
  /// **'{shown} / {total} shown'**
  String builtInAssetsCount(int shown, int total);

  /// No description provided for @addBuiltInAsset.
  ///
  /// In en, this message translates to:
  /// **'Add built-in asset'**
  String get addBuiltInAsset;

  /// No description provided for @importAsset.
  ///
  /// In en, this message translates to:
  /// **'Import asset'**
  String get importAsset;

  /// No description provided for @importBackground.
  ///
  /// In en, this message translates to:
  /// **'Import Background'**
  String get importBackground;

  /// No description provided for @importProp.
  ///
  /// In en, this message translates to:
  /// **'Import Prop'**
  String get importProp;

  /// No description provided for @importCharacterAsset.
  ///
  /// In en, this message translates to:
  /// **'Import Character Asset'**
  String get importCharacterAsset;

  /// No description provided for @importAudio.
  ///
  /// In en, this message translates to:
  /// **'Import Audio'**
  String get importAudio;

  /// No description provided for @noImportedAssets.
  ///
  /// In en, this message translates to:
  /// **'No imported assets'**
  String get noImportedAssets;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get characters;

  /// No description provided for @expressionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} expressions'**
  String expressionsCount(int count);

  /// No description provided for @character.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get character;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @triggerPoint.
  ///
  /// In en, this message translates to:
  /// **'Trigger Point'**
  String get triggerPoint;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// No description provided for @eventChains.
  ///
  /// In en, this message translates to:
  /// **'Event Chains'**
  String get eventChains;

  /// No description provided for @addEventChain.
  ///
  /// In en, this message translates to:
  /// **'Add event chain'**
  String get addEventChain;

  /// No description provided for @eventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} events'**
  String eventsCount(int count);

  /// No description provided for @createOrSelectChain.
  ///
  /// In en, this message translates to:
  /// **'Create or select a chain.'**
  String get createOrSelectChain;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @addNode.
  ///
  /// In en, this message translates to:
  /// **'Add Node'**
  String get addNode;

  /// No description provided for @characterMove.
  ///
  /// In en, this message translates to:
  /// **'Character Move'**
  String get characterMove;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get wait;

  /// No description provided for @changeExpression.
  ///
  /// In en, this message translates to:
  /// **'Change Expression'**
  String get changeExpression;

  /// No description provided for @dialogue.
  ///
  /// In en, this message translates to:
  /// **'Dialogue'**
  String get dialogue;

  /// No description provided for @fadeOut.
  ///
  /// In en, this message translates to:
  /// **'Fade Out'**
  String get fadeOut;

  /// No description provided for @cameraFollow.
  ///
  /// In en, this message translates to:
  /// **'Camera Follow'**
  String get cameraFollow;

  /// No description provided for @cameraFocus.
  ///
  /// In en, this message translates to:
  /// **'Camera Focus'**
  String get cameraFocus;

  /// No description provided for @playSound.
  ///
  /// In en, this message translates to:
  /// **'Play Sound'**
  String get playSound;

  /// No description provided for @playBgm.
  ///
  /// In en, this message translates to:
  /// **'Play BGM'**
  String get playBgm;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play Video'**
  String get playVideo;

  /// No description provided for @startFollow.
  ///
  /// In en, this message translates to:
  /// **'Start Follow'**
  String get startFollow;

  /// No description provided for @stopFollow.
  ///
  /// In en, this message translates to:
  /// **'Stop Follow'**
  String get stopFollow;

  /// No description provided for @expression.
  ///
  /// In en, this message translates to:
  /// **'Expression'**
  String get expression;

  /// No description provided for @fade.
  ///
  /// In en, this message translates to:
  /// **'Fade'**
  String get fade;

  /// No description provided for @canvasJump.
  ///
  /// In en, this message translates to:
  /// **'Canvas Jump'**
  String get canvasJump;

  /// No description provided for @noAssetSelected.
  ///
  /// In en, this message translates to:
  /// **'No asset selected'**
  String get noAssetSelected;

  /// No description provided for @noEvent.
  ///
  /// In en, this message translates to:
  /// **'No event'**
  String get noEvent;

  /// No description provided for @noActiveEvent.
  ///
  /// In en, this message translates to:
  /// **'No active event'**
  String get noActiveEvent;

  /// No description provided for @scratchProject.
  ///
  /// In en, this message translates to:
  /// **'Scratch project'**
  String get scratchProject;

  /// No description provided for @inspector.
  ///
  /// In en, this message translates to:
  /// **'Inspector'**
  String get inspector;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoom;

  /// No description provided for @addActor.
  ///
  /// In en, this message translates to:
  /// **'Add Actor'**
  String get addActor;

  /// No description provided for @addDoorTrigger.
  ///
  /// In en, this message translates to:
  /// **'Add Door Trigger'**
  String get addDoorTrigger;

  /// No description provided for @createEventChain.
  ///
  /// In en, this message translates to:
  /// **'Create Event Chain'**
  String get createEventChain;

  /// No description provided for @addMoveEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Move Event'**
  String get addMoveEvent;

  /// No description provided for @selectSomething.
  ///
  /// In en, this message translates to:
  /// **'Select a canvas object, path node, event, asset, or character.'**
  String get selectSomething;

  /// No description provided for @missingObject.
  ///
  /// In en, this message translates to:
  /// **'Missing object.'**
  String get missingObject;

  /// No description provided for @missingTrigger.
  ///
  /// In en, this message translates to:
  /// **'Missing trigger.'**
  String get missingTrigger;

  /// No description provided for @missingEventChain.
  ///
  /// In en, this message translates to:
  /// **'Missing event chain.'**
  String get missingEventChain;

  /// No description provided for @missingEvent.
  ///
  /// In en, this message translates to:
  /// **'Missing event.'**
  String get missingEvent;

  /// No description provided for @missingPathNode.
  ///
  /// In en, this message translates to:
  /// **'Missing path node.'**
  String get missingPathNode;

  /// No description provided for @missingAsset.
  ///
  /// In en, this message translates to:
  /// **'Missing asset.'**
  String get missingAsset;

  /// No description provided for @missingCharacter.
  ///
  /// In en, this message translates to:
  /// **'Missing character.'**
  String get missingCharacter;

  /// No description provided for @characterInstance.
  ///
  /// In en, this message translates to:
  /// **'Character Instance'**
  String get characterInstance;

  /// No description provided for @propObject.
  ///
  /// In en, this message translates to:
  /// **'Prop Object'**
  String get propObject;

  /// No description provided for @backgroundObject.
  ///
  /// In en, this message translates to:
  /// **'Background Object'**
  String get backgroundObject;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @facing.
  ///
  /// In en, this message translates to:
  /// **'Facing'**
  String get facing;

  /// No description provided for @initialExpression.
  ///
  /// In en, this message translates to:
  /// **'Initial expression'**
  String get initialExpression;

  /// No description provided for @visual.
  ///
  /// In en, this message translates to:
  /// **'Visual'**
  String get visual;

  /// No description provided for @builtInRoom.
  ///
  /// In en, this message translates to:
  /// **'Built-in room'**
  String get builtInRoom;

  /// No description provided for @builtIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtIn;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @interactable.
  ///
  /// In en, this message translates to:
  /// **'Interactable'**
  String get interactable;

  /// No description provided for @advancedPosition.
  ///
  /// In en, this message translates to:
  /// **'Advanced Position'**
  String get advancedPosition;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @bottom.
  ///
  /// In en, this message translates to:
  /// **'Bottom'**
  String get bottom;

  /// No description provided for @top.
  ///
  /// In en, this message translates to:
  /// **'Top'**
  String get top;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @eventChain.
  ///
  /// In en, this message translates to:
  /// **'Event Chain'**
  String get eventChain;

  /// No description provided for @triggerMode.
  ///
  /// In en, this message translates to:
  /// **'Trigger Mode'**
  String get triggerMode;

  /// No description provided for @triggerModeTriggerPoint.
  ///
  /// In en, this message translates to:
  /// **'Trigger Point'**
  String get triggerModeTriggerPoint;

  /// No description provided for @triggerModeAlways.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get triggerModeAlways;

  /// No description provided for @linkedDoor.
  ///
  /// In en, this message translates to:
  /// **'Linked Door'**
  String get linkedDoor;

  /// No description provided for @triggerPointHelp.
  ///
  /// In en, this message translates to:
  /// **'Path nodes can link directly to this trigger. When the actor reaches the node, this chain runs.'**
  String get triggerPointHelp;

  /// No description provided for @pathNode.
  ///
  /// In en, this message translates to:
  /// **'Path Node'**
  String get pathNode;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @shake.
  ///
  /// In en, this message translates to:
  /// **'Shake'**
  String get shake;

  /// No description provided for @addPathNode.
  ///
  /// In en, this message translates to:
  /// **'Add Path Node'**
  String get addPathNode;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @portrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get portrait;

  /// No description provided for @dialogueStyle.
  ///
  /// In en, this message translates to:
  /// **'Dialogue Style'**
  String get dialogueStyle;

  /// No description provided for @dialogueStyleRegular.
  ///
  /// In en, this message translates to:
  /// **'Classic White'**
  String get dialogueStyleRegular;

  /// No description provided for @dialogueStyleDarkWorld.
  ///
  /// In en, this message translates to:
  /// **'Dark World'**
  String get dialogueStyleDarkWorld;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @canvasMarker.
  ///
  /// In en, this message translates to:
  /// **'Canvas marker'**
  String get canvasMarker;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @waitSeconds.
  ///
  /// In en, this message translates to:
  /// **'Wait seconds'**
  String get waitSeconds;

  /// No description provided for @linkedTrigger.
  ///
  /// In en, this message translates to:
  /// **'Linked Trigger'**
  String get linkedTrigger;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @deleteNode.
  ///
  /// In en, this message translates to:
  /// **'Delete Node'**
  String get deleteNode;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @missingFile.
  ///
  /// In en, this message translates to:
  /// **'Missing file'**
  String get missingFile;

  /// No description provided for @kind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get kind;

  /// No description provided for @path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @assetInUse.
  ///
  /// In en, this message translates to:
  /// **'Asset In Use'**
  String get assetInUse;

  /// No description provided for @deleteAsset.
  ///
  /// In en, this message translates to:
  /// **'Delete Asset'**
  String get deleteAsset;

  /// No description provided for @characterDefinition.
  ///
  /// In en, this message translates to:
  /// **'Character Definition'**
  String get characterDefinition;

  /// No description provided for @defaultSpeed.
  ///
  /// In en, this message translates to:
  /// **'Default speed'**
  String get defaultSpeed;

  /// No description provided for @defaultShake.
  ///
  /// In en, this message translates to:
  /// **'Default shake'**
  String get defaultShake;

  /// No description provided for @expressions.
  ///
  /// In en, this message translates to:
  /// **'Expressions'**
  String get expressions;

  /// No description provided for @addExpression.
  ///
  /// In en, this message translates to:
  /// **'Add Expression'**
  String get addExpression;

  /// No description provided for @pointX.
  ///
  /// In en, this message translates to:
  /// **'Point X'**
  String get pointX;

  /// No description provided for @pointY.
  ///
  /// In en, this message translates to:
  /// **'Point Y'**
  String get pointY;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get height;

  /// No description provided for @scale.
  ///
  /// In en, this message translates to:
  /// **'Scale'**
  String get scale;

  /// No description provided for @zoomPercent.
  ///
  /// In en, this message translates to:
  /// **'Zoom {percent}%'**
  String zoomPercent(int percent);

  /// No description provided for @triggerLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'-> trigger'**
  String get triggerLinkLabel;

  /// No description provided for @moveDescription.
  ///
  /// In en, this message translates to:
  /// **'{count} nodes, speed {speed}, shake {shake}'**
  String moveDescription(int count, double speed, double shake);

  /// No description provided for @nodeCoordinates.
  ///
  /// In en, this message translates to:
  /// **'x {x}, y {y}'**
  String nodeCoordinates(String x, String y);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
