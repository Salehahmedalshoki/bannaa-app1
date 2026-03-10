// ══════════════════════════════════════════════════════════
//  screens/calculator_screen.dart — نسخة مُحسَّنة v2
//  • نتائج فورية بدون زر "احسب"
//  • رسوم SVG توضيحية للأبعاد
//  • سجل آخر 10 حسابات
// ══════════════════════════════════════════════════════════


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: unused_import
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';

// ── نموذج سجل الحسابات ───────────────────────────────────
class _CalcRecord {
  final String title;
  final String value;
  final String unit;
  final String cost;
  final DateTime time;
  _CalcRecord({
    required this.title, required this.value,
    required this.unit, required this.cost,
  }) : time = DateTime.now();
}

// ── سجل عام مشترك بين التبويبات ─────────────────────────
final List<_CalcRecord> _history = [];

// ══════════════════════════════════════════════════════════
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context, t),
          _buildTabs(context, t),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _ConcreteTab(),
                _MaterialsTab(),
                _SteelTab(),
                _HistoryTab(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BannaaLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.tr('quickCalc'), style: GoogleFonts.cairo(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary)),
          Text(t.tr('quickCalcSub'), style: GoogleFonts.cairo(
            fontSize: 11, color: AppTheme.textMuted)),
        ])),
        // بادج سجل الحسابات
        if (_history.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accentGlow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('📋', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text('${_history.length}', style: GoogleFonts.cairo(
                fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700)),
            ]),
          ),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTabs(BuildContext context, BannaaLocalizations t) {
    final tabs  = [t.tr('tabConcrete'), t.tr('tabMaterials'), t.tr('tabSteel'), t.tr('calcHistory')];
    const icons = ['🧱', '📦', '⚙️', '📋'];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border)),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]),
          borderRadius: BorderRadius.circular(10)),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabs: List.generate(tabs.length, (i) => Tab(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(icons[i], style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(tabs[i], style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: _tabCtrl.index == i ? FontWeight.w700 : FontWeight.normal,
              color: _tabCtrl.index == i ? Colors.black : AppTheme.textMuted)),
          ]),
        )),
      ),
    ).animate(delay: 100.ms).fadeIn();
  }
}

// ══════════════════════════════════════════════════════════
//  تبويب 1 — حجم الخرسانة (نتائج فورية + SVG)
// ══════════════════════════════════════════════════════════
class _ConcreteTab extends StatefulWidget {
  const _ConcreteTab();
  @override
  State<_ConcreteTab> createState() => _ConcreteTabState();
}

class _ConcreteTabState extends State<_ConcreteTab> {
  final _lCtrl = TextEditingController();
  final _wCtrl = TextEditingController();
  final _hCtrl = TextEditingController();
  final _cCtrl = TextEditingController(text: '1');

  double get _l => double.tryParse(_lCtrl.text) ?? 0;
  double get _w => double.tryParse(_wCtrl.text) ?? 0;
  double get _h => double.tryParse(_hCtrl.text) ?? 0;
  int    get _c => int.tryParse(_cCtrl.text) ?? 1;
  double get _vol => (_l > 0 && _w > 0 && _h > 0) ? _l * _w * _h * _c : 0;

  @override
  void dispose() {
    _lCtrl.dispose(); _wCtrl.dispose();
    _hCtrl.dispose(); _cCtrl.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _saveToHistory(AppSettingsProvider s, MixRatios mix, BannaaLocalizations t) {
    if (_vol <= 0) return;
    final cost = _estimateCost(_vol, mix, s.prices);
    _history.insert(0, _CalcRecord(
      title: '${t.tr('tabConcrete')} — ${t.tr('concreteVolResult')}',
      value: _vol.toStringAsFixed(3),
      unit: t.tr('perM3'),
      cost: s.formatAmount(cost),
    ));
    if (_history.length > 10) _history.removeLast();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t.tr('savedToHistory'),
        style: GoogleFonts.cairo(color: Colors.black)),
      backgroundColor: AppTheme.accent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  double _estimateCost(double vol, MixRatios mix, Map<String, double> prices) {
    final bags   = (vol * mix.cementKgPerM3 / 50).ceil().toDouble();
    final sand   = vol * mix.sandM3PerM3;
    final gravel = vol * mix.gravelM3PerM3;
    final steel  = vol * mix.steelKgPerM3;
    return bags   * (prices['cement']  ?? 50)
         + sand   * (prices['sand']    ?? 150)
         + gravel * (prices['gravel']  ?? 180)
         + steel  * (prices['steel']   ?? 4);
  }

  @override
  Widget build(BuildContext context) {
    final t      = BannaaLocalizations.of(context);
    final s      = context.watch<AppSettingsProvider>();
    final mix    = s.currentMix;
    final prices = s.prices;
    final hasResult = _vol > 0;
    final cost = hasResult ? _estimateCost(_vol, mix, prices) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [

        // ── بادج الكود ──────────────────────────────────
        _CodeBadge(code: s.buildingCode.label, grade: mix.grade,
          gradeLabel: t.tr('gradeLabel')),
        const SizedBox(height: 14),

        // ── رسم SVG توضيحي ──────────────────────────────
        _ConcreteShapeSVG(l: _l, w: _w, h: _h),
        const SizedBox(height: 14),

        // ── حقول الإدخال ────────────────────────────────
        DarkCard(
          child: Column(children: [
            Row(children: [
              const Text('📐', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(t.tr('concreteDimTitle'), style: GoogleFonts.cairo(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
              const Spacer(),
              // مؤشر "حي"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: hasResult
                    ? AppTheme.success.withOpacity(0.12)
                    : AppTheme.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: hasResult ? AppTheme.success : AppTheme.textMuted,
                      shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(t.tr('liveResults'), style: GoogleFonts.cairo(
                    fontSize: 9,
                    color: hasResult ? AppTheme.success : AppTheme.textMuted,
                    fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _liveInput(_lCtrl, t.tr('length'), t.tr('meter'), _onChanged)),
              const SizedBox(width: 10),
              Expanded(child: _liveInput(_wCtrl, t.tr('width'), t.tr('meter'), _onChanged)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _liveInput(_hCtrl, t.tr('heightDepth'), t.tr('meter'), _onChanged)),
              const SizedBox(width: 10),
              Expanded(child: _liveInput(_cCtrl, t.tr('count'), t.tr('unitCount'), _onChanged, isInt: true)),
            ]),
          ]),
        ),
        const SizedBox(height: 10),

        // ── زر مسح ──────────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          GestureDetector(
            onTap: () {
              _lCtrl.clear(); _wCtrl.clear();
              _hCtrl.clear(); _cCtrl.text = '1';
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.refresh, color: AppTheme.textMuted, size: 14),
                const SizedBox(width: 4),
                Text(t.tr('cancel'), style: GoogleFonts.cairo(
                  fontSize: 11, color: AppTheme.textMuted)),
              ]),
            ),
          ),
        ]),

        // ── نتائج فورية ─────────────────────────────────
        AnimatedSize(
          duration: 350.ms,
          curve: Curves.easeOut,
          child: hasResult
            ? Column(children: [
                const SizedBox(height: 14),
                _LiveResultCard(
                  title: t.tr('concreteVolResult'),
                  mainValue: _vol.toStringAsFixed(3),
                  mainUnit: t.tr('perM3'),
                  costStr: s.formatAmount(cost),
                  costLabel: t.tr('costEstim'),
                  rows: [
                    _ResultRow('🪣', t.tr('cement'),
                      '${((_vol * mix.cementKgPerM3) / 50).ceil()} ${t.tr('bag50kg')}',
                      color: const Color(0xFFF97316)),
                    _ResultRow('🏖️', t.tr('sand'),
                      '${(_vol * mix.sandM3PerM3).toStringAsFixed(2)} ${t.tr('perM3')}',
                      color: const Color(0xFFF59E0B)),
                    _ResultRow('🪨', t.tr('gravel'),
                      '${(_vol * mix.gravelM3PerM3).toStringAsFixed(2)} ${t.tr('perM3')}',
                      color: AppTheme.textSub),
                    _ResultRow('⚙️', t.tr('steel'),
                      '${(_vol * mix.steelKgPerM3).toStringAsFixed(0)} ${t.tr('kg')}',
                      color: AppTheme.info),
                    _ResultRow('💧', t.tr('water'),
                      '${(_vol * mix.waterLPerM3).toStringAsFixed(0)} ${t.tr('liter')}',
                      color: const Color(0xFF38BDF8)),
                  ],
                  onSave: () => _saveToHistory(s, mix, t),
                  saveLabel: t.tr('calcHistory'),
                ).animate().scale(
                  begin: const Offset(0.96, 0.96), duration: 300.ms,
                  curve: Curves.easeOut),
              ])
            : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  تبويب 2 — المواد من الحجم
// ══════════════════════════════════════════════════════════
class _MaterialsTab extends StatefulWidget {
  const _MaterialsTab();
  @override
  State<_MaterialsTab> createState() => _MaterialsTabState();
}

class _MaterialsTabState extends State<_MaterialsTab> {
  final _volCtrl = TextEditingController();
  bool _showAdvanced = false;
  double? _cementOverride;
  double? _sandOverride;
  double? _gravelOverride;

  double get _vol => double.tryParse(_volCtrl.text) ?? 0;

  @override
  void dispose() { _volCtrl.dispose(); super.dispose(); }

  Map<String, double>? _compute(MixRatios mix, Map<String, double> prices) {
    final v = _vol;
    if (v <= 0) return null;
    final c = _cementOverride ?? mix.cementKgPerM3;
    final s = _sandOverride   ?? mix.sandM3PerM3;
    final g = _gravelOverride ?? mix.gravelM3PerM3;
    return {
      'vol':    v,
      'cement': (v * c / 50).ceilToDouble(),
      'sand':   double.parse((v * s).toStringAsFixed(2)),
      'gravel': double.parse((v * g).toStringAsFixed(2)),
      'water':  double.parse((v * mix.waterLPerM3).toStringAsFixed(0)),
      'steel':  double.parse((v * mix.steelKgPerM3).toStringAsFixed(1)),
      'cost':   (v * c / 50).ceilToDouble() * (prices['cement'] ?? 50)
              + (v * s) * (prices['sand']   ?? 150)
              + (v * g) * (prices['gravel'] ?? 180)
              + (v * mix.steelKgPerM3) * (prices['steel'] ?? 4),
    };
  }

  void _saveToHistory(AppSettingsProvider s, Map<String, double> res, BannaaLocalizations t) {
    _history.insert(0, _CalcRecord(
      title: '${t.tr('tabMaterials')} — ${t.tr('materialQty')}',
      value: res['vol']!.toStringAsFixed(2),
      unit: t.tr('perM3'),
      cost: s.formatAmount(res['cost']!),
    ));
    if (_history.length > 10) _history.removeLast();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t.tr('savedToHistory'),
        style: GoogleFonts.cairo(color: Colors.black)),
      backgroundColor: AppTheme.accent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t   = BannaaLocalizations.of(context);
    final s   = context.watch<AppSettingsProvider>();
    final mix = s.currentMix;
    final cR  = _cementOverride ?? mix.cementKgPerM3;
    final sR  = _sandOverride   ?? mix.sandM3PerM3;
    final gR  = _gravelOverride ?? mix.gravelM3PerM3;
    final res = _compute(mix, s.prices);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _CodeBadge(code: s.buildingCode.label, grade: mix.grade,
          gradeLabel: t.tr('gradeLabel')),
        const SizedBox(height: 14),
        DarkCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('📦', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(t.tr('enterConcreteVol'), style: GoogleFonts.cairo(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
              const Spacer(),
              _LiveDot(active: res != null),
            ]),
            const SizedBox(height: 14),
            _liveInput(_volCtrl, t.tr('totalConcreteVol'), t.tr('perM3'),
              () => setState(() {})),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _showAdvanced = !_showAdvanced),
              child: Row(children: [
                Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.accent, size: 18),
                const SizedBox(width: 6),
                Text(t.tr('customMixRatios'), style: GoogleFonts.cairo(
                  fontSize: 11, color: AppTheme.accent)),
              ]),
            ),
            if (_showAdvanced) ...[
              const SizedBox(height: 12),
              _sliderRow(context, '🪣 ${t.tr('cement')} (${t.tr('kg')}/${t.tr('perM3')})',
                cR, 250, 500, (v) => setState(() => _cementOverride = v)),
              _sliderRow(context, '🏖️ ${t.tr('sand')}', sR, 0.30, 0.65,
                (v) => setState(() => _sandOverride = v), divisions: 35),
              _sliderRow(context, '🪨 ${t.tr('gravel')}', gR, 0.50, 0.90,
                (v) => setState(() => _gravelOverride = v), divisions: 40),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => setState(() {
                  _cementOverride = null;
                  _sandOverride   = null;
                  _gravelOverride = null;
                }),
                child: Text('↺ ${t.tr('resetCodeRatios')} ${s.buildingCode.short}',
                  style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.accent))),
            ],
          ]),
        ),

        AnimatedSize(
          duration: 350.ms,
          curve: Curves.easeOut,
          child: res != null
            ? Column(children: [
                const SizedBox(height: 14),
                _LiveResultCard(
                  title: t.tr('materialQty'),
                  mainValue: res['vol']!.toStringAsFixed(2),
                  mainUnit: t.tr('perM3'),
                  costStr: s.formatAmount(res['cost']!),
                  costLabel: t.tr('costLabel'),
                  rows: [
                    _ResultRow('🪣', t.tr('cement'),
                      '${res['cement']!.toInt()} ${t.tr('bag50kg')}',
                      color: const Color(0xFFF97316)),
                    _ResultRow('🏖️', t.tr('sand'),
                      '${res['sand']!.toStringAsFixed(2)} ${t.tr('perM3')}',
                      color: const Color(0xFFF59E0B)),
                    _ResultRow('🪨', t.tr('gravel'),
                      '${res['gravel']!.toStringAsFixed(2)} ${t.tr('perM3')}',
                      color: AppTheme.textSub),
                    _ResultRow('💧', t.tr('water'),
                      '${res['water']!.toStringAsFixed(0)} ${t.tr('liter')}',
                      color: const Color(0xFF38BDF8)),
                    _ResultRow('⚙️', t.tr('steel'),
                      '${res['steel']!.toStringAsFixed(1)} ${t.tr('kg')}',
                      color: AppTheme.info),
                  ],
                  onSave: () => _saveToHistory(s, res, t),
                  saveLabel: t.tr('calcHistory'),
                ).animate().fadeIn(duration: 300.ms),
              ])
            : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  تبويب 3 — حاسبة الحديد
// ══════════════════════════════════════════════════════════
class _SteelTab extends StatefulWidget {
  const _SteelTab();
  @override
  State<_SteelTab> createState() => _SteelTabState();
}

class _SteelTabState extends State<_SteelTab> {
  final _lenCtrl   = TextEditingController();
  final _countCtrl = TextEditingController();
  int _diameter    = 12;

  static const Map<int, double> _kgPerMeter = {
    6:  0.222, 8:  0.395, 10: 0.617, 12: 0.888,
    14: 1.208, 16: 1.578, 18: 1.998, 20: 2.466,
    22: 2.984, 25: 3.853, 28: 4.834, 32: 6.313,
  };

  double get _len   => double.tryParse(_lenCtrl.text) ?? 0;
  int    get _count => int.tryParse(_countCtrl.text) ?? 0;
  double get _weight => (_len > 0 && _count > 0)
    ? _len * _count * (_kgPerMeter[_diameter] ?? 0.888) : 0;

  @override
  void dispose() { _lenCtrl.dispose(); _countCtrl.dispose(); super.dispose(); }

  void _saveToHistory(AppSettingsProvider s, BannaaLocalizations t) {
    if (_weight <= 0) return;
    final cost = _weight * (s.prices['steel'] ?? 4.0);
    _history.insert(0, _CalcRecord(
      title: '${t.tr('tabSteel')} — Ø$_diameter ${t.tr('mm')}',
      value: _weight.toStringAsFixed(2),
      unit: t.tr('kg'),
      cost: s.formatAmount(cost),
    ));
    if (_history.length > 10) _history.removeLast();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t.tr('savedToHistory'),
        style: GoogleFonts.cairo(color: Colors.black)),
      backgroundColor: AppTheme.accent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t          = BannaaLocalizations.of(context);
    final s          = context.watch<AppSettingsProvider>();
    final pricePerKg = s.prices['steel'] ?? 4.0;
    final sym        = s.currencyInfo.symbol;
    final hasResult  = _weight > 0;
    final cost       = _weight * pricePerKg;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [

        // ── رسم SVG حديد ───────────────────────────────
        _SteelBarSVG(diameter: _diameter, count: _count > 0 ? _count.clamp(1, 6) : 0),
        const SizedBox(height: 14),

        DarkCard(
          child: Column(children: [
            Row(children: [
              const Text('⚙️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(t.tr('steelCalcTitle'), style: GoogleFonts.cairo(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
              const Spacer(),
              _LiveDot(active: hasResult),
            ]),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerRight,
              child: Text(t.tr('diameter'), style: GoogleFonts.cairo(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: AppTheme.textSub))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7, runSpacing: 7,
              children: _kgPerMeter.keys.map((d) {
                final sel = d == _diameter;
                return GestureDetector(
                  onTap: () { setState(() => _diameter = d); HapticFeedback.selectionClick(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 52, height: 36,
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.accentGlow : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: sel ? AppTheme.accent : AppTheme.border,
                        width: sel ? 1.5 : 1)),
                    child: Center(child: Text('Ø$d',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: sel ? AppTheme.accent : AppTheme.textMuted,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.normal))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _liveInput(_lenCtrl, t.tr('barLength'), t.tr('meter'),
                () => setState(() {}))),
              const SizedBox(width: 10),
              Expanded(child: _liveInput(_countCtrl, t.tr('barCount'), t.tr('barUnit'),
                () => setState(() {}), isInt: true)),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppTheme.accent, size: 14),
                const SizedBox(width: 6),
                Expanded(child: Text(
                  'Ø$_diameter ${t.tr('mm')}  ←  ${t.tr('barWeightPerM')}: ${_kgPerMeter[_diameter]} ${t.tr('kg')}/${t.tr('meter')}',
                  style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSub))),
              ]),
            ),
          ]),
        ),

        AnimatedSize(
          duration: 350.ms,
          curve: Curves.easeOut,
          child: hasResult
            ? Column(children: [
                const SizedBox(height: 14),
                _LiveResultCard(
                  title: t.tr('steelResult'),
                  mainValue: _weight.toStringAsFixed(2),
                  mainUnit: t.tr('kg'),
                  costStr: '${cost.toStringAsFixed(0)} $sym',
                  costLabel: t.tr('costEstim'),
                  rows: [
                    _ResultRow('📏', t.tr('selectedDiameter'), 'Ø$_diameter ${t.tr('mm')}',
                      color: AppTheme.accent),
                    _ResultRow('⚖️', t.tr('barWeightPerM'),
                      '${_kgPerMeter[_diameter]} ${t.tr('kg')}/${t.tr('meter')}',
                      color: AppTheme.info),
                    _ResultRow('🔢', t.tr('barCount'), '$_count ${t.tr('barUnit')}',
                      color: AppTheme.textSub),
                    _ResultRow('📐', t.tr('totalLength'),
                      '${(_len * _count).toStringAsFixed(1)} ${t.tr('meter')}',
                      color: AppTheme.textSub),
                  ],
                  onSave: () => _saveToHistory(s, t),
                  saveLabel: t.tr('calcHistory'),
                ).animate().fadeIn(duration: 300.ms),
              ])
            : const SizedBox.shrink(),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  تبويب 4 — سجل الحسابات
// ══════════════════════════════════════════════════════════
class _HistoryTab extends StatefulWidget {
  const _HistoryTab();
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return _history.isEmpty
      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(t.tr('noHistory'), style: GoogleFonts.cairo(
            fontSize: 14, color: AppTheme.textMuted)),
        ]))
      : Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Text('${t.tr('calcHistory')} (${_history.length})',
                style: GoogleFonts.cairo(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: AppTheme.textSub)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _history.clear()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.danger.withOpacity(0.2))),
                  child: Text(t.tr('clearHistory'), style: GoogleFonts.cairo(
                    fontSize: 10, color: AppTheme.danger, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _history.length,
              itemBuilder: (_, i) {
                final rec = _history[i];
                final mins = DateTime.now().difference(rec.time).inMinutes;
                final timeStr = t.trTime(mins);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border)),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGlow,
                        borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(
                        i == 0 ? '🥇' : i == 1 ? '🥈' : '📊',
                        style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec.title, style: GoogleFonts.cairo(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Text(rec.cost, style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.success,
                          fontWeight: FontWeight.w600)),
                      ],
                    )),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${rec.value} ${rec.unit}', style: GoogleFonts.cairo(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: AppTheme.accent)),
                      const SizedBox(height: 2),
                      Text(timeStr, style: GoogleFonts.cairo(
                        fontSize: 9, color: AppTheme.textMuted)),
                    ]),
                  ]),
                ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideX(
                  begin: 0.05, curve: Curves.easeOut);
              },
            ),
          ),
        ]);
  }
}

// ══════════════════════════════════════════════════════════
//  SVG — رسم مكعب الخرسانة
// ══════════════════════════════════════════════════════════
class _ConcreteShapeSVG extends StatelessWidget {
  final double l, w, h;
  const _ConcreteShapeSVG({required this.l, required this.w, required this.h});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border)),
      child: CustomPaint(
        painter: _CubePainter(l: l, w: w, h: h, t: t),
        size: const Size(double.infinity, 130),
      ),
    );
  }
}

class _CubePainter extends CustomPainter {
  final double l, w, h;
  final BannaaLocalizations t;
  _CubePainter({required this.l, required this.w, required this.h, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 8;
    const bw = 90.0;
    const bh = 50.0;
    const sk = 28.0; // skew for isometric

    final face  = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
    final top   = Paint()..color = const Color(0xFF243044)..style = PaintingStyle.fill;
    final side  = Paint()..color = const Color(0xFF162032)..style = PaintingStyle.fill;
    final edge  = Paint()
      ..color = AppTheme.accent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final dimLine = Paint()
      ..color = AppTheme.accent.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final textStyle = TextStyle(
      color: AppTheme.accent, fontSize: 9.5,
      fontWeight: FontWeight.w700,
      fontFamily: 'Cairo',
    );
    final muted = TextStyle(
      color: AppTheme.textMuted, fontSize: 8.5,
      fontFamily: 'Cairo',
    );

    // حساب النقاط الثمانية للمكعب
    final tfl = Offset(cx - bw/2,       cy - bh/2 - sk/2);
    final tfr = Offset(cx + bw/2,       cy - bh/2 - sk/2);
    final tbr = Offset(cx + bw/2 + sk,  cy - bh/2 + sk/2);
    final tbl = Offset(cx - bw/2 + sk,  cy - bh/2 + sk/2);
    final bfl = Offset(cx - bw/2,       cy + bh/2 - sk/2);
    final bfr = Offset(cx + bw/2,       cy + bh/2 - sk/2);
    final bbr = Offset(cx + bw/2 + sk,  cy + bh/2 + sk/2);

    // وجه أمامي
    canvas.drawPath(Path()
      ..moveTo(tfl.dx, tfl.dy) ..lineTo(tfr.dx, tfr.dy)
      ..lineTo(bfr.dx, bfr.dy) ..lineTo(bfl.dx, bfl.dy) ..close(), face);
    // وجه علوي
    canvas.drawPath(Path()
      ..moveTo(tfl.dx, tfl.dy) ..lineTo(tfr.dx, tfr.dy)
      ..lineTo(tbr.dx, tbr.dy) ..lineTo(tbl.dx, tbl.dy) ..close(), top);
    // وجه جانبي
    canvas.drawPath(Path()
      ..moveTo(tfr.dx, tfr.dy) ..lineTo(tbr.dx, tbr.dy)
      ..lineTo(bbr.dx, bbr.dy) ..lineTo(bfr.dx, bfr.dy) ..close(), side);

    // حواف
    for (final pts in [
      [tfl, tfr], [tfr, tbr], [tbl, tfl], [tbl, tbr],
      [tfl, bfl], [tfr, bfr], [tbr, bbr],
      [bfl, bfr], [bfr, bbr],
    ]) canvas.drawLine(pts[0], pts[1], edge);

    // خطوط الأبعاد
    void drawDim(Offset a, Offset b, String label, {bool above = false}) {
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final off = above ? const Offset(0, -10) : const Offset(0, 10);
      canvas.drawLine(a, b, dimLine);
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, mid + off - Offset(tp.width / 2, tp.height / 2));
    }

    // عرض
    final wLabel = w > 0 ? '${w.toStringAsFixed(1)} م' : t.tr('width');
    drawDim(bfl - const Offset(0, 6), bfr - const Offset(0, 6), wLabel, above: false);

    // ارتفاع
    final hLabel = h > 0 ? '${h.toStringAsFixed(1)} م' : t.tr('height');
    final hMid = Offset(bfr.dx + 14, (tfr.dy + bfr.dy) / 2);
    canvas.drawLine(bfr + const Offset(8, 0), tfr + const Offset(8, 0), dimLine);
    final hTp = TextPainter(
      text: TextSpan(text: hLabel, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    hTp.paint(canvas, hMid + Offset(2, -hTp.height / 2));

    // طول (skew)
    final lLabel = l > 0 ? '${l.toStringAsFixed(1)} م' : t.tr('length');
    drawDim(tfr + const Offset(3, -3), tbr + const Offset(3, -3), lLabel, above: true);

    // حجم مركزي
    if (l > 0 && w > 0 && h > 0) {
      final vol = l * w * h;
      final volTp = TextPainter(
        text: TextSpan(text: '${vol.toStringAsFixed(2)} م³', style: TextStyle(
          color: AppTheme.accent.withOpacity(0.9), fontSize: 11,
          fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
        textDirection: TextDirection.ltr,
      )..layout();
      volTp.paint(canvas,
        Offset(cx - volTp.width / 2, cy - volTp.height / 2 - 2));
    } else {
      // وسم توضيحي
      final hint = TextPainter(
        text: TextSpan(text: '📐 ${t.tr('dimGuide')}', style: muted),
        textDirection: TextDirection.ltr,
      )..layout();
      hint.paint(canvas, Offset(cx - hint.width / 2, cy - hint.height / 2));
    }
  }

  @override
  bool shouldRepaint(_CubePainter old) =>
    old.l != l || old.w != w || old.h != h;
}

// ══════════════════════════════════════════════════════════
//  SVG — رسم قضبان الحديد
// ══════════════════════════════════════════════════════════
class _SteelBarSVG extends StatelessWidget {
  final int diameter;
  final int count;
  const _SteelBarSVG({required this.diameter, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border)),
      child: CustomPaint(
        painter: _SteelPainter(diameter: diameter, count: count),
        size: const Size(double.infinity, 90),
      ),
    );
  }
}

class _SteelPainter extends CustomPainter {
  final int diameter, count;
  _SteelPainter({required this.diameter, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    if (count == 0) {
      // رسم خلفي فارغ
      final p = Paint()..color = AppTheme.border.withOpacity(0.4)..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final r = Rect.fromLTWH(20, 30, size.width - 40, 30);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), p);
      final tp = TextPainter(
        text: TextSpan(text: 'Ø — mm', style: TextStyle(
          color: AppTheme.textMuted, fontSize: 11, fontFamily: 'Cairo')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width/2 - tp.width/2, 42));
      return;
    }

    final barR  = (diameter / 2.0).clamp(4.0, 16.0);
    final n     = count.clamp(1, 6);
    final total = n * barR * 2 + (n - 1) * 8.0;
    var startX  = (size.width - total) / 2;
    final cy    = size.height / 2;

    for (int i = 0; i < n; i++) {
      final cx = startX + barR;
      // جسم القضيب
      final barPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF64748B),
            const Color(0xFF94A3B8),
            const Color(0xFF64748B),
          ],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: barR));
      canvas.drawCircle(Offset(cx, cy), barR, barPaint);

      // حلقة الحجم
      canvas.drawCircle(Offset(cx, cy), barR, Paint()
        ..color = AppTheme.accent.withOpacity(0.4)
        ..style = PaintingStyle.stroke ..strokeWidth = 1.2);

      // المقاس
      if (i == 0) {
        final tp = TextPainter(
          text: TextSpan(text: 'Ø$diameter', style: TextStyle(
            color: AppTheme.accent, fontSize: 8,
            fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width/2, cy + barR + 4));
      }
      startX += barR * 2 + 8;
    }
  }

  @override
  bool shouldRepaint(_SteelPainter old) =>
    old.diameter != diameter || old.count != count;
}

// ══════════════════════════════════════════════════════════
//  بطاقة نتائج مباشرة محسّنة
// ══════════════════════════════════════════════════════════
class _ResultRow {
  final String emoji, label, value;
  final Color color;
  _ResultRow(this.emoji, this.label, this.value, {required this.color});
}

class _LiveResultCard extends StatelessWidget {
  final String title, mainValue, mainUnit, costStr, costLabel, saveLabel;
  final List<_ResultRow> rows;
  final VoidCallback onSave;

  const _LiveResultCard({
    required this.title, required this.mainValue, required this.mainUnit,
    required this.costStr, required this.costLabel,
    required this.rows, required this.onSave, required this.saveLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withOpacity(0.16),
            AppTheme.accentDark.withOpacity(0.06),
          ]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
      child: Column(children: [
        // رأس البطاقة
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.cairo(
                fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              RichText(text: TextSpan(children: [
                TextSpan(text: mainValue, style: GoogleFonts.cairo(
                  fontSize: 30, fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary)),
                TextSpan(text: '  $mainUnit', style: GoogleFonts.cairo(
                  fontSize: 12, color: AppTheme.textSub)),
              ])),
            ]),
            const Spacer(),
            // تكلفة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.success.withOpacity(0.25))),
              child: Column(children: [
                Text(costLabel, style: GoogleFonts.cairo(
                  fontSize: 9, color: AppTheme.success)),
                Text(costStr, style: GoogleFonts.cairo(
                  fontSize: 13, color: AppTheme.success,
                  fontWeight: FontWeight.w800)),
              ]),
            ),
          ]),
        ),
        // صفوف النتائج
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark.withOpacity(0.5),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18))),
          child: Column(children: [
            ...rows.map((row) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(
                  color: AppTheme.border.withOpacity(0.4)))),
              child: Row(children: [
                Text(row.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(child: Text(row.label, style: GoogleFonts.cairo(
                  fontSize: 12, color: AppTheme.textSub))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: row.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: row.color.withOpacity(0.25))),
                  child: Text(row.value, style: GoogleFonts.cairo(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: row.color)),
                ),
              ]),
            )),
            // زر حفظ في السجل
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border.withOpacity(0.4)))),
              child: TextButton(
                onPressed: onSave,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.bookmark_add_outlined,
                    color: AppTheme.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(saveLabel, style: GoogleFonts.cairo(
                    fontSize: 12, color: AppTheme.accent,
                    fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  ودجات مشتركة
// ══════════════════════════════════════════════════════════
class _LiveDot extends StatelessWidget {
  final bool active;
  const _LiveDot({required this.active});
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active
          ? AppTheme.success.withOpacity(0.12)
          : AppTheme.border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: active ? AppTheme.success : AppTheme.textMuted,
            shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(t.tr('liveResults'), style: GoogleFonts.cairo(
          fontSize: 9,
          color: active ? AppTheme.success : AppTheme.textMuted,
          fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  final String code, grade, gradeLabel;
  const _CodeBadge({required this.code, required this.grade, required this.gradeLabel});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppTheme.accentGlow,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
    child: Row(children: [
      const Text('🏗️', style: TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Expanded(child: Text(code, style: GoogleFonts.cairo(
        fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600))),
      Text('$gradeLabel: $grade', style: GoogleFonts.cairo(
        fontSize: 10, color: AppTheme.textSub)),
    ]),
  );
}

Widget _liveInput(TextEditingController ctrl, String label, String suffix,
    VoidCallback onChanged, {bool isInt = false}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: GoogleFonts.cairo(
      fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSub)),
    const SizedBox(height: 5),
    TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          isInt ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
        ),
      ],
      onChanged: (val) {
        // منع النقطتين المتتاليتين في الأرقام العشرية
        if (!isInt && val.contains('..')) {
          ctrl.text = val.replaceAll('..', '.');
          ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
        }
        onChanged();
      },
      style: GoogleFonts.cairo(
        color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        suffixText: suffix,
        suffixStyle: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        errorStyle: GoogleFonts.cairo(fontSize: 9, color: AppTheme.danger),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        if (v == null || v.isEmpty) return null; // الحقل اختياري في الحاسبة
        if (isInt) {
          final n = int.tryParse(v);
          if (n == null || n <= 0) return '> 0';
        } else {
          final n = double.tryParse(v);
          if (n == null || n < 0) return '> 0';
          if (n > 9999) return '< 9999';
        }
        return null;
      },
    ),
  ]);
}

Widget _sliderRow(BuildContext context, String label, double val,
    double min, double max, ValueChanged<double> onChange, {int divisions = 20}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSub)),
      Text(val.toStringAsFixed(val >= 10 ? 0 : 2), style: GoogleFonts.cairo(
        fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700)),
    ]),
    SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppTheme.accent,
        inactiveTrackColor: AppTheme.border,
        thumbColor: AppTheme.accent,
        overlayColor: AppTheme.accentGlow,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7)),
      child: Slider(
        value: val.clamp(min, max), min: min, max: max,
        divisions: divisions, onChanged: onChange),
    ),
  ]);
}
