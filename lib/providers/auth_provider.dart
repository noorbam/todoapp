import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// AuthProvider — manages authentication state for the whole app
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser; // Parent user (Firebase Auth)
  UserModel? _childUser;   // Active child session (PIN login, no Firebase Auth)
  bool _isLoading = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────────────────────

  /// Returns the active child session if set, otherwise the parent user
  UserModel? get currentUser => _childUser ?? _currentUser;
  UserModel? get parentUser => _currentUser;
  UserModel? get activeChild => _childUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => currentUser != null;
  bool get isParent => _currentUser != null && _childUser == null;
  bool get isChild => _childUser != null;

  // ── Initialize ────────────────────────────────────────────────────────────

  /// Called at app startup — restores parent session if Firebase user exists
  Future<void> initializeAuth() async {
    _setLoading(true);
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _currentUser = await _authService.getUserById(firebaseUser.uid);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Reset Data ─────────────────────────────────────────────────────────────

  Future<bool> resetAllData() async {
    if (_currentUser == null) return false;
    _setLoading(true);
    try {
      final firestoreService = FirestoreService();
      await firestoreService.resetParentData(_currentUser!.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Parent: Google Sign-In ─────────────────────────────────────────────────

  /// Returns true on success, false on cancel/error
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Parent: Email/Password Sign-In ─────────────────────────────────────────

  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final user =
          await _authService.signInWithEmailPassword(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      _error = 'لم يتم العثور على الحساب';
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authService.registerWithEmailPassword(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Complete parent setup after role selection (legacy — kept for compatibility)
  Future<void> completeParentSetup(String name) async {
    _setLoading(true);
    _error = null;
    try {
      _currentUser = await _authService.createParentAccount(name);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Parent: Create Child Account ───────────────────────────────────────────

  Future<UserModel?> createChildAccount({
    required String name,
    required String pin,
    int avatarIndex = 0,
  }) async {
    if (_currentUser == null) return null;
    _setLoading(true);
    _error = null;
    try {
      final child = await _authService.createChildAccount(
        name: name,
        pin: pin,
        parentId: _currentUser!.id,
        avatarIndex: avatarIndex,
      );
      return child;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ── Child: PIN Login ───────────────────────────────────────────────────────

  /// Verifies the child's PIN against Firestore and sets active child session
  Future<bool> childLogin(String childId, String pin) async {
    _setLoading(true);
    _error = null;
    try {
      final child = await _authService.childPinLogin(
        childId: childId,
        pin: pin,
      );
      if (child != null) {
        _childUser = child;
        notifyListeners();
        return true;
      }
      _error = 'الرمز خاطئ! حاول مجدداً 🔒';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (_childUser != null) {
        // Child logs out — return to child login, parent session stays
        _childUser = null;
        notifyListeners();
      } else {
        // Parent logs out — full sign-out
        await _authService.signOut();
        _currentUser = null;
        _childUser = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
