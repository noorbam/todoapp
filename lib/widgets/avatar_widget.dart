import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Built-in avatar set — 8 cartoon-style circular avatars using emoji + color backgrounds.
/// Children pick one of these; parents can see it on their dashboard.
class AvatarWidget extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final bool isSelected;
  final VoidCallback? onTap;

  const AvatarWidget({
    super.key,
    required this.avatarIndex,
    this.size = 64,
    this.isSelected = false,
    this.onTap,
  });

  // 8 avatar definitions: emoji + background color
  static const List<Map<String, dynamic>> _avatars = [
    {'emoji': '🦁', 'color': Color(0xFFFF9800)},
    {'emoji': '🐼', 'color': Color(0xFF607D8B)},
    {'emoji': '🐸', 'color': Color(0xFF4CAF50)},
    {'emoji': '🐯', 'color': Color(0xFFF44336)},
    {'emoji': '🦊', 'color': Color(0xFFFF5722)},
    {'emoji': '🐧', 'color': Color(0xFF2196F3)},
    {'emoji': '🦄', 'color': Color(0xFF9C27B0)},
    {'emoji': '🐻', 'color': Color(0xFF795548)},
  ];

  static String emojiForIndex(int index) =>
      _avatars[index.clamp(0, _avatars.length - 1)]['emoji'] as String;

  @override
  Widget build(BuildContext context) {
    final idx = avatarIndex.clamp(0, _avatars.length - 1);
    final avatar = _avatars[idx];
    final emoji = avatar['emoji'] as String;
    final bgColor = avatar['color'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(
            color: isSelected ? AppColors.primaryStrong : Theme.of(context).cardColor,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppColors.primaryStrong : bgColor)
                  .withValues(alpha: 0.3),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.52),
          ),
        ),
      ),
    );
  }
}
