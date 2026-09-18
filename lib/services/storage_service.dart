import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/work_entry.dart';

/// Saves and loads working days using SharedPreferences
/// (a single JSON string holding the list of days).
class StorageService {
  static const _key = 'work_entries';

  Future<List<WorkEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    final entries = list
        .map((e) => WorkEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.date.compareTo(a.date)); // most recent first
    return entries;
  }

  Future<void> saveEntries(List<WorkEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Adds a new day or overwrites the existing one for the same date
  /// (a single entry per day).
  Future<void> addOrUpdateEntry(WorkEntry entry) async {
    final entries = await loadEntries();
    final index = entries.indexWhere((e) => _sameDay(e.date, entry.date));
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.add(entry);
    }
    await saveEntries(entries);
  }

  Future<bool> hasEntryForDate(DateTime date) async {
    final entries = await loadEntries();
    return entries.any((e) => _sameDay(e.date, date));
  }

  Future<void> deleteEntry(WorkEntry entry) async {
    final entries = await loadEntries();
    entries.removeWhere((e) => _sameDay(e.date, entry.date));
    await saveEntries(entries);
  }

  static const _backupVersion = 1;

  /// Produces the JSON backup content (indented, human-readable).
  Future<String> exportBackup() async {
    final entries = await loadEntries();
    final backup = {
      'app': 'work_tracker',
      'version': _backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  /// Imports a backup, replacing the current days. Returns the number of
  /// imported days. Throws [FormatException] if the file is not valid.
  Future<int> importBackup(String content) async {
    final dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } catch (_) {
      throw const FormatException('Invalid file: not a JSON.');
    }
    if (decoded is! Map || decoded['entries'] is! List) {
      throw const FormatException('Backup file not recognized.');
    }
    final entries = <WorkEntry>[];
    for (final item in decoded['entries'] as List) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid day data.');
      }
      entries.add(WorkEntry.fromJson(item));
    }
    await saveEntries(entries);
    return entries.length;
  }
}
