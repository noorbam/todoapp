import 'package:cloud_firestore/cloud_firestore.dart';

/// Task (Mission) model for the gamified to-do system
class TaskModel {
  final String id;
  final String title;
  final String description;
  final int points; // coins awarded on approval
  final DateTime? deadline;
  final String status; // 'pending' | 'completed' | 'approved' | 'rejected'
  final String childId;
  final String parentId;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.points,
    this.deadline,
    required this.status,
    required this.childId,
    required this.parentId,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  /// Whether deadline has passed
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isApproved;
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      points: map['points'] ?? 10,
      deadline: (map['deadline'] as Timestamp?)?.toDate(),
      status: map['status'] ?? 'pending',
      childId: map['childId'] ?? '',
      parentId: map['parentId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'points': points,
      if (deadline != null) 'deadline': Timestamp.fromDate(deadline!),
      'status': status,
      'childId': childId,
      'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    int? points,
    DateTime? deadline,
    String? status,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      childId: childId,
      parentId: parentId,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
