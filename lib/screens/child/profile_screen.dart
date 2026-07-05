import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../core/utils/level_utils.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/xp_progress_card.dart';
import '../../models/badge_model.dart';

/// Child Profile / Progress screen
class ProfileScreen extends StatefulWidget {
  final bool isTab;
  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = context.read<AuthProvider>().currentUser?.avatarIndex ?? 0;
  }

  Future<void> _saveAvatar() async {
    final child = context.read<AuthProvider>().currentUser!;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(child.id)
        .update({'avatarIndex': _selectedAvatar});

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.get(context, 'avatarUpdated')), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<ProgressProvider>();
    final child = context.watch<AuthProvider>().currentUser;

    if (child == null) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryStrong)));
    }

    final double xpProgress = LevelUtils.getLevelProgress(progressProvider.xp);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    if (!widget.isTab)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.primaryStrong),
                      ),
                    Expanded(
                      child: Text(
                        '📈 My Progress',
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Circular Progress Chart
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: xpProgress,
                        strokeWidth: 16,
                        backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                        color: AppColors.primaryStrong,
                        strokeCap: StrokeCap.round,
                      ).animate().scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.easeOutCubic),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AvatarWidget(avatarIndex: _selectedAvatar, size: 70)
                                .animate()
                                .scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 8),
                            Text(
                              '${AppStrings.get(context, 'level')} ${progressProvider.level}',
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryStrong,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                child.name,
                style: GoogleFonts.cairo(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 4),

              Text(
                '${LevelUtils.getLevelEmoji(progressProvider.level)} ${AppStrings.get(context, 'lvl_title_${progressProvider.level.clamp(1, 10)}')}',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w800,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              XPProgressCard(
                level: progressProvider.level,
                xp: progressProvider.xp,
                streak: progressProvider.streak,
                coins: progressProvider.points,
                earnedBadges: BadgeModel.allBadges.where((b) => progressProvider.xp >= b.requiredXp).length,
                totalBadges: BadgeModel.allBadges.length,
              ),

              const SizedBox(height: 32),

              // Avatar picker
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get(context, 'chooseAvatar'),
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return AvatarWidget(
                          avatarIndex: index,
                          size: 70,
                          isSelected: _selectedAvatar == index,
                          onTap: () => setState(() => _selectedAvatar = index),
                        ).animate(delay: (index * 50).ms).scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 300.ms,
                            curve: Curves.easeOut);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveAvatar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryStrong,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          '${AppStrings.get(context, 'saveAvatar')} 🎨',
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (!context.mounted) return;
                      // Since we are likely in the child dashboard which was pushed over login, we pop until we are out or just push replacement
                      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(
                      AppStrings.get(context, 'signOut'),
                      style: (Provider.of<LanguageProvider>(context).isArabic ? GoogleFonts.cairo() : GoogleFonts.cairo()).copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  const _StatBox(this.emoji, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
