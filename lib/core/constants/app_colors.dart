import 'package:flutter/material.dart';

/// Hero Mission — App Color Palette
/// Two themes: child (vivid game-like) & parent (clean minimal)
class AppColors {
  // ── Core Palette ─────────────────────────────────────────
  static const Color primaryStrong = Color(0xFF6C63FF);  // Modern Soft Purple
  static const Color softPurple = Color(0xFF8E7CFF);     // Secondary Purple
  static const Color softBlue = Color(0xFFAEE2FF);       // Tasks accent
  static const Color softYellow = Color(0xFFFFF3B0);     // Rewards
  static const Color softMint = Color(0xFFB4F8C8);       // Progress / Success
  static const Color background = Color(0xFFF7F8FC);     // Light grey/white background
  static const Color white = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF2D3142);       // Dark blue-grey for readability
  static const Color textSub = Color(0xFF9094A6);        // Muted subtext

  // ── Dark Mode Palette ────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F121F);
  static const Color darkSurface = Color(0xFF1A1F3D);
  static const Color darkTextMain = Color(0xFFFFFFFF);
  static const Color darkTextSub = Color(0xFFD1D5DB);

  // ── Semantic Colors ─────────────────────────────────────
  static const Color taskColor = primaryStrong;
  static const Color rewardColor = Color(0xFFFFC107);    // Warmer yellow for rewards
  static const Color progressColor = Color(0xFF4CAF50);  // Green for progress

  // ── Gradients (Soft & Playful) ──────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF8E7CFF),
  ];
  
  static const List<Color> taskGradient = [
    Color(0xFF8E7CFF),
    Color(0xFFAEE2FF),
  ];
  
  static const List<Color> rewardGradient = [
    Color(0xFFFFE082),
    Color(0xFFFFC107),
  ];
  
  static const List<Color> progressGradient = [
    Color(0xFFB4F8C8),
    Color(0xFF81C784),
  ];

  // Mission card gradients (refined pastel palette)
  static const List<List<Color>> missionCardGradients = [
    [Color(0xFF8E7CFF), Color(0xFFAEE2FF)], // Purple/Blue
    [Color(0xFFAEE2FF), Color(0xFFB4F8C8)], // Blue/Mint
    [Color(0xFFB4F8C8), Color(0xFFFFF3B0)], // Mint/Yellow
    [Color(0xFF8E7CFF), Color(0xFFC5CAE9)], // Deep Purple/Light
  ];

  // ── Shared / Utils ──────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color transparent = Colors.transparent;

  // ── Shadow Styles ──────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // ── Honor / Medal Theme ─────────────────────────────────
  static const Color honorBackground = Color(0xFF1A1F3D); // Dark Navy
  static const Color honorCard = Color(0xFF262B4D);       // Lighter card blue
  static const Color honorAccent = Color(0xFF6C63FF);     // Purple ribbon
  static const Color honorGold = Color(0xFFFFD700);       // Gold
  static const List<Color> honorMedalGradient = [
    Color(0xFF8E7CFF),
    Color(0xFF6C63FF),
  ];
}
