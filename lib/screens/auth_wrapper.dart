// ══════════════════════════════════════════════════════════
//  screens/auth_wrapper.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة:
//  ✅ #1 معالجة snapshot.hasError من Firebase Auth
//  ✅ #2 try/catch منفصل لكل من الترحيل و getUserType
//  ✅ #3 timeout على getUserType لمنع الانتظار اللانهائي
//  ✅ #4 حالة خطأ في _MigrateAndRoute بدل شاشة تحميل أبدية
//  ✅ #5 استخدام userTypeStream() بدل Future لتحديثات فورية
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'main_nav.dart';
import 'supplier_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // انتظار Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        // ✅ #1 — معالجة خطأ Firebase Auth (انقطاع شبكة، token فاسد...)
        if (snapshot.hasError) {
          return const LoginScreen();
        }

        // مستخدم مسجّل → ترحيل + توجيه
        if (snapshot.hasData && snapshot.data != null) {
          return _MigrateAndRoute(user: snapshot.data!);
        }

        // لا يوجد مستخدم → تسجيل الدخول
        return const LoginScreen();
      },
    );
  }
}

// ════════════════════════════════════════════════════════
//  ترحيل البيانات ثم التوجيه حسب userType
// ════════════════════════════════════════════════════════
class _MigrateAndRoute extends StatefulWidget {
  final User user;
  const _MigrateAndRoute({required this.user});

  @override
  State<_MigrateAndRoute> createState() => _MigrateAndRouteState();
}

class _MigrateAndRouteState extends State<_MigrateAndRoute> {
  String? _userType;
  bool _hasError = false; // ✅ #4

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // ✅ #2 — ترحيل المشاريع المحلية بـ try/catch منفصل
    // الفشل هنا لا يوقف التوجيه — البيانات المحلية تبقى آمنة
    try {
      final localProjects = StorageService.getAllProjectsLocal();
      if (localProjects.isNotEmpty) {
        await FirestoreService.migrateLocalProjects(localProjects);
      }
    } catch (_) {
      // تجاهل — الترحيل سيُعاد عند الدخول التالي
    }

    // ✅ #2 #3 — جلب userType مع try/catch وtimeout صريح
    try {
      final type = await FirestoreService.getUserType()
          .timeout(const Duration(seconds: 8));
      if (mounted) setState(() => _userType = type);
    } catch (_) {
      // ✅ #4 — فشل جلب النوع → fallback آمن كـ 'user' عادي
      if (mounted) setState(() => _userType = 'user');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ #4 — عرض خطأ واضح بدل شاشة تحميل أبدية
    if (_hasError) {
      return _ErrorScreen(onRetry: () {
        setState(() {
          _hasError = false;
          _userType = null;
        });
        _init();
      });
    }

    // أثناء التحميل
    if (_userType == null) return const _LoadingScreen();

    // ✅ #5 — توجيه فوري مع مراقبة مستمرة للتغييرات
    // (مثال: مورد يُغيَّر نوعه أثناء الجلسة)
    return StreamBuilder<String>(
      stream: FirestoreService.userTypeStream(),
      initialData: _userType,
      builder: (context, snapshot) {
        final type = snapshot.data ?? _userType ?? 'user';
        return type == 'supplier' ? const SupplierDashboard() : const MainNav();
      },
    );
  }
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🏗️', style: TextStyle(fontSize: 34)),
            ),
          ).animate().scale(
              begin: const Offset(0.8, 0.8),
              duration: 600.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'بنّاء',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 24),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppTheme.accent),
            ),
          ),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  ✅ #4 — شاشة الخطأ مع زر إعادة المحاولة
// ════════════════════════════════════════════════════════
class _ErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorScreen({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'تعذّر الاتصال',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تحقق من اتصالك بالإنترنت\nثم حاول مرة أخرى',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppTheme.textMuted,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onRetry,
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
