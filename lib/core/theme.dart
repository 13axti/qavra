import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0F0F14);
  static const surface = Color(0xFF1C1C28);
  static const surfaceVariant = Color(0xFF252535);
  static const primary = Color(0xFF7C6FE0);
  static const primaryDark = Color(0xFF5A4FC7);
  static const correct = Color(0xFF4CAF7D);
  static const wrong = Color(0xFFE05C5C);
  static const text = Colors.white;
  static const subtext = Color(0xFF9898B0);
  static const streak = Color(0xFFFF9800);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    surface: AppColors.surface,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    onSurface: AppColors.text,
  ),
  cardTheme: const CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: AppColors.text, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.subtext, fontSize: 14),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600),
    iconTheme: IconThemeData(color: AppColors.text),
  ),
);
