// ══════════════════════════════════════════════════════════
//  screens/project_detail_screen.dart
//  تفاصيل المشروع الكاملة مع إمكانية التعديل
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
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

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    await PdfService.generateAndShare(_project);
    if (mounted) setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>();
    final mix = s.currentMix;
    final prices = PriceSheet(
      cementPerBag: s.prices['cement'] ?? 50,
      sandPerM3:    s.prices['sand']   ?? 150,
      gravelPerM3:  s.prices['gravel'] ?? 180,
      steelPerKg:   s.prices['steel']  ?? 4,
      waterPerM3:   s.prices['water']  ?? 5,
      currencySymbol: s.currencyInfo.symbol,
    );
    final mixParams = MixParameters(
      cementKgPerM3: mix.cementKgPerM3,
      sandM3PerM3:   mix.sandM3PerM3,
      gravelM3PerM3: mix.gravelM3PerM3,
      waterLPerM3:   mix.waterLPerM3,
      steelKgPerM3:  mix.steelKgPerM3,
    );
    final materials = _project.calculateMaterials(mix: mixParams, prices: prices);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildProjectBanner(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _OverviewTab(project: _project, materials: materials),
                _ComponentsTab(project: _project,
                  onEdit: _goToEdit),
                _CostTab(project: _project, materials: materials),
              ],
            ),
          ),
          _buildBottomActions(),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ScreenHeader(
        title: 'تفاصيل المشروع',
        actions: [
          // زر PDF
          GestureDetector(
            onTap: _exportPdf,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border)),
              child: Center(
                child: _isExporting
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.accent))
                    : const Text('📤', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // زر التقرير
          GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                ReportScreen(project: _project))),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark]),
                borderRadius: BorderRadius.circular(10)),
              child: const Center(
                child: Text('📄', style: TextStyle(fontSize: 16))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.accent.withOpacity(0.18),
            AppTheme.accentDark.withOpacity(0.06),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
        ),
        child: Row(children: [
          // أيقونة
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppTheme.accentGlow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
            child: Center(child: Text(_project.buildingType.emoji,
              style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_project.name, style: GoogleFonts.cairo(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                  size: 11, color: AppTheme.textMuted),
                const SizedBox(width: 3),
                Text(_project.city, style: GoogleFonts.cairo(
                  fontSize: 11, color: AppTheme.textMuted)),
                const SizedBox(width: 8),
                Text('•', style: GoogleFonts.cairo(
                  color: AppTheme.border)),
                const SizedBox(width: 8),
                Text('${_project.floors} طوابق', style: GoogleFonts.cairo(
                  fontSize: 11, color: AppTheme.textMuted)),
              ]),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${_project.totalVolume.toStringAsFixed(1)} م³',
              style: GoogleFonts.cairo(
                fontSize: 18, fontWeight: FontWeight.w900,
                color: AppTheme.accent)),
            Text('خرسانة', style: GoogleFonts.cairo(
              fontSize: 9, color: AppTheme.textMuted)),
          ]),
        ]),
      ),
    ).animate().fadeIn(duration: 300.ms)
     .slideY(begin: -0.1, end: 0);
  }

  Widget _buildTabBar() {
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
        tabs: [
          _tab('📊', 'نظرة عامة'),
          _tab('📐', 'المكوّنات'),
          _tab('💰', 'التكاليف'),
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

  void _goToEdit() async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (_) =>
        DimensionsScreen(project: _project)));
    // تحديث بعد التعديل
    final updated = StorageService.getProject(_project.id);
    if (updated != null && mounted) {
      setState(() => _project = updated);
    }
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(children: [
        Expanded(
          child: GoldenButton(
            label: 'تعديل المكوّنات',
            icon: '✏️',
            outline: true,
            onTap: _goToEdit,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GoldenButton(
            label: 'عرض التقرير',
            icon: '📄',
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                ReportScreen(project: _project))),
          ),
        ),
      ]),
    );
  }
}

// ══ تبويب نظرة عامة ══════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final Project project;
  final List<MaterialQuantity> materials;
  const _OverviewTab({required this.project, required this.materials});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>();
    final totalCost = materials.fold(0.0, (sum, m) => sum + m.totalCost);
    final sym = s.currencyInfo.symbol;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        // بطاقات الإحصاء
        Row(children: [
          _StatBox(label: 'حجم الخرسانة',
            value: '${project.totalVolume.toStringAsFixed(2)}',
            unit: 'م³', icon: '🧱', color: AppTheme.accent),
          const SizedBox(width: 10),
          _StatBox(label: 'عدد المكوّنات',
            value: '${project.components.length}',
            unit: 'مكوّن', icon: '📐', color: AppTheme.info),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatBox(label: 'التكلفة التقديرية',
            value: _fmt(totalCost),
            unit: sym, icon: '💰', color: AppTheme.success),
          const SizedBox(width: 10),
          _StatBox(label: 'الطوابق',
            value: '${project.floors}',
            unit: 'طابق', icon: '🏢', color: const Color(0xFFEC4899)),
        ]),
        const SizedBox(height: 16),

        // ملخص المواد
        Text('ملخص المواد', style: GoogleFonts.cairo(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppTheme.textSub)),
        const SizedBox(height: 8),
        ...materials.map((m) => _MaterialRow(m: m))
          .toList(),

        const SizedBox(height: 16),

        // معلومات المشروع
        Text('معلومات المشروع', style: GoogleFonts.cairo(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppTheme.textSub)),
        const SizedBox(height: 8),
        DarkCard(
          child: Column(children: [
            _infoRow('النوع', project.buildingType.label,
              project.buildingType.emoji),
            _div(),
            _infoRow('المدينة', project.city, '📍'),
            _div(),
            _infoRow('تاريخ الإنشاء',
              _fmtDate(project.createdAt), '📅'),
            _div(),
            _infoRow('المعرّف', project.id.substring(0, 8) + '...', '🆔'),
          ]),
        ),
      ],
    );
  }

  Widget _div() => Container(
    height: 1, margin: const EdgeInsets.symmetric(vertical: 0),
    color: AppTheme.border);

  Widget _infoRow(String label, String value, String icon) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.cairo(
          fontSize: 12, color: AppTheme.textSub)),
        const Spacer(),
        Text(value, style: GoogleFonts.cairo(
          fontSize: 12, color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600)),
      ]),
    );

  String _fmt(double v) =>
    v >= 1000 ? '${(v/1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _StatBox extends StatelessWidget {
  final String label, value, unit, icon;
  final Color color;
  const _StatBox({required this.label, required this.value,
    required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            RichText(text: TextSpan(children: [
              TextSpan(text: value, style: GoogleFonts.cairo(
                fontSize: 20, fontWeight: FontWeight.w900, color: color)),
              TextSpan(text: ' $unit', style: GoogleFonts.cairo(
                fontSize: 10, color: AppTheme.textMuted)),
            ])),
            Text(label, style: GoogleFonts.cairo(
              fontSize: 10, color: AppTheme.textMuted)),
          ]),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Text(m.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(m.name, style: GoogleFonts.cairo(
            fontSize: 12, color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600))),
          Text('${m.quantity.toStringAsFixed(m.quantity > 100 ? 0 : 1)} ${m.unit}',
            style: GoogleFonts.cairo(
              fontSize: 11, color: AppTheme.textSub)),
          const SizedBox(width: 12),
          Text('${m.totalCost.toStringAsFixed(0)} $sym',
            style: GoogleFonts.cairo(
              fontSize: 12, color: AppTheme.accent,
              fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ══ تبويب المكوّنات ══════════════════════════════════════
class _ComponentsTab extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  const _ComponentsTab({required this.project, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    if (project.components.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📐', style: TextStyle(fontSize: 44)),
        const SizedBox(height: 12),
        Text('لا توجد مكوّنات', style: GoogleFonts.cairo(
          fontSize: 15, color: AppTheme.textSub,
          fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GoldenButton(label: 'إضافة مكوّنات',
            icon: '＋', onTap: onEdit),
        ),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: project.components.length + 1,
      itemBuilder: (_, i) {
        if (i == project.components.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GoldenButton(
              label: 'تعديل المكوّنات', icon: '✏️',
              outline: true, onTap: onEdit),
          );
        }
        final c = project.components[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: DarkCard(
            child: Row(children: [
              // أيقونة
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentGlow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2))),
                child: Center(child: Text(c.type.emoji,
                  style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
                  const SizedBox(height: 3),
                  Text(
                    '${c.length}م × ${c.width}م × ${c.height}م'
                    '${c.count > 1 ? ' × ${c.count}' : ''}',
                    style: GoogleFonts.cairo(
                      fontSize: 11, color: AppTheme.textMuted)),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${c.volume.toStringAsFixed(3)}',
                  style: GoogleFonts.cairo(
                    fontSize: 14, fontWeight: FontWeight.w800,
                    color: AppTheme.accent)),
                Text('م³', style: GoogleFonts.cairo(
                  fontSize: 9, color: AppTheme.textMuted)),
              ]),
            ]),
          ),
        ).animate().fadeIn(
          delay: Duration(milliseconds: i * 60), duration: 300.ms)
         .slideX(begin: 0.1, end: 0);
      },
    );
  }
}

// ══ تبويب التكاليف ════════════════════════════════════════
class _CostTab extends StatelessWidget {
  final Project project;
  final List<MaterialQuantity> materials;
  const _CostTab({required this.project, required this.materials});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>();
    final total = materials.fold(0.0, (sum, m) => sum + m.totalCost);
    final sym = s.currencyInfo.symbol;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        // إجمالي التكلفة
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppTheme.success.withOpacity(0.15),
              AppTheme.success.withOpacity(0.05),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.success.withOpacity(0.25))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('التكلفة التقديرية الكاملة', style: GoogleFonts.cairo(
                  fontSize: 11, color: AppTheme.success)),
                const SizedBox(height: 4),
                Text('${total.toStringAsFixed(0)} $sym',
                  style: GoogleFonts.cairo(
                    fontSize: 28, fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary)),
              ]),
              const Text('💰', style: TextStyle(fontSize: 40)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // رسم بياني بسيط (أشرطة نسبية)
        Text('توزيع التكاليف', style: GoogleFonts.cairo(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: AppTheme.textSub)),
        const SizedBox(height: 10),
        ...materials.map((m) {
          final pct = total > 0 ? m.totalCost / total : 0.0;
          return _CostBar(m: m, percent: pct, total: total);
        }),

        const SizedBox(height: 16),
        // ملاحظة
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.info.withOpacity(0.2))),
          child: Row(children: [
            const Icon(Icons.info_outline,
              color: AppTheme.info, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'الأسعار تقديرية وتختلف حسب المورد والمنطقة. '
              'يُنصح بمراجعة مهندس مختص.',
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
  final double percent, total;
  const _CostBar({required this.m, required this.percent, required this.total});

  @override
  Widget build(BuildContext context) {
    final sym = context.watch<AppSettingsProvider>().currencyInfo.symbol;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        Row(children: [
          Text(m.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(m.name, style: GoogleFonts.cairo(
            fontSize: 12, color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600))),
          Text('${(percent * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.cairo(
              fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(width: 8),
          Text('${m.totalCost.toStringAsFixed(0)} $sym',
            style: GoogleFonts.cairo(
              fontSize: 11, color: AppTheme.accent,
              fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 5,
            backgroundColor: AppTheme.border,
            valueColor: AlwaysStoppedAnimation(AppTheme.accent),
          ),
        ),
      ]),
    );
  }
}
