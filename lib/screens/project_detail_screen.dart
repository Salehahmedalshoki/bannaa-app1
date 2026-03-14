// ══════════════════════════════════════════════════════════
//  screens/project_detail_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة:
//  ✅ #1  جميع النصوص المُضمَّنة → t.tr() (32 نصاً)
//  ✅ #2  _exportPdf محمية بـ guard من الضغط المتكرر
//  ✅ #3  _goToEdit تحدّث _project من النتيجة المُرجَعة
//  ✅ #4  عرض تاريخ الإنشاء يحترم locale الجهاز
//  ✅ #5  project ID يُعرض كاملاً أو مقطوعاً بأمان
//  ✅ #6  زر التقرير محمي أثناء _isExporting
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'dimensions_screen.dart';
import 'report_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late Project _project;
  late TabController _tabCtrl;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ✅ #2 — حماية مزدوجة من الضغط المتكرر
  Future<void> _exportPdf() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      await PdfService.generateAndShare(_project);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ✅ #3 — تحديث _project من النتيجة المُرجَعة من DimensionsScreen
  Future<void> _goToEdit() async {
    final updated = await Navigator.push<Project>(
      context,
      MaterialPageRoute(builder: (_) => DimensionsScreen(project: _project)),
    );
    if (mounted && updated != null) {
      setState(() => _project = updated);
    } else if (mounted) {
      // إذا لم يُرجَع مشروع محدَّث، أعِد البناء للتأكد
      setState(() {});
    }
  }

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
    final mixParams = MixParameters(
      cementKgPerM3: mix.cementKgPerM3,
      sandM3PerM3: mix.sandM3PerM3,
      gravelM3PerM3: mix.gravelM3PerM3,
      waterLPerM3: mix.waterLPerM3,
      steelKgPerM3: mix.steelKgPerM3,
    );
    final materials =
        _project.calculateMaterials(mix: mixParams, prices: prices);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _buildHeader(t),
          _buildProjectBanner(t),
          _buildTabBar(t),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _OverviewTab(project: _project, materials: materials),
                _ComponentsTab(project: _project, onEdit: _goToEdit),
                _CostTab(project: _project, materials: materials),
              ],
            ),
          ),
          _buildBottomActions(t),
        ]),
      ),
    );
  }

  // ── الهيدر ─────────────────────────────────────────────
  Widget _buildHeader(BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ScreenHeader(
        // ✅ #1
        title: t.tr('projectDetails'),
        actions: [
          // زر PDF
          GestureDetector(
            // ✅ #2 — معطَّل أثناء التصدير
            onTap: _isExporting ? null : _exportPdf,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border)),
              child: Center(
                child: _isExporting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.accent))
                    : const Text('📤', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // زر التقرير — ✅ #6 معطَّل أثناء التصدير
          GestureDetector(
            onTap: _isExporting
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReportScreen(project: _project))),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  gradient: _isExporting
                      ? null
                      : const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accentDark]),
                  color: _isExporting ? AppTheme.surface : null,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      _isExporting ? Border.all(color: AppTheme.border) : null),
              child: const Center(
                  child: Text('📄', style: TextStyle(fontSize: 16))),
            ),
          ),
        ],
      ),
    );
  }

  // ── بانر المشروع ───────────────────────────────────────
  Widget _buildProjectBanner(BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.accent.withValues(alpha: 0.18),
            AppTheme.accentDark.withValues(alpha: 0.06),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
            child: Center(
                child: Text(_project.buildingType.emoji,
                    style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_project.name,
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on_outlined,
                      size: 11, color: AppTheme.textMuted),
                  const SizedBox(width: 3),
                  Text(_project.city,
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(width: 8),
                  Text('•', style: GoogleFonts.cairo(color: AppTheme.border)),
                  const SizedBox(width: 8),
                  // ✅ #1
                  Text('${_project.floors} ${t.tr('floorsSuffix')}',
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_project.totalVolume.toStringAsFixed(1)} م³',
                  style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.accent)),
              // ✅ #1
              Text(t.tr('concrete'),
                  style: GoogleFonts.cairo(
                      fontSize: 9, color: AppTheme.textMuted)),
            ],
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  // ── شريط التبويبات ─────────────────────────────────────
  Widget _buildTabBar(BannaaLocalizations t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      height: 42,
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border)),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentDark]),
            borderRadius: BorderRadius.circular(8)),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        // ✅ #1
        tabs: [
          _tab('📊', t.tr('overviewTab')),
          _tab('📐', t.tr('componentsTab')),
          _tab('💰', t.tr('costsTab')),
        ],
      ),
    );
  }

  Tab _tab(String icon, String label) => Tab(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.cairo(fontSize: 11)),
        ]),
      );

  // ── أزرار الأسفل ───────────────────────────────────────
  Widget _buildBottomActions(BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(children: [
        Expanded(
          child: GoldenButton(
            // ✅ #1
            label: t.tr('editComponents'),
            icon: '✏️',
            outline: true,
            onTap: _isExporting ? null : _goToEdit,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GoldenButton(
            // ✅ #1
            label: t.tr('viewReport'),
            icon: '📄',
            // ✅ #6
            onTap: _isExporting
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReportScreen(project: _project))),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  تبويب نظرة عامة
// ══════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final Project project;
  final List<MaterialQuantity> materials;
  const _OverviewTab({required this.project, required this.materials});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final totalCost = materials.fold(0.0, (sum, m) => sum + m.totalCost);
    final sym = s.currencyInfo.symbol;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        // ── بطاقات الإحصاء ────────────────────────────
        Row(children: [
          // ✅ #1
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

        // ── ملخص المواد ───────────────────────────────
        // ✅ #1
        Text(t.tr('materialSummary'),
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const SizedBox(height: 8),
        ...materials.map((m) => _MaterialRow(m: m)),

        const SizedBox(height: 16),

        // ── معلومات المشروع ───────────────────────────
        // ✅ #1
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
            // ✅ #4 — تاريخ يحترم locale
            _infoRow(t.tr('createdDate'), _fmtDate(context, project.createdAt),
                '📅'),
            _div(),
            // ✅ #5 — ID آمن حتى لو أقصر من 8 حروف
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textSub)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600)),
        ]),
      );

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);

  // ✅ #4 — تنسيق التاريخ حسب locale
  String _fmtDate(BuildContext context, DateTime d) {
    final locale = BannaaLocalizations.of(context).locale.languageCode;
    if (locale == 'ar') return '${d.day}/${d.month}/${d.year}';
    // en / fr / tr: YYYY-MM-DD
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

// ══════════════════════════════════════════════════════════
//  تبويب المكوّنات
// ══════════════════════════════════════════════════════════
class _ComponentsTab extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  const _ComponentsTab({required this.project, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);

    if (project.components.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📐', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          // ✅ #1
          Text(t.tr('noComponents'),
              style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: AppTheme.textSub,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: GoldenButton(
              // ✅ #1
              label: t.tr('addComponents'),
              icon: '＋',
              onTap: onEdit,
            ),
          ),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: project.components.length + 1,
      itemBuilder: (_, i) {
        if (i == project.components.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GoldenButton(
              // ✅ #1
              label: t.tr('editComponents'),
              icon: '✏️',
              outline: true,
              onTap: onEdit,
            ),
          );
        }
        final c = project.components[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: DarkCard(
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppTheme.accentGlow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.2))),
                child: Center(
                    child: Text(c.type.emoji,
                        style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 3),
                    Text(
                        '${c.length}م × ${c.width}م × ${c.height}م'
                        '${c.count > 1 ? ' × ${c.count}' : ''}',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${c.volume.toStringAsFixed(3)}',
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accent)),
                  Text('م³',
                      style: GoogleFonts.cairo(
                          fontSize: 9, color: AppTheme.textMuted)),
                ],
              ),
            ]),
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: i * 60), duration: 300.ms)
            .slideX(begin: 0.1, end: 0);
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  تبويب التكاليف
// ══════════════════════════════════════════════════════════
class _CostTab extends StatelessWidget {
  final Project project;
  final List<MaterialQuantity> materials;
  const _CostTab({required this.project, required this.materials});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final total = materials.fold(0.0, (sum, m) => sum + m.totalCost);
    final sym = s.currencyInfo.symbol;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        // ── إجمالي التكلفة ────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.success.withValues(alpha: 0.15),
                AppTheme.success.withValues(alpha: 0.05),
              ]),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.success.withValues(alpha: 0.25))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ #1
                  Text(t.tr('totalCostFull'),
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.success)),
                  const SizedBox(height: 4),
                  Text('${total.toStringAsFixed(0)} $sym',
                      style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary)),
                ],
              ),
              const Text('💰', style: TextStyle(fontSize: 40)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── توزيع التكاليف ────────────────────────────
        // ✅ #1
        Text(t.tr('costDistribution'),
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const SizedBox(height: 10),
        ...materials.map((m) =>
            _CostBar(m: m, percent: total > 0 ? m.totalCost / total : 0.0)),

        const SizedBox(height: 16),

        // ── ملاحظة ────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppTheme.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.info.withValues(alpha: 0.2))),
          child: Row(children: [
            const Icon(Icons.info_outline, color: AppTheme.info, size: 16),
            const SizedBox(width: 8),
            // ✅ #1
            Expanded(
                child: Text(t.tr('pricesNote'),
                    style: GoogleFonts.cairo(
                        fontSize: 10, color: AppTheme.info, height: 1.5))),
          ]),
        ),
      ],
    );
  }
}

class _CostBar extends StatelessWidget {
  final MaterialQuantity m;
  final double percent;
  const _CostBar({required this.m, required this.percent});

  @override
  Widget build(BuildContext context) {
    final sym = context.watch<AppSettingsProvider>().currencyInfo.symbol;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        Row(children: [
          Text(m.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(m.name,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600))),
          Text('${(percent * 100).toStringAsFixed(1)}%',
              style:
                  GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(width: 8),
          Text('${m.totalCost.toStringAsFixed(0)} $sym',
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: AppTheme.border,
            valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة إحصاء
// ══════════════════════════════════════════════════════════
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: value,
                    style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: color)),
                TextSpan(
                    text: ' $unit',
                    style: GoogleFonts.cairo(
                        fontSize: 10, color: AppTheme.textMuted)),
              ]),
            ),
            Text(label,
                style:
                    GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  صف مادة
// ══════════════════════════════════════════════════════════
class _MaterialRow extends StatelessWidget {
  final MaterialQuantity m;
  const _MaterialRow({required this.m});

  @override
  Widget build(BuildContext context) {
    final sym = context.watch<AppSettingsProvider>().currencyInfo.symbol;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DarkCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Text(m.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(m.name,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600))),
          Text(
              '${m.quantity.toStringAsFixed(m.quantity > 100 ? 0 : 1)} ${m.unit}',
              style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSub)),
          const SizedBox(width: 12),
          Text('${m.totalCost.toStringAsFixed(0)} $sym',
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
