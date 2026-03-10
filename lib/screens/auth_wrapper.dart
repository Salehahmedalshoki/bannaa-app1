// ══════════════════════════════════════════════════════════
//  screens/auth_wrapper.dart
//  يعمل بوضعين: مع Firebase أو بدونه (وضع التجربة)
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'main_nav.dart';

// في وضع التجربة (بدون Firebase) → نذهب مباشرةً للرئيسية
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ── وضع التجربة: بدون تسجيل دخول ────────────────────
    return const MainNav();

    // ── لتفعيل Firebase: استبدل ما فوق بالكود التالي ─────
    // return StreamBuilder<User?>(
    //   stream: AuthService.authStateStream,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting)
    //       return const _LoadingScreen();
    //     if (snapshot.hasData && snapshot.data != null)
    //       return const MainNav();
    //     return const LoginScreen();
    //   },
    // );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentDark]),
              borderRadius: BorderRadius.circular(20)),
            child: const Center(
              child: Text('🏗️', style: TextStyle(fontSize: 34))),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('بنّاء', style: GoogleFonts.cairo(
            fontSize: 22, fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary)).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 24),
          const SizedBox(width: 24, height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppTheme.accent))),
        ]),
      ),
    );
  }
}
