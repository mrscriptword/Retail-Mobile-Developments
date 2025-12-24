import 'package:flutter/material.dart';
import '../main.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: isDark ? Colors.white : Colors.black87,
      ),
      onPressed: () {
        final appState = MyApp.of(context);
        appState?.changeTheme(
          isDark ? ThemeMode.light : ThemeMode.dark,
        );
      },
      tooltip: isDark ? 'Light Mode' : 'Dark Mode',
    );
  }
}
