import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../core/constants/app_colors.dart';

/// Celebration screen — shown after completing a mission
/// Full-screen confetti with points earned animation
class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({super.key});

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    // Start confetti after frame builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int points = (ModalRoute.of(context)!.settings.arguments as int?) ?? 10;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFE8EAF6), Color(0xFFF3E5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Confetti from top
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primaryStrong,
                AppColors.rewardColor,
                AppColors.success,
                Color(0xFF6C63FF),
                Color(0xFFFF8A65),
                Color(0xFFF48FB1),
              ],
              numberOfParticles: 50,
              gravity: 0.3,
              emissionFrequency: 0.06,
              maxBlastForce: 30,
              minBlastForce: 15,
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy
                  const Text('🏆', style: TextStyle(fontSize: 110))
                      .animate()
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 32),

                  // Mission Complete title
                  Text(
                    'Mission Complete!',
                    style: GoogleFonts.nunito(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'You\'re a true hero! 🦸',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      color: AppColors.textSub,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                  const SizedBox(height: 48),

                  // Points earned card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.rewardGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rewardColor.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '+$points',
                          style: GoogleFonts.nunito(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text(
                              'Coins Earned!',
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        delay: 200.ms,
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Waiting badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Text(
                      '⏳ Waiting for parent approval...',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.textSub,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 56),

                  // Continue button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/child-home',
                          (route) => false,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryStrong,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'Continue Adventure! 🚀',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 400.ms).slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
