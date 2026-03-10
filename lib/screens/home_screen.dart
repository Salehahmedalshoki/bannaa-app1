// ══════════════════════════════════════════════════════════
//  screens/home_screen.dart — مع الترجمة الكاملة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'new_project_screen.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    setState(() {
      _projects = StorageService.getAllProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStats(context),
            _buildNewProjectButton(context),
            Expanded(child: _buildProjectsList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final user = AuthService.currentUser;
    final name = user?.displayName ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '؟';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.accent.withOpacity(0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.tr('greeting'),
                  style: GoogleFonts.cairo(
                    fontSize: 12, color: AppTheme.textMuted)),
                Text(t.tr('welcomeUser'),
                  style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
              ],
            ),
          ),
          // زر الأفاتار / تسجيل الخروج
          GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                  title: Text(t.tr('logoutTitle'),
                    style: GoogleFonts.cairo(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700)),
                  content: Text(t.tr('signOutConfirm'),
                    style: GoogleFonts.cairo(color: AppTheme.textSub)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(t.tr('cancel'),
                        style: GoogleFonts.cairo(color: AppTheme.textMuted))),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(t.tr('signOut'),
                        style: GoogleFonts.cairo(
                          color: AppTheme.danger,
                          fontWeight: FontWeight.w700))),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await AuthService.signOut();
              }
            },
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark]),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(initial,
                  style: GoogleFonts.cairo(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: Colors.black)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStats(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final totalVolume = _projects.fold(0.0, (s, p) => s + p.totalVolume);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          StatChip(
            icon: '📁',
            value: '${_projects.length}',
            label: t.tr('projectsCount')),
          const SizedBox(width: 10),
          StatChip(
            icon: '📅',
            value: '${_projectsThisMonth()}',
            label: t.tr('thisMonth')),
          const SizedBox(width: 10),
          StatChip(
            icon: '🧱',
            value: totalVolume.toStringAsFixed(0),
            label: t.tr('totalConcreteM3')),
        ],
      ),
    ).animate().slideY(
      begin: 0.3, end: 0,
      duration: 500.ms, delay: 100.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildNewProjectButton(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GoldenButton(
        label: t.tr('newProject'),
        icon: '＋',
        onTap: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NewProjectScreen()));
          _loadProjects();
        },
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms);
  }

  Widget _buildProjectsList(BuildContext context) {
    if (_projects.isEmpty) return _buildEmptyState(context);

    final t = BannaaLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Text(t.tr('lastProjects'),
            style: GoogleFonts.cairo(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: AppTheme.textSub)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _projects.length,
            itemBuilder: (ctx, i) => _ProjectCard(
              project: _projects[i],
              onTap: () async {
                await Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                    ProjectDetailScreen(project: _projects[i])));
                _loadProjects();
              },
              onDelete: () async {
                await StorageService.deleteProject(_projects[i].id);
                _loadProjects();
              },
            ).animate().fadeIn(delay: Duration(milliseconds: i * 80)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🏗️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          Text(t.tr('noProjectsYet'),
            style: GoogleFonts.cairo(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppTheme.textSub)),
          const SizedBox(height: 6),
          Text(t.tr('startFirst'),
            style: GoogleFonts.cairo(
              fontSize: 12, color: AppTheme.textMuted)),
        ],
      ),
    );
  }

  int _projectsThisMonth() {
    final now = DateTime.now();
    return _projects.where((p) =>
      p.createdAt.month == now.month &&
      p.createdAt.year == now.year).length;
  }
}

// ── بطاقة مشروع ───────────────────────────────────────────
class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: DarkCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // أيقونة النوع
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentGlow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2))),
                child: Center(child: Text(project.buildingType.emoji,
                  style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                      style: GoogleFonts.cairo(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                    const SizedBox(height: 3),
                    Text(
                      '${project.buildingType.label} • ${project.city} • '
                      '${_formatDate(project.createdAt)}',
                      style: GoogleFonts.cairo(
                        fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatNumber(project.totalCost)} ${s.currencyInfo.symbol}',
                    style: GoogleFonts.cairo(
                      fontSize: 12, fontWeight: FontWeight.w800,
                      color: AppTheme.accent)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(t.tr('completed'),
                      style: GoogleFonts.cairo(
                        fontSize: 9, color: AppTheme.success,
                        fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _formatNumber(double n) =>
    n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : n.toStringAsFixed(0);
}
