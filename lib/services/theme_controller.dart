import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app preferences (theme mode, main color, entry text size,
/// weekly working hours and language) and persists them on SharedPreferences.
///
/// It is exposed through the global [themeController] instance: the
/// [MaterialApp] subscribes to it to rebuild when the settings change.
class ThemeController extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode'; // 0=system, 1=light, 2=dark
  static const _keySeedColor = 'seed_color'; // int ARGB
  static const _keyEntryFontScale = 'entry_font_scale'; // double
  static const _keyWeeklyHours = 'weekly_hours'; // int
  static const _keyLanguage = 'language'; // 'en' | 'it'

  /// Bounds of the entry text scale factor.
  static const double minEntryFontScale = 1.0;
  static const double maxEntryFontScale = 1.8;

  /// Bounds and default for the weekly working hours (used for overtime).
  static const int minWeeklyHours = 1;
  static const int maxWeeklyHours = 60;
  static const int defaultWeeklyHours = 40;

  /// Languages supported by the app (the first one is the default).
  static const List<Locale> availableLocales = [Locale('en'), Locale('it')];

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.indigo;
  double _entryFontScale = 1.0;
  int _weeklyHours = defaultWeeklyHours;
  Locale _locale = const Locale('en'); // English as default

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  double get entryFontScale => _entryFontScale;
  int get weeklyHours => _weeklyHours;
  Locale get locale => _locale;

  /// Colors offered for the app's main theme.
  static const List<Color> availableColors = [
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.brown,
    Colors.blueGrey,
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_keyThemeMode);
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ThemeMode.values.length) {
      _themeMode = _fromStoredIndex(modeIndex);
    }
    final colorValue = prefs.getInt(_keySeedColor);
    if (colorValue != null) _seedColor = Color(colorValue);
    final scale = prefs.getDouble(_keyEntryFontScale);
    if (scale != null) _entryFontScale = _clampScale(scale);
    final hours = prefs.getInt(_keyWeeklyHours);
    if (hours != null) _weeklyHours = _clampWeeklyHours(hours);
    final language = prefs.getString(_keyLanguage);
    if (language != null &&
        availableLocales.any((l) => l.languageCode == language)) {
      _locale = Locale(language);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, _toStoredIndex(mode));
  }

  Future<void> setSeedColor(Color color) async {
    if (color.toARGB32() == _seedColor.toARGB32()) return;
    _seedColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeedColor, color.toARGB32());
  }

  Future<void> setEntryFontScale(double scale) async {
    final v = _clampScale(scale);
    if (v == _entryFontScale) return;
    _entryFontScale = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyEntryFontScale, v);
  }

  double _clampScale(double v) =>
      v.clamp(minEntryFontScale, maxEntryFontScale).toDouble();

  Future<void> setWeeklyHours(int hours) async {
    final v = _clampWeeklyHours(hours);
    if (v == _weeklyHours) return;
    _weeklyHours = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWeeklyHours, v);
  }

  int _clampWeeklyHours(int v) => v.clamp(minWeeklyHours, maxWeeklyHours);

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, locale.languageCode);
  }

  // Explicit 0=system, 1=light, 2=dark mapping so we don't depend on the
  // order of the ThemeMode enum.
  int _toStoredIndex(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 0,
    ThemeMode.light => 1,
    ThemeMode.dark => 2,
  };

  ThemeMode _fromStoredIndex(int index) => switch (index) {
    1 => ThemeMode.light,
    2 => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

/// Global instance used by the app and the Settings screen.
final ThemeController themeController = ThemeController();
