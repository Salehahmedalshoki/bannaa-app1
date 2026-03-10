// ══════════════════════════════════════════════════════════
//  screens/splash_screen.dart
//  شاشة البداية مع أنيميشن
// ══════════════════════════════════════════════════════════

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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال التلقائي للرئيسية بعد 2.5 ثانية
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      // تحقق من onboarding
      final box = await Hive.openBox('settings');
      final done = box.get('onboarding_done', defaultValue: false) as bool;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
            done ? const AuthWrapper() : const OnboardingScreen(),
          transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

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
              // الشعار
              Container(
                width: 100, height: 100,
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
                  child: Text('🏗️',
                    style: TextStyle(fontSize: 46)),
                ),
              ).animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  duration: 600.ms,
                  curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // الاسم
              Text('بنّاء',
                style: GoogleFonts.cairo(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ))
              .animate(delay: 300.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 6),

              Text('BANNAA',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppTheme.accent,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w600,
                ))
              .animate(delay: 400.ms)
              .fadeIn(duration: 400.ms),

              const SizedBox(height: 12),

              Text('حاسبة كميات الخرسانة وتقدير أسعار البناء',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 400.ms),

              const SizedBox(height: 60),

              // مؤشر التحميل
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation(
                      AppTheme.accent),
                    minHeight: 3,
                  ),
                ),
              )
              .animate(delay: 600.ms)
              .fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
