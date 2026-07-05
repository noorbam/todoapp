import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/level_utils.dart';

class XPProgressCard extends StatefulWidget {
  final int level;
  final int xp;
  final int streak;
  final int earnedBadges;
  final int totalBadges;

  // Optional header fields (used in child home screen)
  final String? childName;
  final int? avatarIndex;
  final int? coins;
  final Widget? avatarWidget;

  const XPProgressCard({
    super.key,
    required this.level,
    required this.xp,
    required this.streak,
    required this.earnedBadges,
    required this.totalBadges,
    this.childName,
    this.avatarIndex,
    this.coins,
    this.avatarWidget,
  });

  @override
  State<XPProgressCard> createState() => _XPProgressCardState();
}

class _XPProgressCardState extends State<XPProgressCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late AnimationController _sparkleController;
  late Animation<double> _progressAnim;
  late Animation<double> _glowAnim;

  final List<_Sparkle> _sparkles = [];
  final _rand = Random();

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _sparkleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _progressAnim = Tween<double>(
      begin: 0,
      end: LevelUtils.getLevelProgress(widget.xp),
    ).animate(CurvedAnimation(
        parent: _progressController, curve: Curves.easeOutCubic));

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _generateSparkles();

    Future.delayed(300.ms, () {
      if (mounted) {
        _progressController.forward();
        _sparkleController.forward();
      }
    });
  }

  void _generateSparkles() {
    for (int i = 0; i < 12; i++) {
      _sparkles.add(_Sparkle(
        x: _rand.nextDouble(),
        y: _rand.nextDouble() * 0.6,
        size: _rand.nextDouble() * 6 + 4,
        delay: _rand.nextDouble() * 0.6,
        emoji: ['✨', '⭐', '💫', '🌟'][_rand.nextInt(4)],
      ));
    }
  }

  @override
  void didUpdateWidget(XPProgressCard old) {
    super.didUpdateWidget(old);
    if (old.xp != widget.xp) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: LevelUtils.getLevelProgress(widget.xp),
      ).animate(CurvedAnimation(
          parent: _progressController, curve: Curves.easeOutCubic));
      _progressController
        ..reset()
        ..forward();
      _sparkleController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  bool get _hasHeader =>
      widget.childName != null || widget.avatarWidget != null;

  @override
  Widget build(BuildContext context) {
    final emoji = LevelUtils.getLevelEmoji(widget.level);
    final levelKey = 'lvl_title_${widget.level.clamp(1, 10)}';
    final title = AppStrings.get(context, levelKey);
    final toNext = LevelUtils.xpToNextLevel(widget.xp);
    final currentLevelXP = LevelUtils.getCurrentLevelXP(widget.xp);
    final levelTotalXP = LevelUtils.getLevelTotalXP(widget.level);

    // When used as full-width header: no horizontal margin, larger radius at bottom only
    final bool isFullWidth = _hasHeader;
    final borderRadius = isFullWidth
        ? const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          )
        : BorderRadius.circular(36);

    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) => Container(
        margin: isFullWidth ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryStrong.withValues(alpha: 0.25 * _glowAnim.value),
              blurRadius: 40 * _glowAnim.value,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.15 * _glowAnim.value),
              blurRadius: 60 * _glowAnim.value,
              spreadRadius: 4,
            ),
          ],
        ),
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF9333EA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(
            children: [
              // Background orbs
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // Sparkles
              ...List.generate(_sparkles.length, (i) {
                final s = _sparkles[i];
                return AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, _) {
                    final t = (_sparkleController.value - s.delay).clamp(0.0, 1.0);
                    final opacity = t < 0.5 ? t * 2 : (1 - t) * 2;
                    final scale = t < 0.5 ? t * 2 : 1.0;
                    return Positioned(
                      left: s.x * 340,
                      top: s.y * 200,
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Text(s.emoji, style: TextStyle(fontSize: s.size)),
                        ),
                      ),
                    );
                  },
                );
              }),

              // Main content
              Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  isFullWidth ? MediaQuery.of(context).padding.top + 20 : 28,
                  24,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Merged Header (Avatar + Name + Coins) ──────────────
                    if (_hasHeader) ...[
                      Row(
                        children: [
                          // Avatar with glow
                          if (widget.avatarWidget != null)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: widget.avatarWidget!,
                            ).animate().scale(
                                begin: const Offset(0.5, 0.5),
                                duration: 400.ms,
                                curve: Curves.elasticOut),
                          if (widget.avatarWidget != null) const SizedBox(width: 14),

                          // Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${AppStrings.get(context, 'hey')} ${widget.childName}! 👋',
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
                              ],
                            ),
                          ),

                          // Coins badge
                          if (widget.coins != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFACC15),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFACC15).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🏛️', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.coins}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF78350F),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(color: Colors.white.withValues(alpha: 0.15)),
                      const SizedBox(height: 20),
                    ],

                    // ── Level + Streak badges row ──────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 6),
                              Text(
                                '${AppStrings.get(context, 'levelLabel')} ${widget.level}',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: -0.2, end: 0),
                        const Spacer(),
                        // Streak badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8E53).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFF8E53).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.streak}${AppStrings.get(context, 'streakDay')}',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.2, end: 0),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Level title
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 4),

                    // XP display
                    Text(
                      '${widget.xp} ${AppStrings.get(context, 'xpLabel')}',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: 24),

                    // Progress bar
                    AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _glowAnim,
                                  builder: (context, _) => FractionallySizedBox(
                                    widthFactor: _progressAnim.value,
                                    child: Container(
                                      height: 18,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFF0ABFC)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF818CF8).withValues(alpha: 0.6 * _glowAnim.value),
                                            blurRadius: 12,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [Colors.white.withValues(alpha: 0.25), Colors.transparent],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    '$currentLevelXP / $levelTotalXP ${AppStrings.get(context, 'xpLabel')}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (toNext > 0)
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$toNext ${AppStrings.get(context, 'xpToNext')}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      AppStrings.get(context, 'maxLevel'),
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.amber.shade200,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Bottom stats — Badges only (no XP/streak duplicate)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MiniStat('🏅', '${widget.earnedBadges}/${widget.totalBadges}',
                              AppStrings.get(context, 'medalCollection')),
                          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
                          _MiniStat('⭐', '${widget.xp}', AppStrings.get(context, 'xpLabel')),
                          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.2)),
                          _MiniStat('🪙', '${widget.coins ?? 0}', AppStrings.get(context, 'coins')),
                        ],
                      ),
                    ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _MiniStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _MiniStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            )),
        Text(label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _Sparkle {
  final double x, y, size, delay;
  final String emoji;
  const _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
    required this.emoji,
  });
}
