import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/progress_model.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/level_utils.dart';
import 'avatar_widget.dart';

/// Child summary card — shown on parent dashboard
class ChildSummaryCard extends StatelessWidget {
  final UserModel child;
  final ProgressModel? progress;
  final VoidCallback? onTap;

  const ChildSummaryCard({
    super.key,
    required this.child,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final level = progress?.level ?? 1;
    final points = progress?.points ?? 0;
    final streak = progress?.streak ?? 0;
    final progressValue = LevelUtils.getLevelProgress(progress?.xp ?? 0);
    final emoji = LevelUtils.getLevelEmoji(level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppColors.softShadow,
        ),
        child: Row(
          children: [
            // Avatar
            AvatarWidget(avatarIndex: child.avatarIndex, size: 64),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        child.name,
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$emoji Lv.$level',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: AppColors.primaryStrong,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // XP bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.black.withValues(alpha: 0.05),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryStrong,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatChip('🪙 $points', AppColors.rewardColor),
                      const SizedBox(width: 10),
                      _StatChip('🔥 $streak days', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSub),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
