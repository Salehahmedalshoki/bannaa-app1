// ══════════════════════════════════════════════════════════
//  screens/quote_request_sheet.dart — المرحلة الثالثة
//  🤝 Bottom sheet لإرسال طلب عرض سعر لمورّد
//  الخطوات: اختيار المورّد ← تأكيد المواد ← ملاحظة ← إرسال
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import '../models/quote_request_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class QuoteRequestSheet extends StatefulWidget {
  final Project project;
  final List<MaterialQuantity> materials;

  const QuoteRequestSheet({
    super.key,
    required this.project,
    required this.materials,
  });

  /// فتح الـ sheet
  static Future<void> show(
    BuildContext context, {
    required Project project,
    required List<MaterialQuantity> materials,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuoteRequestSheet(
        project: project,
        materials: materials,
      ),
    );
  }

  @override
  State<QuoteRequestSheet> createState() => _QuoteRequestSheetState();
}

class _QuoteRequestSheetState extends State<QuoteRequestSheet> {
  int _step = 0; // 0=اختر مورّد  1=تأكيد  2=نجاح
  List<SupplierProfile> _suppliers = [];
  SupplierProfile? _selected;
  final _noteCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    final list = await FirestoreService.getSuppliers(city: widget.project.city);
    if (mounted)
      setState(() {
        _suppliers = list;
        _isLoading = false;
      });
  }

  Future<void> _send() async {
    if (_selected == null) return;
    setState(() => _isSending = true);

    final user = FirebaseAuth.instance.currentUser;
    final request = QuoteRequest(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_selected!.uid}',
      userId: user?.uid ?? '',
      userName: user?.displayName ?? 'مستخدم',
      supplierId: _selected!.uid,
      projectName: widget.project.name,
      city: widget.project.city,
      materials: widget.materials
          .map((m) => QuoteMaterial(
                name: m.name,
                icon: m.icon,
                quantity: m.quantity,
                unit: m.unit,
              ))
          .toList(),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      status: QuoteStatus.pending,
      createdAt: DateTime.now(),
    );

    final ok = await FirestoreService.sendQuoteRequest(request);
    if (!mounted) return;

    setState(() {
      _isSending = false;
      if (ok) _step = 2;
    });
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('فشل الإرسال — تحقق من الاتصال'),
          backgroundColor: AppTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          // handle
          Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 4),
          Expanded(
            child: _step == 0
                ? _StepSelectSupplier(
                    suppliers: _suppliers,
                    isLoading: _isLoading,
                    selected: _selected,
                    projectCity: widget.project.city,
                    scrollCtrl: scrollCtrl,
                    onSelect: (s) => setState(() {
                      _selected = s;
                      _step = 1;
                    }),
                  )
                : _step == 1
                    ? _StepConfirm(
                        project: widget.project,
                        materials: widget.materials,
                        supplier: _selected!,
                        noteCtrl: _noteCtrl,
                        isSending: _isSending,
                        scrollCtrl: scrollCtrl,
                        onBack: () => setState(() => _step = 0),
                        onSend: _send,
                      )
                    : _StepSuccess(
                        supplierName: _selected!.name,
                        onClose: () => Navigator.pop(context),
                      ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  الخطوة ١ — اختيار المورّد
// ══════════════════════════════════════════════════════════
class _StepSelectSupplier extends StatelessWidget {
  final List<SupplierProfile> suppliers;
  final bool isLoading;
  final SupplierProfile? selected;
  final String projectCity;
  final ScrollController scrollCtrl;
  final ValueChanged<SupplierProfile> onSelect;

  const _StepSelectSupplier({
    required this.suppliers,
    required this.isLoading,
    required this.selected,
    required this.projectCity,
    required this.scrollCtrl,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Row(children: [
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.storefront_outlined,
                  color: AppTheme.accent, size: 18)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('اختر مورّداً',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                Text(
                    projectCity.isNotEmpty
                        ? 'الموردون القريبون من: $projectCity'
                        : 'جميع الموردين المسجّلين',
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppTheme.textMuted)),
              ])),
        ]),
      ),
      const Divider(color: AppTheme.border, height: 1),
      Expanded(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(AppTheme.accent)))
            : suppliers.isEmpty
                ? _EmptySuppliers()
                : ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: suppliers.length,
                    itemBuilder: (_, i) => _SupplierTile(
                      supplier: suppliers[i],
                      isSelected: selected?.uid == suppliers[i].uid,
                      onTap: () => onSelect(suppliers[i]),
                    )
                        .animate(delay: Duration(milliseconds: i * 60))
                        .fadeIn()
                        .slideY(begin: 0.1, end: 0),
                  ),
      ),
    ]);
  }
}

class _SupplierTile extends StatelessWidget {
  final SupplierProfile supplier;
  final bool isSelected;
  final VoidCallback onTap;

  const _SupplierTile({
    required this.supplier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6).withOpacity(0.08)
                : AppTheme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isSelected ? const Color(0xFF3B82F6) : AppTheme.border,
                width: isSelected ? 1.5 : 1)),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(
                    supplier.name.isNotEmpty
                        ? supplier.name[0].toUpperCase()
                        : '؟',
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(supplier.name,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                if (supplier.cities.isNotEmpty)
                  Text(supplier.cities.take(3).join('، '),
                      style: GoogleFonts.cairo(
                          fontSize: 10, color: AppTheme.textMuted)),
                if (supplier.categories.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                      spacing: 4,
                      children: supplier.categories
                          .take(3)
                          .map((c) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(c,
                                  style: GoogleFonts.cairo(
                                      fontSize: 9,
                                      color: const Color(0xFF3B82F6)))))
                          .toList()),
                ],
              ])),
          if (supplier.rating > 0) ...[
            Column(children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_rounded,
                    color: AppTheme.accent, size: 14),
                const SizedBox(width: 2),
                Text(supplier.rating.toStringAsFixed(1),
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent)),
              ]),
              if (supplier.totalOrders > 0)
                Text('${supplier.totalOrders} طلب',
                    style: GoogleFonts.cairo(
                        fontSize: 9, color: AppTheme.textMuted)),
            ]),
          ],
          const SizedBox(width: 8),
          AnimatedContainer(
              duration: 200.ms,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                  border: Border.all(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : AppTheme.border,
                      width: 1.5)),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null),
        ]),
      ),
    );
  }
}

class _EmptySuppliers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔍', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 14),
        Text('لا يوجد موردون مسجّلون بعد',
            style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('يمكن للموردين التسجيل في التطبيق\nواختيار نوع الحساب "مورّد"',
            style: GoogleFonts.cairo(
                fontSize: 12, color: AppTheme.textMuted, height: 1.6),
            textAlign: TextAlign.center),
      ]),
    ));
  }
}

// ══════════════════════════════════════════════════════════
//  الخطوة ٢ — تأكيد الطلب
// ══════════════════════════════════════════════════════════
class _StepConfirm extends StatelessWidget {
  final Project project;
  final List<MaterialQuantity> materials;
  final SupplierProfile supplier;
  final TextEditingController noteCtrl;
  final bool isSending;
  final ScrollController scrollCtrl;
  final VoidCallback onBack;
  final VoidCallback onSend;

  const _StepConfirm({
    required this.project,
    required this.materials,
    required this.supplier,
    required this.noteCtrl,
    required this.isSending,
    required this.scrollCtrl,
    required this.onBack,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // رأس الخطوة
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border)),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: AppTheme.textMuted, size: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('تأكيد الطلب',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                Text('المورّد: ${supplier.name}',
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppTheme.textMuted)),
              ])),
        ]),
      ),
      const Divider(color: AppTheme.border, height: 16),
      Expanded(
          child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // ملخص المشروع
          _SectionLabel(label: 'المشروع', icon: Icons.folder_outlined),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border)),
            child: Row(children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppTheme.accentGlow,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Text(project.buildingType.emoji,
                          style: const TextStyle(fontSize: 20)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(project.name,
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    Text('${project.buildingType.label} • ${project.city}',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textMuted)),
                  ])),
            ]),
          ),
          const SizedBox(height: 16),

          // المواد المطلوبة
          _SectionLabel(
              label: 'المواد المطلوبة', icon: Icons.inventory_2_outlined),
          const SizedBox(height: 8),
          ...materials.map((m) => _MaterialRow(material: m)),

          const SizedBox(height: 16),

          // ملاحظة اختيارية
          _SectionLabel(
              label: 'ملاحظة للمورّد (اختياري)', icon: Icons.notes_outlined),
          const SizedBox(height: 8),
          TextField(
            controller: noteCtrl,
            maxLines: 3,
            style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
                hintText:
                    'مثال: أريد التوريد خلال أسبوعين، الدفع بعد الاستلام...',
                hintStyle:
                    GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 11),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.accent, width: 1.5))),
          ),
          const SizedBox(height: 20),

          // زر الإرسال
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: AnimatedContainer(
              duration: 200.ms,
              height: 52,
              decoration: BoxDecoration(
                  gradient: isSending
                      ? null
                      : const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accentDark]),
                  color: isSending ? AppTheme.border : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSending
                      ? null
                      : [
                          BoxShadow(
                              color: AppTheme.accent.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 5))
                        ]),
              child: Center(
                child: isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.send_rounded,
                            color: Colors.black, size: 18),
                        const SizedBox(width: 8),
                        Text('إرسال طلب عرض السعر',
                            style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.black)),
                      ]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('سيصلك رد المورّد في قائمة طلباتك',
              style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted),
              textAlign: TextAlign.center),
        ],
      )),
    ]);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.textMuted, size: 14),
      const SizedBox(width: 6),
      Text(label,
          style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSub)),
    ]);
  }
}

class _MaterialRow extends StatelessWidget {
  final MaterialQuantity material;
  const _MaterialRow({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Text(material.icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
            child: Text(material.name,
                style: GoogleFonts.cairo(
                    fontSize: 13, color: AppTheme.textPrimary))),
        Text('${material.quantity.toStringAsFixed(1)} ${material.unit}',
            style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  الخطوة ٣ — نجاح الإرسال
// ══════════════════════════════════════════════════════════
class _StepSuccess extends StatelessWidget {
  final String supplierName;
  final VoidCallback onClose;

  const _StepSuccess({required this.supplierName, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.success.withOpacity(0.3))),
            child: const Center(
                child: Icon(Icons.check_circle_outline_rounded,
                    color: AppTheme.success, size: 42)),
          ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 500.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text('تم إرسال الطلب!',
                  style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary))
              .animate(delay: 200.ms)
              .fadeIn()
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text('وصل طلبك إلى $supplierName\nسيردّ عليك قريباً',
                  style: GoogleFonts.cairo(
                      fontSize: 13, color: AppTheme.textMuted, height: 1.6),
                  textAlign: TextAlign.center)
              .animate(delay: 300.ms)
              .fadeIn(),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accentDark]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.accent.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 5))
                  ]),
              child: Center(
                  child: Text('حسناً',
                      style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black))),
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2, end: 0),
        ]),
      ),
    );
  }
}
