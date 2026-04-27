import 'package:flutter/material.dart';
import '../models/badge_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// Badge chip widget — displays an earned badge as a small pill
class BadgeChip extends StatelessWidget {
  final String badgeId;
  final bool isEarned;

  const BadgeChip({super.key, required this.badgeId, this.isEarned = true});

  @override
  Widget build(BuildContext context) {
    final badge = BadgeModel.findById(badgeId);
    if (badge == null) return const SizedBox.shrink();

    return Tooltip(
      message: '${badge.title}\n${badge.description}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isEarned
              ? Colors.amber.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEarned ? Colors.amber : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.emoji,
              style: TextStyle(
                fontSize: 16,
                color: isEarned ? null : const Color(0x55FFFFFF),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              badge.title,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isEarned ? Colors.amber : Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
