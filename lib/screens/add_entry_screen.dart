import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/work_entry.dart';
import '../services/storage_service.dart';

/// Result of the screen: day saved or delete requested.
enum EntryAction { saved, deleted }

class EntryResult {
  final EntryAction action;
  final WorkEntry entry;
  const EntryResult(this.action, this.entry);
}

class AddEntryScreen extends StatefulWidget {
  final WorkEntry? existingEntry;
  final DateTime initialDate;

  const AddEntryScreen({
    super.key,
    this.existingEntry,
    required this.initialDate,
  });

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final StorageService _storage = StorageService();

  late DateTime _date;
  TimeOfDay _clockIn = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _clockOut = const TimeOfDay(hour: 18, minute: 0);
  int _breakMinutes = 60;
  bool _isDayOff = false;
  final _notesController = TextEditingController();

  // Break entry mode: false = duration (slider), true = time.
  bool _breakByTime = false;
  TimeOfDay _breakStart = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _breakEnd = const TimeOfDay(hour: 14, minute: 0);

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEntry;
    _date = existing?.date ?? widget.initialDate;
    if (existing != null) {
      _clockIn = existing.clockIn;
      _clockOut = existing.clockOut;
      _breakMinutes = existing.breakMinutes;
      _isDayOff = existing.isDayOff;
      _notesController.text = existing.notes;
      if (existing.breakStart != null && existing.breakEnd != null) {
        _breakByTime = true;
        _breakStart = existing.breakStart!;
        _breakEnd = existing.breakEnd!;
      }
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String get _lang => Localizations.localeOf(context).languageCode;

  /// Break duration (minutes) actually used in calculations, depending on the
  /// chosen mode.
  int get _effectiveBreakMinutes {
    if (_breakByTime) {
      final diff = _toMinutes(_breakEnd) - _toMinutes(_breakStart);
      return diff < 0 ? 0 : diff;
    }
    return _breakMinutes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) setState(() => _date = result);
  }

  Future<void> _pickTime(bool isClockIn) async {
    final result = await showTimePicker(
      context: context,
      initialTime: isClockIn ? _clockIn : _clockOut,
    );
    if (result != null) {
      setState(() {
        if (isClockIn) {
          _clockIn = result;
        } else {
          _clockOut = result;
        }
      });
    }
  }

  Future<void> _pickBreakTime(bool isStart) async {
    final result = await showTimePicker(
      context: context,
      initialTime: isStart ? _breakStart : _breakEnd,
    );
    if (result != null) {
      setState(() {
        if (isStart) {
          _breakStart = result;
        } else {
          _breakEnd = result;
        }
      });
    }
  }

  int get _computedMinutes {
    final startMin = _clockIn.hour * 60 + _clockIn.minute;
    final endMin = _clockOut.hour * 60 + _clockOut.minute;
    final diff = endMin - startMin - _effectiveBreakMinutes;
    return diff < 0 ? 0 : diff;
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    if (!_isDayOff) {
      final startMin = _clockIn.hour * 60 + _clockIn.minute;
      final endMin = _clockOut.hour * 60 + _clockOut.minute;
      if (endMin <= startMin) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.clockOutError)));
        return;
      }
      if (_breakByTime && _toMinutes(_breakEnd) <= _toMinutes(_breakStart)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.breakEndError)));
        return;
      }
    }

    final entry = WorkEntry(
      date: DateTime(_date.year, _date.month, _date.day),
      clockIn: _clockIn,
      clockOut: _clockOut,
      breakMinutes: _effectiveBreakMinutes,
      notes: _notesController.text.trim(),
      isDayOff: _isDayOff,
      breakStart: _breakByTime ? _breakStart : null,
      breakEnd: _breakByTime ? _breakEnd : null,
    );

    await _storage.addOrUpdateEntry(entry);
    if (mounted) {
      Navigator.pop(context, EntryResult(EntryAction.saved, entry));
    }
  }

  Future<void> _delete() async {
    final entry = widget.existingEntry;
    if (entry == null) return;
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteDayTitle),
        content: Text(
          l.deleteDayContent(
            DateFormat('EEEE dd/MM/yyyy', _lang).format(entry.date),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // The actual deletion (with the option to undo) is handled by the home
      // screen, so it can show the SnackBar with "Undo".
      Navigator.pop(context, EntryResult(EntryAction.deleted, entry));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hours = _computedMinutes / 60.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEntry == null ? l.addDayTitle : l.editDayTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.dateLabel),
            subtitle: Text(DateFormat('dd/MM/yyyy', _lang).format(_date)),
            trailing: const Icon(Icons.edit_calendar),
            onTap: _pickDate,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.dayOff),
            subtitle: Text(l.dayOffSubtitle),
            value: _isDayOff,
            onChanged: (v) => setState(() => _isDayOff = v),
          ),
          if (!_isDayOff) ...[
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.clockIn),
              subtitle: Text(_clockIn.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.clockOut),
              subtitle: Text(_clockOut.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(false),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.lunchBreak,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(l.durationMode)),
                    ButtonSegment(value: true, label: Text(l.timeMode)),
                  ],
                  selected: {_breakByTime},
                  onSelectionChanged: (s) =>
                      setState(() => _breakByTime = s.first),
                ),
              ],
            ),
            if (!_breakByTime) ...[
              const SizedBox(height: 8),
              Text(l.durationMinutes(_breakMinutes)),
              Slider(
                value: _breakMinutes.toDouble(),
                min: 0,
                max: 120,
                divisions: 24,
                label: '$_breakMinutes min',
                onChanged: (v) => setState(() => _breakMinutes = v.round()),
              ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.breakStart),
                subtitle: Text(_breakStart.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickBreakTime(true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.breakEnd),
                subtitle: Text(_breakEnd.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _pickBreakTime(false),
              ),
              Text(l.breakDurationMinutes(_effectiveBreakMinutes)),
            ],
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.effectiveHours(hours.toStringAsFixed(2)),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l.notesLabel,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: Text(l.save),
          ),
          if (widget.existingEntry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l.deleteDay),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
