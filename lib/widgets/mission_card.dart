import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../core/constants/app_colors.dart';

/// Mission card for the child's missions list
/// Displays task as a colorful game card with gradient background
class MissionCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onComplete;
  final int colorIndex;

  const MissionCard({
    super.key,
    required this.task,
    this.onComplete,
    this.colorIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors
        .missionCardGradients[colorIndex % AppColors.missionCardGradients.length];
    final isActive = task.isPending || task.isRejected;
    final isCompleted = task.isCompleted;
    final isApproved = task.isApproved;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isApproved
              ? [Colors.grey.shade200, Colors.grey.shade300]
              : gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: status badge + points
            Row(
              children: [
                _StatusBadge(task: task),
                const Spacer(),
                _PointsBadge(points: task.points),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              task.title,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),

            // Description
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textMain.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Deadline
            if (task.deadline != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: AppColors.textMain.withValues(alpha: 0.6)),
                  const SizedBox(width: 6),
                  Text(
                    'Due: ${DateFormat('MMM d').format(task.deadline!)}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color:
                          task.isOverdue ? AppColors.error : AppColors.textMain.withValues(alpha: 0.6),
                      fontWeight: task.isOverdue ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            // Complete Button (only for active tasks)
            if (isActive && onComplete != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.primaryStrong,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    '⚔️  Complete Mission!',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],

            // Waiting for approval indicator
            if (isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_top,
                        size: 16, color: AppColors.textMain.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Text(
                      'Waiting for parent approval...',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Approved checkmark
            if (isApproved) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Mission Approved! +${task.points} 🪙',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskModel task;
  const _StatusBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color textColor;

    if (task.isApproved) {
      label = '✅ Done';
      bg = AppColors.progressColor.withValues(alpha: 0.2);
      textColor = AppColors.progressColor;
    } else if (task.isCompleted) {
      label = '⏳ In Review';
      bg = Colors.orange.withValues(alpha: 0.2);
      textColor = Colors.orange.shade900;
    } else if (task.isRejected) {
      label = '❌ Rejected';
      bg = AppColors.error.withValues(alpha: 0.2);
      textColor = AppColors.error;
    } else {
      label = '⚔️ Active';
      bg = AppColors.primaryStrong.withValues(alpha: 0.1);
      textColor = AppColors.primaryStrong;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  final int points;
  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const Text('🪙', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '+$points',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
