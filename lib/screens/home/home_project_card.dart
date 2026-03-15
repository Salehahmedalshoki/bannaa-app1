import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/project_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_localizations.dart';
import '../project_detail_screen.dart';

class HomeProjectCard extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback? onDeleteConfirm;

  const HomeProjectCard({
    super.key,
    required this.project,
    required this.index,
    this.onDeleteConfirm,
  });

  String _formatNum(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final sym = '\$';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(project.buildingType.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                        '${project.floors} ${t.tr('floors')} • ${project.buildingType.name}',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppTheme.danger),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(t.tr('deleteProject')),
                      content: Text(t.tr('deleteConfirm')),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(t.tr('cancel'))),
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(t.tr('delete'),
                                style:
                                    const TextStyle(color: AppTheme.danger))),
                      ],
                    ),
                  );
                  if (confirm == true && onDeleteConfirm != null) {
                    HapticFeedback.mediumImpact();
                    onDeleteConfirm!();
                  }
                },
              ),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _InfoChip(
                  icon: '📏',
                  label: '${project.totalVolume.toStringAsFixed(1)} م³',
                  color: AppTheme.success),
              const SizedBox(width: 8),
              _InfoChip(
                  icon: '🧱',
                  label: '${project.floors} ${t.tr('floors')}',
                  color: AppTheme.info),
              const Spacer(),
              Text(_formatNum(project.totalCost),
                  style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent)),
              Text(' $sym',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: AppTheme.textMuted)),
            ]),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn()
        .slideX(begin: 0.04, end: 0);
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
