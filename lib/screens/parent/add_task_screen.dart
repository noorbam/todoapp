import 'package:flutter/material.dart';
import '../../core/constants/app_strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/child_provider.dart';
import '../../models/user_model.dart';

/// Add Task screen — parent creates a new mission for a child
class AddTaskScreen extends StatefulWidget {
  final UserModel? child;
  const AddTaskScreen({super.key, this.child});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _points = 25;
  String _difficulty = 'easy';
  DateTime? _deadline;
  UserModel? _selectedChild;
  bool _isLoading = false;

  int get _minCoins => _difficulty == 'easy' ? 5 : _difficulty == 'medium' ? 51 : 101;
  int get _maxCoins => _difficulty == 'easy' ? 50 : _difficulty == 'medium' ? 100 : 200;
  int get _fixedXp => _difficulty == 'easy' ? 50 : _difficulty == 'medium' ? 100 : 200;

  @override
  void initState() {
    super.initState();
    _selectedChild = widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedChild == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserModel) {
        _selectedChild = args;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChild == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.get(context, 'pleaseAssignMission'))),
      );
      return;
    }

    setState(() => _isLoading = true);
    final parent = context.read<AuthProvider>().currentUser!;
    final success = await context.read<TaskProvider>().addTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          points: _points,
          difficulty: _difficulty,
          xp: _fixedXp,
          childId: _selectedChild!.id,
          parentId: parent.id,
          deadline: _deadline,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get(context, 'missionCreated')),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<TaskProvider>().error ?? 'Error!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final font = langProvider.isArabic ? GoogleFonts.cairo() : GoogleFonts.cairo();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          AppStrings.get(context, 'newMission'),
          style: font.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryStrong),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(AppStrings.get(context, 'missionTitle'), font),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: font.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: AppStrings.get(context, 'missionTitleHint'),
                  hintStyle: font.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.emoji_flags, color: AppColors.primaryStrong),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? AppStrings.get(context, 'enterTitle') : null,
              ),
              const SizedBox(height: 24),

              _sectionLabel(AppStrings.get(context, 'missionDesc'), font),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: font.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: AppStrings.get(context, 'missionDescHint'),
                  hintStyle: font.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                  prefixIcon: const Icon(Icons.description, color: AppColors.primaryStrong),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _sectionLabel(AppStrings.get(context, 'difficultyLevel'), font),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _difficultyButton('easy', AppStrings.get(context, 'easy'), font)),
                  const SizedBox(width: 8),
                  Expanded(child: _difficultyButton('medium', AppStrings.get(context, 'medium'), font)),
                  const SizedBox(width: 8),
                  Expanded(child: _difficultyButton('hard', AppStrings.get(context, 'hard'), font)),
                ],
              ),
              const SizedBox(height: 32),

              _sectionLabel(AppStrings.get(context, 'coinReward'), font),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      '$_points ${AppStrings.get(context, 'coins')}',
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.rewardColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+$_fixedXp XP',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _points.toDouble(),
                      min: _minCoins.toDouble(),
                      max: _maxCoins.toDouble(),
                      divisions: (_maxCoins - _minCoins) > 0 ? (_maxCoins - _minCoins) : 1,
                      activeColor: AppColors.rewardColor,
                      inactiveColor: AppColors.rewardColor.withValues(alpha: 0.1),
                      onChanged: (v) => setState(() => _points = v.round()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_minCoins', style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w800)),
                        Text('$_maxCoins', style: GoogleFonts.cairo(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionLabel(AppStrings.get(context, 'deadlineOptional'), font),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.primaryStrong, size: 22),
                      const SizedBox(width: 14),
                      Text(
                        _deadline != null
                            ? DateFormat('MMMM d, yyyy').format(_deadline!)
                            : AppStrings.get(context, 'noDeadlineHint'),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _deadline != null
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const Spacer(),
                      if (_deadline != null)
                        IconButton(
                          onPressed: () => setState(() => _deadline = null),
                          icon: Icon(Icons.close,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), size: 20),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryStrong))
                    : ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send),
                        label: Text(AppStrings.get(context, 'launchMission'), style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryStrong,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, TextStyle font) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: font.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _difficultyButton(String value, String label, TextStyle font) {
    final isSelected = _difficulty == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _difficulty = value;
          // Ensure points stay within the new valid range
          if (_points < _minCoins) _points = _minCoins;
          if (_points > _maxCoins) _points = _maxCoins;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryStrong : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryStrong : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: font.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
