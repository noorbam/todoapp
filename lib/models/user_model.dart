import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for both Parent and Child accounts
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'parent' or 'child'
  final String? parentId; // set for children; null for parents
  final int avatarIndex; // index into the built-in avatar set (0–7)
  final String? pin; // 4-digit PIN for child login
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.parentId,
    this.avatarIndex = 0,
    this.pin,
    required this.createdAt,
  });

  bool get isParent => role == 'parent';
  bool get isChild => role == 'child';

  // ── Serialization ─────────────────────────────────────────────────────────

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'child',
      parentId: map['parentId'],
      avatarIndex: map['avatarIndex'] ?? 0,
      pin: map['pin'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (parentId != null) 'parentId': parentId,
      'avatarIndex': avatarIndex,
      if (pin != null) 'pin': pin,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? role,
    String? parentId,
    int? avatarIndex,
    String? pin,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      parentId: parentId ?? this.parentId,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      pin: pin ?? this.pin,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
