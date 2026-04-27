import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// ChildProvider — manages list of children.
/// - When parentId == 'all': fetches all children (used on child login screen)
/// - When parentId is a real ID: fetches only that parent's children (parent dashboard)
class ChildProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<UserModel> _children = [];
  UserModel? _selectedChild;
  bool _isLoading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<UserModel> get children => _children;
  UserModel? get selectedChild => _selectedChild;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Stream ────────────────────────────────────────────────────────────────

  void listenToChildren(String parentId) {
    _isLoading = true;
    notifyListeners();

    // 'all' → show every child (for child login screen)
    // real parentId → show only this parent's children
    final stream = parentId == 'all'
        ? _firestoreService.getAllChildrenStream()
        : _firestoreService.getChildrenByParent(parentId);

    stream.listen(
      (children) {
        _children = children;
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

  void selectChild(UserModel child) {
    _selectedChild = child;
    notifyListeners();
  }

  void clearSelection() {
    _selectedChild = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
