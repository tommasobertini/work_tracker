// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Work Tracker';

  @override
  String get homeTitle => 'Ore di Lavoro';

  @override
  String get monthlyStatsTooltip => 'Statistiche mensili';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get addToday => 'Aggiungi oggi';

  @override
  String get prevMonth => 'Mese precedente';

  @override
  String get nextMonth => 'Mese successivo';

  @override
  String monthTotal(String hours) {
    return 'Totale: $hours h';
  }

  @override
  String get noEntriesEver =>
      'Nessun giorno registrato.\nUsa il pulsante \"Aggiungi oggi\" per iniziare.';

  @override
  String get noEntriesThisMonth => 'Nessun giorno registrato in questo mese.';

  @override
  String get dayOff => 'Giorno libero';

  @override
  String entrySubtitle(String start, String end, int minutes) {
    return '$start - $end  (pausa $minutes min)';
  }

  @override
  String hoursValue(String hours) {
    return '$hours h';
  }

  @override
  String get deleteDayTitle => 'Eliminare la giornata?';

  @override
  String deleteDayContent(String date) {
    return 'Vuoi eliminare la giornata del $date?';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get dayUpdated => 'Giornata aggiornata ✓';

  @override
  String get dayAdded => 'Giornata aggiunta ✓';

  @override
  String dayDeleted(String date) {
    return 'Giornata del $date eliminata';
  }

  @override
  String get undo => 'Annulla';

  @override
  String get addDayTitle => 'Aggiungi giornata';

  @override
  String get editDayTitle => 'Modifica giornata';

  @override
  String get dateLabel => 'Data';

  @override
  String get dayOffSubtitle => 'Ferie, malattia, festivo, ecc.';

  @override
  String get clockIn => 'Ingresso';

  @override
  String get clockOut => 'Uscita';

  @override
  String get lunchBreak => 'Pausa pranzo';

  @override
  String get durationMode => 'Durata';

  @override
  String get timeMode => 'Orario';

  @override
  String durationMinutes(int minutes) {
    return 'Durata: $minutes minuti';
  }

  @override
  String breakDurationMinutes(int minutes) {
    return 'Durata pausa: $minutes minuti';
  }

  @override
  String get breakStart => 'Inizio pausa';

  @override
  String get breakEnd => 'Fine pausa';

  @override
  String effectiveHours(String hours) {
    return 'Ore effettive lavorate: $hours h';
  }

  @override
  String get notesLabel => 'Note (opzionale)';

  @override
  String get save => 'Salva';

  @override
  String get deleteDay => 'Elimina giornata';

  @override
  String get clockOutError => 'L\'orario di uscita deve essere dopo l\'entrata';

  @override
  String get breakEndError => 'La fine della pausa deve essere dopo l\'inizio';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeSystemSubtitle => 'Segui le impostazioni del dispositivo';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get mainColor => 'Colore principale';

  @override
  String get entryTextSize => 'Dimensione testo giornate';

  @override
  String get weeklyHoursSection => 'Ore settimanali lavorative';

  @override
  String get weeklyHoursDesc =>
      'Usate nel recap mensile per calcolare le ore di straordinario (oltre la soglia settimanale).';

  @override
  String get language => 'Lingua';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get backup => 'Backup';

  @override
  String get backupDesc =>
      'Esporta i tuoi dati in un file work_tracker_backup.json oppure ripristinali da un backup salvato.';

  @override
  String get export => 'Esporta';

  @override
  String get import => 'Importa';

  @override
  String get saveBackup => 'Salva backup';

  @override
  String get backupExported => 'Backup esportato ✓';

  @override
  String exportError(String error) {
    return 'Errore durante l\'export: $error';
  }

  @override
  String get chooseBackupFile => 'Scegli il file di backup';

  @override
  String get cannotReadFile => 'Impossibile leggere il file.';

  @override
  String get importBackupTitle => 'Importare il backup?';

  @override
  String get importBackupContent =>
      'Le giornate attuali verranno sostituite con quelle del file di backup. Vuoi continuare?';

  @override
  String importedDays(int count) {
    return 'Importate $count giornate ✓';
  }

  @override
  String importError(String error) {
    return 'Errore durante l\'import: $error';
  }

  @override
  String get invalidJson => 'File non valido: non è un JSON.';

  @override
  String get unrecognizedBackup => 'File di backup non riconosciuto.';

  @override
  String get invalidEntries => 'Dati delle giornate non validi.';

  @override
  String get statsTitle => 'Statistiche mensili';

  @override
  String get weeklyHoursTooltip => 'Ore settimanali';

  @override
  String get totalHours => 'Ore totali';

  @override
  String get workedDays => 'Giorni lavorati';

  @override
  String get dailyAverage => 'Media giornaliera';

  @override
  String get daysOff => 'Giorni liberi';

  @override
  String get overtime => 'Straordinari';

  @override
  String overtimeSubtitle(int hours) {
    return 'Oltre $hours h a settimana';
  }

  @override
  String get noDataThisMonth => 'Nessun dato per questo mese';
}
