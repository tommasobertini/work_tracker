import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/work_entry.dart';
import '../services/storage_service.dart';
import '../services/theme_controller.dart';
import 'add_entry_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<WorkEntry> _entries = [];
  bool _loading = true;

  // First day of the currently displayed month.
  late DateTime _displayedMonth;

  // Direction of the last month change: +1 = forward, -1 = backward.
  // Used to animate the slide in the correct direction.
  int _direction = 1;

  // Date of the just-saved day, to briefly highlight it in the list.
  DateTime? _highlightDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _displayedMonth = DateTime(today.year, today.month, 1);
    // Rebuilds when the settings change (e.g. font size), so changes made in
    // Settings show up immediately when coming back.
    themeController.addListener(_onSettingsChanged);
    _loadEntries();
  }

  @override
  void dispose() {
    themeController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  // Current language code, used to format dates.
  String get _lang => themeController.locale.languageCode;

  /// Entries of the displayed month only (already sorted, most recent first).
  List<WorkEntry> get _monthEntries => _entries
      .where(
        (e) =>
            e.date.year == _displayedMonth.year &&
            e.date.month == _displayedMonth.month,
      )
      .toList();

  /// Total hours worked in the displayed month.
  double get _monthTotalHours =>
      _monthEntries.fold(0.0, (total, e) => total + e.workedHours);

  /// Furthest month reachable going forward: the current month or, if more
  /// recent, the last month that contains an entry (so future days already
  /// saved stay reachable without scrolling endlessly into the void).
  DateTime get _forwardLimitMonth {
    final now = DateTime.now();
    var limit = DateTime(now.year, now.month, 1);
    for (final e in _entries) {
      final month = DateTime(e.date.year, e.date.month, 1);
      if (month.isAfter(limit)) limit = month;
    }
    return limit;
  }

  bool get _canGoForward => _displayedMonth.isBefore(_forwardLimitMonth);

  void _changeMonth(int delta) {
    if (delta > 0 && !_canGoForward) return;
    setState(() {
      _direction = delta > 0 ? 1 : -1;
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
        1,
      );
    });
  }

  /// Horizontal swipe: left = next month, right = previous. Used both on the
  /// header and on the list area.
  void _handleSwipe(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v < -250) {
      _changeMonth(1); // swipe left
    } else if (v > 250) {
      _changeMonth(-1); // swipe right
    }
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);
    final entries = await _storage.loadEntries();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _openAddToday() async {
    final today = DateTime.now();
    final existing = _entries.where(
      (e) =>
          e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day,
    );
    final wasEdit = existing.isNotEmpty;

    final result = await Navigator.push<EntryResult>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEntryScreen(
          existingEntry: wasEdit ? existing.first : null,
          initialDate: DateTime(today.year, today.month, today.day),
        ),
      ),
    );
    _handleResult(result, wasEdit: wasEdit);
  }

  Future<void> _openEdit(WorkEntry entry) async {
    final result = await Navigator.push<EntryResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEntryScreen(existingEntry: entry, initialDate: entry.date),
      ),
    );
    _handleResult(result, wasEdit: true);
  }

  void _handleResult(EntryResult? result, {required bool wasEdit}) {
    if (result == null) return;
    switch (result.action) {
      case EntryAction.saved:
        _onSaved(result.entry, wasEdit: wasEdit);
      case EntryAction.deleted:
        _delete(result.entry);
    }
  }

  /// Reloads the entries without showing the full-screen spinner.
  Future<void> _reload() async {
    final entries = await _storage.loadEntries();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  /// After a save: reload, bring the view to the day's month, show a
  /// notification and make the just-saved entry "glow".
  Future<void> _onSaved(WorkEntry entry, {required bool wasEdit}) async {
    await _reload();
    if (!mounted) return;
    final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
    setState(() {
      _displayedMonth = DateTime(entry.date.year, entry.date.month, 1);
      _highlightDate = day;
    });

    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(wasEdit ? l.dayUpdated : l.dayAdded),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

    // Clears the highlight once the animation is done.
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _highlightDate = null);
    });
  }

  Future<void> _delete(WorkEntry entry) async {
    await _storage.deleteEntry(entry);
    await _reload();
    if (!mounted) return;
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(
          l.dayDeleted(DateFormat('dd/MM/yyyy', _lang).format(entry.date)),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: l.undo,
          onPressed: () async {
            await _storage.addOrUpdateEntry(entry);
            await _reload();
          },
        ),
      ),
    );
    // Guaranteed close after 5s: the SnackBar's internal timer may not fire
    // when there is an action and accessibility features are enabled.
    Future.delayed(const Duration(seconds: 5), () {
      try {
        controller.close();
      } catch (_) {
        // Already closed (internal timer or "Undo" pressed): nothing to do.
      }
    });
  }

  /// Asks for confirmation before deleting, to avoid accidental deletions.
  Future<bool> _confirmDelete(WorkEntry entry) async {
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
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: l.monthlyStatsTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.settingsTooltip,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              // Reload: data may have changed (backup import).
              _reload();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthHeader(),
                const Divider(height: 1),
                Expanded(child: _buildMonthList()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddToday,
        icon: const Icon(Icons.add),
        label: Text(l.addToday),
      ),
    );
  }

  /// Bar with the month name, navigation arrows and total hours.
  Widget _buildMonthHeader() {
    final l = AppLocalizations.of(context)!;
    final monthName = DateFormat('MMMM yyyy', _lang).format(_displayedMonth);
    final monthNameCap = monthName.isEmpty
        ? monthName
        : monthName[0].toUpperCase() + monthName.substring(1);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _handleSwipe,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: l.prevMonth,
              onPressed: () => _changeMonth(-1),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    monthNameCap,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l.monthTotal(_monthTotalHours.toStringAsFixed(2)),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: l.nextMonth,
              onPressed: _canGoForward ? () => _changeMonth(1) : null,
            ),
          ],
        ),
      ),
    );
  }

  /// List of the displayed month's entries, with an animated swipe to change
  /// month.
  Widget _buildMonthList() {
    final l = AppLocalizations.of(context)!;
    final entries = _monthEntries;
    final monthKey = ValueKey(
      '${_displayedMonth.year}-${_displayedMonth.month}',
    );

    final Widget content = entries.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _entries.isEmpty ? l.noEntriesEver : l.noEntriesThisMonth,
                textAlign: TextAlign.center,
              ),
            ),
          )
        : MediaQuery(
            // Scales only the entries text, not the header.
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(themeController.entryFontScale),
            ),
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                final highlight =
                    _highlightDate != null &&
                    e.date.year == _highlightDate!.year &&
                    e.date.month == _highlightDate!.month &&
                    e.date.day == _highlightDate!.day;
                return Dismissible(
                  key: ValueKey(e.date.toIso8601String()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => _confirmDelete(e),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _delete(e),
                  child: _EntryTile(
                    highlight: highlight,
                    child: ListTile(
                      title: Text(
                        DateFormat('EEEE dd/MM/yyyy', _lang).format(e.date),
                      ),
                      subtitle: e.isDayOff
                          ? Text(l.dayOff)
                          : Text(
                              l.entrySubtitle(
                                e.clockIn.format(context),
                                e.clockOut.format(context),
                                e.breakMinutes,
                              ),
                            ),
                      trailing: e.isDayOff
                          ? null
                          : Text(
                              l.hoursValue(e.workedHours.toStringAsFixed(2)),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                      onTap: () => _openEdit(e),
                    ),
                  ),
                );
              },
            ),
          );

    // Slide transition: the new page enters from the direction side, the old
    // one exits from the opposite side.
    final animated = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        final bool isIncoming = child.key == monthKey;
        final Offset begin = isIncoming
            ? Offset(_direction.toDouble(), 0) // enters from the direction side
            : Offset(-_direction.toDouble(), 0); // exits to the opposite side
        return ClipRect(
          child: SlideTransition(
            position: Tween<Offset>(
              begin: begin,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      // Key on the container so the switcher detects the month change.
      child: KeyedSubtree(key: monthKey, child: content),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _handleSwipe,
      child: animated,
    );
  }
}

/// A day row that, if [highlight] is true at creation time, runs a brief glow
/// effect (a double pulse that fades out) to flag the just-saved entry.
class _EntryTile extends StatefulWidget {
  final bool highlight;
  final Widget child;

  const _EntryTile({required this.highlight, required this.child});

  @override
  State<_EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends State<_EntryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.highlight) _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(_EntryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight && !oldWidget.highlight) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Double glow (|sin| with two humps) that fades as t progresses.
        final intensity = t == 0
            ? 0.0
            : (math.sin(t * 2 * math.pi).abs() * (1 - t)) * 0.45;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: intensity),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
