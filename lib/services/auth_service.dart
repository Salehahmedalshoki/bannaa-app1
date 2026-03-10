// ══════════════════════════════════════════════════════════
//  services/auth_service.dart
//  ⚠️ نسخة تجريبية بدون Firebase
// ══════════════════════════════════════════════════════════

class AuthResult {
  final bool success;
  final String? errorMessage;
  const AuthResult({required this.success, this.errorMessage});
}

class _MockUser {
  final String? displayName;
  final String? email;
  final String uid;
  const _MockUser({this.displayName, this.email, this.uid = 'local-user'});
}

class AuthService {
  static _MockUser? _currentUser;

  static _MockUser? get currentUser => _currentUser;

  static Stream<_MockUser?> get authStateStream =>
    Stream.value(_currentUser);

  static Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = _MockUser(
      email: email,
      displayName: email.split('@').first,
    );
    return const AuthResult(success: true);
  }

  static Future<AuthResult> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = const _MockUser(
      email: 'test@gmail.com',
      displayName: 'مستخدم تجريبي',
    );
    return const AuthResult(success: true);
  }

  static Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = _MockUser(email: email, displayName: name);
    return const AuthResult(success: true);
  }

  static Future<AuthResult> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const AuthResult(success: true);
  }

  static Future<void> signOut() async {
    _currentUser = null;
  }

  static Future<void> updateDisplayName(String name) async {
    _currentUser = _MockUser(
      email: _currentUser?.email,
      displayName: name,
      uid: _currentUser?.uid ?? 'local-user',
    );
  }

  static Future<AuthResult> changePassword(
      String currentPassword, String newPassword) async {
    return const AuthResult(success: true);
  }
}
