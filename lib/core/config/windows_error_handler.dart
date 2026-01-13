// Windows-specific error handler for accessibility issues
import 'package:flutter/foundation.dart';

class WindowsErrorHandler {
  static bool isAccessibilityViewIdError(dynamic error) {
    final errorString = error.toString();
    return errorString.contains('viewId') && 
           (errorString.contains('FlutterViewId') || errorString.contains('accessibility_plugin'));
  }
  
  static void handleAccessibilityError() {
    // Silently handle accessibility viewId errors on Windows
    if (defaultTargetPlatform == TargetPlatform.windows) {
      // Completely silent - don't even print in debug mode
    }
  }
  
  static bool shouldFilterError(dynamic error) {
    if (defaultTargetPlatform != TargetPlatform.windows) {
      return false;
    }
    
    final errorString = error.toString().toLowerCase();
    final accessibilityKeywords = [
      'viewid', 'flutterviewid', 'accessibility_plugin', 
      'announce message', 'presence heartbeat'
    ];
    
    return accessibilityKeywords.any((keyword) => errorString.contains(keyword));
  }
}
