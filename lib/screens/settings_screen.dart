import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../services/theme_controller.dart';

/// App settings: theme, color, text size, weekly hours, language and data
/// backup (export/import).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static final StorageService _storage = StorageService();

  /// Exports the backup, letting the user choose where to save it.
  Future<void> _export(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final content = await _storage.exportBackup();
      final bytes = Uint8List.fromList(utf8.encode(content));
      final uri = await FilePicker.saveFile(
        dialogTitle: l.saveBackup,
        fileName: 'work_tracker_backup.json',
        bytes: bytes,
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (uri == null) return; // cancelled
      messenger.showSnackBar(SnackBar(content: Text(l.backupExported)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.exportError(e.toString()))),
      );
    }
  }

  /// Imports a backup chosen by the user, after confirmation.
  Future<void> _import(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final files = await FilePicker.pickFiles(
        dialogTitle: l.chooseBackupFile,
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (files.isEmpty) return; // cancelled

      final bytes = await files.first.readAsBytes();

      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.importBackupTitle),
          content: Text(l.importBackupContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.import),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final n = await _storage.importBackup(utf8.decode(bytes));
      messenger.showSnackBar(SnackBar(content: Text(l.importedDays(n))));
    } on FormatException {
      messenger.showSnackBar(SnackBar(content: Text(l.unrecognizedBackup)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.importError(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListenableBuilder(
        listenable: themeController,
        builder: (context, _) {
          final lang = themeController.locale.languageCode;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _SectionTitle(l.language),
              RadioGroup<String>(
                groupValue: lang,
                onChanged: (v) {
                  if (v != null) themeController.setLocale(Locale(v));
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(l.languageEnglish),
                      value: 'en',
                    ),
                    RadioListTile<String>(
                      title: Text(l.languageItalian),
                      value: 'it',
                    ),
                  ],
                ),
              ),
              const Divider(),
              _SectionTitle(l.theme),
              RadioGroup<ThemeMode>(
                groupValue: themeController.themeMode,
                onChanged: (v) {
                  if (v != null) themeController.setThemeMode(v);
                },
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: Text(l.themeSystem),
                      subtitle: Text(l.themeSystemSubtitle),
                      value: ThemeMode.system,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(l.themeLight),
                      value: ThemeMode.light,
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text(l.themeDark),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              ),
              const Divider(),
              _SectionTitle(l.mainColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final color in ThemeController.availableColors)
                      _ColorSwatch(
                        color: color,
                        selected:
                            color.toARGB32() ==
                            themeController.seedColor.toARGB32(),
                        onTap: () => themeController.setSeedColor(color),
                      ),
                  ],
                ),
              ),
              const Divider(),
              _SectionTitle(l.entryTextSize),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(
                              themeController.entryFontScale,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              DateFormat(
                                'EEEE dd/MM/yyyy',
                                lang,
                              ).format(DateTime(2026, 9, 15)),
                            ),
                            subtitle: Text(
                              l.entrySubtitle('09:00', '18:00', 60),
                            ),
                            trailing: Text(
                              l.hoursValue('8.00'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Text('A', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Slider(
                            value: themeController.entryFontScale,
                            min: ThemeController.minEntryFontScale,
                            max: ThemeController.maxEntryFontScale,
                            divisions: 8,
                            label:
                                '${(themeController.entryFontScale * 100).round()}%',
                            onChanged: (v) =>
                                themeController.setEntryFontScale(v),
                          ),
                        ),
                        const Text('A', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              _SectionTitle(l.weeklyHoursSection),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.weeklyHoursDesc,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: themeController.weeklyHours.toDouble(),
                            min: ThemeController.minWeeklyHours.toDouble(),
                            max: ThemeController.maxWeeklyHours.toDouble(),
                            divisions:
                                ThemeController.maxWeeklyHours -
                                ThemeController.minWeeklyHours,
                            label: '${themeController.weeklyHours} h',
                            onChanged: (v) =>
                                themeController.setWeeklyHours(v.round()),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: Text(
                            '${themeController.weeklyHours} h',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              _SectionTitle(l.backup),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l.backupDesc,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _export(context),
                        icon: const Icon(Icons.upload_file),
                        label: Text(l.export),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _import(context),
                        icon: const Icon(Icons.download),
                        label: Text(l.import),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
