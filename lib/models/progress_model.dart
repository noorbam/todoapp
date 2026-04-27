import 'package:cloud_firestore/cloud_firestore.dart';

/// Progress model — tracks a child's gamification stats
class ProgressModel {
  final String childId;
  final int points; // total coins (spendable balance)
  final int xp; // cumulative XP used for leveling (never decreases)
  final int level;
  final int streak; // consecutive days with at least one approved task
  final DateTime? lastActivityDate;
  final List<String> badges; // list of earned badge IDs
  final DateTime updatedAt;

  const ProgressModel({
    required this.childId,
    this.points = 0,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.lastActivityDate,
    this.badges = const [],
    required this.updatedAt,
  });

  // ── Serialization ─────────────────────────────────────────────────────────

  factory ProgressModel.fromMap(Map<String, dynamic> map, String childId) {
    return ProgressModel(
      childId: childId,
      points: map['points'] ?? 0,
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      streak: map['streak'] ?? 0,
      lastActivityDate: (map['lastActivityDate'] as Timestamp?)?.toDate(),
      badges: List<String>.from(map['badges'] ?? []),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'points': points,
      'xp': xp,
      'level': level,
      'streak': streak,
      if (lastActivityDate != null)
        'lastActivityDate': Timestamp.fromDate(lastActivityDate!),
      'badges': badges,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProgressModel copyWith({
    int? points,
    int? xp,
    int? level,
    int? streak,
    DateTime? lastActivityDate,
    List<String>? badges,
  }) {
    return ProgressModel(
      childId: childId,
      points: points ?? this.points,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      badges: badges ?? this.badges,
      updatedAt: DateTime.now(),
    );
  }
}
