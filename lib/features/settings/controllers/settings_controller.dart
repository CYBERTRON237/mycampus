import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsController with ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  late AppSettings _settings;
  bool _isInitialized = false;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get darkMode => _settings.darkMode;
  String get language => _settings.language;
  String get themeColor => _settings.themeColor;
  bool get readReceipts => _settings.readReceipts;
  bool get screenSecurity => _settings.screenSecurity;
  bool get autoDownload => _settings.autoDownload;
  bool get highQualityUpload => _settings.highQualityUpload;
  bool get vibrate => _settings.vibrate;
  bool get popupNotification => _settings.popupNotification;
  String get fontSize => _settings.fontSize;
  bool get enterKeySends => _settings.enterKeySends;
  bool get backupEnabled => _settings.backupEnabled;
  String? get chatWallpaper => _settings.chatWallpaper;
  
  // Initialisation
  Future<void> loadSettings() async {
    _settings = await _settingsService.loadSettings();
    _isInitialized = true;
    notifyListeners();
  }
  
  // Méthodes pour mettre à jour les paramètres
  Future<void> updateNotifications(bool enabled) async {
    _settings.notificationsEnabled = enabled;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleDarkMode(bool value) async {
    _settings.darkMode = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> changeLanguage(String newLanguage) async {
    _settings.language = newLanguage;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> changeThemeColor(String color) async {
    _settings.themeColor = color;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleReadReceipts(bool value) async {
    _settings.readReceipts = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleScreenSecurity(bool value) async {
    _settings.screenSecurity = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleAutoDownload(bool value) async {
    _settings.autoDownload = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleUploadQuality(bool value) async {
    _settings.highQualityUpload = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleVibrate(bool value) async {
    _settings.vibrate = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> togglePopupNotification(bool value) async {
    _settings.popupNotification = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> changeFontSize(String size) async {
    _settings.fontSize = size;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleEnterKeySends(bool value) async {
    _settings.enterKeySends = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> toggleBackup(bool value) async {
    _settings.backupEnabled = value;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
  
  Future<void> changeChatWallpaper(String? wallpaper) async {
    _settings.chatWallpaper = wallpaper;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }
}
