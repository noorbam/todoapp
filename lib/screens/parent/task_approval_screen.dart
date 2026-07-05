import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/task_approval_card.dart';

class TaskApprovalScreen extends StatefulWidget {
  const TaskApprovalScreen({super.key});

  @override
  State<TaskApprovalScreen> createState() => _TaskApprovalScreenState();
}

class _TaskApprovalScreenState extends State<TaskApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parent = context.read<AuthProvider>().currentUser;
      if (parent != null) {
        context.read<TaskProvider>().listenToPendingApprovals(parent.id);
      }
    });
  }

  Future<String> _getChildName(String childId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(childId).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['name'] ?? 'Unknown';
    }
    return 'Unknown Hero';
  }

  Future<void> _approve(TaskModel task) async {
    final success = await context.read<TaskProvider>().approveTask(task);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? AppStrings.get(context, 'approveSuccess')
            : AppStrings.get(context, 'approveError')),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _reject(String taskId) async {
    await context.read<TaskProvider>().rejectTask(taskId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get(context, 'rejectMsg')),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.pendingApprovals;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          AppStrings.get(context, 'missionApprovals'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryStrong),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryStrong))
          : tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🎉', style: TextStyle(fontSize: 80))
                          .animate()
                          .scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.get(context, 'allClear'),
                        style: GoogleFonts.cairo(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get(context, 'noPendingApprovals'),
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return FutureBuilder<String>(
                      future: _getChildName(task.childId),
                      builder: (context, snapshot) {
                        return TaskApprovalCard(
                          task: task,
                          childName: snapshot.data ?? '...',
                          onApprove: () => _approve(task),
                          onReject: () => _reject(task.id),
                        ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
                      },
                    );
                  },
                ),
    );
  }
}
