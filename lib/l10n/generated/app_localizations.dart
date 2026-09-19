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
  /// **'New Project'**
  String get newProject;

  /// No description provided for @openProject.
  ///
  /// In en, this message translates to:
  /// **'Open Project'**
  String get openProject;

  /// No description provided for @saveProject.
  ///
  /// In en, this message translates to:
  /// **'Save Project'**
  String get saveProject;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project name'**
  String get projectName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noProject.
  ///
  /// In en, this message translates to:
  /// **'No project is open.'**
  String get noProject;

  /// No description provided for @projectCreated.
  ///
  /// In en, this message translates to:
  /// **'Created project at {path}'**
  String projectCreated(Object path);

  /// No description provided for @projectOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened project {name}'**
  String projectOpened(Object name);

  /// No description provided for @projectSaved.
  ///
  /// In en, this message translates to:
  /// **'Project saved.'**
  String get projectSaved;

  /// No description provided for @projectStructure.
  ///
  /// In en, this message translates to:
  /// **'Project structure'**
  String get projectStructure;

  /// No description provided for @buildAndRun.
  ///
  /// In en, this message translates to:
  /// **'Build and run in Godot'**
  String get buildAndRun;

  /// No description provided for @godotStarted.
  ///
  /// In en, this message translates to:
  /// **'Godot runtime started.'**
  String get godotStarted;

  /// No description provided for @newRoom.
  ///
  /// In en, this message translates to:
  /// **'New Room'**
  String get newRoom;

  /// No description provided for @roomCreated.
  ///
  /// In en, this message translates to:
  /// **'Created room {name}.'**
  String roomCreated(Object name);

  /// No description provided for @projectTab.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get projectTab;

  /// No description provided for @resourcesTab.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resourcesTab;

  /// No description provided for @charactersTab.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get charactersTab;

  /// No description provided for @roomsTab.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get roomsTab;

  /// No description provided for @projectPath.
  ///
  /// In en, this message translates to:
  /// **'Project path'**
  String get projectPath;

  /// No description provided for @sceneFolder.
  ///
  /// In en, this message translates to:
  /// **'Main room'**
  String get sceneFolder;

  /// No description provided for @resourceBrowserNextStep.
  ///
  /// In en, this message translates to:
  /// **'Resource browser will be connected here.'**
  String get resourceBrowserNextStep;

  /// No description provided for @noResources.
  ///
  /// In en, this message translates to:
  /// **'No resources in this category.'**
  String get noResources;

  /// No description provided for @searchResources.
  ///
  /// In en, this message translates to:
  /// **'Search resources'**
  String get searchResources;

  /// No description provided for @importResource.
  ///
  /// In en, this message translates to:
  /// **'Import resource'**
  String get importResource;

  /// No description provided for @selectResourceType.
  ///
  /// In en, this message translates to:
  /// **'Select resource type'**
  String get selectResourceType;

  /// No description provided for @resourceImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {name}.'**
  String resourceImported(Object name);

  /// No description provided for @backgroundResources.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get backgroundResources;

  /// No description provided for @characterResources.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get characterResources;

  /// No description provided for @portraitResources.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get portraitResources;

  /// No description provided for @propResources.
  ///
  /// In en, this message translates to:
  /// **'Prop'**
  String get propResources;

  /// No description provided for @audioResources.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioResources;

  /// No description provided for @videoResources.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoResources;

  /// No description provided for @selectObject.
  ///
  /// In en, this message translates to:
  /// **'Select an object to edit its properties.'**
  String get selectObject;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @importHere.
  ///
  /// In en, this message translates to:
  /// **'Import here'**
  String get importHere;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameFolder;

  /// No description provided for @renameResource.
  ///
  /// In en, this message translates to:
  /// **'Rename resource'**
  String get renameResource;

  /// No description provided for @renameRoom.
  ///
  /// In en, this message translates to:
  /// **'Rename room'**
  String get renameRoom;

  /// No description provided for @resourceRenamed.
  ///
  /// In en, this message translates to:
  /// **'Resource renamed.'**
  String get resourceRenamed;

  /// No description provided for @resourceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Resource deleted.'**
  String get resourceDeleted;

  /// No description provided for @folderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created.'**
  String get folderCreated;

  /// No description provided for @folderRenamed.
  ///
  /// In en, this message translates to:
  /// **'Folder renamed.'**
  String get folderRenamed;

  /// No description provided for @folderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted.'**
  String get folderDeleted;

  /// No description provided for @roomRenamed.
  ///
  /// In en, this message translates to:
  /// **'Room renamed.'**
  String get roomRenamed;

  /// No description provided for @roomDeleted.
  ///
  /// In en, this message translates to:
  /// **'Room deleted.'**
  String get roomDeleted;

  /// No description provided for @deleteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteQuestion(Object name);

  /// No description provided for @resourceProperties.
  ///
  /// In en, this message translates to:
  /// **'Resource properties'**
  String get resourceProperties;

  /// No description provided for @roomProperties.
  ///
  /// In en, this message translates to:
  /// **'Room properties'**
  String get roomProperties;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @objectCount.
  ///
  /// In en, this message translates to:
  /// **'Object count'**
  String get objectCount;

  /// No description provided for @newCharacter.
  ///
  /// In en, this message translates to:
  /// **'New character'**
  String get newCharacter;

  /// No description provided for @noCharacters.
  ///
  /// In en, this message translates to:
  /// **'No characters yet.'**
  String get noCharacters;

  /// No description provided for @characterCreated.
  ///
  /// In en, this message translates to:
  /// **'Created character {name}.'**
  String characterCreated(Object name);

  /// No description provided for @characterSaved.
  ///
  /// In en, this message translates to:
  /// **'Character saved.'**
  String get characterSaved;

  /// No description provided for @characterDeleted.
  ///
  /// In en, this message translates to:
  /// **'Character deleted.'**
  String get characterDeleted;

  /// No description provided for @characterProperties.
  ///
  /// In en, this message translates to:
  /// **'Character properties'**
  String get characterProperties;

  /// No description provided for @characterId.
  ///
  /// In en, this message translates to:
  /// **'Character ID'**
  String get characterId;

  /// No description provided for @defaultSize.
  ///
  /// In en, this message translates to:
  /// **'Default size'**
  String get defaultSize;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @moveSpeed.
  ///
  /// In en, this message translates to:
  /// **'Move speed'**
  String get moveSpeed;

  /// No description provided for @collisionBox.
  ///
  /// In en, this message translates to:
  /// **'Collision box'**
  String get collisionBox;

  /// No description provided for @animations.
  ///
  /// In en, this message translates to:
  /// **'Animations'**
  String get animations;

  /// No description provided for @addAnimation.
  ///
  /// In en, this message translates to:
  /// **'Add animation'**
  String get addAnimation;

  /// No description provided for @deleteAnimation.
  ///
  /// In en, this message translates to:
  /// **'Delete animation'**
  String get deleteAnimation;

  /// No description provided for @direction.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get direction;

  /// No description provided for @directionUp.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get directionUp;

  /// No description provided for @directionDown.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get directionDown;

  /// No description provided for @directionLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get directionLeft;

  /// No description provided for @directionRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get directionRight;

  /// No description provided for @framesPerSecond.
  ///
  /// In en, this message translates to:
  /// **'Frames per second'**
  String get framesPerSecond;

  /// No description provided for @loop.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get loop;

  /// No description provided for @addFrame.
  ///
  /// In en, this message translates to:
  /// **'Add frame'**
  String get addFrame;

  /// No description provided for @characterDefinition.
  ///
  /// In en, this message translates to:
  /// **'Character definition'**
  String get characterDefinition;

  /// No description provided for @characterDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Character'**
  String get characterDefaultName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;
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
