import 'progress_model.dart';

class BadgeProgress {
  final int current;
  final int target;
  final double fraction;

  BadgeProgress({required int current, required this.target})
      : current = current.clamp(0, target),
        fraction = target == 0 ? 0.0 : (current.clamp(0, target) / target);
}

/// Badge model — achievements for the gamification system
class BadgeModel {
  final String id;
  final String titleKey;
  final String descKey;
  final String emoji;
  final int requiredXp; // unified XP requirement

  const BadgeModel({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.emoji,
    required this.requiredXp,
  });

  /// The unified XP badge progression
  static const List<BadgeModel> allBadges = [
    BadgeModel(
      id: 'novice',
      titleKey: 'badge_novice_title',
      descKey: 'badge_novice_desc',
      emoji: '🌟',
      requiredXp: 50,
    ),
    BadgeModel(
      id: 'apprentice',
      titleKey: 'badge_apprentice_title',
      descKey: 'badge_apprentice_desc',
      emoji: '🛡️',
      requiredXp: 300,
    ),
    BadgeModel(
      id: 'knight',
      titleKey: 'badge_knight_title',
      descKey: 'badge_knight_desc',
      emoji: '⚔️',
      requiredXp: 750,
    ),
    BadgeModel(
      id: 'master',
      titleKey: 'badge_master_title',
      descKey: 'badge_master_desc',
      emoji: '👑',
      requiredXp: 1400,
    ),
    BadgeModel(
      id: 'legend',
      titleKey: 'badge_legend_title',
      descKey: 'badge_legend_desc',
      emoji: '🐉',
      requiredXp: 2250,
    ),
  ];

  /// Check which new badges should be awarded given current stats
  static List<String> checkNewBadges({
    required int xp,
    required List<String> existingBadges,
  }) {
    final List<String> newBadges = [];

    for (var badge in allBadges) {
      if (!existingBadges.contains(badge.id)) {
        if (xp >= badge.requiredXp) {
          newBadges.add(badge.id);
        }
      }
    }

    return newBadges;
  }

  /// Get the current progress towards earning this badge
  BadgeProgress getProgress(ProgressModel progress) {
    int current = progress.xp;
    int target = requiredXp;

    if (current > target) current = target;
    return BadgeProgress(current: current, target: target);
  }

  /// Get badge by id
  static BadgeModel? findById(String id) {
    try {
      return allBadges.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
