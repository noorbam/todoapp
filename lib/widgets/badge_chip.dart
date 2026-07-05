import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_colors.dart';

class BadgeChip extends StatelessWidget {
  final String badgeId;
  final bool isEarned;
  final BadgeProgress? progress;

  const BadgeChip({
    super.key,
    required this.badgeId,
    this.isEarned = true,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final badge = BadgeModel.findById(badgeId);
    if (badge == null) return const SizedBox.shrink();

    return Tooltip(
      message: '${AppStrings.get(context, badge.titleKey)}\n${AppStrings.get(context, badge.descKey)}',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isEarned ? AppColors.primaryStrong.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStrong.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge Title at top
            Text(
              AppStrings.get(context, badge.titleKey),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isEarned ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 12),

            // Central Medal Circle
            Stack(
              alignment: Alignment.center,
              children: [
                // Glowing outer circle for earned
                if (isEarned)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryStrong.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                  ),
                
                // Inner circle (Medal)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isEarned 
                        ? [AppColors.softPurple.withValues(alpha: 0.2), AppColors.primaryStrong.withValues(alpha: 0.1)]
                        : [Colors.grey.shade100, Colors.grey.shade50],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      badge.emoji,
                      style: TextStyle(
                        fontSize: 36,
                        color: isEarned ? null : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ribbon Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isEarned ? AppColors.primaryStrong : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isEarned ? AppStrings.get(context, 'unlocked') : AppStrings.get(context, 'locked'),
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isEarned ? Colors.white : Colors.grey.shade400,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Progress / Status
            if (!isEarned && progress != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get(context, 'next'),
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    '${(progress!.fraction * 100).toInt()}%',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryStrong,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress!.fraction,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryStrong),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress!.current} / ${progress!.target} XP',
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ] else ...[
              Text(
                AppStrings.get(context, 'completed_badge'),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryStrong.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
