import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/mission_card.dart';
import '../../widgets/xp_progress_card.dart';
import '../../models/badge_model.dart';

import 'missions_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _currentIndex = 0;
  ConfettiController? _confettiController;
  late List<Widget> _pages;

  ConfettiController get confettiController {
    _confettiController ??= ConfettiController(duration: const Duration(seconds: 2));
    return _confettiController!;
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    _pages = [
      _ChildDashboardView(confettiController: confettiController),
      MissionsScreen(isTab: true, confettiController: confettiController),
      const RewardsScreen(isTab: true),
      const ProfileScreen(isTab: true),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = context.read<AuthProvider>().currentUser;
      if (child != null) {
        context.read<TaskProvider>().listenToChildTasks(child.id);
        context.read<ProgressProvider>().listenToProgress(child.id);
      }
    });
  }

  @override
  void dispose() {
    _confettiController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final child = authProvider.currentUser;

    if (child == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // Confetti Overlay
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primaryStrong,
                AppColors.rewardColor,
                AppColors.success,
                Colors.orange,
                Colors.pink,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStrong.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Theme.of(context).cardColor,
            selectedItemColor: AppColors.primaryStrong,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 12),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: AppStrings.get(context, 'hey').replaceAll('،', '').trim(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.check_circle_rounded),
                label: AppStrings.get(context, 'myMissions').replaceAll('⚔️ ', ''),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.card_giftcard_rounded),
                label: AppStrings.get(context, 'rewardsShop').replaceAll('🎁 ', ''),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: AppStrings.get(context, 'profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildDashboardView extends StatelessWidget {
  final ConfettiController confettiController;
  const _ChildDashboardView({required this.confettiController});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final progressProvider = context.watch<ProgressProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final child = authProvider.currentUser!;

    final activeTasks = taskProvider.activeTasks.take(3).toList();

    return RefreshIndicator(
      color: AppColors.primaryStrong,
      onRefresh: () async {
        context.read<TaskProvider>().listenToChildTasks(child.id);
      },
      child: CustomScrollView(
        slivers: [
          // Merged Header + XP Card
          SliverToBoxAdapter(
            child: XPProgressCard(
              level: progressProvider.level,
              xp: progressProvider.xp,
              streak: progressProvider.streak,
              earnedBadges: BadgeModel.allBadges.where((b) => progressProvider.xp >= b.requiredXp).length,
              totalBadges: BadgeModel.allBadges.length,
              childName: child.name,
              coins: progressProvider.points,
              avatarWidget: AvatarWidget(avatarIndex: child.avatarIndex, size: 60),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get(context, 'recentTasks'),
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final state = context.findAncestorStateOfType<_ChildHomeScreenState>();
                      if (state != null) {
                        state.setState(() {
                          state._currentIndex = 1;
                        });
                      }
                    },
                    child: Text(
                      AppStrings.get(context, 'seeAll'),
                      style: GoogleFonts.cairo(
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 52))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds)
                          .rotate(begin: -0.05, end: 0.05, curve: Curves.easeInOut),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get(context, 'allCaughtUp'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                        // Navigate immediately for instant feedback
                        Navigator.pushNamed(context, '/celebration', arguments: task.points);
                        // Update Firestore in background
                        context.read<TaskProvider>().completeTask(task.id);
                      },
                    ).animate(delay: (index * 100).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
                  },
                  childCount: activeTasks.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
