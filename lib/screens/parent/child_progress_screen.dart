import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/progress_model.dart';
import '../../models/badge_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/utils/level_utils.dart';
import '../../providers/progress_provider.dart';
import '../../providers/reward_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/xp_progress_card.dart';
import '../../widgets/task_approval_card.dart';
import '../../widgets/mission_card.dart';

/// Child Progress screen — parent views detailed stats of a child
class ChildProgressScreen extends StatefulWidget {
  const ChildProgressScreen({super.key});

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  bool _isInit = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final child = ModalRoute.of(context)!.settings.arguments as UserModel;
      context.read<TaskProvider>().listenToChildTasks(child.id);
      context.read<ProgressProvider>().listenToProgress(child.id);
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = ModalRoute.of(context)!.settings.arguments as UserModel;
    final progressProvider = context.watch<ProgressProvider>();
    final progress = progressProvider.progress;

    if (progressProvider.isLoading && progress == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Theme.of(context).cardColor, elevation: 0),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primaryStrong)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          '${child.name}${AppStrings.get(context, 'childProgress')}',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryStrong),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showAddRewardDialog(context, child),
            icon: const Icon(Icons.card_giftcard, color: AppColors.rewardColor),
            label: Text(
              AppStrings.get(context, 'rewardsButton'),
              style: GoogleFonts.cairo(
                color: AppColors.primaryStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar + name header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(32),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  AvatarWidget(avatarIndex: child.avatarIndex, size: 100),
                  const SizedBox(height: 16),
                  Text(
                    child.name,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${LevelUtils.getLevelEmoji(progress?.level ?? 1)} ${AppStrings.get(context, 'levelLabel')} ${progress?.level ?? 1} — ${AppStrings.get(context, 'lvl_title_${(progress?.level ?? 1).clamp(1, 10)}')}',
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: AppColors.primaryStrong,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            XPProgressCard(
              level: progress?.level ?? 1,
              xp: progress?.xp ?? 0,
              streak: progress?.streak ?? 0,
              earnedBadges: BadgeModel.allBadges.where((b) => (progress?.xp ?? 0) >= b.requiredXp).length,
              totalBadges: BadgeModel.allBadges.length,
              coins: progress?.points,
            ),

            const SizedBox(height: 32),

            // Redemptions History
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().getRedemptionsStream(child.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
                final redemptions = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get(context, 'recentRewards'),
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    ...redemptions.take(3).map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.rewardColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppStrings.get(context, 'redeemed')} ${r['rewardTitle']}',
                                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                                ),
                                Text(
                                  '${r['cost']} ${AppStrings.get(context, 'coins')} • ${r['redeemedAt'] != null ? DateFormat('MMM d, h:mm a').format((r['redeemedAt'] as Timestamp).toDate()) : AppStrings.get(context, 'justNow')}',
                                  style: GoogleFonts.cairo(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ).animate(delay: 350.ms).fadeIn(duration: 400.ms),

            // Tasks Section
            Consumer<TaskProvider>(
              builder: (context, taskProvider, childWidget) {
                if (taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final pendingApprovals = taskProvider.tasks.where((t) => t.isCompleted).toList();
                final activeTasks = taskProvider.tasks.where((t) => t.isPending || t.isRejected).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pendingApprovals.isNotEmpty) ...[
                      Text(
                        AppStrings.get(context, 'needsApproval'),
                        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 16),
                      ...pendingApprovals.map((task) => TaskApprovalCard(
                        task: task,
                        childName: child.name,
                        onApprove: () async {
                          final success = await taskProvider.approveTask(task);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? AppStrings.get(context, 'approveSuccess')
                                    : AppStrings.get(context, 'approveError')),
                                backgroundColor: success ? AppColors.success : AppColors.error,
                              ),
                            );
                          }
                        },
                        onReject: () async {
                          await taskProvider.rejectTask(task.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.get(context, 'rejectMsg')),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                      )),
                      const SizedBox(height: 24),
                    ],
                    
                    Text(
                      AppStrings.get(context, 'assignedMissions'),
                      style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    if (activeTasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: Center(child: Text(AppStrings.get(context, 'noActiveMissions'))),
                      )
                    else
                      ...activeTasks.map((task) => MissionCard(
                        task: task,
                        onDelete: () async {
                          debugPrint('ChildProgressScreen: Deleting task ${task.id}');
                          final success = await context.read<TaskProvider>().deleteTask(task.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? 'تم الحذف' : 'فشل الحذف')),
                            );
                          }
                        },
                      )),
                  ],
                );
              },
            ).animate(delay: 380.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // Add task for this child
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/add-task',
                  arguments: child,
                ),
                icon: const Icon(Icons.add, size: 22),
                label: Text(
                  AppStrings.get(context, 'assignNewMission'),
                  style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryStrong,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  textStyle: GoogleFonts.cairo(
                      fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showAddRewardDialog(BuildContext context, UserModel child) {
    final titleController = TextEditingController();
    final costController = TextEditingController();
    final parent = context.read<AuthProvider>().currentUser;
    if (parent == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(AppStrings.get(context, 'addReward'), style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                  labelText: AppStrings.get(context, 'rewardName'),
                prefixIcon: Icon(Icons.card_giftcard, color: AppColors.rewardColor),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: AppStrings.get(context, 'coinCost'),
                prefixIcon: Icon(Icons.monetization_on, color: AppColors.rewardColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.get(context, 'cancel'), style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final costText = costController.text.trim();
              final cost = int.tryParse(costText);

              if (title.isEmpty || cost == null || cost <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.get(context, 'enterValidReward'))),
                );
                return;
              }

              Navigator.pop(ctx);
              final success = await context.read<RewardProvider>().createReward(
                    title: title,
                    cost: cost,
                    childId: child.id,
                    parentId: parent.id,
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(success
                        ? AppStrings.get(context, 'rewardAddedSuccess')
                        : AppStrings.get(context, 'rewardAddedError')),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryStrong, foregroundColor: Colors.white),
            child: Text(AppStrings.get(context, 'addReward'), style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
          ),
        ],
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
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
