import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../models/reward_model.dart';
import '../../models/progress_model.dart';
import '../../models/badge_model.dart';

/// DemoData — static demo content for preview/demo mode (no Firebase required)
class DemoData {
  // ── Users ──────────────────────────────────────────────────────────────────
  
  static final UserModel demoParent = UserModel(
    id: 'demo-parent-001',
    name: 'أحمد (أب تجريبي)',
    email: 'parent@demo.com',
    role: 'parent',
    createdAt: DateTime.now(),
  );

  static final UserModel demoChild1 = UserModel(
    id: 'demo-child-001',
    name: 'سامر',
    email: '',
    role: 'child',
    parentId: 'demo-parent-001',
    avatarIndex: 0, // 🦁
    pin: '1234',
    createdAt: DateTime.now(),
  );

  static final UserModel demoChild2 = UserModel(
    id: 'demo-child-002',
    name: 'لونا',
    email: '',
    role: 'child',
    parentId: 'demo-parent-001',
    avatarIndex: 6, // 🦄
    pin: '5678',
    createdAt: DateTime.now(),
  );

  // mutable list for demo session
  static List<UserModel> childrenList = [demoChild1, demoChild2];

  static List<UserModel> get children => childrenList;

  // ── Tasks ──────────────────────────────────────────────────────────────────

  static List<TaskModel> tasksForChild(String childId) => [
        TaskModel(
          id: 'task-001',
          title: 'ترتيب الغرفة',
          description: 'رتب سريرك وضع ألعابك في مكانها!',
          points: 20,
          deadline: DateTime.now().add(const Duration(days: 1)),
          status: 'pending',
          childId: childId,
          parentId: 'demo-parent-001',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TaskModel(
          id: 'task-002',
          title: 'حل الواجبات',
          description: 'أكمل جميع تمارين كتاب الرياضيات.',
          points: 30,
          deadline: DateTime.now().add(const Duration(days: 2)),
          status: 'pending',
          childId: childId,
          parentId: 'demo-parent-001',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        TaskModel(
          id: 'task-003',
          title: 'القراءة لمدة 20 دقيقة',
          description: 'اختر أي كتاب تحبه واقرأه بهدوء.',
          points: 15,
          status: 'approved',
          childId: childId,
          parentId: 'demo-parent-001',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(hours: 10)),
        ),
      ];

  static List<TaskModel> get pendingApprovals => [
        TaskModel(
          id: 'task-004',
          title: 'المساعدة في تحضير المائدة',
          description: 'ضع الأطباق والأكواب لتناول العشاء.',
          points: 10,
          status: 'completed',
          childId: demoChild1.id,
          parentId: 'demo-parent-001',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

  // ── Rewards ────────────────────────────────────────────────────────────────

  static List<RewardModel> rewardsForChild(String childId) => [
        RewardModel(
          id: 'reward-001',
          title: '30 دقيقة وقت إضافي للجهاز',
          description: 'وقت إضافي على الجهاز اللوحي أو التلفاز!',
          cost: 30,
          iconName: '📱',
          childId: childId,
          parentId: 'demo-parent-001',
          createdAt: DateTime.now(),
        ),
        RewardModel(
          id: 'reward-002',
          title: 'اختيار العشاء!',
          description: 'أنت من يختار ماذا سنأكل الليلة.',
          cost: 50,
          iconName: '🍕',
          childId: childId,
          parentId: 'demo-parent-001',
          createdAt: DateTime.now(),
        ),
      ];

  // ── Progress ───────────────────────────────────────────────────────────────

  static ProgressModel progressForChild(String childId) => ProgressModel(
        childId: childId,
        points: 65,
        xp: 165,
        level: 3,
        streak: 4,
        lastActivityDate: DateTime.now().subtract(const Duration(hours: 2)),
        badges: ['first_mission', 'streak_5', 'coins_100'],
        updatedAt: DateTime.now(),
      );
}
