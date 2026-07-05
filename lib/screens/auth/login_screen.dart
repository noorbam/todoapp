import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';

/// Login screen — Gamified Redesign
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthMode { signIn, register }

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  _AuthMode _authMode = _AuthMode.signIn;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isSigningIn = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();
    if (!mounted) return;
    setState(() => _isSigningIn = false);

    if (authProvider.error != null) {
      _showError(authProvider.error!);
      authProvider.clearError();
      return;
    }

    if (success) {
      Navigator.pushReplacementNamed(context, '/parent-dashboard');
    }
  }

  // ── Email/Password Sign-In ─────────────────────────────────────────────────

  Future<void> _handleEmailSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSigningIn = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signInWithEmailPassword(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSigningIn = false);

    if (authProvider.error != null) {
      _showError(authProvider.error!);
      authProvider.clearError();
      return;
    }
    if (success) Navigator.pushReplacementNamed(context, '/parent-dashboard');
  }

  Future<void> _handleEmailRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSigningIn = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.registerWithEmailPassword(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSigningIn = false);

    if (authProvider.error != null) {
      _showError(authProvider.error!);
      authProvider.clearError();
      return;
    }
    if (success) Navigator.pushReplacementNamed(context, '/parent-dashboard');
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final isRegister = _authMode == _AuthMode.register;
    final font = langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.cairo();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Wave Header
          ClipPath(
            clipper: _WaveClipper(),
            child: Container(
              height: 420,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Game Logo / Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Text('🎮', style: TextStyle(fontSize: 80)),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scale(duration: 600.ms, curve: Curves.elasticOut)
                     .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut),

                    const SizedBox(height: 24),

                    Text(
                      AppStrings.get(context, 'appName'),
                      style: GoogleFonts.cairo(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          const Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    Text(
                      AppStrings.get(context, 'tagline'),
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 60),

                    // Login Card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            langProvider.isArabic ? 'سجل الدخول للمغامرة' : 'Login for Adventure',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          _isSigningIn
                              ? const CircularProgressIndicator(color: AppColors.primaryStrong)
                              : SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: ElevatedButton(
                                    onPressed: _handleGoogleSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : AppColors.darkSurface,
                                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                                      elevation: 3,
                                      shadowColor: Colors.black12,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                                          height: 24,
                                          errorBuilder: (ctx, err, st) => const Icon(Icons.account_circle, color: Colors.blue),
                                        ),
                                        const SizedBox(width: 12),
                                        Flexible(
                                          child: Text(
                                            AppStrings.get(context, 'signInParent'),
                                            style: GoogleFonts.cairo(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                 .shimmer(delay: 3.seconds, duration: 1.5.seconds, color: Colors.white.withValues(alpha: 0.2))
                                 .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02), duration: 2.seconds),
                          
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/child-login'),
                            child: Text(
                              AppStrings.get(context, 'iAmAChild'),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryStrong,
                              ),
                            ),
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                           .shimmer(delay: 2.seconds, duration: 2.seconds, color: AppColors.primaryStrong.withValues(alpha: 0.2))
                           .moveX(begin: -2, end: 2, duration: 1.seconds, curve: Curves.easeInOut),
                        ],
                      ),
                    ).animate().slideY(begin: 0.2, duration: 500.ms).fadeIn(),
                    
                    const SizedBox(height: 40),
                    
                    Text(
                      AppStrings.get(context, 'parentHint'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Language Toggle (On Top)
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: langProvider.isArabic ? MainAxisAlignment.start : MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => langProvider.toggleLanguage(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              langProvider.isArabic ? 'English' : 'العربية',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

// ── Custom Wave Clipper ───────────────────────────────────────────────────────

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
        size.width / 4, size.height, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height - 40, size.width, size.height - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ── Scale Button Animation Wrapper ──────────────────────────────────────────

class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  
  const _ScaleButton({required this.child, required this.onPressed});

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
