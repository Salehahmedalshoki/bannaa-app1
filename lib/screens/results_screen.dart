// ══════════════════════════════════════════════════════════
//  screens/results_screen.dart — مع الترجمة الكاملة
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

class ResultsScreen extends StatefulWidget {
  final Project project;
  const ResultsScreen({super.key, required this.project});
  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isExporting = false;

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
      sandPerM3:    s.prices['sand']   ?? 150,
      gravelPerM3:  s.prices['gravel'] ?? 180,
      steelPerKg:   s.prices['steel']  ?? 4,
      waterPerM3:   s.prices['water']  ?? 5,
      currencySymbol: s.currencyInfo.symbol,
    );
    final mixParams = MixParameters(
      cementKgPerM3: mix.cementKgPerM3, sandM3PerM3: mix.sandM3PerM3,
      gravelM3PerM3: mix.gravelM3PerM3, waterLPerM3: mix.waterLPerM3,
      steelKgPerM3:  mix.steelKgPerM3);
    final materials = widget.project.calculateMaterials(mix: mixParams, prices: prices);
    final totalCost = materials.fold(0.0, (sum, m) => sum + m.totalCost);
    final sym = s.currencyInfo.symbol;

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
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
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
                      : const Text('📤', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accent.withOpacity(0.25))),
              child: Row(children: [
                const Text('🏗️', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                Text(s.buildingCode.label, style: GoogleFonts.cairo(
                  fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('${t.tr('gradePrefix')} ${mix.grade}', style: GoogleFonts.cairo(
                  fontSize: 10, color: AppTheme.textSub)),
              ]),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.accent.withOpacity(0.2), AppTheme.accentDark.withOpacity(0.1)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.tr('totalConcreteVolumeTitle'), style: GoogleFonts.cairo(
                    fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: widget.project.totalVolume.toStringAsFixed(2),
                      style: GoogleFonts.cairo(fontSize: 30, fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary)),
                    TextSpan(text: '  ${t.tr('perM3')}', style: GoogleFonts.cairo(
                      fontSize: 14, color: AppTheme.textSub)),
                  ])),
                  Text(widget.project.name, style: GoogleFonts.cairo(
                    fontSize: 10, color: AppTheme.textMuted)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(t.tr('estimatedCostTitle'), style: GoogleFonts.cairo(
                    fontSize: 10, color: AppTheme.textSub)),
                  const SizedBox(height: 4),
                  Text(s.formatAmount(totalCost), style: GoogleFonts.cairo(
                    fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.success)),
                  Text(s.currencyInfo.nameAr, style: GoogleFonts.cairo(
                    fontSize: 9, color: AppTheme.textMuted)),
                ]),
              ]),
            ),
          ).animate().scale(begin: const Offset(0.95, 0.95),
            duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text(t.tr('materialDetails'), style: GoogleFonts.cairo(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textSub)),
              const Spacer(),
              Text('${materials.length} ${t.tr('materialsCount')} · ${s.buildingCode.short}',
                style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
            ]),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              itemCount: materials.length,
              itemBuilder: (_, i) => _MaterialCard(
                material: materials[i], delay: i * 80, currencySymbol: sym),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(children: [
              Expanded(child: GoldenButton(
                label: t.tr('save'), icon: '💾', outline: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(t.tr('savedSuccess2'),
                      style: GoogleFonts.cairo(color: Colors.white)),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating));
                })),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: GoldenButton(
                label: t.tr('generatePdfBtn'), icon: '📄',
                isLoading: _isExporting, onTap: _exportPdf)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final MaterialQuantity material;
  final int delay;
  final String currencySymbol;
  const _MaterialCard({required this.material, required this.delay, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DarkCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppTheme.accentGlow,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppTheme.accent.withOpacity(0.15))),
            child: Center(child: Text(material.icon, style: const TextStyle(fontSize: 19))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(material.name, style: GoogleFonts.cairo(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            Text(material.unit, style: GoogleFonts.cairo(
              fontSize: 10, color: AppTheme.textMuted)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              '${material.quantity.toStringAsFixed(material.quantity >= 100 ? 0 : 1)} ${_shortUnit(material.unit)}',
              style: GoogleFonts.cairo(
                fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text('${material.totalCost.toStringAsFixed(0)} $currencySymbol',
              style: GoogleFonts.cairo(
                fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    ).animate()
     .slideX(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 350.ms, curve: Curves.easeOut)
     .fadeIn(delay: Duration(milliseconds: delay));
  }

  String _shortUnit(String unit) {
    if (unit.contains('م³')) return 'م³';
    if (unit.contains('كيس')) return 'كيس';
    if (unit.contains('كغ')) return 'كغ';
    if (unit.contains('لتر')) return 'لتر';
    return unit;
  }
}
