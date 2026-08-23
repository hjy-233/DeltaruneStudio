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

  /// No description provided for @selectObject.
  ///
  /// In en, this message translates to:
  /// **'Select an object to edit its properties.'**
  String get selectObject;
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
