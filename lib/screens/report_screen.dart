// ══════════════════════════════════════════════════════════
//  screens/report_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة:
//  ✅ #1  _exportPdf: guard + try/finally — لا تجميد عند الفشل
//  ✅ #2  _buildTextReport تستقبل mats — لا حساب مزدوج
//  ✅ #3  الإجمالي في التقرير النصي يستخدم أسعار المستخدم
//  ✅ #4  _fmtDate تحترم locale التطبيق
//  ✅ #5  withOpacity المُهمَلة → withValues(alpha:) (3 مواضع)
//  ✅ #6  أزرار الأسفل معطَّلة أثناء _isExporting
// ══════════════════════════════════════════════════════════

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

class ReportScreen extends StatefulWidget {
  final Project project;
  const ReportScreen({super.key, required this.project});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isExporting = false;
  bool _includeComponents = true;
  bool _includePrices = true;
  bool _includeNotes = true;

  Future<void> _exportPdf() async {
    if (_isExporting) return; // ✅ guard ضد الضغط المتكرر
    setState(() => _isExporting = true);
    try {
      await PdfService.generateAndShare(widget.project);
    } catch (_) {
      // فشل التصدير — _isExporting يُعاد في finally دائماً
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _copyToClipboard(BannaaLocalizations t, AppSettingsProvider s,
      List<MaterialQuantity> mats) {
    final text = _buildTextReport(t, s, mats);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.tr('reportCopied'),
            style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  // ✅ mats تُمرَّر من build() — لا إعادة حساب، ويستخدم أسعار المستخدم
  String _buildTextReport(BannaaLocalizations t, AppSettingsProvider s,
      List<MaterialQuantity> mats) {
    final p = widget.project;
    final sym = s.currencyInfo.symbol;
    final totalCost = mats.fold(0.0, (acc, m) => acc + m.totalCost);
    final buf = StringBuffer();
    buf.writeln('══════════════════════════════');
    buf.writeln('${t.tr('reportTitle')} — ${t.tr('appBrand')} 🏗️');
    buf.writeln('══════════════════════════════');
    buf.writeln('${t.tr('projectName')}: ${p.name}');
    buf.writeln('${t.tr('buildingType')}: ${p.buildingType.label}');
    buf.writeln('${t.tr('city')}: ${p.city}');
    buf.writeln('${t.tr('floors')}: ${p.floors}');
    buf.writeln(
        '${t.tr('date')}: ${p.createdAt.day}/${p.createdAt.month}/${p.createdAt.year}');
    buf.writeln('──────────────────────────────');
    buf.writeln(
        '${t.tr('totalConcreteVolumeTitle')}: ${p.totalVolume.toStringAsFixed(2)} ${t.tr('perM3')}');
    buf.writeln('──────────────────────────────');
    for (final m in mats) {
      buf.writeln(
          '${m.icon} ${m.name}: ${m.quantity.toStringAsFixed(1)} ${m.unit} — ${m.totalCost.toStringAsFixed(0)} $sym');
    }
    buf.writeln('──────────────────────────────');
    buf.writeln('${t.tr('grandTotal')}: ${totalCost.toStringAsFixed(0)} $sym');
    buf.writeln('══════════════════════════════');
    buf.writeln(t.tr('estimatedPricesNote'));
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final s = context.watch<AppSettingsProvider>();
    final p = widget.project;
    final mats = p.calculateMaterials();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: ScreenHeader(title: t.tr('finalReport'))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                _buildReportPreview(context, t, s, p, mats),
                const SizedBox(height: 20),
                _buildOptions(t),
                const SizedBox(height: 20),
              ]),
            ),
          ),
          _buildExportButtons(t, s, mats),
        ]),
      ),
    );
  }

  Widget _buildReportPreview(BuildContext context, BannaaLocalizations t,
      AppSettingsProvider s, Project p, List<MaterialQuantity> mats) {
    final sym = s.currencyInfo.symbol;
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ]),
      child: Column(children: [
        // رأس التقرير
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: Row(children: [
            const Text('🏗️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(t.tr('reportTitle'),
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black)),
                  Text('${t.tr('appBrand')} — ${_fmtDate(p.createdAt)}',
                      style: GoogleFonts.cairo(
                          fontSize: 10, color: Colors.black54)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(
                  '${p.totalVolume.toStringAsFixed(1)} ${t.tr('perM3')}',
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.w800)),
            ),
          ]),
        ),

        // معلومات المشروع
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            _infoChip('📁', p.name),
            const SizedBox(width: 8),
            _infoChip('📍', p.city),
            const SizedBox(width: 8),
            _infoChip('🏢', '${p.floors} ${t.tr('floorsSuffix')}'),
          ]),
        ),
        Container(height: 1, color: AppTheme.border),

        // جدول المواد
        if (_includeComponents) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(children: [
              Text(t.tr('materialCol'),
                  style: _hStyle(), textAlign: TextAlign.right),
              const Spacer(),
              SizedBox(
                  width: 70,
                  child: Text(t.tr('quantityCol'),
                      style: _hStyle(), textAlign: TextAlign.center)),
              SizedBox(
                  width: 70,
                  child: Text(t.tr('costCol'),
                      style: _hStyle(), textAlign: TextAlign.left)),
            ]),
          ),
          Container(height: 1, color: AppTheme.border),
          ...mats.map((m) => _matRow(m, sym)),
          Container(height: 1, color: AppTheme.border),
        ],

        // الإجمالي
        if (_includePrices)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(0))),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t.tr('grandTotal'),
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  Text('${p.totalCost.toStringAsFixed(0)} $sym',
                      style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accent)),
                ]),
          ),

        // ملاحظة
        if (_includeNotes)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16))),
            child: Text(t.tr('reportNote'),
                style: GoogleFonts.cairo(
                    fontSize: 9, color: AppTheme.textMuted, height: 1.5),
                textAlign: TextAlign.center),
          ),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _matRow(MaterialQuantity m, String sym) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: const BoxDecoration(
          border:
              Border(bottom: BorderSide(color: AppTheme.border, width: 0.5))),
      child: Row(children: [
        Text(m.icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(m.name,
                style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600))),
        SizedBox(
            width: 90,
            child: Text(
                '${m.quantity.toStringAsFixed(m.quantity > 100 ? 0 : 1)} ${_shortUnit(m.unit)}',
                style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textSub),
                textAlign: TextAlign.center)),
        SizedBox(
            width: 70,
            child: Text('${m.totalCost.toStringAsFixed(0)}',
                style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.left)),
      ]),
    );
  }

  Widget _buildOptions(BannaaLocalizations t) {
    return DarkCard(
      child: Column(children: [
        Row(children: [
          const Text('⚙️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(t.tr('reportOptions'),
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ]),
        const SizedBox(height: 12),
        _optionSwitch(t.tr('inclMaterialTable'), _includeComponents,
            (v) => setState(() => _includeComponents = v)),
        _optionSwitch(t.tr('inclPrices'), _includePrices,
            (v) => setState(() => _includePrices = v)),
        _optionSwitch(t.tr('inclNote'), _includeNotes,
            (v) => setState(() => _includeNotes = v)),
      ]),
    ).animate(delay: 200.ms).fadeIn();
  }

  Widget _optionSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style:
                    GoogleFonts.cairo(fontSize: 12, color: AppTheme.textSub))),
        Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.accent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      ]),
    );
  }

  Widget _buildExportButtons(BannaaLocalizations t, AppSettingsProvider s,
      List<MaterialQuantity> mats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(children: [
        GoldenButton(
            label: t.tr('downloadPdf'),
            icon: '⬇️',
            isLoading: _isExporting,
            onTap: _exportPdf),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: GoldenButton(
                  label: t.tr('copyText'),
                  icon: '📋',
                  outline: true,
                  onTap: _isExporting
                      ? null
                      : () => _copyToClipboard(t, s, mats))),
          const SizedBox(width: 10),
          Expanded(
              child: GoldenButton(
                  label: t.tr('shareBtn'),
                  icon: '📤',
                  outline: true,
                  onTap: _isExporting ? null : _exportPdf)),
        ]),
      ]),
    );
  }

  TextStyle _hStyle() => GoogleFonts.cairo(
      fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w700);

  Widget _infoChip(String icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.cairo(fontSize: 10, color: AppTheme.textSub)),
        ]),
      );

  String _fmtDate(DateTime d) {
    // ✅ تنسيق يحترم locale: عربي → D/M/YYYY | غير ذلك → YYYY-MM-DD
    final lang = BannaaLocalizations.of(context).locale.languageCode;
    if (lang == 'ar') {
      return '${d.day}/${d.month}/${d.year}';
    }
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  String _shortUnit(String u) {
    if (u.contains('كيس')) return 'كيس';
    if (u.contains('م³')) return 'م³';
    if (u.contains('كغ')) return 'كغ';
    if (u.contains('لتر')) return 'لتر';
    return u;
  }
}
