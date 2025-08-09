import 'package:flutter/material.dart';

class AppTheme {
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryLight = Color(0xFF42A5F5);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryDark),
    scaffoldBackgroundColor: Colors.white,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
