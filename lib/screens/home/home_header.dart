import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../my_quotes_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? t.tr('greetingMorning')
        : hour < 17
            ? t.tr('greetingAfternoon')
            : t.tr('greetingEvening');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.accent.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snap) {
          final user = snap.data ?? AuthService.currentUser;
          final name = user?.displayName ?? '';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : '؟';

          return Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: AppTheme.textMuted)),
                  Text(
                    name.isNotEmpty ? '$name 👋' : t.tr('welcomeUser'),
                    style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyQuotesScreen())),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Center(
                      child: Text('🔔', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.danger,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('●',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentDark]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(initial,
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.black)),
              ),
            ),
          ]).animate().fadeIn(duration: 400.ms);
        },
      ),
    );
  }
}
