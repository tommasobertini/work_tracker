import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'services/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Date formatting data for the supported languages.
  await initializeDateFormatting('en');
  await initializeDateFormatting('it');
  await themeController.load();
  runApp(const WorkTrackerApp());
}

class WorkTrackerApp extends StatelessWidget {
  const WorkTrackerApp({super.key});

  /// Builds the theme for the given brightness, with the AppBar colored
  /// according to the selected main color.
  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: themeController.seedColor,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Work Tracker',
          debugShowCheckedModeBanner: false,
          themeMode: themeController.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          locale: themeController.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        );
      },
    );
  }
}
