import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/project_model.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_localizations.dart';

class ProjectOverviewCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;

  const ProjectOverviewCard({
    super.key,
    required this.project,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accent.withValues(alpha: 0.15),
              AppTheme.accentDark.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(project.buildingType.emoji,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(project.name,
                    style: GoogleFonts.cairo(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getStatusColor(project.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(project.status.emoji,
                    style: const TextStyle(fontSize: 14)),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _InfoChip(Icons.location_on, project.city),
              const SizedBox(width: 12),
              _InfoChip(
                  Icons.layers, '${project.floors} ${t.tr('floorSuffix')}'),
            ]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.tr('componentsCount'),
                    style: GoogleFonts.cairo(
                        color: AppTheme.textSub, fontSize: 12)),
                Text('${project.components.length}',
                    style: GoogleFonts.cairo(
                        color: AppTheme.accent, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return AppTheme.textMuted;
      case ProjectStatus.inProgress:
        return AppTheme.info;
      case ProjectStatus.completed:
        return AppTheme.success;
      case ProjectStatus.onHold:
        return AppTheme.danger;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}
