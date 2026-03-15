import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/common_widgets.dart';

class ProjectOverviewTab extends StatelessWidget {
  final Project project;
  final List<MaterialQuantity> materials;

  const ProjectOverviewTab({
    super.key,
    required this.project,
    required this.materials,
  });

  String _fmt(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  String _fmtDate(BuildContext context, DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final totalCost = materials.fold(0.0, (sum, m) => sum + m.totalCost);
    final sym = s.currencyInfo.symbol;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Row(children: [
          _StatBox(
              label: t.tr('concreteVolume'),
              value: project.totalVolume.toStringAsFixed(2),
              unit: 'م³',
              icon: '🧱',
              color: AppTheme.accent),
          const SizedBox(width: 10),
          _StatBox(
              label: t.tr('componentsCount'),
              value: '${project.components.length}',
              unit: t.tr('componentSuffix'),
              icon: '📐',
              color: AppTheme.info),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatBox(
              label: t.tr('estimatedCost'),
              value: _fmt(totalCost),
              unit: sym,
              icon: '💰',
              color: AppTheme.success),
          const SizedBox(width: 10),
          _StatBox(
              label: t.tr('floors'),
              value: '${project.floors}',
              unit: t.tr('floorSuffix'),
              icon: '🏢',
              color: const Color(0xFFEC4899)),
        ]),
        const SizedBox(height: 16),
        Text(t.tr('materialSummary'),
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const SizedBox(height: 8),
        ...materials.map((m) => _MaterialRow(m: m)),
        const SizedBox(height: 16),
        Text(t.tr('projectInfo'),
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const SizedBox(height: 8),
        DarkCard(
          child: Column(children: [
            _infoRow(t.tr('typeLabel'), project.buildingType.label,
                project.buildingType.emoji),
            _div(),
            _infoRow(t.tr('cityInfo'), project.city, '📍'),
            _div(),
            _infoRow(t.tr('createdDate'), _fmtDate(context, project.createdAt),
                '📅'),
            _div(),
            _infoRow(
                t.tr('projectIdLabel'),
                '${project.id.substring(0, project.id.length.clamp(0, 8))}…',
                '🆔'),
          ]),
        ),
      ],
    );
  }

  Widget _div() =>
      Container(height: 1, margin: EdgeInsets.zero, color: AppTheme.border);

  Widget _infoRow(String label, String value, String icon) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style:
                    GoogleFonts.cairo(fontSize: 13, color: AppTheme.textMuted)),
          ),
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ]),
      );
}

class _StatBox extends StatelessWidget {
  final String label, value, unit, icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ]),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit,
                      style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.textMuted)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label,
                style:
                    GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  final MaterialQuantity m;

  const _MaterialRow({required this.m});

  @override
  Widget build(BuildContext context) {
    final sym = context.watch<AppSettingsProvider>().currencyInfo.symbol;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DarkCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(m.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text('${m.quantity.toStringAsFixed(2)} ${m.unit}',
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Text('${m.totalCost.toStringAsFixed(0)} $sym',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.success)),
        ]),
      ),
    );
  }
}
