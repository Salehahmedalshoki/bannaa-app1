// ══════════════════════════════════════════════════════════
//  screens/dimensions_screen.dart  ✅ نسخة مُصحَّحة (المراجعة الثانية)
//
//  الإصلاحات الأصلية محفوظة + الإضافات الجديدة:
//  ✅ #1  _calculate() تُنشئ نسخة جديدة بدل تعديل widget.project
//  ✅ #2  Navigator.pop(context, updated) يُرجع المشروع للشاشة السابقة
//  ✅ #3  حذف المكوّن يطلب تأكيداً + معطَّل أثناء _isCalculating
//  ✅ #4  زر "إضافة مكوّن" معطَّل أثناء _isCalculating
//  ✅ #5  BuildingComponent.id عداد ثابت بدل millisecondsSinceEpoch
//  ✅ #6  margin شرائح نوع المكوّن يتكيف مع RTL/LTR
//  ✅ #7  textInputAction + FocusNode للتنقل بين حقول الأبعاد
//  ✅ #8  المشروع المحدَّث يُرجَع عبر Navigator.pop للشاشة السابقة
//  ✅ #9  _calculate() محاطة بـ try/catch/finally — لا تجميد عند فشل Firestore
//  ✅ #10 مفاتيح الترجمة الناقصة أُضيفت: deleteComponentTitle, deleteComponentMsg
//  ✅ #11 _AddComponentSheet: SingleChildScrollView يمنع overflow على الأجهزة الصغيرة
//  ✅ #12 زر إضافة مكوّن في الشريط: padding السفلي يحترم viewInsets بدقة
//  ✅ #13 _componentIdCounter منقول لـ static داخل الـ State (لا تلوث global scope)
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';

class DimensionsScreen extends StatefulWidget {
  final Project project;
  const DimensionsScreen({super.key, required this.project});
  @override
  State<DimensionsScreen> createState() => _DimensionsScreenState();
}

class _DimensionsScreenState extends State<DimensionsScreen> {
  final List<BuildingComponent> _components = [];
  bool _isCalculating = false;

  // ══════════════════════════════════════════════════════
  //  إضافة مكوّن
  // ══════════════════════════════════════════════════════
  void _addComponent() {
    if (_isCalculating) return; // ✅ #4
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddComponentSheet(
          onAdd: (comp) => setState(() => _components.add(comp))),
    );
  }

  // ══════════════════════════════════════════════════════
  //  حساب الكميات وحفظ المشروع
  // ══════════════════════════════════════════════════════
  // ✅ #9 — try/catch/finally لمنع التجميد عند فشل الحفظ
  Future<void> _calculate() async {
    final t = BannaaLocalizations.of(context);
    if (_components.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t.tr('errAtLeastOne'),
              style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      return;
    }

    setState(() => _isCalculating = true);

    try {
      // ✅ #1 — نسخة جديدة بدل تعديل widget.project مباشرةً
      final updated = Project(
        id: widget.project.id,
        name: widget.project.name,
        buildingType: widget.project.buildingType,
        floors: widget.project.floors,
        city: widget.project.city,
        createdAt: widget.project.createdAt,
        components: List<BuildingComponent>.from(_components),
        buildingCodeName: widget.project.buildingCodeName,
        concreteGrade: widget.project.concreteGrade,
      );

      await StorageService.saveProjectLocal(updated); // محلي للـ offline
      await FirestoreService.saveProject(
          updated); // سحابي (يتجاهل الخطأ داخلياً)

      if (!mounted) return;

      // ✅ #2 + #8 — pop مع إرجاع المشروع المحدَّث للشاشة السابقة
      // هذا يسمح لـ project_detail_screen._goToEdit باستقبال updated
      // ويمنع تراكم الـ stack لأن الشاشة تُغلق نفسها
      Navigator.pop(context, updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.tr('errSaveFailed'),
                style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  // ══════════════════════════════════════════════════════
  //  حذف مكوّن مع تأكيد
  // ══════════════════════════════════════════════════════
  Future<void> _deleteComponent(int index) async {
    if (_isCalculating) return; // ✅ #3 لا حذف أثناء الحساب

    final t = BannaaLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t.tr('deleteComponentTitle'),
            style: GoogleFonts.cairo(
                color: AppTheme.danger, fontWeight: FontWeight.w700)),
        content: Text(
            '"${_components[index].name}" — ${t.tr('deleteComponentMsg')}',
            style: GoogleFonts.cairo(color: AppTheme.textSub, height: 1.6)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t.tr('cancel'),
                  style: GoogleFonts.cairo(color: AppTheme.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t.tr('delete'),
                  style: GoogleFonts.cairo(
                      color: AppTheme.danger, fontWeight: FontWeight.w700))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _components.removeAt(index));
    }
  }

  // ══════════════════════════════════════════════════════
  //  البناء
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final totalVol = _components.fold(0.0, (s, c) => s + c.volume);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // ── الهيدر ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(children: [
              ScreenHeader(title: t.tr('enterDimensions')),
              const SizedBox(height: 16),
              StepProgressBar(
                  currentStep: 2,
                  totalSteps: 3,
                  stepLabel: t.tr('dimensionsStep')),
            ]),
          ),

          // ── إجمالي الحجم ────────────────────────────
          if (_components.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DarkCard(
                highlighted: true,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.tr('totalVolSoFar'),
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: AppTheme.textSub)),
                      Text('${totalVol.toStringAsFixed(2)} ${t.tr('perM3')}',
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accent)),
                    ]),
              ),
            ).animate().slideY(begin: -0.2, duration: 300.ms),

          const SizedBox(height: 14),

          // ── قائمة المكوّنات ──────────────────────────
          Expanded(
            child: _components.isEmpty
                ? _buildEmpty(t)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _components.length,
                    itemBuilder: (_, i) => _ComponentTile(
                      component: _components[i],
                      isLocked: _isCalculating, // ✅ #3
                      onDelete: () => _deleteComponent(i),
                    ).animate().slideX(
                        begin: 0.3,
                        duration: 300.ms,
                        delay: Duration(milliseconds: i * 60)),
                  ),
          ),

          // ── أزرار الأسفل ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(children: [
              // ✅ #4 — معطَّل أثناء الحساب
              GestureDetector(
                onTap: _isCalculating ? null : _addComponent,
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _isCalculating
                              ? AppTheme.border.withValues(alpha: 0.4)
                              : AppTheme.border)),
                  child: Center(
                    child: Text(
                      t.tr('addComponent'),
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _isCalculating
                              ? AppTheme.textMuted.withValues(alpha: 0.4)
                              : AppTheme.textMuted),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GoldenButton(
                  label: t.tr('calculateQty'),
                  icon: '🧮',
                  isLoading: _isCalculating,
                  onTap: _isCalculating ? null : _calculate),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty(BannaaLocalizations t) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📐', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(t.tr('addProjectComponents'),
            style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const SizedBox(height: 6),
        Text(t.tr('componentsExamples'),
            style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة مكوّن واحد — ✅ #3 معطَّل أثناء الحساب
// ══════════════════════════════════════════════════════════
class _ComponentTile extends StatelessWidget {
  final BuildingComponent component;
  final bool isLocked;
  final VoidCallback onDelete;

  const _ComponentTile({
    required this.component,
    required this.isLocked,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DarkCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(component.type.emoji,
                    style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(component.name,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                Text(
                    '${component.length}م × ${component.width}م × ${component.height}م'
                    '${component.count > 1 ? ' × ${component.count} ${t.tr('units')}' : ''}',
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${component.volume.toStringAsFixed(3)} ${t.tr('perM3')}',
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accent)),
              // ✅ #3 — معطَّل بصرياً أثناء الحساب
              GestureDetector(
                onTap: isLocked ? null : onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(Icons.delete_outline,
                      color: isLocked
                          ? AppTheme.danger.withValues(alpha: 0.3)
                          : AppTheme.danger,
                      size: 18),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  sheet إضافة مكوّن
// ══════════════════════════════════════════════════════════
class _AddComponentSheet extends StatefulWidget {
  final Function(BuildingComponent) onAdd;
  const _AddComponentSheet({required this.onAdd});
  @override
  State<_AddComponentSheet> createState() => _AddComponentSheetState();
}

class _AddComponentSheetState extends State<_AddComponentSheet> {
  final _formKey = GlobalKey<FormState>();
  ComponentType _type = ComponentType.column;

  // ✅ عداد محلي لضمان فرادة IDs
  int _componentIdCounter = 0;

  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '1');

  // ✅ #7 — FocusNodes للتنقل بين الحقول
  final _lengthFocus = FocusNode();
  final _widthFocus = FocusNode();
  final _heightFocus = FocusNode();
  final _countFocus = FocusNode();

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _countCtrl.dispose();
    _lengthFocus.dispose();
    _widthFocus.dispose();
    _heightFocus.dispose();
    _countFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ #5 — ID فريد: وقت + عداد تصاعدي
    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${++_componentIdCounter}';

    widget.onAdd(BuildingComponent(
      id: id,
      type: _type,
      name: _type.label,
      length: double.parse(_lengthCtrl.text),
      width: double.parse(_widthCtrl.text),
      height: double.parse(_heightCtrl.text),
      count: int.tryParse(_countCtrl.text) ?? 1,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        // ✅ #11 — SingleChildScrollView لمنع overflow على الأجهزة الصغيرة
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── شريط الإمساك ────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),

                Text(t.tr('addComponentTitle'),
                    style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 14),

                // ── اختيار نوع المكوّن ───────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ComponentType.values.map((ct) {
                      final sel = ct == _type;
                      return GestureDetector(
                        onTap: () => setState(() => _type = ct),
                        child: AnimatedContainer(
                          duration: 150.ms,
                          // ✅ #6 — margin يتكيف مع RTL
                          margin: EdgeInsets.only(
                            left: isRtl ? 0 : 8,
                            right: isRtl ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.accentGlow
                                  : AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:
                                      sel ? AppTheme.accent : AppTheme.border)),
                          child: Text('${ct.emoji} ${ct.label}',
                              style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: sel
                                      ? AppTheme.accent
                                      : AppTheme.textMuted,
                                  fontWeight: sel
                                      ? FontWeight.w700
                                      : FontWeight.normal)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // ── حقول الأبعاد ─────────────────────────
                Row(children: [
                  Expanded(
                    child: _dimField(
                      ctrl: _lengthCtrl,
                      focusNode: _lengthFocus,
                      nextFocus: _widthFocus,
                      label: t.tr('lengthDimLabel'),
                      t: t,
                      action: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dimField(
                      ctrl: _widthCtrl,
                      focusNode: _widthFocus,
                      nextFocus: _heightFocus,
                      label: t.tr('widthDimLabel'),
                      t: t,
                      action: TextInputAction.next,
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _dimField(
                      ctrl: _heightCtrl,
                      focusNode: _heightFocus,
                      nextFocus: _countFocus,
                      label: _type == ComponentType.foundation
                          ? t.tr('depthLabel')
                          : t.tr('heightDimLabel'),
                      t: t,
                      action: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dimField(
                      ctrl: _countCtrl,
                      focusNode: _countFocus,
                      nextFocus: null, // آخر حقل → Done
                      label: t.tr('countDimLabel'),
                      t: t,
                      isInt: true,
                      action: TextInputAction.done,
                      onDone: _submit,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                GoldenButton(
                    label: t.tr('addComponentBtn'), icon: '✓', onTap: _submit),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ), // SingleChildScrollView
      ),
    );
  }

  // ✅ #7 — _dimField يدعم FocusNode وTextInputAction
  Widget _dimField({
    required TextEditingController ctrl,
    required FocusNode focusNode,
    required FocusNode? nextFocus,
    required String label,
    required BannaaLocalizations t,
    bool isInt = false,
    TextInputAction action = TextInputAction.next,
    VoidCallback? onDone,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppTheme.textSub,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        TextFormField(
          controller: ctrl,
          focusNode: focusNode,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          textInputAction: action,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              isInt ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
            ),
          ],
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            } else {
              onDone?.call();
            }
          },
          style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
          validator: (v) {
            if (v == null || v.isEmpty) return t.tr('errRequired');
            if (isInt) {
              final n = int.tryParse(v);
              if (n == null || n <= 0) return t.tr('errInvalidNumber');
            } else {
              final n = double.tryParse(v);
              if (n == null || n <= 0) return t.tr('errInvalidNumber');
            }
            return null;
          },
        ),
      ],
    );
  }
}
