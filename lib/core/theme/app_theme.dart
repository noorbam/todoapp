import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// KidQuest — Theme Configuration
/// Two distinct themes: childTheme (game-like) and parentTheme (professional)
class AppTheme {
  // ── Common Style Helpers ──────────────────────────────────────────────────
  static double get largeRadius => 32.0;
  static double get mediumRadius => 20.0;
  static double get smallRadius => 12.0;

  // ── Child Theme ────────────────────────────────────────────────────────────
  static ThemeData get childTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryStrong,
        secondary: AppColors.softYellow,
        surface: AppColors.white,
        error: AppColors.error,
        onSurface: AppColors.textMain,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textMain,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textMain,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textMain,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryStrong,
          foregroundColor: AppColors.white,
          elevation: 4,
          shadowColor: AppColors.primaryStrong.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(mediumRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          textStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.textMain,
        ),
        iconTheme: const IconThemeData(color: AppColors.textMain),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          borderSide: const BorderSide(color: AppColors.primaryStrong, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSub),
      ),
    );
  }

  // ── Parent Theme ───────────────────────────────────────────────────────────
  static ThemeData get parentTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryStrong,
        secondary: AppColors.softBlue,
        surface: AppColors.white,
        error: AppColors.error,
        onSurface: AppColors.textMain,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textMain,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          color: AppColors.textMain,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mediumRadius),
          side: BorderSide(color: AppColors.textSub.withValues(alpha: 0.1)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryStrong,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: BorderSide(color: AppColors.textSub.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: AppColors.primaryStrong, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSub),
      ),
      dividerTheme: DividerThemeData(color: AppColors.textSub.withValues(alpha: 0.1)),
    );
  }
}
