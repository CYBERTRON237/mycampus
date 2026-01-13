import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales - plus douces et apaisantes
  static const MaterialColor primaryMaterial = MaterialColor(
    0xFF1976D2,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );
  
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF4F46E5);     // Bleu plus foncé
  static const Color primaryLight = Color(0xFFE8EAF6);     // Bleu très clair
  static const Color accent = Color(0xFF64B5F6);        // Vert d'eau apaisant
  static const Color secondary = Color(0xFFF97316);        // Orange pêche doux
  
  // Couleurs de texte - meilleur contraste pour le mode clair
  static const Color textPrimary = Color(0xFF1A1A1A);     // Noir doux
  static const Color textSecondary = Color(0xFF4A5568);     // Gris bleuté
  static const Color textLight = Color(0xFF6B7280);       // Gris moyen
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Color(0xFF1A1A1A);
  
  // Couleurs d'arrière-plan - plus douces et moins agressives
  static const Color lightBackground = Color(0xFFFAFBFC);   // Blanc cassé très doux
  static const Color background = Color(0xFFF8FAFC);     // Blanc légèrement teinté
  static const Color backgroundLight = Color(0xFFF5F5F5);   // gris clair pour le module de messagerie
  static const Color backgroundDark = Color(0xFF121212);    // Noir foncé pour mode sombre
  static const Color surface = Color(0xFFFEFEFE);        // Blanc pur
  static const Color surfaceLight = Color(0xFFFFFFFF);   // Blanc pur pour mode clair
  static const Color surfaceDark = Color(0xFF1E1E1E);     // Gris foncé pour mode sombre
  static const Color error = Color(0xFFDC2626);           // Rouge plus doux
  
  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFF44336);
  
  // Couleurs supplémentaires
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x40000000);
  
  // Couleurs pour les graphiques
  static const List<Color> chartColors = [
    Color(0xFF4285F4),
    Color(0xFF34A853),
    Color(0xFFFBBC05),
    Color(0xFFEA4335),
    Color(0xFF673AB7),
    Color(0xFFFF5722),
    Color(0xFF00BCD4),
    Color(0xFF8BC34A),
  ];
  
  // Dégradés - avec les nouvelles couleurs douces
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],  // Bleu doux dégradé
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFFDBA5C)],  // Orange pêche dégradé
  );
  
  // Couleurs par rôle
  static const Map<String, Color> roleColors = {
    'admin': Color(0xFFD32F2F),
    'teacher': Color(0xFF1976D2),
    'student': Color(0xFF388E3C),
    'parent': Color(0xFF7B1FA2),
    'staff': Color(0xFFFFA000),
  };
  
  // Obtenir une couleur en fonction du rôle
  static Color getRoleColor(String role) {
    return roleColors[role.toLowerCase()] ?? Colors.grey;
  }
}