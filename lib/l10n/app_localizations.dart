import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Tracker'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get homeTitle;

  /// No description provided for @monthlyStatsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Monthly statistics'**
  String get monthlyStatsTooltip;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @addToday.
  ///
  /// In en, this message translates to:
  /// **'Add today'**
  String get addToday;

  /// No description provided for @prevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get prevMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @monthTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {hours} h'**
  String monthTotal(String hours);

  /// No description provided for @noEntriesEver.
  ///
  /// In en, this message translates to:
  /// **'No day recorded.\nUse the \"Add today\" button to start.'**
  String get noEntriesEver;

  /// No description provided for @noEntriesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No day recorded this month.'**
  String get noEntriesThisMonth;

  /// No description provided for @dayOff.
  ///
  /// In en, this message translates to:
  /// **'Day off'**
  String get dayOff;

  /// No description provided for @entrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}  (break {minutes} min)'**
  String entrySubtitle(String start, String end, int minutes);

  /// No description provided for @hoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String hoursValue(String hours);

  /// No description provided for @deleteDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the day?'**
  String get deleteDayTitle;

  /// No description provided for @deleteDayContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the day of {date}?'**
  String deleteDayContent(String date);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dayUpdated.
  ///
  /// In en, this message translates to:
  /// **'Day updated ✓'**
  String get dayUpdated;

  /// No description provided for @dayAdded.
  ///
  /// In en, this message translates to:
  /// **'Day added ✓'**
  String get dayAdded;

  /// No description provided for @dayDeleted.
  ///
  /// In en, this message translates to:
  /// **'Day of {date} deleted'**
  String dayDeleted(String date);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @addDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Add day'**
  String get addDayTitle;

  /// No description provided for @editDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit day'**
  String get editDayTitle;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @dayOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Holiday, sick leave, public holiday, etc.'**
  String get dayOffSubtitle;

  /// No description provided for @clockIn.
  ///
  /// In en, this message translates to:
  /// **'Clock in'**
  String get clockIn;

  /// No description provided for @clockOut.
  ///
  /// In en, this message translates to:
  /// **'Clock out'**
  String get clockOut;

  /// No description provided for @lunchBreak.
  ///
  /// In en, this message translates to:
  /// **'Lunch break'**
  String get lunchBreak;

  /// No description provided for @durationMode.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationMode;

  /// No description provided for @timeMode.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeMode;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration: {minutes} minutes'**
  String durationMinutes(int minutes);

  /// No description provided for @breakDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Break duration: {minutes} minutes'**
  String breakDurationMinutes(int minutes);

  /// No description provided for @breakStart.
  ///
  /// In en, this message translates to:
  /// **'Break start'**
  String get breakStart;

  /// No description provided for @breakEnd.
  ///
  /// In en, this message translates to:
  /// **'Break end'**
  String get breakEnd;

  /// No description provided for @effectiveHours.
  ///
  /// In en, this message translates to:
  /// **'Effective hours worked: {hours} h'**
  String effectiveHours(String hours);

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteDay.
  ///
  /// In en, this message translates to:
  /// **'Delete day'**
  String get deleteDay;

  /// No description provided for @clockOutError.
  ///
  /// In en, this message translates to:
  /// **'Clock-out time must be after clock-in'**
  String get clockOutError;

  /// No description provided for @breakEndError.
  ///
  /// In en, this message translates to:
  /// **'Break end must be after its start'**
  String get breakEndError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow device settings'**
  String get themeSystemSubtitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @mainColor.
  ///
  /// In en, this message translates to:
  /// **'Main color'**
  String get mainColor;

  /// No description provided for @entryTextSize.
  ///
  /// In en, this message translates to:
  /// **'Entry text size'**
  String get entryTextSize;

  /// No description provided for @weeklyHoursSection.
  ///
  /// In en, this message translates to:
  /// **'Weekly working hours'**
  String get weeklyHoursSection;

  /// No description provided for @weeklyHoursDesc.
  ///
  /// In en, this message translates to:
  /// **'Used in the monthly recap to compute overtime (beyond the weekly threshold).'**
  String get weeklyHoursDesc;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @backupDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your data to a work_tracker_backup.json file or restore it from a saved backup.'**
  String get backupDesc;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @saveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save backup'**
  String get saveBackup;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported ✓'**
  String get backupExported;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export error: {error}'**
  String exportError(String error);

  /// No description provided for @chooseBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Choose the backup file'**
  String get chooseBackupFile;

  /// No description provided for @cannotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot read the file.'**
  String get cannotReadFile;

  /// No description provided for @importBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Import the backup?'**
  String get importBackupTitle;

  /// No description provided for @importBackupContent.
  ///
  /// In en, this message translates to:
  /// **'The current days will be replaced with those from the backup file. Do you want to continue?'**
  String get importBackupContent;

  /// No description provided for @importedDays.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} days ✓'**
  String importedDays(int count);

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import error: {error}'**
  String importError(String error);

  /// No description provided for @invalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid file: not a JSON.'**
  String get invalidJson;

  /// No description provided for @unrecognizedBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup file not recognized.'**
  String get unrecognizedBackup;

  /// No description provided for @invalidEntries.
  ///
  /// In en, this message translates to:
  /// **'Invalid day data.'**
  String get invalidEntries;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly statistics'**
  String get statsTitle;

  /// No description provided for @weeklyHoursTooltip.
  ///
  /// In en, this message translates to:
  /// **'Weekly hours'**
  String get weeklyHoursTooltip;

  /// No description provided for @totalHours.
  ///
  /// In en, this message translates to:
  /// **'Total hours'**
  String get totalHours;

  /// No description provided for @workedDays.
  ///
  /// In en, this message translates to:
  /// **'Worked days'**
  String get workedDays;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @daysOff.
  ///
  /// In en, this message translates to:
  /// **'Days off'**
  String get daysOff;

  /// No description provided for @overtime.
  ///
  /// In en, this message translates to:
  /// **'Overtime'**
  String get overtime;

  /// No description provided for @overtimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Beyond {hours} h per week'**
  String overtimeSubtitle(int hours);

  /// No description provided for @noDataThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No data for this month'**
  String get noDataThisMonth;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
