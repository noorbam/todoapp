import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// Streak badge — fire icon + day count
class StreakBadge extends StatelessWidget {
  final int streak;
  final double size;

  const StreakBadge({super.key, required this.streak, this.size = 1.0});

  @override
  Widget build(BuildContext context) {
    final isActive = streak > 0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * size,
        vertical: 6 * size,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [const Color(0xFFFF8E53), const Color(0xFFFEAC5E)]
              : [Colors.grey.shade200, Colors.grey.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20 * size),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF8E53).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isActive ? '🔥' : '💤',
            style: TextStyle(fontSize: 18 * size),
          ),
          SizedBox(width: 6 * size),
          Text(
            '$streak Day${streak == 1 ? '' : 's'}',
            style: GoogleFonts.nunito(
              fontSize: 14 * size,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
