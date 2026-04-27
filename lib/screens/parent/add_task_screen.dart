import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/child_provider.dart';
import '../../models/user_model.dart';

/// Add Task screen — parent creates a new mission for a child
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _points = 10;
  DateTime? _deadline;
  UserModel? _selectedChild;
  bool _isLoading = false;

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
        const SnackBar(content: Text('Please assign this mission to a hero!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final parent = context.read<AuthProvider>().currentUser!;
    final success = await context.read<TaskProvider>().addTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          points: _points,
          childId: _selectedChild!.id,
          parentId: parent.id,
          deadline: _deadline,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mission created! ⚔️'),
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
    final childProvider = context.watch<ChildProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'New Mission ⚔️',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            color: AppColors.textMain,
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
              _sectionLabel('Mission Title'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'e.g. Clean your room',
                  hintStyle: GoogleFonts.nunito(color: AppColors.textSub.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.emoji_flags, color: AppColors.primaryStrong),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 24),

              _sectionLabel('Description (optional)'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Add details about this mission...',
                  hintStyle: GoogleFonts.nunito(color: AppColors.textSub.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.description, color: AppColors.primaryStrong),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _sectionLabel('Coin Reward 🪙'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      '$_points Coins',
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.rewardColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _points.toDouble(),
                      min: 5,
                      max: 100,
                      divisions: 19,
                      activeColor: AppColors.rewardColor,
                      inactiveColor: AppColors.rewardColor.withValues(alpha: 0.1),
                      onChanged: (v) => setState(() => _points = v.round()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5', style: GoogleFonts.nunito(color: AppColors.textSub, fontWeight: FontWeight.w800)),
                        Text('100', style: GoogleFonts.nunito(color: AppColors.textSub, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _sectionLabel('Deadline (optional)'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
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
                            : 'No deadline — pick a date',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _deadline != null
                              ? AppColors.textMain
                              : AppColors.textSub,
                        ),
                      ),
                      const Spacer(),
                      if (_deadline != null)
                        IconButton(
                          onPressed: () => setState(() => _deadline = null),
                          icon: const Icon(Icons.close,
                              color: AppColors.textSub, size: 20),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _sectionLabel('Assign to Hero'),
              const SizedBox(height: 10),
              if (childProvider.children.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: AppColors.error, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'No heroes yet! Add a child first.',
                        style: GoogleFonts.nunito(
                            fontSize: 14, color: AppColors.error, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: DropdownButtonFormField<UserModel>(
                    value: _selectedChild,
                    hint: Text('Select a hero', style: GoogleFonts.nunito(color: AppColors.textSub)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person, color: AppColors.primaryStrong),
                    ),
                    items: childProvider.children
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name, style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedChild = v),
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
                        label: const Text('Launch Mission!'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryStrong,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900),
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

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.textMain,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
