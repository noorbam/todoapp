import 'dart:async';
import 'package:flutter/material.dart';
import '../models/progress_model.dart';
import '../services/firestore_service.dart';

/// ProgressProvider — real-time gamification stats for a child
class ProgressProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  ProgressModel? _progress;
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  ProgressModel? get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get points => _progress?.points ?? 0;
  int get xp => _progress?.xp ?? 0;
  int get level => _progress?.level ?? 1;
  int get streak => _progress?.streak ?? 0;
  int get approvedTasksCount => _progress?.approvedTasksCount ?? 0;
  List<String> get badges => _progress?.badges ?? [];

  // ── Stream ────────────────────────────────────────────────────────────────
  StreamSubscription<ProgressModel?>? _progressSubscription;

  void listenToProgress(String childId) {
    _progressSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _progressSubscription = _firestoreService.getProgressStream(childId).listen(
      (progress) {
        _progress = progress;
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

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  // ── Fetch Once (for parent overview) ──────────────────────────────────────

  Future<ProgressModel?> fetchProgress(String childId) async {
    return await _firestoreService.getProgress(childId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
