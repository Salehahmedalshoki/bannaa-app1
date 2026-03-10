// ══════════════════════════════════════════════════════════
//  screens/new_project_screen.dart
//  الخطوة 1: معلومات المشروع الأساسية
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

  BuildingType _selectedType = BuildingType.villa;
  int _floors = 1;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    // إنشاء المشروع وتمريره لشاشة الأبعاد
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      buildingType: _selectedType,
      floors: _floors,
      city: _cityCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DimensionsScreen(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── الهيدر ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                children: [
                  ScreenHeader(title: t.tr('newProject')),
                  const SizedBox(height: 16),
                  StepProgressBar(
                    currentStep: 1,
                    totalSteps: 3,
                    stepLabel: t.tr('projectName'),
                  ),
                ],
              ),
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
                      // اسم المشروع
                      AppTextField(
                        label: t.tr('projectName'),
                        hint: t.tr('newProject'),
                        controller: _nameCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t.tr('errRequired') : null,
                      ),
                      const SizedBox(height: 16),

                      // نوع المنشأ
                      Text('نوع المنشأ',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSub,
                        )),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: BuildingType.values.map((t) {
                          final selected = t == _selectedType;
                          return GestureDetector(
                            onTap: () =>
                              setState(() => _selectedType = t),
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
                                  Text(t.emoji,
                                    style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 5),
                                  Text(t.label,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: selected
                                          ? AppTheme.accent
                                          : AppTheme.textMuted,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    )),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // عدد الطوابق
                      Text('عدد الطوابق',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSub,
                        )),
                      const SizedBox(height: 8),
                      Row(
                        children: [1, 2, 3, 4].map((n) {
                          final selected = n == _floors;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                setState(() => _floors = n),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                margin: EdgeInsets.only(
                                  left: n < 4 ? 8 : 0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12),
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
                                          : AppTheme.textMuted,
                                    )),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // المدينة
                      AppTextField(
                        label: 'المنطقة / المدينة',
                        hint: 'مثال: الرياض',
                        controller: _cityCtrl,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.textMuted, size: 18),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'يرجى إدخال المدينة' : null,
                      ),
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
                label: 'التالي: إدخال الأبعاد',
                icon: '←',
                onTap: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
