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

  // ── Getters ───────────────────────────────────────────────────────────────

  List<TaskModel> get tasks => _tasks;
  List<TaskModel> get activeTasks =>
      _tasks.where((t) => t.isPending || t.isRejected).toList();
  List<TaskModel> get completedTasks =>
      _tasks.where((t) => t.isCompleted || t.isApproved).toList();
  List<TaskModel> get pendingApprovals => _pendingApprovals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Streams ───────────────────────────────────────────────────────────────

  void listenToChildTasks(String childId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getChildTasksStream(childId).listen(
      (tasks) {
        _tasks = tasks;
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

  void listenToPendingApprovals(String parentId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getPendingApprovalsStream(parentId).listen(
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
    try {
      await _firestoreService.completeTask(taskId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> approveTask(TaskModel task) async {
    try {
      await _firestoreService.approveTask(task);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> rejectTask(String taskId) async {
    try {
      await _firestoreService.rejectTask(taskId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
