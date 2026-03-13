// ══════════════════════════════════════════════════════════
//  screens/land_cost_screen.dart
//  💰 حساب الكميات والتكاليف التفصيلية لمشروع البناء
// ══════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'land_plan_screen.dart';

// ════════════════════════════════════════════════════════
//  موديل بند التكلفة
// ════════════════════════════════════════════════════════
class CostItem {
  final String category;
  final String name;
  final String icon;
  final double quantity;
  final String unit;
  final double unitPrice;
  final Color color;

  const CostItem({
    required this.category,
    required this.name,
    required this.icon,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.color,
  });

  double get total => quantity * unitPrice;
}

// ════════════════════════════════════════════════════════
//  شاشة حساب التكاليف
// ════════════════════════════════════════════════════════
class LandCostScreen extends StatefulWidget {
  final String city;
  final LatLng location;
  final double length, width;
  final int floors;
  final String buildingUse;
  final ArchitecturalPlan selectedPlan;

  const LandCostScreen({
    super.key,
    required this.city,
    required this.location,
    required this.length,
    required this.width,
    required this.floors,
    required this.buildingUse,
    required this.selectedPlan,
  });

  @override
  State<LandCostScreen> createState() => _LandCostScreenState();
}

class _LandCostScreenState extends State<LandCostScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late List<CostItem> _items;
  String _selectedCategory = 'الكل';

  // ── أسعار الوحدات (ر.ي) ─────────────────────────────
  static const _prices = {
    'concrete': 45000.0, // م³ خرسانة
    'steel': 950.0, // كجم حديد
    'cement_bag': 7500.0, // كيس أسمنت
    'sand_m3': 12000.0, // م³ رمل
    'gravel_m3': 15000.0, // م³ حصى
    'brick': 350.0, // كل ألف طابوقة
    'tiles_m2': 18000.0, // م² بلاط
    'plaster_m2': 3500.0, // م² لياسة
    'paint_m2': 2500.0, // م² دهان
    'windows_m2': 35000.0, // م² نوافذ
    'doors_each': 120000.0, // باب
    'elec_m2': 8000.0, // م² كهرباء
    'plumb_m2': 6000.0, // م² سباكة
    'labor_m2': 25000.0, // م² عمالة
    'waterproof_m2': 4500.0, // م² عزل
    'insulation_m2': 3800.0, // م² عزل حراري
  };

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _items = _calculateCosts();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── حساب الكميات والتكاليف ──────────────────────────
  List<CostItem> _calculateCosts() {
    final area = widget.length * widget.width;
    final totalArea = area * widget.floors;
    final wallArea = 2 * (widget.length + widget.width) * 3.0 * widget.floors;
    final floorH = 3.0; // ارتفاع الدور

    // ── معامل التعقيد حسب الاستخدام ──
    final complexFactor = widget.buildingUse == 'تجاري'
        ? 1.2
        : widget.buildingUse == 'مكتبي'
            ? 1.15
            : 1.0;

    return [
      // ════ الخرسانة والهيكل ════
      CostItem(
          category: 'هيكل',
          name: 'خرسانة مسلحة (أعمدة + أسقف)',
          icon: '🏗️',
          quantity: (totalArea * 0.35 * complexFactor).roundToDouble(),
          unit: 'م³',
          unitPrice: _prices['concrete']!,
          color: const Color(0xFF64748B)),
      CostItem(
          category: 'هيكل',
          name: 'حديد تسليح',
          icon: '⚙️',
          quantity: (totalArea * 35 * complexFactor).roundToDouble(),
          unit: 'كجم',
          unitPrice: _prices['steel']!,
          color: const Color(0xFF475569)),
      CostItem(
          category: 'هيكل',
          name: 'أسمنت',
          icon: '🪨',
          quantity: (totalArea * 8 * complexFactor).roundToDouble(),
          unit: 'كيس',
          unitPrice: _prices['cement_bag']!,
          color: const Color(0xFF94A3B8)),
      CostItem(
          category: 'هيكل',
          name: 'رمل',
          icon: '🏖️',
          quantity: (totalArea * 0.5).roundToDouble(),
          unit: 'م³',
          unitPrice: _prices['sand_m3']!,
          color: const Color(0xFFD97706)),
      CostItem(
          category: 'هيكل',
          name: 'حصى',
          icon: '🪨',
          quantity: (totalArea * 0.45).roundToDouble(),
          unit: 'م³',
          unitPrice: _prices['gravel_m3']!,
          color: const Color(0xFF92400E)),

      // ════ المباني والتشطيب ════
      CostItem(
          category: 'تشطيب',
          name: 'طابوق بناء',
          icon: '🧱',
          quantity: (wallArea * 50).roundToDouble(),
          unit: 'طابوقة',
          unitPrice: _prices['brick']! / 1000,
          color: const Color(0xFFDC2626)),
      CostItem(
          category: 'تشطيب',
          name: 'بلاط أرضيات وجدران',
          icon: '🔲',
          quantity: (totalArea * 1.1).roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['tiles_m2']!,
          color: const Color(0xFF0891B2)),
      CostItem(
          category: 'تشطيب',
          name: 'لياسة داخلية وخارجية',
          icon: '🖌️',
          quantity: (wallArea * 2).roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['plaster_m2']!,
          color: const Color(0xFF7C3AED)),
      CostItem(
          category: 'تشطيب',
          name: 'دهانات',
          icon: '🎨',
          quantity: (wallArea * 1.8).roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['paint_m2']!,
          color: const Color(0xFFDB2777)),
      CostItem(
          category: 'تشطيب',
          name: 'نوافذ ألمنيوم',
          icon: '🪟',
          quantity: (widget.floors * 6.0 * complexFactor).roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['windows_m2']!,
          color: const Color(0xFF0284C7)),
      CostItem(
          category: 'تشطيب',
          name: 'أبواب (داخلية وخارجية)',
          icon: '🚪',
          quantity: (widget.floors * 5 + 2.0).roundToDouble(),
          unit: 'باب',
          unitPrice: _prices['doors_each']!,
          color: const Color(0xFF65A30D)),

      // ════ الكهرباء والسباكة ════
      CostItem(
          category: 'تمديدات',
          name: 'شبكة كهربائية كاملة',
          icon: '⚡',
          quantity: totalArea.roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['elec_m2']!,
          color: const Color(0xFFF59E0B)),
      CostItem(
          category: 'تمديدات',
          name: 'شبكة سباكة وصرف',
          icon: '💧',
          quantity: totalArea.roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['plumb_m2']!,
          color: const Color(0xFF06B6D4)),
      CostItem(
          category: 'تمديدات',
          name: 'عزل مائي (أسطح وحمامات)',
          icon: '🛡️',
          quantity: (area + wallArea * 0.3).roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['waterproof_m2']!,
          color: const Color(0xFF10B981)),
      CostItem(
          category: 'تمديدات',
          name: 'عزل حراري',
          icon: '🌡️',
          quantity: (area * 1.1).roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['insulation_m2']!,
          color: const Color(0xFFEF4444)),

      // ════ العمالة ════
      CostItem(
          category: 'عمالة',
          name: 'عمالة عامة وتشطيب',
          icon: '👷',
          quantity: totalArea.roundToDouble(),
          unit: 'م²',
          unitPrice: _prices['labor_m2']!,
          color: const Color(0xFF8B5CF6)),
    ];
  }

  // ── المجاميع ─────────────────────────────────────────
  double get _totalCost => _items.fold(0.0, (s, i) => s + i.total);
  double get _structureCost => _items
      .where((i) => i.category == 'هيكل')
      .fold(0.0, (s, i) => s + i.total);
  double get _finishCost => _items
      .where((i) => i.category == 'تشطيب')
      .fold(0.0, (s, i) => s + i.total);
  double get _mechCost => _items
      .where((i) => i.category == 'تمديدات')
      .fold(0.0, (s, i) => s + i.total);
  double get _laborCost => _items
      .where((i) => i.category == 'عمالة')
      .fold(0.0, (s, i) => s + i.total);

  // ══════════════════════════════════════════════════════
  //  بناء الواجهة
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>();
    final sym = s.currencyInfo.symbol;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('التكاليف التفصيلية',
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppTheme.accent),
            onPressed: _shareReport,
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelStyle:
              GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.accent,
          tabs: const [
            Tab(text: 'ملخص'),
            Tab(text: 'تفاصيل'),
            Tab(text: 'جدول زمني'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildSummaryTab(sym),
          _buildDetailsTab(sym),
          _buildTimelineTab(),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  تبويب الملخص
  // ══════════════════════════════════════════════════════
  Widget _buildSummaryTab(String sym) {
    final area = widget.length * widget.width;
    final totalArea = area * widget.floors;
    final costPerM2 = totalArea > 0 ? _totalCost / totalArea : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // ── بطاقة المخطط المختار ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark]),
              borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Text(widget.selectedPlan.icon,
                style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.selectedPlan.name,
                    style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black)),
                Text('${widget.city} • ${widget.buildingUse}',
                    style:
                        GoogleFonts.cairo(fontSize: 11, color: Colors.black54)),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${widget.floors} دور',
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black)),
              Text('${area.toStringAsFixed(0)} م²',
                  style:
                      GoogleFonts.cairo(fontSize: 11, color: Colors.black54)),
            ]),
          ]),
        ).animate().fadeIn(),

        const SizedBox(height: 16),

        // ── إجمالي التكلفة ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
          child: Column(children: [
            Text('إجمالي التكاليف المتوقعة',
                style:
                    GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
            const SizedBox(height: 6),
            Text(_formatNum(_totalCost),
                style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accent)),
            Text('$sym • يمني',
                style:
                    GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('تكلفة المتر: ${_formatNum(costPerM2.toDouble())} $sym',
                  style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppTheme.textSub,
                      fontWeight: FontWeight.w600)),
            ]),
          ]),
        ).animate(delay: 100.ms).fadeIn().scale(),

        const SizedBox(height: 16),

        // ── توزيع التكاليف ──
        ...[
          _CostSummaryRow(
              icon: '🏗️',
              label: 'الهيكل والخرسانة',
              amount: _structureCost,
              total: _totalCost,
              sym: sym,
              color: const Color(0xFF64748B)),
          _CostSummaryRow(
              icon: '🔲',
              label: 'التشطيبات',
              amount: _finishCost,
              total: _totalCost,
              sym: sym,
              color: const Color(0xFF0891B2)),
          _CostSummaryRow(
              icon: '⚡',
              label: 'التمديدات والمرافق',
              amount: _mechCost,
              total: _totalCost,
              sym: sym,
              color: const Color(0xFFF59E0B)),
          _CostSummaryRow(
              icon: '👷',
              label: 'العمالة',
              amount: _laborCost,
              total: _totalCost,
              sym: sym,
              color: const Color(0xFF8B5CF6)),
        ]
            .asMap()
            .entries
            .map((e) => e.value
                .animate(delay: Duration(milliseconds: 150 + e.key * 80))
                .fadeIn()
                .slideX(begin: 0.1))
            .toList(),

        const SizedBox(height: 16),

        // ── ملاحظة ──
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.info.withOpacity(0.2))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ℹ️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    'هذا تقدير أولي بناءً على الأسعار المحلية الحالية. '
                    'قد تختلف التكاليف الفعلية حسب جودة المواد والمقاول المختار.',
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppTheme.textSub, height: 1.5))),
          ]),
        ).animate(delay: 500.ms).fadeIn(),

        const SizedBox(height: 16),

        // ── أزرار الإجراءات ──
        GoldenButton(
          label: 'حفظ التقرير كمشروع جديد',
          icon: '💾',
          onTap: _saveAsProject,
        ).animate(delay: 550.ms).fadeIn(),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════
  //  تبويب التفاصيل
  // ══════════════════════════════════════════════════════
  Widget _buildDetailsTab(String sym) {
    final categories = ['الكل', 'هيكل', 'تشطيب', 'تمديدات', 'عمالة'];
    final filtered = _selectedCategory == 'الكل'
        ? _items
        : _items.where((i) => i.category == _selectedCategory).toList();

    return Column(children: [
      // ── فلتر التصنيف ──
      Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) {
            final cat = categories[i];
            final isActive = cat == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: 250.ms,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: isActive ? AppTheme.accent : AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isActive ? AppTheme.accent : AppTheme.border)),
                child: Text(cat,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isActive ? Colors.black : AppTheme.textSub,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500)),
              ),
            );
          },
        ),
      ),

      // ── قائمة البنود ──
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) =>
              _CostItemCard(item: filtered[i], index: i, sym: sym),
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════
  //  تبويب الجدول الزمني
  // ══════════════════════════════════════════════════════
  Widget _buildTimelineTab() {
    final phases = _buildPhases();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: phases.length,
      itemBuilder: (ctx, i) => _PhaseCard(phase: phases[i], index: i),
    );
  }

  List<Map<String, dynamic>> _buildPhases() {
    final baseWeeks = widget.floors * 8 + 4;
    return [
      {
        'phase': 1,
        'name': 'أعمال الحفر والأساسات',
        'duration': '2-3 أسابيع',
        'icon': '⛏️',
        'color': const Color(0xFF92400E),
        'tasks': [
          'حفر الأساسات',
          'صب خرسانة العزل',
          'تسليح الأساسات',
          'صب الأساسات'
        ],
        'cost_pct': 0.12,
      },
      {
        'phase': 2,
        'name': 'الهيكل الخرساني',
        'duration': '${widget.floors * 3}-${widget.floors * 4} أسابيع',
        'icon': '🏗️',
        'color': const Color(0xFF475569),
        'tasks': [
          'أعمدة الدور الأول',
          'سقف الدور الأول',
          ...(widget.floors > 1
              ? ['أعمدة الأدوار العلوية', 'السقف النهائي']
              : [])
        ],
        'cost_pct': 0.38,
      },
      {
        'phase': 3,
        'name': 'مباني وتقسيمات',
        'duration': '3-4 أسابيع',
        'icon': '🧱',
        'color': const Color(0xFFDC2626),
        'tasks': [
          'بناء الجدران الخارجية',
          'الجدران الداخلية',
          'فتحات النوافذ والأبواب'
        ],
        'cost_pct': 0.15,
      },
      {
        'phase': 4,
        'name': 'التمديدات الكهربائية والسباكة',
        'duration': '2-3 أسابيع',
        'icon': '⚡',
        'color': const Color(0xFFF59E0B),
        'tasks': [
          'شبكة الكهرباء',
          'شبكة الماء والصرف',
          'تمديدات الإنترنت',
          'تمديدات المكيفات'
        ],
        'cost_pct': 0.12,
      },
      {
        'phase': 5,
        'name': 'اللياسة والتشطيب الخشن',
        'duration': '3-4 أسابيع',
        'icon': '🖌️',
        'color': const Color(0xFF7C3AED),
        'tasks': [
          'لياسة الجدران',
          'تسوية الأرضيات',
          'لياسة السقف',
          'المناور والشبابيك'
        ],
        'cost_pct': 0.10,
      },
      {
        'phase': 6,
        'name': 'التشطيب النهائي والديكور',
        'duration': '4-6 أسابيع',
        'icon': '✨',
        'color': const Color(0xFF0891B2),
        'tasks': [
          'بلاط الأرضيات',
          'دهانات جدران',
          'تركيب الأبواب والنوافذ',
          'نقاط الكهرباء',
          'صحيات الحمامات'
        ],
        'cost_pct': 0.13,
      },
    ];
  }

  // ── مساعدات ──────────────────────────────────────────
  String _formatNum(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }

  void _shareReport() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('جارٍ إعداد التقرير للمشاركة...', style: GoogleFonts.cairo()),
        backgroundColor: AppTheme.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveAsProject() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم حفظ المشروع بنجاح!',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════
//  صف ملخص التكلفة
// ════════════════════════════════════════════════════════
class _CostSummaryRow extends StatelessWidget {
  final String icon, label, sym;
  final double amount, total;
  final Color color;

  const _CostSummaryRow(
      {required this.icon,
      required this.label,
      required this.sym,
      required this.amount,
      required this.total,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (amount / total * 100).round() : 0;
    final formatted = amount >= 1000000
        ? '${(amount / 1000000).toStringAsFixed(2)}M'
        : '${(amount / 1000).toStringAsFixed(1)}K';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                    value: total > 0 ? amount / total : 0,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 4)),
          ],
        )),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$formatted $sym',
              style: GoogleFonts.cairo(
                  fontSize: 12, fontWeight: FontWeight.w800, color: color)),
          Text('$pct%',
              style:
                  GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════
//  بطاقة بند التكلفة
// ════════════════════════════════════════════════════════
class _CostItemCard extends StatelessWidget {
  final CostItem item;
  final int index;
  final String sym;

  const _CostItemCard(
      {required this.item, required this.index, required this.sym});

  @override
  Widget build(BuildContext context) {
    final totalFmt = item.total >= 1000000
        ? '${(item.total / 1000000).toStringAsFixed(2)}M'
        : '${(item.total / 1000).toStringAsFixed(1)}K';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(item.icon, style: const TextStyle(fontSize: 16)))),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name,
                style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            Text(
                '${item.quantity.toStringAsFixed(0)} ${item.unit} × '
                '${(item.unitPrice / 1000).toStringAsFixed(1)}K $sym',
                style:
                    GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('$totalFmt $sym',
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: item.color)),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: item.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(item.category,
                  style: GoogleFonts.cairo(fontSize: 9, color: item.color))),
        ]),
      ]),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn()
        .slideX(begin: 0.05);
  }
}

// ════════════════════════════════════════════════════════
//  بطاقة مرحلة البناء
// ════════════════════════════════════════════════════════
class _PhaseCard extends StatelessWidget {
  final Map<String, dynamic> phase;
  final int index;

  const _PhaseCard({required this.phase, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = phase['color'] as Color;
    final tasks = phase['tasks'] as List;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── خط الجدول الزمني ──
        Column(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2)),
              child: Center(
                  child: Text(phase['icon'] as String,
                      style: const TextStyle(fontSize: 18)))),
          if (index < 5)
            Container(width: 2, height: 80, color: color.withOpacity(0.2)),
        ]),
        const SizedBox(width: 14),
        // ── محتوى المرحلة ──
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text('المرحلة ${phase['phase']}: ${phase['name']}',
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary))),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(phase['duration'] as String,
                      style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 10),
            ...tasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(task as String,
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textSub)),
                  ]),
                )),
          ]),
        )),
      ],
    )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn()
        .slideX(begin: 0.1);
  }
}
