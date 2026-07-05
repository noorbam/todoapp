import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_strings.dart';

/// AuthService — handles Firebase Authentication for both parents and children
class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();

  // ── Current User ──────────────────────────────────────────────────────────

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Parent: Google Sign-In ─────────────────────────────────────────────────

  /// Signs in a parent with Google.
  /// Returns [UserModel] if the parent already has a Firestore document.
  /// Returns null if it's a new user (needs to complete setup).
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User firebaseUser = userCredential.user!;

      // Check if parent document already exists
      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }

      // New user — create parent document automatically
      final newParent = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Parent',
        email: firebaseUser.email ?? '',
        role: AppStrings.parentRole,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newParent.toMap());
      return newParent;
    } catch (e) {
      if (e.toString().contains('ApiException: 10')) {
        throw Exception(
            'فشل تسجيل الدخول بـ Google: يجب إضافة بصمة SHA-1 في إعدادات Firebase (ApiException: 10)');
      }
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ── Parent: Email/Password Sign-In ─────────────────────────────────────────

  /// Sign in parent with email and password.
  Future<UserModel?> signInWithEmailPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User firebaseUser = userCredential.user!;

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Register a new parent with email and password.
  Future<UserModel> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User firebaseUser = userCredential.user!;

      // Update Firebase display name
      await firebaseUser.updateDisplayName(name.trim());

      final parent = UserModel(
        id: firebaseUser.uid,
        name: name.trim().isNotEmpty ? name.trim() : 'Parent',
        email: firebaseUser.email ?? '',
        role: AppStrings.parentRole,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(parent.id)
          .set(parent.toMap());
      return parent;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  Future<UserModel> createParentAccount(String name) async {
    final firebaseUser = _auth.currentUser!;
    final user = UserModel(
      id: firebaseUser.uid,
      name: name.isNotEmpty ? name : (firebaseUser.displayName ?? 'Parent'),
      email: firebaseUser.email ?? '',
      role: AppStrings.parentRole,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(user.id).set(user.toMap());
    return user;
  }

  // ── Parent: Create Child Account ───────────────────────────────────────────

  Future<UserModel> createChildAccount({
    required String name,
    required String pin,
    required String parentId,
    int avatarIndex = 0,
  }) async {
    final docRef = _firestore.collection('users').doc();
    final child = UserModel(
      id: docRef.id,
      name: name,
      email: '',
      role: AppStrings.childRole,
      parentId: parentId,
      avatarIndex: avatarIndex,
      pin: pin,
      createdAt: DateTime.now(),
    );

    await docRef.set(child.toMap());

    // Initialize progress document
    await _firestore.collection('progress').doc(docRef.id).set({
      'points': 0,
      'xp': 0,
      'level': 1,
      'streak': 0,
      'badges': [],
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return child;
  }

  // ── Child: PIN Login ───────────────────────────────────────────────────────

  Future<UserModel?> childPinLogin({
    required String childId,
    required String pin,
  }) async {
    final doc = await _firestore.collection('users').doc(childId).get();
    if (!doc.exists) return null;

    final user = UserModel.fromMap(doc.data()!, doc.id);
    if (user.pin == pin) return user;
    return null;
  }

  // ── Fetch User ─────────────────────────────────────────────────────────────

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Google sign-in might not have been used
    }
    await _auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً (6 أحرف على الأقل)';
      case 'too-many-requests':
        return 'محاولات كثيرة، حاول لاحقاً';
      case 'invalid-credential':
        return 'البريد أو كلمة المرور غير صحيحة. تأكد من إدخالها صحيحاً أو قم بإنشاء حساب جديد.';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بهذه الطريقة غير مفعل. الرجاء تفعيله من لوحة تحكم Firebase.';
      default:
        return 'البريد الإلكتروني غير مسجل أو توجد مشكلة في الاتصال. ($code)';
    }
  }
}
