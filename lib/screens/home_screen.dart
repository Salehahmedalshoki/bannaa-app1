// ══════════════════════════════════════════════════════════
//  screens/home_screen.dart — المرحلة الثانية
//  ✅ لوحة تحكم: إجمالي التكاليف + إحصائيات ذكية
//  ✅ آخر مشروع تم تعديله + اقتراح ذكي لإكمال المشاريع
//  ✅ بطاقات مشاريع أجمل مع شريط تقدم وتكاليف
//  ✅ انتقالات Hero بين الشاشات
//  ✅ بطاقات تنزلق تدريجياً عند الدخول
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Project> _projects = [];
  late final AnimationController _dashCtrl;

  @override
  void initState() {
    super.initState();
    _dashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _loadProjects();
  }

  @override
  void dispose() {
    _dashCtrl.dispose();
    super.dispose();
  }

  void _loadProjects() {
    setState(() {
      _projects = StorageService.getAllProjects();
      // ترتيب: الأحدث تعديلاً أولاً
      _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
    _dashCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.surface,
          onRefresh: () async => _loadProjects(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── الرأس ──
              SliverToBoxAdapter(child: _buildHeader(context)),
              // ── لوحة التحكم ──
              SliverToBoxAdapter(child: _buildDashboard(context)),
              // ── اقتراح ذكي ──
              if (_projects.isNotEmpty)
                SliverToBoxAdapter(child: _buildSmartSuggestion(context)),
              // ── زر مشروع جديد ──
              SliverToBoxAdapter(child: _buildNewProjectButton(context)),
              // ── عنوان القائمة ──
              if (_projects.isNotEmpty)
                SliverToBoxAdapter(child: _buildListHeader(context)),
              // ── قائمة المشاريع ──
              _projects.isEmpty
                  ? SliverFillRemaining(child: _buildEmptyState(context))
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _ProjectCard(
                            project: _projects[i],
                            index: i,
                            onTap: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => ProjectDetailScreen(
                                          project: _projects[i])));
                              _loadProjects();
                            },
                            onDelete: () async {
                              HapticFeedback.mediumImpact();
                              await StorageService.deleteProject(
                                  _projects[i].id);
                              _loadProjects();
                            },
                          ),
                          childCount: _projects.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  الرأس
  // ════════════════════════════════════════════════════════
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
            colors: [AppTheme.accent.withOpacity(0.08), Colors.transparent]),
      ),
      child: Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.tr('greeting'),
                style:
                    GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
            Text(
                name.isNotEmpty
                    ? '${t.tr('welcomeUser')}، $name 👋'
                    : t.tr('welcomeUser'),
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
          ],
        )),
        GestureDetector(
          onTap: () => _showLogoutDialog(context, t),
          child: Hero(
            tag: 'user_avatar',
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentDark]),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                  child: Text(initial,
                      style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black))),
            ),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }

  // ════════════════════════════════════════════════════════
  //  لوحة التحكم — 4 بطاقات إحصائية
  // ════════════════════════════════════════════════════════
  Widget _buildDashboard(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();

    final totalProjects = _projects.length;
    final thisMonth = _projects.where((p) {
      final now = DateTime.now();
      return p.createdAt.month == now.month && p.createdAt.year == now.year;
    }).length;
    final totalVolume = _projects.fold(0.0, (sum, p) => sum + p.totalVolume);
    final totalCost = _projects.fold(0.0, (sum, p) => sum + p.totalCost);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(children: [
        // صف الأول: مشاريع + هذا الشهر
        Row(children: [
          Expanded(
              child: _DashCard(
            icon: '📁',
            value: '$totalProjects',
            label: t.tr('projectsCount'),
            color: AppTheme.accent,
            delay: 0,
          )),
          const SizedBox(width: 10),
          Expanded(
              child: _DashCard(
            icon: '📅',
            value: '$thisMonth',
            label: t.tr('thisMonth'),
            color: AppTheme.info,
            delay: 80,
          )),
        ]),
        const SizedBox(height: 10),
        // صف الثاني: الحجم + التكلفة
        Row(children: [
          Expanded(
              child: _DashCard(
            icon: '🧱',
            value: totalVolume.toStringAsFixed(1),
            label: t.tr('totalConcreteM3'),
            color: AppTheme.success,
            delay: 160,
            unit: 'م³',
          )),
          const SizedBox(width: 10),
          Expanded(
              child: _DashCard(
            icon: '💰',
            value: _formatLargeNumber(totalCost),
            label: t.tr('totalCostAll'),
            color: const Color(0xFF8B5CF6),
            delay: 240,
            unit: s.currencyInfo.symbol,
          )),
        ]),
      ]),
    ).animate().slideY(
        begin: 0.3,
        end: 0,
        duration: 500.ms,
        delay: 100.ms,
        curve: Curves.easeOut);
  }

  // ════════════════════════════════════════════════════════
  //  اقتراح ذكي
  // ════════════════════════════════════════════════════════
  Widget _buildSmartSuggestion(BuildContext context) {
    if (_projects.isEmpty) return const SizedBox.shrink();
    final lastProject = _projects.first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(project: lastProject)));
          _loadProjects();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('💡', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تابع آخر مشروع',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent)),
                Text(lastProject.name,
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            )),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppTheme.accent),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 300.ms);
  }

  // ════════════════════════════════════════════════════════
  //  زر مشروع جديد
  // ════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════
  //  رأس قائمة المشاريع
  // ════════════════════════════════════════════════════════
  Widget _buildListHeader(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(children: [
        Text(t.tr('lastProjects'),
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const Spacer(),
        Text('${_projects.length} ${t.tr('projectsCount')}',
            style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════
  //  حالة لا توجد مشاريع
  // ════════════════════════════════════════════════════════
  Widget _buildEmptyState(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🏗️', style: TextStyle(fontSize: 56))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
                curve: Curves.easeInOut),
        const SizedBox(height: 14),
        Text(t.tr('noProjectsYet'),
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const SizedBox(height: 6),
        Text(t.tr('startFirst'),
            style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
      ]),
    );
  }

  // ── مساعدات ──────────────────────────────────────────
  String _formatLargeNumber(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
  }

  int _projectsThisMonth() {
    final now = DateTime.now();
    return _projects
        .where((p) =>
            p.createdAt.month == now.month && p.createdAt.year == now.year)
        .length;
  }

  Future<void> _showLogoutDialog(
      BuildContext context, BannaaLocalizations t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(t.tr('logoutTitle'),
            style: GoogleFonts.cairo(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
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
                      color: AppTheme.danger, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await AuthService.signOut();
    }
  }
}

// ════════════════════════════════════════════════════════
//  بطاقة الإحصاء في لوحة التحكم
// ════════════════════════════════════════════════════════
class _DashCard extends StatelessWidget {
  final String icon, value, label;
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child:
              Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(unit != null ? '$value $unit' : value,
                  style: GoogleFonts.cairo(
                      fontSize: 16, fontWeight: FontWeight.w900, color: color)),
            ),
            Text(label,
                style:
                    GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
          ],
        )),
      ]),
    )
        .animate()
        .slideY(
            begin: 0.3,
            end: 0,
            delay: Duration(milliseconds: delay + 100),
            duration: 400.ms,
            curve: Curves.easeOut)
        .fadeIn(delay: Duration(milliseconds: delay + 100));
  }
}

// ════════════════════════════════════════════════════════
//  بطاقة المشروع — محسّنة
// ════════════════════════════════════════════════════════
class _ProjectCard extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final mix = s.currentMix;
    final prices = PriceSheet(
      cementPerBag: s.prices['cement'] ?? 50,
      sandPerM3: s.prices['sand'] ?? 150,
      gravelPerM3: s.prices['gravel'] ?? 180,
      steelPerKg: s.prices['steel'] ?? 4,
      waterPerM3: s.prices['water'] ?? 5,
      currencySymbol: s.currencyInfo.symbol,
    );

    // نسبة الاكتمال (عدد المكوّنات / الأهداف الافتراضية 5)
    final progress = (project.components.length / 5).clamp(0.0, 1.0);

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: AppTheme.danger, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: 'project_${project.id}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(children: [
                Row(children: [
                  // أيقونة النوع
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        color: AppTheme.accentGlow,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: AppTheme.accent.withOpacity(0.2))),
                    child: Center(
                        child: Text(project.buildingType.emoji,
                            style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name,
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 3),
                      Text(
                          '${project.buildingType.label} • ${project.city} • '
                          '${_formatDate(project.createdAt)}',
                          style: GoogleFonts.cairo(
                              fontSize: 10, color: AppTheme.textMuted)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(
                        '${_formatNumber(project.totalCost)} ${s.currencyInfo.symbol}',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accent)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(t.tr('completed'),
                          style: GoogleFonts.cairo(
                              fontSize: 9,
                              color: AppTheme.success,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ]),
                // شريط التقدم
                const SizedBox(height: 10),
                Row(children: [
                  Text('${project.components.length} مكوّن',
                      style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.textMuted)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.border,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                      minHeight: 3,
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text('${project.totalVolume.toStringAsFixed(1)} م³',
                      style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.info)),
                ]),
              ]),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideX(
        begin: 0.1,
        end: 0,
        delay: Duration(milliseconds: index * 80),
        duration: 350.ms,
        curve: Curves.easeOut);
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _formatNumber(double n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : n.toStringAsFixed(0);
}
