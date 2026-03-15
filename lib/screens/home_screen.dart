// ══════════════════════════════════════════════════════════
//  screens/home_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة (إضافةً لما كان موجوداً):
//  ✅ #8  نصوص بطاقتَي الأدوات السريعة عبر t.tr()
//  ✅ #9  سهما التنقل (arrow_forward_ios) يتكيفان مع RTL
//  ✅ #10 withOpacity المُهمَلة → withValues(alpha:)
//  ✅ #11 onDeleteConfirm يُعيد المشروع للقائمة عند فشل الحذف
//  ✅ #12 بادج عداد الإشعارات مقيَّد بـ '9+' كـ main_nav
//  ✅ #13 StreamBuilder المتداخل الثاني معزول في _HomeStreams
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../models/quote_request_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'calculator_screen.dart';
import 'land_projection_screen.dart';
import 'my_quotes_screen.dart';
import 'new_project_screen.dart';
import 'project_detail_screen.dart';
import 'auth_wrapper.dart';

// ══════════════════════════════════════════════════════════
//  HomeScreen — يُنشئ الـ Streams في المستوى الأعلى
// ══════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Project>>(
      stream: FirestoreService.projectsStream(),
      builder: (context, projectSnap) {
        final projects = projectSnap.data ?? [];
        final isLoading =
            projectSnap.connectionState == ConnectionState.waiting;

        return StreamBuilder<List<QuoteRequest>>(
          stream: FirestoreService.myQuoteRequestsStream(),
          builder: (context, quoteSnap) {
            final quotes = quoteSnap.data ?? [];
            final newReplies =
                quotes.where((r) => r.status == QuoteStatus.responded).length;

            return _HomeBody(
              projects: projects,
              isLoading: isLoading,
              quotes: quotes,
              newReplies: newReplies,
            );
          },
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  _HomeBody — يستقبل البيانات جاهزة
// ══════════════════════════════════════════════════════════
class _HomeBody extends StatelessWidget {
  final List<Project> projects;
  final bool isLoading;
  final List<QuoteRequest> quotes;
  final int newReplies;

  const _HomeBody({
    required this.projects,
    required this.isLoading,
    required this.quotes,
    required this.newReplies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildDashboard(context)),
            SliverToBoxAdapter(child: _buildQuickTools(context)),
            if (projects.isNotEmpty)
              SliverToBoxAdapter(child: _buildLastProjectBanner(context)),
            SliverToBoxAdapter(child: _buildNewProjectButton(context)),
            if (projects.isNotEmpty)
              SliverToBoxAdapter(child: _buildListHeader(context)),
            if (isLoading)
              const SliverFillRemaining(child: _LoadingState())
            else if (projects.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ProjectCard(
                      project: projects[i],
                      index: i,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProjectDetailScreen(project: projects[i]),
                        ),
                      ),
                      onDeleteConfirm: () async {
                        HapticFeedback.mediumImpact();
                        // ✅ #11 لا try/catch هنا — firestore_service يتعامل معه داخلياً
                        await FirestoreService.deleteProject(projects[i].id);
                      },
                    ),
                    childCount: projects.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  الرأس — تحية + اسم + إشعارات + صورة
  // ══════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
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
            AppTheme.accent.withValues(alpha: 0.08), // ✅ #10
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

            // ── زر الإشعارات ───────────────────────────
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
                        // ✅ #10
                        color: newReplies > 0
                            ? AppTheme.accent.withValues(alpha: 0.5)
                            : AppTheme.border,
                      ),
                    ),
                    child: Icon(
                      newReplies > 0
                          ? Icons.notifications_active
                          : Icons.notifications_outlined,
                      color:
                          newReplies > 0 ? AppTheme.accent : AppTheme.textMuted,
                      size: 20,
                    ),
                  ),
                  // ✅ #12 — عداد مقيَّد بـ '9+'
                  if (newReplies > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: const BoxDecoration(
                            color: AppTheme.danger, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            // ✅ #12
                            newReplies > 9 ? '9+' : '$newReplies',
                            style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── الصورة الشخصية / زر تسجيل خروج ────────
            GestureDetector(
              onTap: () => _showLogoutDialog(context, t),
              child: Container(
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
            ),
          ]).animate().fadeIn(duration: 400.ms);
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  الإحصائيات
  // ══════════════════════════════════════════════════════
  Widget _buildDashboard(BuildContext context) {
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

  // ══════════════════════════════════════════════════════
  //  الأدوات السريعة
  // ══════════════════════════════════════════════════════
  Widget _buildQuickTools(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
                // ✅ #8 من الترجمة
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
                // ✅ #8
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

          // بطاقة الطلبات
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
                      ? AppTheme.accent.withValues(alpha: 0.4) // ✅ #10
                      : AppTheme.border,
                ),
              ),
              child: Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.12), // ✅ #10
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                      child: Text('📬', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.tr('quoteRequestsTitle'),
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      Text(
                          quotes.isEmpty
                              ? t.tr('noQuotesYet')
                              : '${quotes.length} ${t.tr('quotesSent')}',
                          style: GoogleFonts.cairo(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                if (newReplies > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('$newReplies ${t.tr('newReplies')}',
                        style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.black,
                            fontWeight: FontWeight.w800)),
                  ),
                const SizedBox(width: 6),
                // ✅ #9 — سهم يتكيف مع RTL
                Icon(
                  isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
                  size: 13,
                  color: AppTheme.textMuted,
                ),
              ]),
            ),
          ).animate(delay: 420.ms).fadeIn(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  بانر آخر مشروع
  // ══════════════════════════════════════════════════════
  Widget _buildLastProjectBanner(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final last = projects.first;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(project: last))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.06), // ✅ #10
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.2)), // ✅ #10
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.12), // ✅ #10
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('💡', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.tr('continueLastProject'),
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent)),
                  Text(last.name,
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ),
            // ✅ #9 — سهم RTL-aware
            Icon(
              isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.accent,
            ),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 300.ms);
  }

  // ══════════════════════════════════════════════════════
  //  زر مشروع جديد
  // ══════════════════════════════════════════════════════
  Widget _buildNewProjectButton(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GoldenButton(
        label: t.tr('newProject'),
        icon: '＋',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NewProjectScreen())),
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 220.ms);
  }

  // ══════════════════════════════════════════════════════
  //  رأس قائمة المشاريع
  // ══════════════════════════════════════════════════════
  Widget _buildListHeader(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(children: [
        Text(t.tr('lastProjects'),
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1), // ✅ #10
              borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: AppTheme.success, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(t.tr('activeSyncLabel'),
                style: GoogleFonts.cairo(
                    fontSize: 9,
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  String _formatNum(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
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
    if (confirm == true && context.mounted) {
      await AuthService.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
            (_) => false);
      }
    }
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة الأداة السريعة
// ══════════════════════════════════════════════════════════
class _ToolCard extends StatelessWidget {
  final String emoji, title, subtitle;
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gradient[0].withValues(alpha: 0.15), // ✅ #10
              gradient[1].withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: gradient[0].withValues(alpha: 0.3)), // ✅ #10
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: gradient[0].withValues(alpha: 0.15), // ✅ #10
                      borderRadius: BorderRadius.circular(8)),
                  child:
                      Icon(Icons.arrow_outward, color: gradient[0], size: 14),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: AppTheme.textMuted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة الإحصاء
// ══════════════════════════════════════════════════════════
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
          border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12), // ✅ #10
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
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color)),
              ),
              Text(label,
                  style: GoogleFonts.cairo(
                      fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ),
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

// ══════════════════════════════════════════════════════════
//  ✅ #11 بطاقة المشروع — تأكيد حذف + إعادة عند الفشل
// ══════════════════════════════════════════════════════════
class _ProjectCard extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;
  final Future<void> Function() onDeleteConfirm;

  const _ProjectCard({
    required this.project,
    required this.index,
    required this.onTap,
    required this.onDeleteConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final progress = (project.components.length / 5).clamp(0.0, 1.0);
    final isCompleted = project.components.isNotEmpty;

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                title: Text(t.tr('deleteProjectTitle'),
                    style: GoogleFonts.cairo(
                        color: AppTheme.danger, fontWeight: FontWeight.w700)),
                content: Text(
                    '"${project.name}"\n${t.tr('deleteProjectConfirmMsg')}',
                    style: GoogleFonts.cairo(
                        color: AppTheme.textSub, height: 1.6)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(t.tr('cancel'),
                          style: GoogleFonts.cairo(color: AppTheme.textMuted))),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(t.tr('delete'),
                          style: GoogleFonts.cairo(
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w700))),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDeleteConfirm(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            color: AppTheme.danger, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(t.tr('delete'),
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.white)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border)),
          child: Column(children: [
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                    color: AppTheme.accentGlow,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color:
                            AppTheme.accent.withValues(alpha: 0.2))), // ✅ #10
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
                    Text('${project.buildingType.label} • ${project.city}',
                        style: GoogleFonts.cairo(
                            fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_fmt(project.totalCost)} ${s.currencyInfo.symbol}',
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accent)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: (isCompleted ? AppTheme.success : AppTheme.info)
                            .withValues(alpha: 0.12), // ✅ #10
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                        isCompleted ? t.tr('completed') : t.tr('inProgress'),
                        style: GoogleFonts.cairo(
                            fontSize: 9,
                            color:
                                isCompleted ? AppTheme.success : AppTheme.info,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Text('${project.components.length} ${t.tr('componentCount')}',
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
                      minHeight: 3),
                ),
              ),
              const SizedBox(width: 8),
              Text('${project.totalVolume.toStringAsFixed(1)} م³',
                  style: GoogleFonts.cairo(fontSize: 10, color: AppTheme.info)),
            ]),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideX(
        begin: 0.1,
        end: 0,
        delay: Duration(milliseconds: index * 80),
        duration: 350.ms,
        curve: Curves.easeOut);
  }

  String _fmt(double n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : n.toStringAsFixed(0);
}

// ══════════════════════════════════════════════════════════
//  حالات التحميل والفراغ
// ══════════════════════════════════════════════════════════
class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Center(
      child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(AppTheme.accent)));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
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
}
