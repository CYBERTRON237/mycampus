import 'package:flutter/foundation.dart';

class AppSettings with ChangeNotifier {
  bool _notificationsEnabled;
  bool _darkMode;
  String _language;
  String _themeColor;
  bool _readReceipts;
  bool _screenSecurity;
  bool _autoDownload;
  bool _highQualityUpload;
  bool _vibrate;
  bool _popupNotification;
  String _fontSize;
  bool _enterKeySends;
  bool _backupEnabled;
  String? _chatWallpaper;

  AppSettings({
    bool? notificationsEnabled = true,
    bool? darkMode = false,
    String? language = 'fr',
    String? themeColor = 'blue',
    bool? readReceipts = true,
    bool? screenSecurity = true,
    bool? autoDownload = true,
    bool? highQualityUpload = false,
    bool? vibrate = true,
    bool? popupNotification = true,
    String? fontSize = 'medium',
    bool? enterKeySends = true,
    bool? backupEnabled = false,
    String? chatWallpaper,
  })  : _notificationsEnabled = notificationsEnabled ?? true,
        _darkMode = darkMode ?? false,
        _language = language ?? 'fr',
        _themeColor = themeColor ?? 'blue',
        _readReceipts = readReceipts ?? true,
        _screenSecurity = screenSecurity ?? true,
        _autoDownload = autoDownload ?? true,
        _highQualityUpload = highQualityUpload ?? false,
        _vibrate = vibrate ?? true,
        _popupNotification = popupNotification ?? true,
        _fontSize = fontSize ?? 'medium',
        _enterKeySends = enterKeySends ?? true,
        _backupEnabled = backupEnabled ?? false,
        _chatWallpaper = chatWallpaper;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  String get language => _language;
  String get themeColor => _themeColor;
  bool get readReceipts => _readReceipts;
  bool get screenSecurity => _screenSecurity;
  bool get autoDownload => _autoDownload;
  bool get highQualityUpload => _highQualityUpload;
  bool get vibrate => _vibrate;
  bool get popupNotification => _popupNotification;
  String get fontSize => _fontSize;
  bool get enterKeySends => _enterKeySends;
  bool get backupEnabled => _backupEnabled;
  String? get chatWallpaper => _chatWallpaper;

  // Setters with notifyListeners
  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  set darkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  set language(String value) {
    _language = value;
    notifyListeners();
  }

  set themeColor(String value) {
    _themeColor = value;
    notifyListeners();
  }

  set readReceipts(bool value) {
    _readReceipts = value;
    notifyListeners();
  }

  set screenSecurity(bool value) {
    _screenSecurity = value;
    notifyListeners();
  }

  set autoDownload(bool value) {
    _autoDownload = value;
    notifyListeners();
  }

  set highQualityUpload(bool value) {
    _highQualityUpload = value;
    notifyListeners();
  }

  set vibrate(bool value) {
    _vibrate = value;
    notifyListeners();
  }

  set popupNotification(bool value) {
    _popupNotification = value;
    notifyListeners();
  }

  set fontSize(String value) {
    _fontSize = value;
    notifyListeners();
  }

  set enterKeySends(bool value) {
    _enterKeySends = value;
    notifyListeners();
  }

  set backupEnabled(bool value) {
    _backupEnabled = value;
    notifyListeners();
  }

  set chatWallpaper(String? value) {
    _chatWallpaper = value;
    notifyListeners();
  }

  // Convert to/from map for persistence
  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': _notificationsEnabled,
      'darkMode': _darkMode,
      'language': _language,
      'themeColor': _themeColor,
      'readReceipts': _readReceipts,
      'screenSecurity': _screenSecurity,
      'autoDownload': _autoDownload,
      'highQualityUpload': _highQualityUpload,
      'vibrate': _vibrate,
      'popupNotification': _popupNotification,
      'fontSize': _fontSize,
      'enterKeySends': _enterKeySends,
      'backupEnabled': _backupEnabled,
      'chatWallpaper': _chatWallpaper,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'fr',
      themeColor: map['themeColor'] ?? 'blue',
      readReceipts: map['readReceipts'] ?? true,
      screenSecurity: map['screenSecurity'] ?? true,
      autoDownload: map['autoDownload'] ?? true,
      highQualityUpload: map['highQualityUpload'] ?? false,
      vibrate: map['vibrate'] ?? true,
      popupNotification: map['popupNotification'] ?? true,
      fontSize: map['fontSize'] ?? 'medium',
      enterKeySends: map['enterKeySends'] ?? true,
      backupEnabled: map['backupEnabled'] ?? false,
      chatWallpaper: map['chatWallpaper'],
    );
  }
}
