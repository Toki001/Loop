import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice with intention.\nSee your progress.'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A quiet place for your skills, the work you make, and what you want to try next.'**
  String get welcomeBody;

  /// No description provided for @privateTitle.
  ///
  /// In en, this message translates to:
  /// **'Your practice, on your device'**
  String get privateTitle;

  /// No description provided for @privateBody.
  ///
  /// In en, this message translates to:
  /// **'No account. No feed. Start with a note; add photos or audio when they help.'**
  String get privateBody;

  /// No description provided for @chooseSkill.
  ///
  /// In en, this message translates to:
  /// **'Choose a skill'**
  String get chooseSkill;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your practice starts here'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Choose a skill to give your next practice a starting point.'**
  String get todayEmptyBody;

  /// No description provided for @skillsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Make room for what you want to learn'**
  String get skillsEmptyTitle;

  /// No description provided for @skillsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'There are no skills on this device yet. Your saved skills and history will appear here.'**
  String get skillsEmptyBody;

  /// No description provided for @practiceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a skill'**
  String get practiceEmptyTitle;

  /// No description provided for @practiceEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to work on before starting a session.'**
  String get practiceEmptyBody;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress begins with a practice record'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Your history and comparable measurements will appear here. Time records effort; evidence shows what changed.'**
  String get progressEmptyBody;

  /// No description provided for @libraryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the work you can come back to'**
  String get libraryEmptyTitle;

  /// No description provided for @libraryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Photos and audio you choose to attach will appear here. A recording is never required to practice.'**
  String get libraryEmptyBody;

  /// No description provided for @seeSkills.
  ///
  /// In en, this message translates to:
  /// **'See skills'**
  String get seeSkills;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceBody.
  ///
  /// In en, this message translates to:
  /// **'Choose how Loop looks. This preference is saved on this device.'**
  String get appearanceBody;

  /// No description provided for @systemAppearance.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get systemAppearance;

  /// No description provided for @lightAppearance.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightAppearance;

  /// No description provided for @darkAppearance.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkAppearance;

  /// No description provided for @savingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Saving your choice…'**
  String get savingPreferences;

  /// No description provided for @preferencesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Your choice could not be saved. Your previous preference is unchanged.'**
  String get preferencesSaveFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses and acknowledgments'**
  String get licenses;

  /// No description provided for @aboutLoop.
  ///
  /// In en, this message translates to:
  /// **'About Loop'**
  String get aboutLoop;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and your device'**
  String get privacy;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Loop has no account or cloud service. Your practice stays in private app storage. Loop excludes its private data from automatic system backups and device transfers. Uninstalling Loop or losing your device can lose this data. Files you deliberately share are controlled by the recipient. Optional media and notifications are requested only when you choose those features.'**
  String get privacyBody;

  /// No description provided for @openingTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening Loop'**
  String get openingTitle;

  /// No description provided for @openingBody.
  ///
  /// In en, this message translates to:
  /// **'Opening your private practice data.'**
  String get openingBody;

  /// No description provided for @storageRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not open your practice data'**
  String get storageRecoveryTitle;

  /// No description provided for @storageRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Loop has not reset or replaced your data. Check available device storage, then try again. Keep your app data if the problem continues; do not uninstall Loop to troubleshoot.'**
  String get storageRecoveryBody;

  /// No description provided for @unsupportedStorage.
  ///
  /// In en, this message translates to:
  /// **'This data needs a newer version of Loop. Keep your app data and install a compatible version. Nothing has been reset.'**
  String get unsupportedStorage;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'We could not open your local preferences'**
  String get recoveryTitle;

  /// No description provided for @recoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Your practice data has not been reset. Try again. If the preferences file is damaged, you can reset only preferences while keeping a recovery copy.'**
  String get recoveryBody;

  /// No description provided for @resetPreferences.
  ///
  /// In en, this message translates to:
  /// **'Reset preferences and keep a recovery copy'**
  String get resetPreferences;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'Preferences could not be reset safely. Your original files are still preserved.'**
  String get resetFailed;

  /// No description provided for @unsupportedPreferences.
  ///
  /// In en, this message translates to:
  /// **'These preferences need a newer version of Loop. Keep your data and install a compatible version; nothing has been reset.'**
  String get unsupportedPreferences;

  /// No description provided for @missingTitle.
  ///
  /// In en, this message translates to:
  /// **'This item is not available'**
  String get missingTitle;

  /// No description provided for @missingBody.
  ///
  /// In en, this message translates to:
  /// **'It may not exist on this device. You can return to your skills without changing any history.'**
  String get missingBody;

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get backToToday;

  /// No description provided for @developmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Development build'**
  String get developmentTitle;

  /// No description provided for @developmentBody.
  ///
  /// In en, this message translates to:
  /// **'This foundation contains navigation and saved appearance preferences. Skills, sessions and evidence are enabled only after their verified milestones; incomplete controls stay out of release builds.'**
  String get developmentBody;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String dateLabel(DateTime date);
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
