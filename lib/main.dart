import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database (for favourites)
  final db = DatabaseService();
  await db.database;

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Get initial theme for fast startup
  final settingsService = SettingsService();
  final themeString = await settingsService.getTheme();
  final initialThemeMode = _getThemeMode(themeString);

  runApp(HadithSearcherApp(initialThemeMode: initialThemeMode));
}

ThemeMode _getThemeMode(String theme) {
  switch (theme) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}
