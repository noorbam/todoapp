import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/progress_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/level_utils.dart';
import 'avatar_widget.dart';

/// Child summary card — shown on parent dashboard
class ChildSummaryCard extends StatelessWidget {
  final UserModel child;
  final ProgressModel? progress;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final int pendingApprovalsCount;

  const ChildSummaryCard({
    super.key,
    required this.child,
    this.progress,
    this.onTap,
    this.onDelete,
    this.pendingApprovalsCount = 0,
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
          color: Theme.of(context).cardColor,
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
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$emoji ${AppStrings.get(context, 'levelShort')}$level',
                          style: GoogleFonts.cairo(
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
                      backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryStrong,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StatChip('🪙 $points', AppColors.rewardColor),
                      _StatChip('🔥 $streak days', Colors.orange),
                      if (pendingApprovalsCount > 0)
                        _StatChip('$pendingApprovalsCount 🔔', AppColors.error),
                    ],
                  ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              )
            else
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
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
