import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../calculator_screen.dart';
import '../land_projection_screen.dart';
import '../my_quotes_screen.dart';

class HomeQuickTools extends StatelessWidget {
  final int newReplies;

  const HomeQuickTools({super.key, required this.newReplies});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.tr('quickToolsTitle'),
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSub)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _ToolCard(
                emoji: '🧮',
                title: t.tr('toolCalcTitle'),
                subtitle: t.tr('toolCalcSub'),
                gradient: const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CalculatorScreen())),
              ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.08, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ToolCard(
                emoji: '🛰️',
                title: t.tr('toolMapTitle'),
                subtitle: t.tr('toolMapSub'),
                gradient: const [Color(0xFF059669), Color(0xFF047857)],
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LandProjectionScreen())),
              ).animate(delay: 360.ms).fadeIn().slideX(begin: 0.08, end: 0),
            ),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyQuotesScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: newReplies > 0
                      ? AppTheme.accent.withValues(alpha: 0.4)
                      : AppTheme.border,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                      child: Text('📬', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.tr('quotesRequests'),
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                          newReplies > 0
                              ? '${t.tr('newReplies')}: $newReplies'
                              : t.tr('noNewReplies'),
                          style: GoogleFonts.cairo(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
              ]),
            ).animate(delay: 420.ms).fadeIn().slideX(begin: 0.05, end: 0),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ToolCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.cairo(
                    fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}
