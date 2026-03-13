// ══════════════════════════════════════════════════════════
//  screens/auth_wrapper.dart
//  ✅ Firebase Auth حقيقي — يراقب حالة تسجيل الدخول
//  ✅ ترحيل البيانات المحلية عند أول دخول
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import 'login_screen.dart';
import 'main_nav.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── جاري التحقق ──
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }
        // ── مسجّل الدخول ──
        if (snapshot.hasData && snapshot.data != null) {
          return _MigrateAndHome(user: snapshot.data!);
        }
        // ── غير مسجّل ──
        return const LoginScreen();
      },
    );
  }
}

// ════════════════════════════════════════════════════════
//  ترحيل البيانات المحلية ثم الانتقال للرئيسية
// ════════════════════════════════════════════════════════
class _MigrateAndHome extends StatefulWidget {
  final User user;
  const _MigrateAndHome({required this.user});

  @override
  State<_MigrateAndHome> createState() => _MigrateAndHomeState();
}

class _MigrateAndHomeState extends State<_MigrateAndHome> {
  @override
  void initState() {
    super.initState();
    _migrate();
  }

  Future<void> _migrate() async {
    // ترحيل المشاريع المحلية إلى السحابة (مرة واحدة فقط)
    final localProjects = StorageService.getAllProjects();
    if (localProjects.isNotEmpty) {
      await FirestoreService.migrateLocalProjects(localProjects);
    }
  }

  @override
  Widget build(BuildContext context) => const MainNav();
}

// ════════════════════════════════════════════════════════
//  شاشة التحميل
// ════════════════════════════════════════════════════════
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentDark]),
                borderRadius: BorderRadius.circular(20)),
            child: const Center(
                child: Text('🏗️', style: TextStyle(fontSize: 34))),
          ).animate().scale(
              begin: const Offset(0.8, 0.8),
              duration: 600.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('بنّاء',
                  style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary))
              .animate(delay: 200.ms)
              .fadeIn(),
          const SizedBox(height: 24),
          const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppTheme.accent))),
        ]),
      ),
    );
  }
}
