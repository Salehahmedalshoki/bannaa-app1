import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';

class HomeDashboard extends StatelessWidget {
  final List<Project> projects;

  const HomeDashboard({super.key, required this.projects});

  String _formatNum(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final now = DateTime.now();
    final thisMonth = projects
        .where((p) =>
            p.createdAt.month == now.month && p.createdAt.year == now.year)
        .length;
    final totalVolume = projects.fold(0.0, (acc, p) => acc + p.totalVolume);
    final totalCost = projects.fold(0.0, (acc, p) => acc + p.totalCost);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(children: [
        Row(children: [
          Expanded(
              child: _DashCard(
                  icon: '📁',
                  value: '${projects.length}',
                  label: t.tr('projectsCount'),
                  color: AppTheme.accent,
                  delay: 0)),
          const SizedBox(width: 10),
          Expanded(
              child: _DashCard(
                  icon: '📅',
                  value: '$thisMonth',
                  label: t.tr('thisMonth'),
                  color: AppTheme.info,
                  delay: 80)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _DashCard(
                  icon: '🧱',
                  value: totalVolume.toStringAsFixed(1),
                  label: t.tr('totalConcreteM3'),
                  color: AppTheme.success,
                  delay: 160,
                  unit: 'م³')),
          const SizedBox(width: 10),
          Expanded(
              child: _DashCard(
                  icon: '💰',
                  value: _formatNum(totalCost),
                  label: t.tr('totalCostAll'),
                  color: const Color(0xFF8B5CF6),
                  delay: 240,
                  unit: s.currencyInfo.symbol)),
        ]),
      ]),
    ).animate().slideY(
        begin: 0.3,
        end: 0,
        duration: 500.ms,
        delay: 100.ms,
        curve: Curves.easeOut);
  }
}

class _DashCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;
  final int delay;
  final String? unit;

  const _DashCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.delay,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              if (unit != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit!,
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .slideY(begin: 0.15, end: 0);
  }
}
