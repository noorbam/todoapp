import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../core/utils/level_utils.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/level_bar.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/badge_chip.dart';
import '../../models/badge_model.dart';

/// Child Profile / Avatar selector screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
      const SnackBar(content: Text('Avatar updated! 🎉'), backgroundColor: AppColors.success),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: AppColors.primaryStrong),
                      ),
                      Expanded(
                        child: Text(
                          '🧑‍🎤 My Profile',
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Current avatar + name
                AvatarWidget(avatarIndex: _selectedAvatar, size: 110)
                    .animate()
                    .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 400.ms,
                        curve: Curves.elasticOut),

                const SizedBox(height: 16),

                Text(
                  child.name,
                  style: GoogleFonts.nunito(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 4),

                Text(
                  '${LevelUtils.getLevelEmoji(progressProvider.level)} ${LevelUtils.getLevelTitle(progressProvider.level)} · Level ${progressProvider.level}',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: AppColors.primaryStrong,
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 12),
                StreakBadge(streak: progressProvider.streak),

                const SizedBox(height: 32),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _StatBox('🪙', 'Coins', '${progressProvider.points}',
                          AppColors.rewardColor),
                      _StatBox('⭐', 'Total XP', '${progressProvider.xp}',
                          AppColors.primaryStrong),
                      _StatBox('🔥', 'Streak', '${progressProvider.streak}d',
                          const Color(0xFFFF8A65)),
                    ],
                  ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                ),

                const SizedBox(height: 32),

                // XP bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LevelBar(
                      level: progressProvider.level, xp: progressProvider.xp),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // Avatar picker
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Avatar:',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                            onTap: () =>
                                setState(() => _selectedAvatar = index),
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
                            'Save Avatar 🎨',
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Badges
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Badges 🏅',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: BadgeModel.allBadges.map((b) {
                          final earned = progressProvider.badges.contains(b.id);
                          return BadgeChip(badgeId: b.id, isEarned: earned);
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 48),
              ],
            ),
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: AppColors.textSub,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
