// ══════════════════════════════════════════════════════════
//  screens/my_projects_screen.dart — مع الترجمة الكاملة
//  شاشة مشاريعي — بحث، تصفية، فرز
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
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
  String _sortBy = 'date'; // date | cost | name

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _all = StorageService.getAllProjects();
      _applyFilter();
    });
  }

  void _applyFilter() {
    var list = List<Project>.from(_all);

    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.city.toLowerCase().contains(q) ||
        p.buildingType.label.contains(q)).toList();
    }

    if (_filterType != null) {
      list = list.where((p) => p.buildingType == _filterType).toList();
    }

    switch (_sortBy) {
      case 'cost':
        list.sort((a, b) => b.totalCost.compareTo(a.totalCost));
        break;
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    setState(() => _filtered = list);
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, t),
            _buildSearchBar(context, t),
            _buildFilterRow(context, t),
            _buildStats(context, t),
            Expanded(child: _buildList(context, t)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const NewProjectScreen()));
          _load();
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: Text(t.tr('newProject2'),
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.tr('myProjects'),
                  style: GoogleFonts.cairo(
                    fontSize: 22, fontWeight: FontWeight.w800,
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
                Text(_sortLabel(t), style: GoogleFonts.cairo(
                  fontSize: 11, color: AppTheme.textSub)),
              ]),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSearchBar(BuildContext context, BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: GoogleFonts.cairo(
                  color: AppTheme.textPrimary, fontSize: 13),
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
                onTap: () { _searchCtrl.clear(); _applyFilter(); },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, color: AppTheme.textMuted, size: 16)),
              ),
          ],
        ),
      ),
    ).animate(delay: 100.ms).fadeIn();
  }

  Widget _buildFilterRow(BuildContext context, BannaaLocalizations t) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        children: [
          _FilterChip(
            label: t.tr('allTypes'),
            selected: _filterType == null,
            onTap: () { setState(() => _filterType = null); _applyFilter(); },
          ),
          ...BuildingType.values.map((bt) => _FilterChip(
            label: '${bt.emoji} ${bt.label}',
            selected: _filterType == bt,
            onTap: () {
              setState(() => _filterType = _filterType == bt ? null : bt);
              _applyFilter();
            },
          )),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn();
  }

  Widget _buildStats(BuildContext context, BannaaLocalizations t) {
    if (_all.isEmpty) return const SizedBox.shrink();

    final s = context.watch<AppSettingsProvider>();
    final totalCost = _all.fold(0.0, (sum, p) => sum + p.totalCost);
    final totalVol  = _all.fold(0.0, (sum, p) => sum + p.totalVolume);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: DarkCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _MiniStat(
              icon: '💰',
              label: t.tr('totalCosts'),
              value: '${(totalCost / 1000).toStringAsFixed(0)}k ${s.currencyInfo.symbol}'),
            _dividerV(),
            _MiniStat(
              icon: '🧱',
              label: t.tr('totalConcreteStat'),
              value: '${totalVol.toStringAsFixed(0)} ${t.tr('perM3')}'),
            _dividerV(),
            _MiniStat(
              icon: '📊',
              label: t.tr('mostCommon'),
              value: _mostCommonType()),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn();
  }

  Widget _buildList(BuildContext context, BannaaLocalizations t) {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🔍', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          Text(t.tr('noResults'), style: GoogleFonts.cairo(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppTheme.textSub)),
          Text(t.tr('tryChangeSearch'),
            style: GoogleFonts.cairo(
              fontSize: 11, color: AppTheme.textMuted)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _filtered.length,
      itemBuilder: (_, i) {
        final p = _filtered[i];
        return _ProjectListTile(
          project: p,
          index: i,
          onTap: () async {
            await Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(project: p)));
            _load();
          },
          onDelete: () async {
            await StorageService.deleteProject(p.id);
            _load();
          },
        );
      },
    );
  }

  void _showSortSheet(BuildContext context, BannaaLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(t.tr('sortBy'), style: GoogleFonts.cairo(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          ...[
            ['date', '📅', t.tr('sortNewest')],
            ['cost', '💰', t.tr('sortCost')],
            ['name', '🔤', t.tr('sortName')],
          ].map((s) => ListTile(
            leading: Text(s[1], style: const TextStyle(fontSize: 20)),
            title: Text(s[2], style: GoogleFonts.cairo(
              color: _sortBy == s[0] ? AppTheme.accent : AppTheme.textPrimary,
              fontWeight: _sortBy == s[0] ? FontWeight.w700 : FontWeight.normal)),
            trailing: _sortBy == s[0]
                ? const Icon(Icons.check, color: AppTheme.accent)
                : null,
            onTap: () {
              setState(() => _sortBy = s[0]);
              _applyFilter();
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  String _sortLabel(BannaaLocalizations t) {
    switch (_sortBy) {
      case 'cost': return t.tr('sortCostLabel');
      case 'name': return t.tr('sortNameLabel');
      default:     return t.tr('sortDate');
    }
  }

  String _mostCommonType() {
    if (_all.isEmpty) return '—';
    final counts = <BuildingType, int>{};
    for (final p in _all) {
      counts[p.buildingType] = (counts[p.buildingType] ?? 0) + 1;
    }
    final top = counts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return top.key.emoji;
  }

  Widget _dividerV() => Container(width: 1, height: 30, color: AppTheme.border);
}

// ── شريحة فلتر ────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 180.ms,
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentGlow : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.border)),
        child: Text(label, style: GoogleFonts.cairo(
          fontSize: 11,
          color: selected ? AppTheme.accent : AppTheme.textMuted,
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
      ),
    );
  }
}

// ── إحصاء مصغّر ───────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String icon, label, value;
  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(height: 3),
      Text(value, style: GoogleFonts.cairo(
        fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.accent)),
      Text(label, style: GoogleFonts.cairo(
        fontSize: 9, color: AppTheme.textMuted),
        textAlign: TextAlign.center),
    ]);
  }
}

// ── بطاقة مشروع في القائمة ────────────────────────────────
class _ProjectListTile extends StatelessWidget {
  final Project project;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectListTile({
    required this.project, required this.index,
    required this.onTap, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();

    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
          title: Text(t.tr('deleteProjectTitle'), style: GoogleFonts.cairo(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          content: Text(
            '${t.tr('deleteProjectConfirm')} "${project.name}"؟',
            style: GoogleFonts.cairo(color: AppTheme.textSub)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.tr('cancel'), style: GoogleFonts.cairo(
                color: AppTheme.textMuted))),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.tr('delete'), style: GoogleFonts.cairo(
                color: AppTheme.danger, fontWeight: FontWeight.w700))),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: DarkCard(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              Row(children: [
                // أيقونة
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGlow,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.2))),
                  child: Center(child: Text(project.buildingType.emoji,
                    style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name, style: GoogleFonts.cairo(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                          size: 11, color: AppTheme.textMuted),
                        const SizedBox(width: 3),
                        Text(project.city, style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.textMuted)),
                        const SizedBox(width: 8),
                        Text('•', style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.border)),
                        const SizedBox(width: 8),
                        Text(project.buildingType.label, style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.textMuted)),
                      ]),
                    ],
                  ),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    '${_formatCost(project.totalCost)} ${s.currencyInfo.symbol}',
                    style: GoogleFonts.cairo(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: AppTheme.accent)),
                  const SizedBox(height: 4),
                  Text(_formatDate(project.createdAt),
                    style: GoogleFonts.cairo(
                      fontSize: 9, color: AppTheme.textMuted)),
                ]),
              ]),
              const SizedBox(height: 10),
              // شريط الإحصاء السفلي
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('🧱',
                      '${project.totalVolume.toStringAsFixed(1)} ${t.tr('perM3')}',
                      t.tr('concrete')),
                    _vDivider(),
                    _stat('📐', '${project.components.length}',
                      t.tr('component')),
                    _vDivider(),
                    _stat('🏢', '${project.floors}', t.tr('floors')),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: index * 70), duration: 350.ms)
    .slideY(begin: 0.1, end: 0,
      delay: Duration(milliseconds: index * 70));
  }

  Widget _stat(String icon, String val, String lbl) => Row(children: [
    Text(icon, style: const TextStyle(fontSize: 12)),
    const SizedBox(width: 4),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: GoogleFonts.cairo(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary)),
      Text(lbl, style: GoogleFonts.cairo(
        fontSize: 9, color: AppTheme.textMuted)),
    ]),
  ]);

  Widget _vDivider() => Container(width: 1, height: 24, color: AppTheme.border);

  String _formatCost(double c) =>
    c >= 1000 ? '${(c / 1000).toStringAsFixed(1)}k' : c.toStringAsFixed(0);
  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
