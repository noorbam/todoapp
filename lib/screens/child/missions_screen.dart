import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/mission_card.dart';


/// Missions screen — full list of all missions with filter tabs
class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryStrong),
                  ),
                  Expanded(
                    child: Text(
                      '⚔️ My Missions',
                      style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppColors.primaryGradient),
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
                unselectedLabelColor: AppColors.textSub,
                labelStyle:
                    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'All (${allTasks.length})'),
                  Tab(text: 'Active (${activeTasks.length})'),
                  Tab(text: 'Done (${completedTasks.length})'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: taskProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryStrong))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _TaskList(tasks: allTasks),
                        _TaskList(tasks: activeTasks),
                        _TaskList(tasks: completedTasks),
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
  const _TaskList({required this.tasks});

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
              'Nothing here yet!',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Missions will appear here\nonce assigned.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: AppColors.textSub,
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
                  final success = await context.read<TaskProvider>().completeTask(task.id);
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.pushNamed(context, '/celebration', arguments: task.points);
                  }
                }
              : null,
        ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
