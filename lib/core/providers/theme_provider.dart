import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkTheme';
  bool _isDarkTheme = false;
  final SharedPreferences? prefs;

  ThemeProvider({this.prefs}) {
    _loadTheme();
  }

  bool get isDarkTheme => _isDarkTheme;

  ThemeMode get themeMode => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    _isDarkTheme = prefs?.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    await prefs?.setBool(_themeKey, _isDarkTheme);
  }
}
