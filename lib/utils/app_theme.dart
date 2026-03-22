// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const greenDeep   = Color(0xFF0A3B2E);
  static const greenMid    = Color(0xFF15603F);
  static const greenAccent = Color(0xFF2FC87A);
  static const greenPale   = Color(0xFFD4F5E3);
  static const amber       = Color(0xFFF5A623);
  static const red         = Color(0xFFE74C3C);
  static const bg          = Color(0xFFF0F4F1);
  static const surface     = Color(0xFFFFFFFF);
  static const surface2    = Color(0xFFF7FAF8);
  static const border      = Color(0x1F0A3B2E);
  static const textDark    = Color(0xFF0A1F15);
  static const textMid     = Color(0xFF2D5A3D);
  static const textMuted   = Color(0xFF5A8070);

  // Category colors
  static const energyColor    = Color(0xFF1D8A55);
  static const transportColor = Color(0xFFF5A623);
  static const foodColor      = Color(0xFF2FC87A);
  static const wasteColor     = Color(0xFF0A3B2E);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.greenDeep,
      primary: AppColors.greenDeep,
      secondary: AppColors.greenAccent,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge: GoogleFonts.syne(fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.syne(fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.syne(fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.syne(fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.syne(fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.syne(fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.dmSans(fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.dmSans(),
      bodyMedium: GoogleFonts.dmSans(),
    ),
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.greenDeep,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.syne(
        fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenDeep,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.greenMid, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
