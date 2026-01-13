import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  // Couleurs pour le thème clair
  static const Color lightPrimary = Color(0xFF1976D2);
  static const Color lightAccent = Color(0xFF2196F3);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightError = Color(0xFFB00020);
  static const Color lightText = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF757575);
  
  // Couleurs pour le thème sombre
  static const Color darkPrimary = Color(0xFF2196F3);
  static const Color darkAccent = Color(0xFF64B5F6);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFFF5252);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeKey = 'theme_mode';

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Méthode pour obtenir le thème actuel avec les couleurs personnalisées
  ThemeData get currentTheme => isDarkMode ? _darkTheme : _lightTheme;

  // Thème clair personnalisé
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.lightText,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      titleLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Colors.white),
    ),
  );

  // Thème sombre personnalisé
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AppColors.darkText,
      onError: Colors.black,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Colors.black),
    ),
  );

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null) {
        _themeMode = ThemeMode.values[themeIndex];
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement du thème: $e');
      _themeMode = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    // Bascule simplement entre clair et sombre
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
            
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du thème: $e');
    }
  }
}
