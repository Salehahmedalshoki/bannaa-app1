// ══════════════════════════════════════════════════════════
//  services/auth_service.dart
//  ✅ Firebase Auth حقيقي — إيميل + Google
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult({required this.success, this.errorMessage});
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── المستخدم الحالي ───────────────────────────────────
  static User? get currentUser => _auth.currentUser;

  // ── Stream لمتابعة حالة تسجيل الدخول ─────────────────
  static Stream<User?> get authStateStream => _auth.authStateChanges();

  // ════════════════════════════════════════════════════════
  //  تسجيل الدخول بالإيميل
  // ════════════════════════════════════════════════════════
  static Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'حدث خطأ غير متوقع');
    }
  }

  // ════════════════════════════════════════════════════════
  //  تسجيل الدخول بـ Google
  // ════════════════════════════════════════════════════════
  static Future<AuthResult> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult(
            success: false, errorMessage: 'تم إلغاء تسجيل الدخول');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    } catch (e) {
      return AuthResult(
          success: false, errorMessage: 'فشل تسجيل الدخول بـ Google');
    }
  }

  // ════════════════════════════════════════════════════════
  //  إنشاء حساب جديد
  // ════════════════════════════════════════════════════════
  static Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // حفظ الاسم في الملف الشخصي
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.reload();
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'حدث خطأ غير متوقع');
    }
  }

  // ════════════════════════════════════════════════════════
  //  إعادة تعيين كلمة المرور
  // ════════════════════════════════════════════════════════
  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    }
  }

  // ════════════════════════════════════════════════════════
  //  تحديث الاسم
  // ════════════════════════════════════════════════════════
  static Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name.trim());
    await _auth.currentUser?.reload();
  }

  // ════════════════════════════════════════════════════════
  //  تغيير كلمة المرور
  // ════════════════════════════════════════════════════════
  static Future<AuthResult> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return const AuthResult(
            success: false, errorMessage: 'المستخدم غير موجود');
      }
      // إعادة المصادقة أولاً
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    }
  }

  // ════════════════════════════════════════════════════════
  //  تسجيل الخروج
  // ════════════════════════════════════════════════════════
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ════════════════════════════════════════════════════════
  //  ترجمة أكواد الخطأ للعربية
  // ════════════════════════════════════════════════════════
  static String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجّل مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة — استخدم 6 أحرف على الأقل';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً — انتظر قليلاً ثم حاول مجدداً';
      case 'network-request-failed':
        return 'لا يوجد اتصال بالإنترنت';
      case 'requires-recent-login':
        return 'يرجى تسجيل الخروج والدخول مجدداً';
      case 'user-disabled':
        return 'هذا الحساب موقوف — تواصل مع الدعم';
      default:
        return 'حدث خطأ — حاول مجدداً ($code)';
    }
  }
}
