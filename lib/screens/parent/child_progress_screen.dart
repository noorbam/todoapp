import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../models/progress_model.dart';
import '../../models/badge_model.dart';
import '../../core/utils/level_utils.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/badge_chip.dart';

/// Child Progress screen — parent views detailed stats of a child
class ChildProgressScreen extends StatefulWidget {
  const ChildProgressScreen({super.key});

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final child = ModalRoute.of(context)!.settings.arguments as UserModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          '${child.name}\'s Progress',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryStrong),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<ProgressModel?>(
        future: context.read<ProgressProvider>().fetchProgress(child.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryStrong));
          }
          final progress = snapshot.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar + name header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      AvatarWidget(avatarIndex: child.avatarIndex, size: 100),
                      const SizedBox(height: 16),
                      Text(
                        child.name,
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${LevelUtils.getLevelEmoji(progress?.level ?? 1)} Level ${progress?.level ?? 1} — ${LevelUtils.getLevelTitle(progress?.level ?? 1)}',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: AppColors.primaryStrong,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Stats row
                Row(
                  children: [
                    _StatCard('🪙', 'Coins', '${progress?.points ?? 0}',
                        AppColors.rewardColor),
                    const SizedBox(width: 12),
                    _StatCard('⭐', 'Total XP', '${progress?.xp ?? 0}',
                        AppColors.primaryStrong),
                    const SizedBox(width: 12),
                    _StatCard('🔥', 'Streak', '${progress?.streak ?? 0}d',
                        const Color(0xFFFF8A65)),
                  ],
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // XP progress bar
                Container(
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
                        'XP Progress',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: LevelUtils.getLevelProgress(progress?.xp ?? 0),
                          backgroundColor: Colors.black.withValues(alpha: 0.05),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryStrong),
                          minHeight: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${LevelUtils.xpToNextLevel(progress?.xp ?? 0)} XP to next level',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.textSub,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // Badges section
                Container(
                  width: double.infinity,
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
                        'Badges 🏅',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: BadgeModel.allBadges.map((b) {
                          final earned =
                              (progress?.badges ?? []).contains(b.id);
                          return BadgeChip(badgeId: b.id, isEarned: earned);
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Add task for this child
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/add-task'),
                    icon: const Icon(Icons.add, size: 22),
                    label: const Text('Assign New Mission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryStrong,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      textStyle: GoogleFonts.nunito(
                          fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard(this.emoji, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
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
                fontSize: 12,
                color: AppColors.textSub,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
