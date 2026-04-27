import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/progress_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/child_summary_card.dart';

/// Parent Dashboard — shows children list with progress overview
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parent = context.read<AuthProvider>().currentUser;
      if (parent != null) {
        context.read<ChildProvider>().listenToChildren(parent.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final childProvider = context.watch<ChildProvider>();
    final parent = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KidQuest',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.primaryStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'My Heroes 🏆',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.task_alt, color: AppColors.primaryStrong),
            tooltip: 'Approvals',
            onPressed: () =>
                Navigator.pushNamed(context, '/task-approval'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSub),
            tooltip: 'Sign Out',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: childProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryStrong))
          : childProvider.children.isEmpty
              ? _buildEmptyState(context)
              : _buildChildrenList(context, childProvider.children),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChildDialog(context, parent!),
        backgroundColor: AppColors.primaryStrong,
        elevation: 4,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          'Add Hero',
          style: GoogleFonts.nunito(
              color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _buildChildrenList(BuildContext context, List<UserModel> children) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        return FutureBuilder(
          future: context.read<ProgressProvider>().fetchProgress(child.id),
          builder: (context, snapshot) {
            return ChildSummaryCard(
              child: child,
              progress: snapshot.data,
              onTap: () {
                context.read<ChildProvider>().selectChild(child);
                Navigator.pushNamed(context, '/child-progress',
                    arguments: child);
              },
            ).animate(delay: (index * 80).ms).fadeIn(duration: 300.ms).slideX(
                  begin: -0.1,
                  end: 0,
                  curve: Curves.easeOut,
                );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👶', style: TextStyle(fontSize: 72))
              .animate()
              .scale(begin: const Offset(0, 0), duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'No Heroes Yet!',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap "Add Hero" to create your\nfirst child account.',
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

  void _showAddChildDialog(BuildContext context, UserModel parent) {
    final nameController = TextEditingController();
    final pinController = TextEditingController();
    int selectedAvatar = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            title: Text(
              'Add New Hero 🦸',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 22),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Hero's Name",
                      prefixIcon: Icon(Icons.person, color: AppColors.primaryStrong),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '4-digit PIN',
                      prefixIcon: Icon(Icons.lock, color: AppColors.primaryStrong),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose Avatar:',
                    style: GoogleFonts.nunito(
                        fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      8,
                      (i) => GestureDetector(
                        onTap: () => setDialogState(() => selectedAvatar = i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedAvatar == i
                                  ? AppColors.primaryStrong
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: _buildAvatarPreview(i, selectedAvatar == i),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel', style: GoogleFonts.nunito(color: AppColors.textSub, fontWeight: FontWeight.w700)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty ||
                      pinController.text.trim().length != 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please fill name and 4-digit PIN!')),
                    );
                    return;
                  }

                  final child =
                      await context.read<AuthProvider>().createChildAccount(
                            name: nameController.text.trim(),
                            pin: pinController.text.trim(),
                            avatarIndex: selectedAvatar,
                          );

                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);

                  if (child != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${child.name} is ready to quest! 🎉'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('Create Hero!'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatarPreview(int index, bool selected) {
    const emojis = ['🦁', '🐼', '🐸', '🐯', '🦊', '🐧', '🦄', '🐻'];
    const colors = [
      Color(0xFFFF9800), Color(0xFF607D8B), Color(0xFF4CAF50),
      Color(0xFFF44336), Color(0xFFFF5722), Color(0xFF2196F3),
      Color(0xFF9C27B0), Color(0xFF795548),
    ];
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors[index],
        boxShadow: selected
            ? [BoxShadow(color: colors[index].withValues(alpha: 0.5), blurRadius: 8)]
            : [],
      ),
      child: Center(
        child: Text(emojis[index], style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
