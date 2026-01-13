// lib/constants/app_styles.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Primary Text Styles (const where possible)
  // Text styles with a more professional and compact design
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading5 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading6 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Text styles for profile page
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textLight,
    letterSpacing: 0.2,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Additional text styles for better hierarchy
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );
  
  static const TextStyle subtitle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ---------------------
  // Backwards-compatible aliases
  static const TextStyle titleLarge = heading5;
  static const TextStyle titleMedium = heading6;
  static const TextStyle titleSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Material 2 legacy support
  static const TextStyle headline6 = heading6;
  static const TextStyle headline5 = heading5;
  static const TextStyle headline4 = heading4;
  static const TextStyle headline3 = heading3;
  static const TextStyle headline2 = heading2;
  static const TextStyle headline1 = heading1;
  
  static const TextStyle subtitle1 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle body1 = bodyText1;
  static const TextStyle body2 = bodyText2;
  
  static const TextStyle buttonText = button;
  
  static const TextStyle captionText = caption;
  
  static const TextStyle overlineText = overline;

  // ---------------------
  // Theme Data
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: Colors.white,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      displayLarge: heading1,
      displayMedium: heading2,
      displaySmall: heading3,
      headlineMedium: heading4,
      titleLarge: heading5,
      titleMedium: heading6,
      bodyLarge: bodyText1,
      bodyMedium: bodyText2,
      labelLarge: button,
      bodySmall: caption,
    ),
    appBarTheme: appBarTheme,
    tabBarTheme: tabBarTheme,
    dividerTheme: dividerTheme,
    bottomNavigationBarTheme: bottomNavBarTheme,
    // You can add other theme customizations here
  );

  // ---------------------
  // App Bar Theme
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: AppColors.primary,
    elevation: 0.5,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    actionsIconTheme: IconThemeData(
      color: Colors.white,
      size: 20,
    ),
    titleSpacing: 16,
    toolbarHeight: 56,
  );

  // ---------------------
  // Tab Bar Theme
  static const TabBarThemeData tabBarTheme = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    indicatorSize: TabBarIndicatorSize.label,
    labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    indicator: const UnderlineTabIndicator(
      borderSide: BorderSide(width: 2, color: AppColors.primary),
    ),
    labelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    unselectedLabelStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      letterSpacing: 0.1,
    ),
  );

  // Alias for backward compatibility
  static TabBarThemeData get tabBarThemeData => tabBarTheme;

  // ---------------------
  // Bottom Navigation Bar Theme
  static const BottomNavigationBarThemeData bottomNavBarTheme =
      BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textLight,
    selectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      height: 1.4,
    ),
    showSelectedLabels: true,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 4,
  );

  // ---------------------
  // Divider Theme
  static const DividerThemeData dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  );

  // ---------------------
  // Input decoration (common style used throughout the app)
  static InputDecoration inputDecoration = InputDecoration(
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border, width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.error, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(
      color: AppColors.textLight,
      fontSize: 14,
    ),
    errorStyle: const TextStyle(
      color: AppColors.error,
      fontSize: 12,
      height: 1.2,
    ),
    errorMaxLines: 2,
    isDense: true,
  );

  // ---------------------
  // Button Styles
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    textStyle: button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: const Size(64, 40),
  );

  static final ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    backgroundColor: Colors.transparent,
    side: const BorderSide(color: AppColors.primary, width: 1.0),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    textStyle: button.copyWith(color: AppColors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    elevation: 0,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: const Size(64, 40),
  );
  
  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    textStyle: button.copyWith(
      color: AppColors.primary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    minimumSize: const Size(32, 36),
  );
  
  static final ButtonStyle iconButtonStyle = IconButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.all(8),
    minimumSize: const Size(40, 40),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  );
  
  // Card style
  static final CardTheme cardTheme = CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    ),
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.all(0),
  );
  
  // Common padding values
  static const EdgeInsets defaultPadding = EdgeInsets.all(16);
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  
  // Common border radius
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(4));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(8));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(12));
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 250);
  static const Duration longAnimationDuration = Duration(milliseconds: 350);
}
