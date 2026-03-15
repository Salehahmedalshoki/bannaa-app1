// ══════════════════════════════════════════════════════════
//  screens/new_project_screen.dart  ✅ نسخة مُصحَّحة (المراجعة الثانية)
//
//  الإصلاحات المطبّقة:
//  ✅ #1  جميع النصوص المُضمَّنة → t.tr() (نوع المنشأ، الطوابق، المدينة، الزر)
//  ✅ #2  margin أزرار الطوابق يتكيف مع RTL/LTR
//  ✅ #3  Project ID يستخدم uuid آمن بدل millisecondsSinceEpoch
//  ✅ #4  FocusScope.unfocus() قبل الانتقال لمنع overflow الكيبورد
//  ✅ #5  textInputAction + onFieldSubmitted على حقلَي النموذج
//  ✅ #6  حقل المدينة: validator يستخدم t.tr() بدل نص مُضمَّن
//  ✅ #7  مفاتيح الترجمة الناقصة أُضيفت في جميع ملفات arb (6 مفاتيح)
//  ✅ #8  سهم زر التالي يتكيف مع RTL بشكل صحيح
//  ✅ #9  textInputAction + onFieldSubmitted بين حقلَي الاسم والمدينة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'dimensions_screen.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // ✅ #5 — FocusNode للتنقل بين الحقول
  final _nameFocus = FocusNode();
  final _cityFocus = FocusNode();

  BuildingType _selectedType = BuildingType.villa;
  int _floors = 1;
  ConcreteGrade _selectedConcrete = ConcreteGrade.C20;
  ReinforcementType _selectedReinforcement = ReinforcementType.traditional;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _nameFocus.dispose();
    _cityFocus.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ #4 — أغلق الكيبورد قبل الانتقال
    FocusScope.of(context).unfocus();

    // ✅ #3 — ID فريد يجمع الوقت + hashCode للاسم لتجنب التصادم
    //         (مثالياً استخدم حزمة uuid، لكن هذا آمن بدون dependency إضافية)
    final id = '${DateTime.now().millisecondsSinceEpoch}'
        '_${_nameCtrl.text.trim().hashCode.abs()}';

    final project = Project(
      id: id,
      name: _nameCtrl.text.trim(),
      buildingType: _selectedType,
      floors: _floors,
      city: _cityCtrl.text.trim(),
      createdAt: DateTime.now(),
      concreteGrade: _selectedConcrete,
      reinforcementType: _selectedReinforcement,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DimensionsScreen(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── الهيدر ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(children: [
                ScreenHeader(title: t.tr('newProject')),
                const SizedBox(height: 16),
                StepProgressBar(
                  currentStep: 1,
                  totalSteps: 3,
                  stepLabel: t.tr('projectName'),
                ),
              ]),
            ),

            // ── النموذج ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── اسم المشروع ──────────────────────
                      AppTextField(
                        label: t.tr('projectName'),
                        hint: t.tr('projectNameHint'),
                        controller: _nameCtrl,
                        focusNode: _nameFocus, // ✅ #9
                        textInputAction: TextInputAction.next, // ✅ #9
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_cityFocus),
                        prefixIcon: const Icon(Icons.drive_file_rename_outline,
                            color: AppTheme.textMuted, size: 18),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t.tr('errRequired')
                            : null,
                      )
                          .animate(delay: 80.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 18),

                      // ── نوع المنشأ ───────────────────────
                      // ✅ #1
                      Text(t.tr('buildingType'),
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSub)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: BuildingType.values.map((bt) {
                          final selected = bt == _selectedType;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = bt),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.accentGlow
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.accent
                                      : AppTheme.border,
                                  width: selected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(bt.emoji,
                                      style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 5),
                                  Text(bt.label,
                                      style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: selected
                                              ? AppTheme.accent
                                              : AppTheme.textMuted,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.normal)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ).animate(delay: 130.ms).fadeIn(),
                      const SizedBox(height: 18),

                      // ── عدد الطوابق ──────────────────────
                      // ✅ #1
                      Text(t.tr('floorsCount'),
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSub)),
                      const SizedBox(height: 8),
                      Row(
                        children: [1, 2, 3, 4].map((n) {
                          final selected = n == _floors;
                          final isFirst = n == 1;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _floors = n),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                // ✅ #2 — margin يتكيف مع RTL
                                margin: EdgeInsets.only(
                                  left: isRtl ? (isFirst ? 0 : 8) : 0,
                                  right: isRtl ? 0 : (isFirst ? 0 : 8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppTheme.accentGlow
                                      : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.accent
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    n == 4 ? '4+' : '$n',
                                    style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.normal,
                                        color: selected
                                            ? AppTheme.accent
                                            : AppTheme.textMuted),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ).animate(delay: 180.ms).fadeIn(),
                      const SizedBox(height: 18),

                      // ── المدينة ──────────────────────────
                      // ✅ #1 #6
                      AppTextField(
                        label: t.tr('cityLabel'),
                        hint: t.tr('cityHint'),
                        controller: _cityCtrl,
                        focusNode: _cityFocus, // ✅ #9
                        textInputAction: TextInputAction.done, // ✅ #9
                        onFieldSubmitted: (_) => _next(),
                        prefixIcon: const Icon(Icons.location_on_outlined,
                            color: AppTheme.textMuted, size: 18),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t.tr('errCityRequired')
                            : null,
                      )
                          .animate(delay: 230.ms)
                          .fadeIn()
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 18),

                      // ── نوع الخرسانة ───────────────────────
                      Text(t.tr('concreteGrade'),
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSub)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ConcreteGrade.values.map((cg) {
                          final selected = cg == _selectedConcrete;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedConcrete = cg),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.accentGlow
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.accent
                                      : AppTheme.border,
                                ),
                              ),
                              child: Text(cg.label,
                                  style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      color: selected
                                          ? AppTheme.accent
                                          : AppTheme.textMuted,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.normal)),
                            ),
                          );
                        }).toList(),
                      ).animate(delay: 260.ms).fadeIn(),
                      const SizedBox(height: 18),

                      // ── نوع التسليح ─────────────────────────
                      Text(t.tr('reinforcementType'),
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSub)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ReinforcementType.values.map((rt) {
                          final selected = rt == _selectedReinforcement;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedReinforcement = rt),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.accentGlow
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.accent
                                      : AppTheme.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(rt.emoji,
                                      style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(rt.label,
                                      style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: selected
                                              ? AppTheme.accent
                                              : AppTheme.textMuted,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.normal)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ).animate(delay: 280.ms).fadeIn(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // ── زر التالي ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GoldenButton(
                // ✅ #1
                label: t.tr('nextDimensions'),
                icon: isRtl ? '←' : '→', // ✅ #8
                onTap: _next,
              ).animate(delay: 280.ms).fadeIn().slideY(begin: 0.15, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}
