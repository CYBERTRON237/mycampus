import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';
  
  // Charger les paramètres
  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_settingsKey);
    
    if (settingsString != null) {
      try {
        final settingsMap = <String, dynamic>{};
        final pairs = settingsString.split(',');
        
        for (final pair in pairs) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            final key = parts[0];
            final value = parts[1];
            
            // Conversion des valeurs selon le type
            if (value == 'true' || value == 'false') {
              settingsMap[key] = value == 'true';
            } else {
              settingsMap[key] = value;
            }
          }
        }
        
        return AppSettings.fromMap(settingsMap);
      } catch (e) {
        // En cas d'erreur, retourner des paramètres par défaut
        return AppSettings();
      }
    }
    
    // Retourner des paramètres par défaut si aucun paramètre n'est sauvegardé
    return AppSettings();
  }
  
  // Sauvegarder les paramètres
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = settings.toMap();
    
    // Convertir la map en une chaîne formatée pour le stockage
    final settingsString = settingsMap.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    
    await prefs.setString(_settingsKey, settingsString);
  }
}
