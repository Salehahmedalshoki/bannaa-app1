// ══════════════════════════════════════════════════════════
//  screens/results_screen.dart — المرحلة الثانية
//  ✅ رسم بياني دائري تفاعلي (CustomPainter)
//  ✅ أرقام تتحرك تصاعدياً عند الظهور
//  ✅ ملخص تنفيذي في الأعلى
//  ✅ مقارنة بصرية بين المكوّنات بأشرطة تقدم
//  ✅ اختيار شريحة من الدائرة يُظهر التفاصيل
// ══════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/project_model.dart';
import '../providers/app_settings_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';

class ResultsScreen extends StatefulWidget {
  final Project project;
  const ResultsScreen({super.key, required this.project});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  // ── أنيميشن الرسم الدائري ──────────────────────────────
  late final AnimationController _pieCtrl;
  late final Animation<double> _pieAnim;

  // ── أنيميشن الأرقام ────────────────────────────────────
  late final AnimationController _numCtrl;
  late final Animation<double> _numAnim;

  bool _isExporting = false;
  int _selectedSlice = -1; // الشريحة المختارة في الدائرة

  @override
  void initState() {
    super.initState();

    _pieCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _pieAnim = CurvedAnimation(parent: _pieCtrl, curve: Curves.easeOutCubic);

    _numCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _numAnim = CurvedAnimation(parent: _numCtrl, curve: Curves.easeOutExpo);

    // تشغيل الأنيميشن بعد البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pieCtrl.forward();
      _numCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pieCtrl.dispose();
    _numCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportPdf() async {
    final t = BannaaLocalizations.of(context);
    setState(() => _isExporting = true);
    try {
      await PdfService.generateAndShare(widget.project);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.tr('pdfError'), style: GoogleFonts.cairo()),
            backgroundColor: AppTheme.danger));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
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
        steelKgPerM3: mix.steelKgPerM3);
    final materials =
        widget.project.calculateMaterials(mix: mixParams, prices: prices);
    final totalCost = materials.fold(0.0, (sum, m) => sum + m.totalCost);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // ── شريط العنوان ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: ScreenHeader(
              title: t.tr('resultsTitle'),
              actions: [
                GestureDetector(
                  onTap: _exportPdf,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border)),
                    child: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.accent))
                        : const Text('📤', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── 1. الملخص التنفيذي ──
                _buildSummaryCard(t, s, totalCost),
                const SizedBox(height: 16),

                // ── 2. الرسم البياني الدائري ──
                _buildPieChartSection(materials, totalCost, t),
                const SizedBox(height: 16),

                // ── 3. مقارنة بصرية بأشرطة ──
                _buildBarsSection(materials, totalCost, t),
                const SizedBox(height: 16),

                // ── 4. تفاصيل المواد ──
                _buildMaterialsList(materials, s, t),
                const SizedBox(height: 16),

                // ── 5. أزرار الحفظ والتصدير ──
                _buildActionButtons(t),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════
  //  1. الملخص التنفيذي
  // ════════════════════════════════════════════════════════
  Widget _buildSummaryCard(
      BannaaLocalizations t, AppSettingsProvider s, double totalCost) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppTheme.accent.withOpacity(0.18),
            AppTheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // بادج نوع المبنى والكود
        Row(children: [
          Text(widget.project.buildingType.emoji,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
              child: Text('${widget.project.name} • ${s.buildingCode.short}',
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.success.withOpacity(0.25))),
            child: Text(t.tr('completed'),
                style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),

        // الأرقام الكبيرة
        Row(children: [
          Expanded(
              child: _AnimatedStat(
            animation: _numAnim,
            value: totalCost,
            label: t.tr('estimatedCostTitle'),
            unit: s.currencyInfo.symbol,
            color: AppTheme.accent,
            large: true,
          )),
          Container(width: 1, height: 55, color: AppTheme.border),
          Expanded(
              child: _AnimatedStat(
            animation: _numAnim,
            value: widget.project.totalVolume,
            label: t.tr('totalConcreteVolumeTitle'),
            unit: 'م³',
            color: AppTheme.info,
            large: true,
            decimals: 2,
          )),
          Container(width: 1, height: 55, color: AppTheme.border),
          Expanded(
              child: _AnimatedStat(
            animation: _numAnim,
            value: widget.project.components
                .fold(0.0, (s, c) => s + c.count)
                .toDouble(),
            label: t.tr('components'),
            unit: '',
            color: AppTheme.success,
            large: true,
            decimals: 0,
          )),
        ]),
      ]),
    ).animate().scale(
        begin: const Offset(0.96, 0.96),
        end: const Offset(1, 1),
        duration: 400.ms,
        curve: Curves.easeOut);
  }

  // ════════════════════════════════════════════════════════
  //  2. الرسم البياني الدائري
  // ════════════════════════════════════════════════════════
  Widget _buildPieChartSection(List<MaterialQuantity> materials,
      double totalCost, BannaaLocalizations t) {
    return DarkCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📊 ${t.tr('costDistribution')}',
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // الرسم الدائري
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1,
              child: GestureDetector(
                onTapUp: (details) =>
                    _handlePieTap(details, materials, totalCost),
                child: AnimatedBuilder(
                  animation: _pieAnim,
                  builder: (_, __) => CustomPaint(
                    painter: _PieChartPainter(
                      materials: materials,
                      totalCost: totalCost,
                      progress: _pieAnim.value,
                      selectedIndex: _selectedSlice,
                    ),
                    child: Center(child: _buildPieCenter(materials, totalCost)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // المفتاح التفاعلي
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: materials.asMap().entries.map((e) {
                final i = e.key;
                final m = e.value;
                final pct = totalCost > 0 ? m.totalCost / totalCost * 100 : 0.0;
                final isSelected = _selectedSlice == i;
                final color = _pieColor(i);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedSlice = isSelected ? -1 : i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isSelected
                              ? color.withOpacity(0.3)
                              : Colors.transparent),
                    ),
                    child: Row(children: [
                      Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.icon + ' ' + m.name,
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSub)),
                          Text('${pct.toStringAsFixed(1)}%',
                              style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                        ],
                      )),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
        ]),

        // تفاصيل الشريحة المختارة
        if (_selectedSlice >= 0 && _selectedSlice < materials.length) ...[
          const SizedBox(height: 14),
          _buildSliceDetail(
              materials[_selectedSlice], _pieColor(_selectedSlice), totalCost),
        ],
      ]),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildPieCenter(List<MaterialQuantity> materials, double totalCost) {
    if (_selectedSlice >= 0 && _selectedSlice < materials.length) {
      final m = materials[_selectedSlice];
      final pct = totalCost > 0
          ? (m.totalCost / totalCost * 100).toStringAsFixed(1)
          : '0';
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Text(m.icon, style: const TextStyle(fontSize: 18)),
        Text('$pct%',
            style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary)),
      ]);
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(
        animation: _numAnim,
        builder: (_, __) {
          final v = widget.project.totalVolume * _numAnim.value;
          return Text(v.toStringAsFixed(1),
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.accent));
        },
      ),
      Text('م³',
          style: GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
    ]);
  }

  Widget _buildSliceDetail(MaterialQuantity m, Color color, double totalCost) {
    final pct = totalCost > 0
        ? (m.totalCost / totalCost * 100).toStringAsFixed(1)
        : '0';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Text(m.icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.name,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            Text('${m.quantity.toStringAsFixed(1)} ${_shortUnit(m.unit)}',
                style:
                    GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${m.totalCost.toStringAsFixed(0)}',
              style: GoogleFonts.cairo(
                  fontSize: 16, fontWeight: FontWeight.w900, color: color)),
          Text('$pct% من الإجمالي',
              style:
                  GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }

  void _handlePieTap(TapUpDetails details, List<MaterialQuantity> materials,
      double totalCost) {
    // حساب زاوية النقرة
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final center = Offset(size.width / 2, size.width / 2);
    final touch = details.localPosition - center;
    double angle = atan2(touch.dy, touch.dx) + pi / 2;
    if (angle < 0) angle += 2 * pi;

    double sweep = 0;
    for (int i = 0; i < materials.length; i++) {
      final slice =
          totalCost > 0 ? materials[i].totalCost / totalCost * 2 * pi : 0.0;
      sweep += slice;
      if (angle <= sweep) {
        HapticFeedback.selectionClick();
        setState(() => _selectedSlice = _selectedSlice == i ? -1 : i);
        return;
      }
    }
  }

  // ════════════════════════════════════════════════════════
  //  3. أشرطة المقارنة البصرية
  // ════════════════════════════════════════════════════════
  Widget _buildBarsSection(List<MaterialQuantity> materials, double totalCost,
      BannaaLocalizations t) {
    return DarkCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📊 ${t.tr('materialComparison')}',
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 14),
        ...materials.asMap().entries.map((e) {
          final i = e.key;
          final m = e.value;
          final pct = totalCost > 0 ? m.totalCost / totalCost : 0.0;
          final color = _pieColor(i);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(children: [
              Row(children: [
                Text(m.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(m.name,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSub)),
                const Spacer(),
                AnimatedBuilder(
                  animation: _numAnim,
                  builder: (_, __) {
                    final animated = m.totalCost * _numAnim.value;
                    return Text('${animated.toStringAsFixed(0)}',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: color));
                  },
                ),
                Text(' • ${(pct * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.cairo(
                        fontSize: 10, color: AppTheme.textMuted)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedBuilder(
                  animation: _pieAnim,
                  builder: (_, __) => LinearProgressIndicator(
                    value: pct * _pieAnim.value,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 5,
                  ),
                ),
              ),
            ]),
          );
        }),
      ]),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  // ════════════════════════════════════════════════════════
  //  4. قائمة المواد التفصيلية
  // ════════════════════════════════════════════════════════
  Widget _buildMaterialsList(List<MaterialQuantity> materials,
      AppSettingsProvider s, BannaaLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(t.tr('materialDetails'),
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSub)),
          const Spacer(),
          Text(
              '${materials.length} ${t.tr('materialsCount')} · ${s.buildingCode.short}',
              style:
                  GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ),
      ...materials.asMap().entries.map((e) {
        final i = e.key;
        final m = e.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DarkCard(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: _pieColor(i).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: _pieColor(i).withOpacity(0.2))),
                child: Center(
                    child: Text(m.icon, style: const TextStyle(fontSize: 19))),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name,
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  Text(m.unit,
                      style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.textMuted)),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                AnimatedBuilder(
                  animation: _numAnim,
                  builder: (_, __) {
                    final animated = m.quantity * _numAnim.value;
                    final qty = m.quantity >= 100
                        ? animated.toStringAsFixed(0)
                        : animated.toStringAsFixed(1);
                    return Text('$qty ${_shortUnit(m.unit)}',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary));
                  },
                ),
                const SizedBox(height: 2),
                AnimatedBuilder(
                  animation: _numAnim,
                  builder: (_, __) {
                    final animated = m.totalCost * _numAnim.value;
                    return Text(
                        '${animated.toStringAsFixed(0)} ${s.currencyInfo.symbol}',
                        style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: _pieColor(i),
                            fontWeight: FontWeight.w600));
                  },
                ),
              ]),
            ]),
          ),
        )
            .animate()
            .slideX(
                begin: 0.2,
                end: 0,
                delay: Duration(milliseconds: i * 80),
                duration: 350.ms,
                curve: Curves.easeOut)
            .fadeIn(delay: Duration(milliseconds: i * 80));
      }),
    ]);
  }

  // ════════════════════════════════════════════════════════
  //  5. أزرار الإجراءات
  // ════════════════════════════════════════════════════════
  Widget _buildActionButtons(BannaaLocalizations t) {
    return Row(children: [
      Expanded(
          child: GoldenButton(
              label: t.tr('save'),
              icon: '💾',
              outline: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(t.tr('savedSuccess2'),
                        style: GoogleFonts.cairo(color: Colors.white)),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating));
              })),
      const SizedBox(width: 10),
      Expanded(
          flex: 2,
          child: GoldenButton(
              label: t.tr('generatePdfBtn'),
              icon: '📄',
              isLoading: _isExporting,
              onTap: _exportPdf)),
    ]);
  }

  // ── مساعدات ──────────────────────────────────────────
  static const _pieColors = [
    AppTheme.accent,
    AppTheme.info,
    AppTheme.success,
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  Color _pieColor(int i) => _pieColors[i % _pieColors.length];

  String _shortUnit(String unit) {
    if (unit.contains('م³')) return 'م³';
    if (unit.contains('كيس')) return 'كيس';
    if (unit.contains('كغ')) return 'كغ';
    if (unit.contains('لتر')) return 'لتر';
    return unit;
  }
}

// ════════════════════════════════════════════════════════
//  CustomPainter — الرسم الدائري
// ════════════════════════════════════════════════════════
class _PieChartPainter extends CustomPainter {
  final List<MaterialQuantity> materials;
  final double totalCost;
  final double progress; // 0→1 (أنيميشن)
  final int selectedIndex;

  _PieChartPainter({
    required this.materials,
    required this.totalCost,
    required this.progress,
    required this.selectedIndex,
  });

  static const _colors = [
    AppTheme.accent,
    AppTheme.info,
    AppTheme.success,
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final holeRadius = radius * 0.52;

    double startAngle = -pi / 2;

    for (int i = 0; i < materials.length; i++) {
      if (totalCost <= 0) continue;
      final sweep = (materials[i].totalCost / totalCost) * 2 * pi * progress;
      final isSelected = selectedIndex == i;
      final color = _colors[i % _colors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // تكبير الشريحة المختارة
      Offset sliceCenter = center;
      if (isSelected) {
        final midAngle = startAngle + sweep / 2;
        sliceCenter = center + Offset(cos(midAngle) * 8, sin(midAngle) * 8);
      }

      final path = Path();
      path.moveTo(sliceCenter.dx, sliceCenter.dy);
      path.arcTo(Rect.fromCircle(center: sliceCenter, radius: radius),
          startAngle, sweep, false);
      path.close();
      canvas.drawPath(path, paint);

      // فراغ بين الشرائح
      final separatorPaint = Paint()
        ..color = const Color(0xFF0A0F1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawPath(path, separatorPaint);

      startAngle += sweep;
    }

    // ثقب الدونت
    final holePaint = Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, holeRadius, holePaint);
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      old.progress != progress || old.selectedIndex != selectedIndex;
}

// ════════════════════════════════════════════════════════
//  ودجة: رقم متحرك تصاعدياً
// ════════════════════════════════════════════════════════
class _AnimatedStat extends StatelessWidget {
  final Animation<double> animation;
  final double value;
  final String label;
  final String unit;
  final Color color;
  final bool large;
  final int decimals;

  const _AnimatedStat({
    required this.animation,
    required this.value,
    required this.label,
    required this.unit,
    required this.color,
    this.large = false,
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            final animated = value * animation.value;
            final formatted = decimals > 0
                ? animated.toStringAsFixed(decimals)
                : animated.toStringAsFixed(0);
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                unit.isEmpty ? formatted : '$formatted $unit',
                style: GoogleFonts.cairo(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: large ? 18 : 14),
              ),
            );
          },
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 10),
        ),
      ]),
    );
  }
}
