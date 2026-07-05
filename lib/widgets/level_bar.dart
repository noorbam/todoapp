import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/level_utils.dart';

class LevelBar extends StatefulWidget {
  final int level;
  final int xp;
  final bool isLight;

  const LevelBar({super.key, required this.level, required this.xp, this.isLight = false});

  @override
  State<LevelBar> createState() => _LevelBarState();
}

class _LevelBarState extends State<LevelBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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
    final title = AppStrings.get(context, 'lvl_title_${widget.level.clamp(1, 10)}');
    final toNext = LevelUtils.xpToNextLevel(widget.xp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              '${AppStrings.get(context, 'levelLabel')} ${widget.level} · $title',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: widget.isLight ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (toNext > 0)
              Text(
                '$toNext ${AppStrings.get(context, 'xpToNext')}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.isLight ? Colors.white70 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: _progressAnim.value,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: AppColors.progressGradient),
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
