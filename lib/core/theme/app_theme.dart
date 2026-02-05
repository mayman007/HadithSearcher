import 'package:flutter/material.dart';
import '../../models/settings.dart';

/// App theme configuration.
class AppTheme {
  AppTheme._();

  static Color _accentColor = Colors.blue;

  /// Set the accent color for themes.
  static void setAccentColor(ColorSchemePreference colorScheme) {
    _accentColor = colorScheme.primaryColor;
  }

  /// Light theme.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1.5, color: Colors.black),
          borderRadius: BorderRadius.circular(50),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: _accentColor),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _accentColor,
        onPrimary: Colors.white,
        primaryContainer: const Color.fromARGB(255, 225, 226, 230),
        secondaryContainer: _accentColor,
        secondary: _accentColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.red,
        surface: Colors.white,
        onSurface: Colors.black,
      ),
    );
  }

  /// Dark theme.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 1.5, color: Colors.white),
          borderRadius: BorderRadius.circular(50),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: _accentColor),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: _accentColor,
        onPrimary: Colors.white,
        primaryContainer: const Color.fromARGB(255, 40, 38, 41),
        secondaryContainer: _accentColor,
        secondary: _accentColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.red,
        surface: Colors.black,
        onSurface: Colors.white,
      ),
    );
  }
}
