import 'package:flutter/material.dart';

/// App settings for theme and hadith display preferences.
class AppSettings {
  final ThemePreference theme;
  final ColorSchemePreference colorScheme;
  final String fontFamily;
  final FontWeightPreference fontWeight;
  final int fontSize;
  final int padding;

  const AppSettings({
    this.theme = ThemePreference.system,
    this.colorScheme = ColorSchemePreference.blue,
    this.fontFamily = 'Roboto',
    this.fontWeight = FontWeightPreference.bold,
    this.fontSize = 20,
    this.padding = 10,
  });

  /// Creates settings from database row.
  factory AppSettings.fromDatabase(Map<String, dynamic> row) {
    return AppSettings(
      theme: ThemePreference.fromString(row['theme'] ?? 'system'),
      colorScheme:
          ColorSchemePreference.fromString(row['colorscheme'] ?? 'blue'),
      fontFamily: row['fontfamily'] ?? 'Roboto',
      fontWeight: FontWeightPreference.fromString(row['fontweight'] ?? 'bold'),
      fontSize: row['fontsize'] ?? 20,
      padding: row['padding'] ?? 10,
    );
  }

  /// Default settings.
  static const AppSettings defaults = AppSettings();

  /// Flutter ThemeMode based on preference.
  ThemeMode get themeMode => theme.toThemeMode();

  /// Flutter FontWeight based on preference.
  FontWeight get flutterFontWeight => fontWeight.toFontWeight();

  /// EdgeInsets based on padding value.
  EdgeInsets get paddingInsets => EdgeInsets.all(padding.toDouble());

  /// Creates a copy with updated values.
  AppSettings copyWith({
    ThemePreference? theme,
    ColorSchemePreference? colorScheme,
    String? fontFamily,
    FontWeightPreference? fontWeight,
    int? fontSize,
    int? padding,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      colorScheme: colorScheme ?? this.colorScheme,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      fontSize: fontSize ?? this.fontSize,
      padding: padding ?? this.padding,
    );
  }
}

/// Theme preference enum.
enum ThemePreference {
  system,
  light,
  dark;

  /// Converts string from database to enum.
  static ThemePreference fromString(String value) {
    switch (value) {
      case 'light':
        return ThemePreference.light;
      case 'dark':
        return ThemePreference.dark;
      default:
        return ThemePreference.system;
    }
  }

  /// Converts to string for database storage.
  String toDbString() {
    switch (this) {
      case ThemePreference.light:
        return 'light';
      case ThemePreference.dark:
        return 'dark';
      case ThemePreference.system:
        return 'system';
    }
  }

  /// Converts to Flutter ThemeMode.
  ThemeMode toThemeMode() {
    switch (this) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  /// Arabic display name.
  String get arabicName {
    switch (this) {
      case ThemePreference.system:
        return 'إتباع النظام';
      case ThemePreference.light:
        return 'الوضع النهاري';
      case ThemePreference.dark:
        return 'الوضع الليلي';
    }
  }
}

/// Font weight preference enum.
enum FontWeightPreference {
  normal,
  bold;

  /// Converts string from database to enum.
  static FontWeightPreference fromString(String value) {
    switch (value) {
      case 'bold':
        return FontWeightPreference.bold;
      default:
        return FontWeightPreference.normal;
    }
  }

  /// Converts to string for database storage.
  String toDbString() {
    switch (this) {
      case FontWeightPreference.normal:
        return 'normal';
      case FontWeightPreference.bold:
        return 'bold';
    }
  }

  /// Converts to Flutter FontWeight.
  FontWeight toFontWeight() {
    switch (this) {
      case FontWeightPreference.normal:
        return FontWeight.normal;
      case FontWeightPreference.bold:
        return FontWeight.bold;
    }
  }

  /// Arabic display name.
  String get arabicName {
    switch (this) {
      case FontWeightPreference.normal:
        return 'عادي';
      case FontWeightPreference.bold:
        return 'عريض';
    }
  }
}

/// Color scheme preference enum.
enum ColorSchemePreference {
  blue,
  green,
  purple,
  orange,
  red,
  teal;

  /// Converts string from database to enum.
  static ColorSchemePreference fromString(String value) {
    switch (value) {
      case 'green':
        return ColorSchemePreference.green;
      case 'purple':
        return ColorSchemePreference.purple;
      case 'orange':
        return ColorSchemePreference.orange;
      case 'red':
        return ColorSchemePreference.red;
      case 'teal':
        return ColorSchemePreference.teal;
      default:
        return ColorSchemePreference.blue;
    }
  }

  /// Converts to string for database storage.
  String toDbString() => name;

  /// Gets the primary color for this scheme.
  Color get primaryColor {
    switch (this) {
      case ColorSchemePreference.blue:
        return Colors.blue;
      case ColorSchemePreference.green:
        return Colors.green;
      case ColorSchemePreference.purple:
        return Colors.purple;
      case ColorSchemePreference.orange:
        return Colors.orange;
      case ColorSchemePreference.red:
        return Colors.red;
      case ColorSchemePreference.teal:
        return Colors.teal;
    }
  }

  /// Arabic display name.
  String get arabicName {
    switch (this) {
      case ColorSchemePreference.blue:
        return 'أزرق';
      case ColorSchemePreference.green:
        return 'أخضر';
      case ColorSchemePreference.purple:
        return 'بنفسجي';
      case ColorSchemePreference.orange:
        return 'برتقالي';
      case ColorSchemePreference.red:
        return 'أحمر';
      case ColorSchemePreference.teal:
        return 'أزرق مخضر';
    }
  }
}
