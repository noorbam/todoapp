import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/level_utils.dart';

/// Animated XP level progress bar with glow effect
class LevelBar extends StatefulWidget {
  final int level;
  final int xp;

  const LevelBar({super.key, required this.level, required this.xp});

  @override
  State<LevelBar> createState() => _LevelBarState();
}

class _LevelBarState extends State<LevelBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _progressAnim = Tween<double>(
      begin: 0,
      end: LevelUtils.getLevelProgress(widget.xp),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(LevelBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.xp != widget.xp) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: LevelUtils.getLevelProgress(widget.xp),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emoji = LevelUtils.getLevelEmoji(widget.level);
    final title = LevelUtils.getLevelTitle(widget.level);
    final toNext = LevelUtils.xpToNextLevel(widget.xp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Level ${widget.level} · $title',
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.textMain,
              ),
            ),
            const Spacer(),
            if (toNext > 0)
              Text(
                '$toNext XP to next',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSub,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _progressAnim,
          builder: (context, _) {
            return Stack(
              children: [
                // Track
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: _progressAnim.value,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.progressGradient,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
