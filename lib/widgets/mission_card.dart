import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/task_provider.dart';

class MissionCard extends StatefulWidget {
  final TaskModel task;
  final Future<void> Function()? onComplete; // Changed to Future
  final VoidCallback? onDelete;
  final int colorIndex;

  const MissionCard({
    super.key,
    required this.task,
    this.onComplete,
    this.onDelete,
    this.colorIndex = 0,
  });

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
  bool _isCompleting = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          AppStrings.get(context, 'deleteTask'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          AppStrings.get(context, 'deleteTaskConfirm'),
          style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.get(context, 'cancel'),
                style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: Text(AppStrings.get(context, 'delete'),
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      debugPrint('Deleting task: ${widget.task.id}');
      final success = await context.read<TaskProvider>().deleteTask(widget.task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            success ? AppStrings.get(context, 'deleteTaskSuccess') : AppStrings.get(context, 'deleteTaskError'),
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.task.isPending || widget.task.isRejected;
    final isCompleted = widget.task.isCompleted;

    final IconData iconData;
    if (widget.task.title.toLowerCase().contains('read') || widget.task.title.contains('قراءة') || widget.task.title.contains('كتاب')) {
      iconData = Icons.menu_book_rounded;
    } else if (widget.task.title.toLowerCase().contains('clean') || widget.task.title.contains('ترتيب') || widget.task.title.contains('نظافة')) {
      iconData = Icons.cleaning_services_rounded;
    } else if (widget.task.title.toLowerCase().contains('math') || widget.task.title.contains('رياضيات') || widget.task.title.contains('واجب')) {
      iconData = Icons.calculate_rounded;
    } else if (widget.task.title.toLowerCase().contains('teeth') || widget.task.title.contains('أسنان')) {
      iconData = Icons.health_and_safety_rounded;
    } else {
      iconData = Icons.star_rounded;
    }

    final gradient = AppColors.missionCardGradients[widget.colorIndex % AppColors.missionCardGradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.softShadow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti explosion from the card!
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primaryStrong,
              AppColors.rewardColor,
              AppColors.success,
              Colors.orange,
              Colors.pink,
              Colors.cyan,
            ],
            numberOfParticles: 50,
            emissionFrequency: 0.05,
            maxBlastForce: 40,
            minBlastForce: 20,
            gravity: 0.3,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(iconData, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (widget.task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.task.description,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (widget.task.deadline != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: widget.task.isOverdue ? AppColors.error : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d').format(widget.task.deadline!),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: widget.task.isOverdue ? AppColors.error : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: widget.task.isOverdue ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _PointsBadge(points: widget.task.points),
                    const SizedBox(height: 8),
                    _StatusBadge(task: widget.task),
                    if (widget.onDelete != null) ...[
                      const SizedBox(height: 8),
                      Consumer<TaskProvider>(
                        builder: (context, taskProvider, _) {
                          final deleting = taskProvider.isDeleting(widget.task.id);
                          return GestureDetector(
                            onTap: deleting ? null : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('جاري بدء عملية الحذف...'), duration: Duration(seconds: 1)),
                              );
                              if (widget.onDelete != null) {
                                widget.onDelete!();
                              } else {
                                _confirmDelete(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: deleting ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (deleting)
                                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
                                  else
                                    const Icon(Icons.delete_rounded, size: 16, color: AppColors.error),
                                  const SizedBox(width: 6),
                                  Text(
                                    deleting ? 'جاري...' : 'حذف',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),

            if (isActive && widget.onComplete != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isCompleting ? null : () {
                    if (widget.onComplete != null) {
                      setState(() => _isCompleting = true);
                      widget.onComplete!().then((_) {
                        if (mounted) setState(() => _isCompleting = false);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryStrong,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isCompleting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                      : Text(
                          AppStrings.get(context, 'completeMission'),
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],

            if (isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_top, size: 16, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get(context, 'waitingApproval'),
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  ),
);
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskModel task;
  const _StatusBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (task.isApproved) {
      icon = Icons.check_circle_rounded;
      color = AppColors.success;
    } else if (task.isCompleted) {
      icon = Icons.hourglass_bottom_rounded;
      color = Colors.orange;
    } else if (task.isRejected) {
      icon = Icons.cancel_rounded;
      color = AppColors.error;
    } else {
      icon = Icons.play_circle_fill_rounded;
      color = AppColors.primaryStrong;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14, color: color)],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.rewardGradient[0].withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+$points',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.rewardColor,
            ),
          ),
          const SizedBox(width: 4),
          const Text('🪙', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
