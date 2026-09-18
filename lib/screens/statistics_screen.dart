import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../models/work_entry.dart';
import '../services/storage_service.dart';
import '../services/theme_controller.dart';
import 'settings_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storage = StorageService();
  List<WorkEntry> _entries = [];
  bool _loading = true;
  late DateTime _selectedMonth;

  // Direction of the last month change: +1 = forward, -1 = backward.
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    // Updates overtime when the weekly hours change in Settings.
    themeController.addListener(_onSettingsChanged);
    _load();
  }

  @override
  void dispose() {
    themeController.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  /// ISO week key: the Monday's date (used for grouping).
  int _weekKey(DateTime d) {
    final dateOnly = DateTime(d.year, d.month, d.day);
    final monday = dateOnly.subtract(Duration(days: d.weekday - 1));
    return monday.year * 10000 + monday.month * 100 + monday.day;
  }

  /// Overtime minutes in the month: for each week, the minutes beyond the
  /// configured weekly threshold. Sums only the excesses (never negative).
  int _overtimeMinutes(List<WorkEntry> workedDays) {
    final thresholdMin = themeController.weeklyHours * 60;
    final byWeek = <int, int>{};
    for (final e in workedDays) {
      final k = _weekKey(e.date);
      byWeek[k] = (byWeek[k] ?? 0) + e.workedMinutes;
    }
    var total = 0;
    for (final minutes in byWeek.values) {
      final extra = minutes - thresholdMin;
      if (extra > 0) total += extra;
    }
    return total;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _storage.loadEntries();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _direction = delta > 0 ? 1 : -1;
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  /// Horizontal swipe: left = next month, right = previous.
  void _handleSwipe(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v < -250) {
      _changeMonth(1);
    } else if (v > 250) {
      _changeMonth(-1);
    }
  }

  List<WorkEntry> get _monthEntries =>
      _entries
          .where(
            (e) =>
                e.date.year == _selectedMonth.year &&
                e.date.month == _selectedMonth.month,
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final lang = themeController.locale.languageCode;
    final monthKey = ValueKey('${_selectedMonth.year}-${_selectedMonth.month}');

    return Scaffold(
      appBar: AppBar(
        title: Text(l.statsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l.weeklyHoursTooltip,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              // Reload: data may have changed (backup import).
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _handleSwipe,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeMonth(-1),
                        ),
                        Text(
                          DateFormat('MMMM yyyy', lang).format(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => _changeMonth(1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        final isIncoming = child.key == monthKey;
                        final begin = isIncoming
                            ? Offset(_direction.toDouble(), 0)
                            : Offset(-_direction.toDouble(), 0);
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
                      child: KeyedSubtree(
                        key: monthKey,
                        child: _buildMonthContent(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthContent(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final monthEntries = _monthEntries;
    final workedDays = monthEntries.where((e) => !e.isDayOff).toList();
    final daysOff = monthEntries.where((e) => e.isDayOff).length;
    final totalMinutes = workedDays.fold<int>(
      0,
      (sum, e) => sum + e.workedMinutes,
    );
    final totalHours = totalMinutes / 60.0;
    final averageHours = workedDays.isEmpty
        ? 0.0
        : totalHours / workedDays.length;
    final overtimeHours = _overtimeMinutes(workedDays) / 60.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l.totalHours,
                  value: l.hoursValue(totalHours.toStringAsFixed(2)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: l.workedDays,
                  value: '${workedDays.length}',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l.dailyAverage,
                  value: l.hoursValue(averageHours.toStringAsFixed(2)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(label: l.daysOff, value: '$daysOff'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: overtimeHours > 0
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: ListTile(
              leading: const Icon(Icons.more_time),
              title: Text(l.overtime),
              subtitle: Text(l.overtimeSubtitle(themeController.weeklyHours)),
              trailing: Text(
                l.hoursValue(overtimeHours.toStringAsFixed(2)),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: monthEntries.isEmpty
              ? Center(child: Text(l.noDataThisMonth))
              : const SizedBox.expand(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
