// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Work Tracker';

  @override
  String get homeTitle => 'Working Hours';

  @override
  String get monthlyStatsTooltip => 'Monthly statistics';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get addToday => 'Add today';

  @override
  String get prevMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String monthTotal(String hours) {
    return 'Total: $hours h';
  }

  @override
  String get noEntriesEver =>
      'No day recorded.\nUse the \"Add today\" button to start.';

  @override
  String get noEntriesThisMonth => 'No day recorded this month.';

  @override
  String get dayOff => 'Day off';

  @override
  String entrySubtitle(String start, String end, int minutes) {
    return '$start - $end  (break $minutes min)';
  }

  @override
  String hoursValue(String hours) {
    return '$hours h';
  }

  @override
  String get deleteDayTitle => 'Delete the day?';

  @override
  String deleteDayContent(String date) {
    return 'Do you want to delete the day of $date?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get dayUpdated => 'Day updated ✓';

  @override
  String get dayAdded => 'Day added ✓';

  @override
  String dayDeleted(String date) {
    return 'Day of $date deleted';
  }

  @override
  String get undo => 'Undo';

  @override
  String get addDayTitle => 'Add day';

  @override
  String get editDayTitle => 'Edit day';

  @override
  String get dateLabel => 'Date';

  @override
  String get dayOffSubtitle => 'Holiday, sick leave, public holiday, etc.';

  @override
  String get clockIn => 'Clock in';

  @override
  String get clockOut => 'Clock out';

  @override
  String get lunchBreak => 'Lunch break';

  @override
  String get durationMode => 'Duration';

  @override
  String get timeMode => 'Time';

  @override
  String durationMinutes(int minutes) {
    return 'Duration: $minutes minutes';
  }

  @override
  String breakDurationMinutes(int minutes) {
    return 'Break duration: $minutes minutes';
  }

  @override
  String get breakStart => 'Break start';

  @override
  String get breakEnd => 'Break end';

  @override
  String effectiveHours(String hours) {
    return 'Effective hours worked: $hours h';
  }

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String get save => 'Save';

  @override
  String get deleteDay => 'Delete day';

  @override
  String get clockOutError => 'Clock-out time must be after clock-in';

  @override
  String get breakEndError => 'Break end must be after its start';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemSubtitle => 'Follow device settings';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get mainColor => 'Main color';

  @override
  String get entryTextSize => 'Entry text size';

  @override
  String get weeklyHoursSection => 'Weekly working hours';

  @override
  String get weeklyHoursDesc =>
      'Used in the monthly recap to compute overtime (beyond the weekly threshold).';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italian';

  @override
  String get backup => 'Backup';

  @override
  String get backupDesc =>
      'Export your data to a work_tracker_backup.json file or restore it from a saved backup.';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get saveBackup => 'Save backup';

  @override
  String get backupExported => 'Backup exported ✓';

  @override
  String exportError(String error) {
    return 'Export error: $error';
  }

  @override
  String get chooseBackupFile => 'Choose the backup file';

  @override
  String get cannotReadFile => 'Cannot read the file.';

  @override
  String get importBackupTitle => 'Import the backup?';

  @override
  String get importBackupContent =>
      'The current days will be replaced with those from the backup file. Do you want to continue?';

  @override
  String importedDays(int count) {
    return 'Imported $count days ✓';
  }

  @override
  String importError(String error) {
    return 'Import error: $error';
  }

  @override
  String get invalidJson => 'Invalid file: not a JSON.';

  @override
  String get unrecognizedBackup => 'Backup file not recognized.';

  @override
  String get invalidEntries => 'Invalid day data.';

  @override
  String get statsTitle => 'Monthly statistics';

  @override
  String get weeklyHoursTooltip => 'Weekly hours';

  @override
  String get totalHours => 'Total hours';

  @override
  String get workedDays => 'Worked days';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get daysOff => 'Days off';

  @override
  String get overtime => 'Overtime';

  @override
  String overtimeSubtitle(int hours) {
    return 'Beyond $hours h per week';
  }

  @override
  String get noDataThisMonth => 'No data for this month';
}
