import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

/// TaskProvider — manages missions for parents and children
class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  List<TaskModel> _pendingApprovals = [];
  bool _isLoading = false;
  String? _error;

  // Track IDs currently being deleted to prevent stream-revert flicker
  final Set<String> _deletingIds = {};

  // ── Stream Subscriptions ──────────────────────────────────────────────────
  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  StreamSubscription<List<TaskModel>>? _approvalsSubscription;

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _approvalsSubscription?.cancel();
    super.dispose();
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  List<TaskModel> get tasks => _tasks.where((t) => !_deletingIds.contains(t.id)).toList();
  List<TaskModel> get activeTasks =>
      tasks.where((t) => t.isPending || t.isRejected).toList();
  List<TaskModel> get completedTasks =>
      tasks.where((t) {
        if (t.isCompleted) return true;
        if (t.isApproved && t.approvedAt != null) {
          // Keep approved tasks for only 24 hours
          return DateTime.now().difference(t.approvedAt!).inHours < 24;
        }
        return false;
      }).toList();
  List<TaskModel> get pendingApprovals => 
      _pendingApprovals.where((t) => !_deletingIds.contains(t.id)).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool isDeleting(String taskId) => _deletingIds.contains(taskId);

  // ── Streams ───────────────────────────────────────────────────────────────

  void listenToChildTasks(String childId) {
    _tasksSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _tasksSubscription = _firestoreService.getChildTasksStream(childId).listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        
        // Auto-cleanup: Delete approved tasks older than 24 hours from Firestore
        for (var task in tasks) {
          if (task.isApproved && task.approvedAt != null) {
            if (DateTime.now().difference(task.approvedAt!).inHours >= 24) {
              _firestoreService.deleteTask(task.id);
            }
          }
        }
        
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void listenToPendingApprovals(String parentId) {
    _approvalsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _approvalsSubscription = _firestoreService.getPendingApprovalsStream(parentId).listen(
      (tasks) {
        _pendingApprovals = tasks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<bool> addTask({
    required String title,
    String? description,
    required int points,
    required String difficulty,
    required int xp,
    required String childId,
    required String parentId,
    DateTime? deadline,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.createTask(
        title: title,
        description: description,
        points: points,
        difficulty: difficulty,
        xp: xp,
        childId: childId,
        parentId: parentId,
        deadline: deadline,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeTask(String taskId) async {
    debugPrint('🔵 completeTask called with id: $taskId');
    try {
      await _firestoreService.completeTask(taskId);
      debugPrint('✅ completeTask SUCCESS');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ completeTask FAILED: $e');
      return false;
    }
  }

  Future<bool> approveTask(TaskModel task) async {
    // Optimistic UI update
    final int taskIndex = _pendingApprovals.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      _pendingApprovals.removeAt(taskIndex);
      notifyListeners();
    }

    try {
      await _firestoreService.approveTask(task);
      return true;
    } catch (e) {
      _error = e.toString();
      // Rollback
      if (taskIndex != -1) {
        _pendingApprovals.insert(taskIndex, task);
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> rejectTask(String taskId) async {
    // Optimistic UI update
    final int taskIndex = _pendingApprovals.indexWhere((t) => t.id == taskId);
    TaskModel? removedTask;
    if (taskIndex != -1) {
      removedTask = _pendingApprovals.removeAt(taskIndex);
      notifyListeners();
    }

    try {
      await _firestoreService.rejectTask(taskId);
      return true;
    } catch (e) {
      _error = e.toString();
      // Rollback
      if (taskIndex != -1 && removedTask != null) {
        _pendingApprovals.insert(taskIndex, removedTask);
        notifyListeners();
      }
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    debugPrint('TaskProvider: Attempting to delete task ID: $taskId');
    
    // Add to deleting set for immediate UI response
    _deletingIds.add(taskId);
    notifyListeners();

    try {
      await _firestoreService.deleteTask(taskId);
      debugPrint('TaskProvider: Successfully deleted from Firestore');
      
      // We keep it in the set for a moment to let streams stabilize
      Future.delayed(const Duration(seconds: 5), () {
        _deletingIds.remove(taskId);
        notifyListeners();
      });
      
      return true;
    } catch (e) {
      debugPrint('TaskProvider: Error deleting task: $e');
      _error = e.toString();
      _deletingIds.remove(taskId);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
