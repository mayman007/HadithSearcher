import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

/// ViewModel for app-wide settings (theme, font preferences).
/// This is shared across all views.
class SettingsViewModel extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  AppSettings _settings = AppSettings.defaults;
  bool _isLoading = true;

  /// Current settings.
  AppSettings get settings => _settings;

  /// Whether settings are still loading.
  bool get isLoading => _isLoading;

  // Convenience getters for common settings
  String get fontFamily => _settings.fontFamily;
  FontWeight get fontWeight => _settings.flutterFontWeight;
  double get fontSize => _settings.fontSize.toDouble();
  EdgeInsets get padding => _settings.paddingInsets;
  ThemeMode get themeMode => _settings.themeMode;
  ColorSchemePreference get colorScheme => _settings.colorScheme;

  /// Available font families.
  static const List<String> fontFamilies = [
    'Roboto',
    'Amiri',
    'Lateef',
    'Gulzar',
    'Aref Ruqaa',
    'Reem Kufi',
  ];

  /// Available font sizes.
  static const List<int> fontSizes = [10, 20, 30, 40, 50];

  /// Available padding values.
  static const List<int> paddingValues = [5, 10, 15, 20, 25, 30];

  /// Load settings from SharedPreferences.
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _settingsService.getSettings();

    _isLoading = false;
    notifyListeners();
  }

  /// Update theme preference.
  Future<void> setTheme(ThemePreference theme) async {
    await _settingsService.updateTheme(theme);
    _settings = _settings.copyWith(theme: theme);
    notifyListeners();
  }

  /// Update color scheme preference.
  Future<void> setColorScheme(ColorSchemePreference colorScheme) async {
    await _settingsService.updateColorScheme(colorScheme);
    _settings = _settings.copyWith(colorScheme: colorScheme);
    notifyListeners();
  }

  /// Update font family.
  Future<void> setFontFamily(String fontFamily) async {
    await _settingsService.updateFontFamily(fontFamily);
    _settings = _settings.copyWith(fontFamily: fontFamily);
    notifyListeners();
  }

  /// Update font weight.
  Future<void> setFontWeight(FontWeightPreference fontWeight) async {
    await _settingsService.updateFontWeight(fontWeight);
    _settings = _settings.copyWith(fontWeight: fontWeight);
    notifyListeners();
  }

  /// Update font size.
  Future<void> setFontSize(int fontSize) async {
    await _settingsService.updateFontSize(fontSize);
    _settings = _settings.copyWith(fontSize: fontSize);
    notifyListeners();
  }

  /// Update padding.
  Future<void> setPadding(int padding) async {
    await _settingsService.updatePadding(padding);
    _settings = _settings.copyWith(padding: padding);
    notifyListeners();
  }

  /// Reset all settings to defaults.
  Future<void> resetToDefaults() async {
    await _settingsService.resetSettings();
    _settings = AppSettings.defaults;
    notifyListeners();
  }
}
