// ══════════════════════════════════════════════════════════
//  services/auth_service.dart — نسخة مُصحَّحة بالكامل
//
//  الإصلاحات المطبّقة:
//  ✅ #1 Google Sign-In: signOut أولاً لإظهار قائمة الحسابات دائماً
//  ✅ #2 Google جديد: حفظ userType='user' في Firestore
//  ✅ #3 كود 'cancelled' مُستثنى من رسائل الخطأ
//  ✅ #4 رسالة خطأ أدق عند فشل Google عموماً
//  ✅ #5 registerWithEmail: انتظار reload() قبل الإرجاع
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult({required this.success, this.errorMessage});
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateStream => _auth.authStateChanges();

  // ════════════════════════════════════════════════════
  //  تسجيل الدخول بالإيميل
  // ════════════════════════════════════════════════════
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
    } catch (_) {
      return const AuthResult(
          success: false, errorMessage: 'حدث خطأ غير متوقع');
    }
  }

  // ════════════════════════════════════════════════════
  //  تسجيل الدخول بـ Google
  // ════════════════════════════════════════════════════
  static Future<AuthResult> loginWithGoogle() async {
    try {
      // ✅ #1 تسجيل خروج مُسبَق لإظهار قائمة اختيار الحساب دائماً
      //       (يمنع استخدام حساب Google المحفوظ تلقائياً)
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // المستخدم ضغط "إلغاء" — لا نُظهر خطأ
        return const AuthResult(success: false, errorMessage: 'cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // ✅ #2 إذا كان المستخدم جديداً → احفظ userType = 'user' في Firestore
      if (result.additionalUserInfo?.isNewUser == true && result.user != null) {
        await FirestoreService.setUserType(result.user!.uid, 'user');
      }

      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    } catch (e) {
      // ✅ #3 تجاهل خطأ الإلغاء الطوعي من Google
      final msg = e.toString().toLowerCase();
      if (msg.contains('sign_in_canceled') ||
          msg.contains('canceled') ||
          msg.contains('cancel')) {
        return const AuthResult(success: false, errorMessage: 'cancelled');
      }
      // ✅ #4 رسالة خطأ مفيدة
      return const AuthResult(
          success: false,
          errorMessage: 'فشل تسجيل الدخول بـ Google — تحقق من الاتصال');
    }
  }

  // ════════════════════════════════════════════════════
  //  إنشاء حساب جديد — مع حفظ userType
  // ════════════════════════════════════════════════════
  static Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String userType = 'user',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // تحديث الاسم
      await cred.user?.updateDisplayName(name.trim());

      // حفظ نوع المستخدم في Firestore
      if (cred.user != null) {
        await FirestoreService.setUserType(cred.user!.uid, userType);
      }

      // ✅ #5 reload بعد كل التحديثات لضمان قراءة البيانات الصحيحة
      await cred.user?.reload();

      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    } catch (_) {
      return const AuthResult(
          success: false, errorMessage: 'حدث خطأ غير متوقع');
    }
  }

  // ════════════════════════════════════════════════════
  //  إعادة تعيين كلمة المرور
  // ════════════════════════════════════════════════════
  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    }
  }

  // ════════════════════════════════════════════════════
  //  تحديث الاسم
  // ════════════════════════════════════════════════════
  static Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name.trim());
    await _auth.currentUser?.reload();
  }

  // ════════════════════════════════════════════════════
  //  تغيير كلمة المرور
  // ════════════════════════════════════════════════════
  static Future<AuthResult> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return const AuthResult(
            success: false, errorMessage: 'المستخدم غير موجود');
      }
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapError(e.code));
    }
  }

  // ════════════════════════════════════════════════════
  //  تسجيل الخروج
  // ════════════════════════════════════════════════════
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ════════════════════════════════════════════════════
  //  ترجمة أكواد الخطأ
  // ════════════════════════════════════════════════════
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
      case 'account-exists-with-different-credential':
        return 'هذا الإيميل مسجّل بطريقة دخول مختلفة — جرّب تسجيل الدخول بالإيميل';
      case 'popup-closed-by-user':
      case 'sign_in_canceled':
        return 'cancelled';
      default:
        return 'حدث خطأ — حاول مجدداً ($code)';
    }
  }
}
