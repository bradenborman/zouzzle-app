import 'package:flutter/material.dart';

class AppTheme {
  static const mizzouGold  = Color(0xFFF1B82D);
  static const mizzouBlack = Color(0xFF000000);
  static const exactGreen  = Color(0xFF538D4E);
  static const closeYellow = Color(0xFFB59F3B);
  static const missGray    = Color(0xFF3A3A3C);
  static const white       = Color(0xFFFFFFFF);

  static ThemeData get theme => ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: mizzouGold,
      onPrimary: mizzouBlack,
      surface: mizzouBlack,
    ),
    scaffoldBackgroundColor: mizzouBlack,
    appBarTheme: const AppBarTheme(
      backgroundColor: mizzouBlack,
      foregroundColor: mizzouGold,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: mizzouGold, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: mizzouGold,
        foregroundColor: mizzouBlack,
      ),
    ),
  );
}
