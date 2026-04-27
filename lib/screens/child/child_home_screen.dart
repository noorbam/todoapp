import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/coin_counter.dart';
import '../../widgets/level_bar.dart';
import '../../widgets/streak_badge.dart';
import '../../widgets/mission_card.dart';

/// Child Home Screen — the main game hub for kids
class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = context.read<AuthProvider>().currentUser;
      if (child != null) {
        context.read<TaskProvider>().listenToChildTasks(child.id);
        context.read<ProgressProvider>().listenToProgress(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final child = authProvider.currentUser;

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeTasks = taskProvider.activeTasks.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryStrong,
          onRefresh: () async {
            context.read<TaskProvider>().listenToChildTasks(child.id);
          },
          child: CustomScrollView(
            slivers: [
              // ── Hero Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFAEE2FF), Color(0xFFAFA8FF)], // Soft Blue to Soft Purple
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top row: avatar + name + coins
                      Row(
                        children: [
                          AvatarWidget(
                            avatarIndex: child.avatarIndex,
                            size: 64,
                          ).animate().scale(begin: const Offset(0.5, 0.5), duration: 400.ms, curve: Curves.elasticOut),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hey, ${child.name}! 👋',
                                  style: GoogleFonts.nunito(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textMain,
                                  ),
                                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                                StreakBadge(streak: progressProvider.streak),
                              ],
                            ),
                          ),
                          CoinCounter(coins: progressProvider.points),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // XP bar
                      LevelBar(
                        level: progressProvider.level,
                        xp: progressProvider.xp,
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ),

              // ── Quick Actions ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(
                    children: [
                      _QuickActionCard(
                        emoji: '⚔️',
                        label: 'Missions',
                        gradient: AppColors.taskGradient,
                        onTap: () => Navigator.pushNamed(context, '/missions'),
                      ),
                      const SizedBox(width: 16),
                      _QuickActionCard(
                        emoji: '🎁',
                        label: 'Rewards',
                        gradient: AppColors.rewardGradient,
                        onTap: () => Navigator.pushNamed(context, '/rewards'),
                      ),
                      const SizedBox(width: 16),
                      _QuickActionCard(
                        emoji: '🧑‍🎤',
                        label: 'Profile',
                        gradient: AppColors.progressGradient,
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                ),
              ),

              // ── Active Missions Preview ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '⚔️ Active Missions',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/missions'),
                        child: Text(
                          'See All',
                          style: GoogleFonts.nunito(
                            color: AppColors.primaryStrong,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Mission cards
              if (taskProvider.isLoading)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primaryStrong)),
                )
              else if (activeTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Column(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 52)),
                          const SizedBox(height: 12),
                          Text(
                            'No active missions!\nAsk a parent to assign you one.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 18,
                              color: AppColors.textSub,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = activeTasks[index];
                        return MissionCard(
                          task: task,
                          colorIndex: index,
                          onComplete: () async {
                            final success = await context.read<TaskProvider>().completeTask(task.id);
                            if (!mounted) return;
                            if (success) {
                              Navigator.pushNamed(
                                context,
                                '/celebration',
                                arguments: task.points,
                              );
                            }
                          },
                        ).animate(delay: (index * 100).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
                      },
                      childCount: activeTasks.length,
                    ),
                  ),
                ),

              // Sign out
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: TextButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout, color: AppColors.textSub, size: 18),
                    label: Text('Switch Hero', style: GoogleFonts.nunito(color: AppColors.textSub, fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick action card for home screen navigation
class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
