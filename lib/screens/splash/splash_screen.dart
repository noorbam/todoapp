import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Splash screen — animates the KidQuest logo and routes based on auth state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.initializeAuth();

    if (!mounted) return;

    final user = authProvider.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else if (user.isParent) {
      Navigator.pushReplacementNamed(context, '/parent-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/child-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE8EAF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: AppColors.softShadow,
                ),
                child: const Center(
                  child: Text('⚔️', style: TextStyle(fontSize: 72)),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              // App name
              Text(
                'KidQuest',
                style: GoogleFonts.nunito(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                  letterSpacing: -1,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms),

              const SizedBox(height: 12),

              Text(
                'Complete Missions. Earn Rewards! 🏆',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: AppColors.textSub,
                  fontWeight: FontWeight.w700,
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms),

              const SizedBox(height: 80),

              // Loading indicator
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: AppColors.primaryStrong,
                  strokeWidth: 4,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
