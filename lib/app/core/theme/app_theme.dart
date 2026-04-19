import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF2F6FED);
  static const Color primaryDark = Color(0xFF1A54CC);
  static const Color primaryLight = Color(0xFF5B8FF3);
  static const Color accent = Color(0xFF00D4A3);
  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF18C76E);
  static const Color danger = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB300);
  static const Color textPrimary = Color(0xFF1A2340);
  static const Color textSecondary = Color(0xFF8A93A8);
  static const Color divider = Color(0xFFEBEEF5);

  // Preset category colors for picker
  static const List<Color> paletteColors = [
    Color(0xFF2F6FED),
    Color(0xFFFF5252),
    Color(0xFF18C76E),
    Color(0xFFFFB300),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF6D00),
    Color(0xFF607D8B),
    Color(0xFFE91E63),
    Color(0xFF4CAF50),
    Color(0xFF795548),
    Color(0xFF3F51B5),
  ];



  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        error: danger,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.dmSans(
              color: textPrimary,
              fontWeight: FontWeight.w800,
            ),
            headlineLarge: GoogleFonts.dmSans(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
            headlineMedium: GoogleFonts.dmSans(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
            headlineSmall: GoogleFonts.dmSans(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: GoogleFonts.dmSans(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: GoogleFonts.dmSans(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.dmSans(color: textPrimary),
            bodyMedium: GoogleFonts.dmSans(color: textSecondary),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
    );
  }
}
