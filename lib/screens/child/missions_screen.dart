import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/mission_card.dart';

class MissionsScreen extends StatefulWidget {
  final bool isTab;
  final ConfettiController? confettiController;
  const MissionsScreen({super.key, this.isTab = false, this.confettiController});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = context.read<AuthProvider>().currentUser;
      if (child != null) {
        context.read<TaskProvider>().listenToChildTasks(child.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final allTasks = taskProvider.tasks;
    final activeTasks = taskProvider.activeTasks;
    final completedTasks = taskProvider.completedTasks;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  if (!widget.isTab)
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryStrong),
                    ),
                  Expanded(
                    child: Text(
                      AppStrings.get(context, 'myMissions'),
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryStrong.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                labelStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w900),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: '${AppStrings.get(context, 'all')} (${allTasks.length})'),
                  Tab(text: '${AppStrings.get(context, 'active')} (${activeTasks.length})'),
                  Tab(text: '${AppStrings.get(context, 'done')} (${completedTasks.length})'),
                ],
              ),
            ),

            Expanded(
              child: taskProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryStrong))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _TaskList(tasks: allTasks, confettiController: widget.confettiController),
                        _TaskList(tasks: activeTasks, confettiController: widget.confettiController),
                        _TaskList(tasks: completedTasks, confettiController: widget.confettiController),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final ConfettiController? confettiController;
  const _TaskList({required this.tasks, this.confettiController});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😴', style: TextStyle(fontSize: 72))
                .animate()
                .scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              AppStrings.get(context, 'nothingHere'),
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get(context, 'missionsWillAppear'),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return MissionCard(
          task: task,
          colorIndex: index,
          onComplete: task.isPending || task.isRejected
              ? () async {
                  // Navigate immediately for instant feedback
                  Navigator.pushNamed(context, '/celebration', arguments: task.points);
                  // Update Firestore in background
                  context.read<TaskProvider>().completeTask(task.id);
                }
              : null,
        ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
