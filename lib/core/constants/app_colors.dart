import 'package:flutter/material.dart';

/// KidQuest — App Color Palette
/// Two themes: child (vivid game-like) & parent (clean minimal)
class AppColors {
  // ── Core Palette ─────────────────────────────────────────
  static const Color primaryStrong = Color(0xFF7B61FF);  // Vibrant purple for buttons
  static const Color softPurple = Color(0xFFAFA8FF);    // Tasks background
  static const Color softBlue = Color(0xFFAEE2FF);      // Tasks accent
  static const Color softYellow = Color(0xFFFFF3B0);    // Rewards
  static const Color softMint = Color(0xFFB4F8C8);      // Progress / Success
  static const Color background = Color(0xFFF9FAFB);    // Main off-white background
  static const Color white = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF2D3142);      // Dark blue-grey for readability
  static const Color textSub = Color(0xFF9094A6);       // Muted subtext

  // ── Semantic Colors ─────────────────────────────────────
  static const Color taskColor = primaryStrong;
  static const Color rewardColor = Color(0xFFFFC107);    // Warmer yellow for rewards
  static const Color progressColor = Color(0xFF4CAF50);  // Green for progress

  // ── Gradients (Soft & Playful) ──────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF7B61FF),
    Color(0xFF9C88FF),
  ];
  static const List<Color> taskGradient = [
    Color(0xFFAFA8FF),
    Color(0xFFAEE2FF),
  ];
  static const List<Color> rewardGradient = [
    Color(0xFFFFF3B0),
    Color(0xFFFFE082),
  ];
  static const List<Color> progressGradient = [
    Color(0xFFB4F8C8),
    Color(0xFFA5D6A7),
  ];

  // Mission card gradients (refined pastel palette)
  static const List<List<Color>> missionCardGradients = [
    [Color(0xFFAFA8FF), Color(0xFFAEE2FF)], // Purple/Blue
    [Color(0xFFAEE2FF), Color(0xFFB4F8C8)], // Blue/Mint
    [Color(0xFFB4F8C8), Color(0xFFFFF3B0)], // Mint/Yellow
    [Color(0xFFAFA8FF), Color(0xFFC5CAE9)], // Deep Purple/Light
  ];

  // ── Shared / Utils ──────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color transparent = Colors.transparent;

  // ── Shadow Styles ──────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];
}
