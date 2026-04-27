/// Badge model — achievements for the gamification system
class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String condition; // human-readable unlock condition

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.condition,
  });

  /// All available badges in the game
  static const List<BadgeModel> allBadges = [
    BadgeModel(
      id: 'first_mission',
      title: 'First Mission!',
      description: 'Completed your very first mission.',
      emoji: '🚀',
      condition: 'Complete 1 approved task',
    ),
    BadgeModel(
      id: 'streak_5',
      title: '5-Day Warrior',
      description: 'Maintained a 5-day streak!',
      emoji: '🔥',
      condition: 'Reach 5-day streak',
    ),
    BadgeModel(
      id: 'streak_10',
      title: '10-Day Legend',
      description: 'An unstoppable force! 10 days in a row!',
      emoji: '⚡',
      condition: 'Reach 10-day streak',
    ),
    BadgeModel(
      id: 'level_5',
      title: 'Level 5 Hero',
      description: 'Reached Level 5 — you are a true hero!',
      emoji: '🏆',
      condition: 'Reach Level 5',
    ),
    BadgeModel(
      id: 'level_10',
      title: 'Grand Master',
      description: 'Maximum level achieved. Legendary!',
      emoji: '👑',
      condition: 'Reach Level 10',
    ),
    BadgeModel(
      id: 'coins_100',
      title: 'Century Collector',
      description: 'Earned 100 coins total!',
      emoji: '💰',
      condition: 'Earn 100 total XP',
    ),
    BadgeModel(
      id: 'missions_10',
      title: 'Mission Master',
      description: 'Completed 10 missions!',
      emoji: '🎖️',
      condition: 'Complete 10 approved tasks',
    ),
  ];

  /// Check which new badges should be awarded given current stats
  static List<String> checkNewBadges({
    required int xp,
    required int level,
    required int streak,
    required int approvedTaskCount,
    required List<String> existingBadges,
  }) {
    final List<String> newBadges = [];

    void check(String id, bool condition) {
      if (condition && !existingBadges.contains(id)) {
        newBadges.add(id);
      }
    }

    check('first_mission', approvedTaskCount >= 1);
    check('streak_5', streak >= 5);
    check('streak_10', streak >= 10);
    check('level_5', level >= 5);
    check('level_10', level >= 10);
    check('coins_100', xp >= 100);
    check('missions_10', approvedTaskCount >= 10);

    return newBadges;
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
