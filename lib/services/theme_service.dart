import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    
    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
  
  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await prefs.setString(_themeKey, themeString);
  }
  
  Future<void> setThemeFromString(String themeString) async {
    switch (themeString) {
      case 'Light':
        await setTheme(ThemeMode.light);
        break;
      case 'Dark':
        await setTheme(ThemeMode.dark);
        break;
      case 'System Default':
      default:
        await setTheme(ThemeMode.system);
        break;
    }
  }
}
