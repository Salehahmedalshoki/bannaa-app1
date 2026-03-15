// ══════════════════════════════════════════════════════════
//  screens/my_projects_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة (إضافةً لما كان موجوداً):
//  ✅ #6  withOpacity المُهمَلة → withValues(alpha:) في كل المكان
//  ✅ #7  _syncIfChanged: مقارنة محتوى المشاريع لا IDs فقط
//  ✅ #8  _FilterChip margin يتكيف مع RTL/LTR
//  ✅ #9  onDelete في _ProjectTile → Future<void> بدل VoidCallback
//  ✅ #10 _buildList: حالة الفراغ لا تُعرض عند التحميل الأولي
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import 'new_project_screen.dart';
import 'project_detail_screen.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  List<Project> _all = [];
  List<Project> _filtered = [];
  final _searchCtrl = TextEditingController();
  BuildingType? _filterType;
  String _sortBy = 'date';
  bool _loading = true; // ✅ #10

  // ✅ #7 — نحفظ IDs + عدد المشاريع للمقارنة الدقيقة
  Set<String> _lastIds = {};
  int _lastCount = -1;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ✅ #7 — مقارنة IDs + عدد + محتوى التكاليف الإجمالية (تغطية تعديل المشروع)
  void _syncIfChanged(List<Project> incoming) {
    final incomingIds = {for (final p in incoming) p.id};
    // تحقق من التغيير: IDs مختلفة، عدد مختلف، أو مجموع التكاليف تغيّر
    final incomingTotal = incoming.fold(0.0, (s, p) => s + p.totalCost);
    final currentTotal = _all.fold(0.0, (s, p) => s + p.totalCost);

    if (incomingIds == _lastIds &&
        incoming.length == _lastCount &&
        incomingTotal == currentTotal) return;

    _lastIds = incomingIds;
    _lastCount = incoming.length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _all = incoming;
      // ✅ #10 — بعد أول تحميل نوقف مؤشر التحميل
      if (_loading) setState(() => _loading = false);
      _applyFilter();
    });
  }

  void _applyFilter() {
    var list = List<Project>.from(_all);

    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.city.toLowerCase().contains(q) ||
              p.buildingType.label.contains(q))
          .toList();
    }

    if (_filterType != null) {
      list = list.where((p) => p.buildingType == _filterType).toList();
    }

    switch (_sortBy) {
      case 'cost':
        list.sort((a, b) => b.totalCost.compareTo(a.totalCost));
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    setState(() => _filtered = list);
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);

    return StreamBuilder<List<Project>>(
      stream: FirestoreService.projectsStream(),
      builder: (context, snapshot) {
        final incoming = snapshot.data ?? [];
        _syncIfChanged(incoming);

        return Scaffold(
          body: SafeArea(
            child: Column(children: [
              _buildHeader(context, t),
              _buildSearchBar(context, t),
              _buildFilterRow(context, t),
              _buildStats(context, t),
              Expanded(child: _buildList(context, t)),
            ]),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NewProjectScreen())),
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add),
            label: Text(t.tr('newProject2'),
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  //  الرأس
  // ══════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.tr('myProjects'),
                  style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              Text('${_all.length} ${t.tr('projectsTotal')}',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showSortSheet(context, t),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border)),
            child: Row(children: [
              const Icon(Icons.sort, color: AppTheme.textMuted, size: 16),
              const SizedBox(width: 5),
              Text(_sortLabel(t),
                  style:
                      GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSub)),
            ]),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  // ══════════════════════════════════════════════════════
  //  شريط البحث
  // ══════════════════════════════════════════════════════
  Widget _buildSearchBar(BuildContext context, BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border)),
        child: Row(children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style:
                  GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                  hintText: t.tr('searchHint'),
                  hintStyle: GoogleFonts.cairo(
                      color: AppTheme.textMuted, fontSize: 12),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                _applyFilter();
              },
              child: const Padding(
                  padding: EdgeInsets.all(8),
                  child:
                      Icon(Icons.close, color: AppTheme.textMuted, size: 16)),
            ),
        ]),
      ),
    ).animate(delay: 100.ms).fadeIn();
  }

  // ══════════════════════════════════════════════════════
  //  شريط الفلتر
  // ══════════════════════════════════════════════════════
  Widget _buildFilterRow(BuildContext context, BannaaLocalizations t) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        children: [
          _FilterChip(
              label: t.tr('allTypes'),
              isActive: _filterType == null,
              onTap: () {
                setState(() => _filterType = null);
                _applyFilter();
              }),
          ...BuildingType.values.map((bt) => _FilterChip(
              label: '${bt.emoji} ${bt.label}',
              isActive: _filterType == bt,
              onTap: () {
                setState(() => _filterType = _filterType == bt ? null : bt);
                _applyFilter();
              })),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn();
  }

  // ══════════════════════════════════════════════════════
  //  الإحصائيات
  // ══════════════════════════════════════════════════════
  Widget _buildStats(BuildContext context, BannaaLocalizations t) {
    if (_all.isEmpty) return const SizedBox.shrink();
    final s = context.watch<AppSettingsProvider>();
    final total = _all.fold(0.0, (acc, p) => acc + p.totalCost);
    final vol = _all.fold(0.0, (acc, p) => acc + p.totalVolume);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(children: [
        _StatPill(
            label:
                '${_filtered.length} / ${_all.length} ${t.tr('projectWord')}',
            color: AppTheme.accent),
        const SizedBox(width: 8),
        _StatPill(label: '${vol.toStringAsFixed(1)} م³', color: AppTheme.info),
        const SizedBox(width: 8),
        _StatPill(
            label: '${_fmtNum(total)} ${s.currencyInfo.symbol}',
            color: AppTheme.success),
      ]),
    ).animate(delay: 200.ms).fadeIn();
  }

  // ══════════════════════════════════════════════════════
  //  القائمة الرئيسية
  // ══════════════════════════════════════════════════════
  Widget _buildList(BuildContext context, BannaaLocalizations t) {
    // ✅ #10 — لا نعرض الفراغ أثناء التحميل الأولي
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(AppTheme.accent)),
      );
    }

    if (_filtered.isEmpty && _searchCtrl.text.isEmpty && _filterType == null) {
      return _buildEmptyState(context, t);
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔍', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(t.tr('noResults'),
              style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSub)),
          const SizedBox(height: 6),
          Text(t.tr('tryChangeSearch'),
              style:
                  GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final p = _filtered[i];
        return _ProjectTile(
          project: p,
          index: i,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p)),
          ),
          // ✅ #9 — Future<void> بدل VoidCallback
          onDelete: () => FirestoreService.deleteProject(p.id),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, BannaaLocalizations t) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📁', style: TextStyle(fontSize: 52))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                begin: const Offset(0.92, 0.92),
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

  // ══════════════════════════════════════════════════════
  //  ورقة الفرز
  // ══════════════════════════════════════════════════════
  void _showSortSheet(BuildContext context, BannaaLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(t.tr('sortBy'),
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ),
          const SizedBox(height: 8),
          ...[
            ('date', t.tr('sortDate'), Icons.calendar_today_outlined),
            ('cost', t.tr('sortCost'), Icons.attach_money_outlined),
            ('name', t.tr('sortName'), Icons.sort_by_alpha_outlined),
          ].map((opt) => ListTile(
                leading: Icon(opt.$3,
                    color: _sortBy == opt.$1
                        ? AppTheme.accent
                        : AppTheme.textMuted,
                    size: 20),
                title: Text(opt.$2,
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: AppTheme.textPrimary)),
                trailing: _sortBy == opt.$1
                    ? const Icon(Icons.check, color: AppTheme.accent, size: 18)
                    : null,
                onTap: () {
                  setState(() => _sortBy = opt.$1);
                  _applyFilter();
                  Navigator.pop(context);
                },
              )),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  String _sortLabel(BannaaLocalizations t) => switch (_sortBy) {
        'cost' => t.tr('sortCost'),
        'name' => t.tr('sortName'),
        _ => t.tr('sortDate'),
      };

  String _fmtNum(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toStringAsFixed(0);
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة المشروع
// ══════════════════════════════════════════════════════════
class _ProjectTile extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;
  // ✅ #9 — Future<void> لانتظار نتيجة الحذف
  final Future<void> Function() onDelete;

  const _ProjectTile({
    required this.project,
    required this.index,
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
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppTheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text(t.tr('deleteProjectTitle'),
                    style: GoogleFonts.cairo(
                        color: AppTheme.danger, fontWeight: FontWeight.w700)),
                content: Text(
                    '${t.tr('deleteProjectConfirm')} "${project.name}"?\n${t.tr('deleteProjectConfirmMsg')}',
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
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
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
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppTheme.accentGlow,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                      // ✅ #6
                      color: AppTheme.accent.withValues(alpha: 0.2))),
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
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: AppTheme.textMuted),
                    const SizedBox(width: 2),
                    Text(project.city,
                        style: GoogleFonts.cairo(
                            fontSize: 10, color: AppTheme.textMuted)),
                    const SizedBox(width: 8),
                    const Icon(Icons.layers_outlined,
                        size: 11, color: AppTheme.textMuted),
                    const SizedBox(width: 2),
                    Text('${project.floors} ${t.tr('floors')}',
                        style: GoogleFonts.cairo(
                            fontSize: 10, color: AppTheme.textMuted)),
                  ]),
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
                Text('${project.totalVolume.toStringAsFixed(1)} م³',
                    style:
                        GoogleFonts.cairo(fontSize: 10, color: AppTheme.info)),
              ],
            ),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 60)).slideX(
        begin: 0.08,
        end: 0,
        delay: Duration(milliseconds: index * 60),
        duration: 320.ms);
  }

  String _fmt(double n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : n.toStringAsFixed(0);
}

// ══════════════════════════════════════════════════════════
//  شريحة الفلتر — ✅ #8 margin يتكيف مع RTL
// ══════════════════════════════════════════════════════════
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ✅ #8 — في RTL نضع margin على اليمين، في LTR على اليسار
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: EdgeInsets.only(
          left: isRtl ? 0 : 8,
          right: isRtl ? 8 : 0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
            color: isActive ? AppTheme.accent : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isActive ? AppTheme.accent : AppTheme.border)),
        child: Text(label,
            style: GoogleFonts.cairo(
                fontSize: 11,
                color: isActive ? Colors.black : AppTheme.textSub,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.normal)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  بادج الإحصاء — ✅ #6 withValues(alpha:)
// ══════════════════════════════════════════════════════════
class _StatPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          // ✅ #6
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Text(label,
          style: GoogleFonts.cairo(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
