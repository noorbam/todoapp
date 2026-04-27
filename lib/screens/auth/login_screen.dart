import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/gradient_button.dart';

/// Login screen — Google Sign-In + Email/Password fallback for parents
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _AuthMode { main, emailSignIn, emailRegister }

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  _AuthMode _authMode = _AuthMode.main;

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
        content: Text(msg, style: GoogleFonts.cairo()),
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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE8EAF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Language Toggle
              Positioned(
                top: 10,
                right: langProvider.isArabic ? null : 20,
                left: langProvider.isArabic ? 20 : null,
                child: TextButton.icon(
                  onPressed: () => langProvider.toggleLanguage(),
                  icon: const Icon(Icons.language, color: AppColors.primaryStrong),
                  label: Text(
                    langProvider.isArabic ? 'English' : 'العربية',
                    style: const TextStyle(
                        color: AppColors.primaryStrong,
                        fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),

              // Main Content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AnimatedSwitcher(
                  duration: 350.ms,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.08), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: _authMode == _AuthMode.main
                      ? _buildMainView(langProvider)
                      : _buildEmailView(langProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main View (Google + child button) ─────────────────────────────────────

  Widget _buildMainView(LanguageProvider langProvider) {
    return Column(
      key: const ValueKey('main'),
      children: [
        const SizedBox(height: 100),

        // Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppColors.softShadow,
          ),
          child: const Center(child: Text('⚔️', style: TextStyle(fontSize: 64))),
        )
            .animate()
            .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),

        const SizedBox(height: 32),

        Text(
          AppStrings.get(context, 'appName'),
          style: (langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.nunito())
              .copyWith(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.textMain),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 12),

        Text(
          AppStrings.get(context, 'tagline'),
          textAlign: TextAlign.center,
          style: (langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.nunito())
              .copyWith(fontSize: 18, color: AppColors.textSub, fontWeight: FontWeight.w600),
        ).animate().fadeIn(delay: 350.ms),

        const SizedBox(height: 60),

        // Google Sign-In button
        if (_isSigningIn)
          const CircularProgressIndicator(color: AppColors.primaryStrong)
        else ...[
          _GoogleSignInButton(
            langProvider: langProvider,
            onPressed: _handleGoogleSignIn,
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),

          const SizedBox(height: 16),

          // Email/Password fallback
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _authMode = _AuthMode.emailSignIn),
              icon: const Icon(Icons.email_outlined, color: AppColors.primaryStrong),
              label: Text(
                langProvider.isArabic
                    ? 'تسجيل الدخول بالبريد الإلكتروني'
                    : 'Sign in with Email',
                style: (langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.nunito())
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaryStrong),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryStrong, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),
        ],

        const SizedBox(height: 24),

        // OR Divider
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.textSub.withValues(alpha: 0.2), endIndent: 12)),
            Text(
              langProvider.isArabic ? 'أو' : 'OR',
              style: const TextStyle(color: AppColors.textSub, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Expanded(child: Divider(color: AppColors.textSub.withValues(alpha: 0.2), indent: 12)),
          ],
        ).animate().fadeIn(delay: 700.ms),

        const SizedBox(height: 24),

        // Child login button
        SizedBox(
          width: double.infinity,
          height: 64,
          child: GradientButton(
            label: AppStrings.get(context, 'iAmAChild'),
            onPressed: () => Navigator.pushNamed(context, '/child-login'),
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, curve: Curves.easeOutQuad),

        const SizedBox(height: 20),

        Text(
          AppStrings.get(context, 'parentHint'),
          textAlign: TextAlign.center,
          style: (langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.nunito())
              .copyWith(fontSize: 13, color: AppColors.textSub),
        ).animate().fadeIn(delay: 950.ms),

        const SizedBox(height: 40),
      ],
    );
  }

  // ── Email/Password View ────────────────────────────────────────────────────

  Widget _buildEmailView(LanguageProvider langProvider) {
    final isRegister = _authMode == _AuthMode.emailRegister;
    final font = langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.nunito();

    return Form(
      key: _formKey,
      child: Column(
        key: ValueKey(_authMode),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 80),

          // Back button
          Align(
            alignment: langProvider.isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _authMode = _AuthMode.main;
                _emailController.clear();
                _passwordController.clear();
                _nameController.clear();
              }),
              icon: Icon(
                langProvider.isArabic ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                size: 16,
                color: AppColors.primaryStrong,
              ),
              label: Text(
                langProvider.isArabic ? 'رجوع' : 'Back',
                style: font.copyWith(color: AppColors.primaryStrong, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            isRegister
                ? (langProvider.isArabic ? 'إنشاء حساب جديد 🦸' : 'Create Account 🦸')
                : (langProvider.isArabic ? 'تسجيل الدخول 👋' : 'Sign In 👋'),
            style: font.copyWith(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textMain),
          ),

          const SizedBox(height: 8),

          Text(
            isRegister
                ? (langProvider.isArabic ? 'أنشئ حسابك كولي أمر' : 'Create your parent account')
                : (langProvider.isArabic ? 'مرحباً بعودتك!' : 'Welcome back!'),
            style: font.copyWith(fontSize: 16, color: AppColors.textSub, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 36),

          // Name field (register only)
          if (isRegister) ...[
            _buildTextField(
              controller: _nameController,
              label: langProvider.isArabic ? 'الاسم الكامل' : 'Full Name',
              icon: Icons.person_outline,
              font: font,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (langProvider.isArabic ? 'أدخل اسمك' : 'Enter your name')
                  : null,
            ),
            const SizedBox(height: 16),
          ],

          // Email
          _buildTextField(
            controller: _emailController,
            label: langProvider.isArabic ? 'البريد الإلكتروني' : 'Email',
            icon: Icons.email_outlined,
            font: font,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return langProvider.isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter email';
              }
              if (!v.contains('@')) {
                return langProvider.isArabic ? 'بريد إلكتروني غير صالح' : 'Invalid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password
          _buildTextField(
            controller: _passwordController,
            label: langProvider.isArabic ? 'كلمة المرور' : 'Password',
            icon: Icons.lock_outline,
            font: font,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textSub,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) {
                return langProvider.isArabic ? 'أدخل كلمة المرور' : 'Enter password';
              }
              if (isRegister && v.length < 6) {
                return langProvider.isArabic
                    ? 'كلمة المرور 6 أحرف على الأقل'
                    : 'Minimum 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Submit button
          SizedBox(
            height: 60,
            child: _isSigningIn
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryStrong))
                : ElevatedButton(
                    onPressed: isRegister ? _handleEmailRegister : _handleEmailSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryStrong,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                    ),
                    child: Text(
                      isRegister
                          ? (langProvider.isArabic ? 'إنشاء الحساب' : 'Create Account')
                          : (langProvider.isArabic ? 'تسجيل الدخول' : 'Sign In'),
                      style: font.copyWith(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          // Toggle sign-in / register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isRegister
                    ? (langProvider.isArabic ? 'لديك حساب بالفعل؟ ' : 'Already have an account? ')
                    : (langProvider.isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? "),
                style: font.copyWith(color: AppColors.textSub, fontSize: 14),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _authMode = isRegister ? _AuthMode.emailSignIn : _AuthMode.emailRegister;
                }),
                child: Text(
                  isRegister
                      ? (langProvider.isArabic ? 'تسجيل الدخول' : 'Sign In')
                      : (langProvider.isArabic ? 'إنشاء حساب' : 'Register'),
                  style: font.copyWith(
                    color: AppColors.primaryStrong,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextStyle font,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: font.copyWith(fontSize: 16, color: AppColors.textMain),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: font.copyWith(color: AppColors.textSub, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: AppColors.primaryStrong),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: AppColors.textSub.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primaryStrong, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}

// ── Google Sign-In Button ──────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final LanguageProvider langProvider;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.langProvider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textMain,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
              height: 28,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.account_circle, color: AppColors.primaryStrong, size: 28),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                AppStrings.get(context, 'signInParent'),
                style: (langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.nunito())
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
