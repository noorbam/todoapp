import 'package:cloud_firestore/cloud_firestore.dart';

/// Reward model — items parents create for children to redeem with coins
class RewardModel {
  final String id;
  final String title;
  final String description;
  final int cost; // coin cost to redeem
  final String iconName; // emoji or icon identifier
  final String childId;
  final String parentId;
  final bool isRedeemed;
  final DateTime createdAt;
  final DateTime? redeemedAt;

  const RewardModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.cost,
    this.iconName = '🎁',
    required this.childId,
    required this.parentId,
    this.isRedeemed = false,
    required this.createdAt,
    this.redeemedAt,
  });

  // ── Serialization ─────────────────────────────────────────────────────────

  factory RewardModel.fromMap(Map<String, dynamic> map, String id) {
    return RewardModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      cost: map['cost'] ?? 50,
      iconName: map['iconName'] ?? '🎁',
      childId: map['childId'] ?? '',
      parentId: map['parentId'] ?? '',
      isRedeemed: map['isRedeemed'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      redeemedAt: (map['redeemedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'cost': cost,
      'iconName': iconName,
      'childId': childId,
      'parentId': parentId,
      'isRedeemed': isRedeemed,
      'createdAt': Timestamp.fromDate(createdAt),
      if (redeemedAt != null) 'redeemedAt': Timestamp.fromDate(redeemedAt!),
    };
  }

  RewardModel copyWith({bool? isRedeemed, DateTime? redeemedAt}) {
    return RewardModel(
      id: id,
      title: title,
      description: description,
      cost: cost,
      iconName: iconName,
      childId: childId,
      parentId: parentId,
      isRedeemed: isRedeemed ?? this.isRedeemed,
      createdAt: createdAt,
      redeemedAt: redeemedAt ?? this.redeemedAt,
    );
  }
}
