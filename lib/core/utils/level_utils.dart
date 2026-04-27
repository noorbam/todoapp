/// KidQuest — Level & XP Utility
/// Manages leveling logic for the gamification system
class LevelUtils {
  /// XP thresholds for each level (cumulative)
  static const List<int> levelThresholds = [
    0,    // Level 1
    50,   // Level 2
    150,  // Level 3
    300,  // Level 4
    500,  // Level 5
    750,  // Level 6
    1050, // Level 7
    1400, // Level 8
    1800, // Level 9
    2250, // Level 10
  ];

  /// Get the level based on total XP (points)
  static int getLevel(int xp) {
    int level = 1;
    for (int i = 0; i < levelThresholds.length; i++) {
      if (xp >= levelThresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }
    return level;
  }

  /// Get progress towards next level (0.0 → 1.0)
  static double getLevelProgress(int xp) {
    int level = getLevel(xp);
    if (level >= levelThresholds.length) return 1.0;

    int currentThreshold = levelThresholds[level - 1];
    int nextThreshold = levelThresholds[level];
    int progressInLevel = xp - currentThreshold;
    int rangeForLevel = nextThreshold - currentThreshold;

    return (progressInLevel / rangeForLevel).clamp(0.0, 1.0);
  }

  /// XP needed to reach next level
  static int xpToNextLevel(int xp) {
    int level = getLevel(xp);
    if (level >= levelThresholds.length) return 0;
    return levelThresholds[level] - xp;
  }

  /// Level title / rank name
  static String getLevelTitle(int level) {
    const titles = [
      'Newbie',
      'Rookie',
      'Explorer',
      'Adventurer',
      'Champion',
      'Hero',
      'Warrior',
      'Legend',
      'Master',
      'Grand Master',
    ];
    final idx = (level - 1).clamp(0, titles.length - 1);
    return titles[idx];
  }

  /// Emoji for level
  static String getLevelEmoji(int level) {
    const emojis = ['🌱', '⭐', '🔥', '💪', '🏆', '⚡', '🗡️', '🌟', '👑', '🎖️'];
    final idx = (level - 1).clamp(0, emojis.length - 1);
    return emojis[idx];
  }
}
