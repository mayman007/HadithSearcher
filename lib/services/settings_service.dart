import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

/// Service for managing app settings using SharedPreferences.
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _themeKey = 'theme';
  static const String _fontFamilyKey = 'fontFamily';
  static const String _fontWeightKey = 'fontWeight';
  static const String _fontSizeKey = 'fontSize';
  static const String _paddingKey = 'padding';

  SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance.
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get app settings.
  Future<AppSettings> getSettings() async {
    final p = await prefs;
    return AppSettings(
      theme: ThemePreference.fromString(p.getString(_themeKey) ?? 'system'),
      fontFamily: p.getString(_fontFamilyKey) ?? 'Roboto',
      fontWeight: FontWeightPreference.fromString(
          p.getString(_fontWeightKey) ?? 'bold'),
      fontSize: p.getInt(_fontSizeKey) ?? 20,
      padding: p.getInt(_paddingKey) ?? 10,
    );
  }

  /// Get theme string (for initial app load before full settings).
  Future<String> getTheme() async {
    final p = await prefs;
    return p.getString(_themeKey) ?? 'system';
  }

  /// Update theme setting.
  Future<void> updateTheme(ThemePreference theme) async {
    final p = await prefs;
    await p.setString(_themeKey, theme.toDbString());
  }

  /// Update font family setting.
  Future<void> updateFontFamily(String fontFamily) async {
    final p = await prefs;
    await p.setString(_fontFamilyKey, fontFamily);
  }

  /// Update font weight setting.
  Future<void> updateFontWeight(FontWeightPreference fontWeight) async {
    final p = await prefs;
    await p.setString(_fontWeightKey, fontWeight.toDbString());
  }

  /// Update font size setting.
  Future<void> updateFontSize(int fontSize) async {
    final p = await prefs;
    await p.setInt(_fontSizeKey, fontSize);
  }

  /// Update padding setting.
  Future<void> updatePadding(int padding) async {
    final p = await prefs;
    await p.setInt(_paddingKey, padding);
  }

  /// Reset all settings to defaults.
  Future<void> resetSettings() async {
    final p = await prefs;
    await p.setString(_themeKey, 'system');
    await p.setString(_fontFamilyKey, 'Roboto');
    await p.setString(_fontWeightKey, 'bold');
    await p.setInt(_fontSizeKey, 20);
    await p.setInt(_paddingKey, 10);
  }
}
