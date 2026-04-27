import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/reward_model.dart';
import '../models/progress_model.dart';
import '../models/user_model.dart';
import '../core/utils/level_utils.dart';

/// FirestoreService — CRUD operations for tasks, rewards, progress, and users
class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ── Collections ───────────────────────────────────────────────────────────

  CollectionReference get _users => _db.collection('users');
  CollectionReference get _tasks => _db.collection('tasks');
  CollectionReference get _rewards => _db.collection('rewards');
  CollectionReference get _progress => _db.collection('progress');

  // ── Users ─────────────────────────────────────────────────────────────────

  /// Get all children belonging to a specific parent (real-time stream)
  Stream<List<UserModel>> getChildrenByParent(String parentId) {
    return _users
        .where('parentId', isEqualTo: parentId)
        .where('role', isEqualTo: 'child')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  /// Get ALL children across all parents (used on child login screen)
  Stream<List<UserModel>> getAllChildrenStream() {
    return _users
        .where('role', isEqualTo: 'child')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> updateChildAvatar(String childId, int avatarIndex) async {
    await _users.doc(childId).update({'avatarIndex': avatarIndex});
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  Stream<List<TaskModel>> getChildTasksStream(String childId) {
    return _tasks
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<TaskModel>> getPendingApprovalsStream(String parentId) {
    return _tasks
        .where('parentId', isEqualTo: parentId)
        .where('status', isEqualTo: 'completed')
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<void> createTask({
    required String title,
    String? description,
    required int points,
    required String childId,
    required String parentId,
    DateTime? deadline,
  }) async {
    final task = TaskModel(
      id: '',
      title: title,
      description: description ?? '',
      points: points,
      childId: childId,
      parentId: parentId,
      deadline: deadline,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await _tasks.doc().set(task.toMap());
  }

  Future<void> completeTask(String taskId) async {
    await _tasks.doc(taskId).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> approveTask(TaskModel task) async {
    final batch = _db.batch();
    batch.update(_tasks.doc(task.id), {'status': 'approved'});

    final progressRef = _progress.doc(task.childId);
    final progressSnap = await progressRef.get();

    if (progressSnap.exists) {
      final progress = ProgressModel.fromMap(
        progressSnap.data() as Map<String, dynamic>,
        task.childId,
      );

      final newXp = progress.xp + task.points;
      final newPoints = progress.points + task.points;
      final newLevel = LevelUtils.getLevel(newXp);
      final newStreak = progress.streak + 1;

      batch.update(progressRef, {
        'points': newPoints,
        'xp': newXp,
        'level': newLevel,
        'streak': newStreak,
        'lastActivityDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> rejectTask(String taskId) async {
    await _tasks.doc(taskId).update({'status': 'rejected'});
  }

  // ── Rewards ───────────────────────────────────────────────────────────────

  Stream<List<RewardModel>> getRewardsStream(String childId) {
    return _rewards
        .where('childId', isEqualTo: childId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                RewardModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Future<bool> redeemReward(RewardModel reward, int currentPoints) async {
    if (currentPoints < reward.cost) return false;

    final batch = _db.batch();
    batch.update(_rewards.doc(reward.id), {
      'isRedeemed': true,
      'redeemedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_progress.doc(reward.childId), {
      'points': FieldValue.increment(-reward.cost),
    });

    await batch.commit();
    return true;
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Stream<ProgressModel?> getProgressStream(String childId) {
    return _progress.doc(childId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return ProgressModel.fromMap(
        snap.data() as Map<String, dynamic>,
        childId,
      );
    });
  }

  Future<ProgressModel?> getProgress(String childId) async {
    final snap = await _progress.doc(childId).get();
    if (!snap.exists) return null;
    return ProgressModel.fromMap(snap.data() as Map<String, dynamic>, childId);
  }
}
