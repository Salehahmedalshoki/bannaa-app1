// ══════════════════════════════════════════════════════════
//  screens/splash_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة:
//  ✅ #1 try/catch شامل حول كامل منطق الانتقال
//  ✅ #2 مؤشر تحميل متزامن حقيقي (AnimationController)
//  ✅ #3 ربط الانتقال بـ Firebase Auth + timeout بدل delay ثابت
//  ✅ #4 fallback آمن عند أي خطأ → ينتقل للـ AuthWrapper
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';
import 'auth_wrapper.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── مؤشر التحميل المتزامن ─────────────────────────────
  late final AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();

    // مؤشر يكتمل في 2800ms بالضبط (أطول قليلاً من الحد الأدنى)
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..forward();

    _navigate();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  // ── منطق الانتقال ──────────────────────────────────────
  Future<void> _navigate() async {
    try {
      // انتظار موازي: حد أدنى 2500ms + Firebase Auth جاهز
      await Future.wait([
        Future.delayed(const Duration(milliseconds: 2500)),
        FirebaseAuth.instance
            .authStateChanges()
            .first
            .timeout(const Duration(seconds: 5)),
      ]);

      if (!mounted) return;

      // قراءة حالة onboarding بأمان
      final bool onboardingDone = await _getOnboardingDone();

      if (!mounted) return;
      _goTo(onboardingDone ? const AuthWrapper() : const OnboardingScreen());
    } catch (_) {
      // ── Fallback: أي خطأ → اذهب لـ AuthWrapper مباشرة ──
      if (!mounted) return;
      _goTo(const AuthWrapper());
    }
  }

  /// قراءة آمنة لحالة onboarding من Hive
  Future<bool> _getOnboardingDone() async {
    try {
      final box = await Hive.openBox('settings');
      return box.get('onboarding_done', defaultValue: false) as bool;
    } catch (_) {
      return false; // إذا فشل Hive → اعرض onboarding كـ fallback آمن
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  // ── واجهة المستخدم ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 0.8,
            colors: [
              AppTheme.accent.withOpacity(0.18),
              AppTheme.background,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── الشعار ──────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.accent, AppTheme.accentDark],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🏗️', style: TextStyle(fontSize: 46)),
                ),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 600.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // ── اسم التطبيق ─────────────────────────────
              Text(
                'بنّاء',
                style: GoogleFonts.cairo(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 6),

              Text(
                'BANNAA',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppTheme.accent,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w600,
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 12),

              Text(
                'حاسبة كميات الخرسانة وتقدير أسعار البناء',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 60),

              // ── مؤشر تحميل متزامن حقيقي ─────────────────
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (_, __) => LinearProgressIndicator(
                      value: _progressCtrl.value, // ← متزامن مع الوقت الفعلي
                      backgroundColor: AppTheme.border,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                      minHeight: 3,
                    ),
                  ),
                ),
              ).animate(delay: 600.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
