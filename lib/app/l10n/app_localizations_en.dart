// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Loop';

  @override
  String get today => 'Today';

  @override
  String get skills => 'Skills';

  @override
  String get practice => 'Practice';

  @override
  String get progress => 'Progress';

  @override
  String get library => 'Library';

  @override
  String get settings => 'Settings';

  @override
  String get navigate => 'Navigate';

  @override
  String get welcomeTitle => 'Practice with intention.\nSee your progress.';

  @override
  String get welcomeBody =>
      'A quiet place for your skills, the work you make, and what you want to try next.';

  @override
  String get privateTitle => 'Your practice, on your device';

  @override
  String get privateBody =>
      'No account. No feed. Start with a note; add photos or audio when they help.';

  @override
  String get chooseSkill => 'Choose a skill';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get todayEmptyTitle => 'Your practice starts here';

  @override
  String get todayEmptyBody =>
      'Choose a skill to give your next practice a starting point.';

  @override
  String get skillsEmptyTitle => 'Make room for what you want to learn';

  @override
  String get skillsEmptyBody =>
      'There are no skills on this device yet. Your saved skills and history will appear here.';

  @override
  String get practiceEmptyTitle => 'Start with a skill';

  @override
  String get practiceEmptyBody =>
      'Choose what you want to work on before starting a session.';

  @override
  String get progressEmptyTitle => 'Progress begins with a practice record';

  @override
  String get progressEmptyBody =>
      'Your history and comparable measurements will appear here. Time records effort; evidence shows what changed.';

  @override
  String get libraryEmptyTitle => 'Keep the work you can come back to';

  @override
  String get libraryEmptyBody =>
      'Photos and audio you choose to attach will appear here. A recording is never required to practice.';

  @override
  String get seeSkills => 'See skills';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceBody =>
      'Choose how Loop looks. This preference is saved on this device.';

  @override
  String get systemAppearance => 'Follow system';

  @override
  String get lightAppearance => 'Light';

  @override
  String get darkAppearance => 'Dark';

  @override
  String get savingPreferences => 'Saving your choice…';

  @override
  String get preferencesSaveFailed =>
      'Your choice could not be saved. Your previous preference is unchanged.';

  @override
  String get retry => 'Try again';

  @override
  String get licenses => 'Licenses and acknowledgments';

  @override
  String get aboutLoop => 'About Loop';

  @override
  String get privacy => 'Privacy and your device';

  @override
  String get privacyBody =>
      'Loop has no account or cloud service. Optional media and notifications are requested only when you choose those features. Device backups and files you deliberately share are controlled by the operating system and recipient.';

  @override
  String get openingTitle => 'Opening Loop';

  @override
  String get openingBody => 'Reading your local preferences.';

  @override
  String get recoveryTitle => 'We could not open your local preferences';

  @override
  String get recoveryBody =>
      'Your files have not been changed. Try again. If the preferences file is damaged, you can reset only preferences while keeping a recovery copy.';

  @override
  String get resetPreferences => 'Reset preferences and keep a recovery copy';

  @override
  String get resetFailed =>
      'Preferences could not be reset safely. Your original files are still preserved.';

  @override
  String get unsupportedPreferences =>
      'These preferences need a newer version of Loop. Keep your data and install a compatible version; nothing has been reset.';

  @override
  String get missingTitle => 'This item is not available';

  @override
  String get missingBody =>
      'It may not exist on this device. You can return to your skills without changing any history.';

  @override
  String get backToToday => 'Back to Today';

  @override
  String get developmentTitle => 'Development build';

  @override
  String get developmentBody =>
      'This foundation contains navigation and saved appearance preferences. Skills, sessions and evidence are enabled only after their verified milestones; incomplete controls stay out of release builds.';

  @override
  String dateLabel(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMEEEEd(
      localeName,
    );
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }
}
