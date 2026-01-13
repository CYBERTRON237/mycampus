import 'package:flutter/material.dart';
import 'presentation/pages/settings_page.dart';

class SettingsRoutes {
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      settings: (context) => const SettingsPage(),
    };
  }
}
