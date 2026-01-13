import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/theme_provider.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Tooltip(
      message: themeProvider.isDarkTheme ? 'Thème clair' : 'Thème sombre',
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: themeProvider.isDarkTheme
              ? const Icon(Icons.light_mode, key: ValueKey('light'))
              : const Icon(Icons.dark_mode, key: ValueKey('dark')),
        ),
        onPressed: () => themeProvider.toggleTheme(),
      ),
    );
  }
}
