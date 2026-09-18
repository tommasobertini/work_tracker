import 'package:flutter/material.dart';

/// Represents a single working day: clock-in time, clock-out time,
/// lunch break duration (in minutes) and an optional "day off" flag
/// (holiday, sick leave, public holiday...).
class WorkEntry {
  final DateTime date; // year/month/day only, without time
  final TimeOfDay clockIn;
  final TimeOfDay clockOut;
  final int breakMinutes;
  final String notes;
  final bool isDayOff;

  /// Actual break start/end times, present only when the user chose to enter
  /// the break by time rather than by duration. When present, [breakMinutes]
  /// stays consistent (end - start) and is the value used for calculations.
  final TimeOfDay? breakStart;
  final TimeOfDay? breakEnd;

  WorkEntry({
    required this.date,
    required this.clockIn,
    required this.clockOut,
    this.breakMinutes = 60,
    this.notes = '',
    this.isDayOff = false,
    this.breakStart,
    this.breakEnd,
  });

  /// Minutes actually worked: (clockOut - clockIn) - lunch break.
  /// Returns 0 if it is a day off or if the result would be negative.
  int get workedMinutes {
    if (isDayOff) return 0;
    final startMin = clockIn.hour * 60 + clockIn.minute;
    final endMin = clockOut.hour * 60 + clockOut.minute;
    final diff = endMin - startMin - breakMinutes;
    return diff < 0 ? 0 : diff;
  }

  double get workedHours => workedMinutes / 60.0;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'clockInHour': clockIn.hour,
    'clockInMinute': clockIn.minute,
    'clockOutHour': clockOut.hour,
    'clockOutMinute': clockOut.minute,
    'breakMinutes': breakMinutes,
    'notes': notes,
    'isDayOff': isDayOff,
    'breakStartHour': breakStart?.hour,
    'breakStartMinute': breakStart?.minute,
    'breakEndHour': breakEnd?.hour,
    'breakEndMinute': breakEnd?.minute,
  };

  factory WorkEntry.fromJson(Map<String, dynamic> json) {
    TimeOfDay? time(String hourKey, String minuteKey) {
      final h = json[hourKey] as int?;
      final m = json[minuteKey] as int?;
      if (h == null || m == null) return null;
      return TimeOfDay(hour: h, minute: m);
    }

    return WorkEntry(
      date: DateTime.parse(json['date'] as String),
      clockIn: TimeOfDay(
        hour: json['clockInHour'] as int,
        minute: json['clockInMinute'] as int,
      ),
      clockOut: TimeOfDay(
        hour: json['clockOutHour'] as int,
        minute: json['clockOutMinute'] as int,
      ),
      breakMinutes: json['breakMinutes'] as int? ?? 60,
      notes: json['notes'] as String? ?? '',
      isDayOff: json['isDayOff'] as bool? ?? false,
      breakStart: time('breakStartHour', 'breakStartMinute'),
      breakEnd: time('breakEndHour', 'breakEndMinute'),
    );
  }
}
