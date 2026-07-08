import 'package:flutter/material.dart';

class AppTheme {
  // Palette de couleurs basée sur la conception technique
  static const Color primaryColor = Color(0xFF1a73e8); // Bleu
  static const Color secondaryColor = Color(0xFF34a853); // Vert
  static const Color accentColor = Color(0xFFfbbc04); // Orange
  static const Color backgroundColor = Color(0xFff8f9fa); // Gris clair
  static const Color textPrimaryColor = Color(0xFF202124); // Texte principal
  static const Color textSecondaryColor = Color(0xFF5f6368); // Texte secondaire
  static const Color errorColor = Color(0xFFd33b27); // Rouge
  static const Color successColor = Color(0xFF34a853); // Vert
  static const Color warningColor = Color(0xFFfbbc04); // Orange

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondaryColor,
        ),
      ),
    );
  }
}

