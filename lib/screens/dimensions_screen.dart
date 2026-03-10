// ══════════════════════════════════════════════════════════
//  screens/dimensions_screen.dart — مع الترجمة الكاملة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'project_detail_screen.dart';

class DimensionsScreen extends StatefulWidget {
  final Project project;
  const DimensionsScreen({super.key, required this.project});
  @override
  State<DimensionsScreen> createState() => _DimensionsScreenState();
}

class _DimensionsScreenState extends State<DimensionsScreen> {
  final List<BuildingComponent> _components = [];
  bool _isCalculating = false;

  void _addComponent() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddComponentSheet(
        onAdd: (comp) => setState(() => _components.add(comp))),
    );
  }

  Future<void> _calculate() async {
    final t = BannaaLocalizations.of(context);
    if (_components.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t.tr('errAtLeastOne'), style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: AppTheme.danger, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      return;
    }
    setState(() => _isCalculating = true);
    widget.project.components.clear();
    widget.project.components.addAll(_components);
    await StorageService.saveProject(widget.project);
    if (!mounted) return;
    setState(() => _isCalculating = false);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProjectDetailScreen(project: widget.project)));
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final totalVol = _components.fold(0.0, (s, c) => s + c.volume);

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(children: [
              ScreenHeader(title: t.tr('enterDimensions')),
              const SizedBox(height: 16),
              StepProgressBar(currentStep: 2, totalSteps: 3,
                stepLabel: t.tr('dimensionsStep')),
            ]),
          ),

          if (_components.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DarkCard(
                highlighted: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.tr('totalVolSoFar'), style: GoogleFonts.cairo(
                      fontSize: 12, color: AppTheme.textSub)),
                    Text('${totalVol.toStringAsFixed(2)} ${t.tr('perM3')}',
                      style: GoogleFonts.cairo(
                        fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.accent)),
                  ]),
              ),
            ).animate().slideY(begin: -0.2, duration: 300.ms),

          const SizedBox(height: 14),

          Expanded(
            child: _components.isEmpty
              ? _buildEmpty(t)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _components.length,
                  itemBuilder: (_, i) => _ComponentTile(
                    component: _components[i],
                    onDelete: () => setState(() => _components.removeAt(i)),
                  ).animate().slideX(begin: 0.3, duration: 300.ms,
                    delay: Duration(milliseconds: i * 60))),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(children: [
              GestureDetector(
                onTap: _addComponent,
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border)),
                  child: Center(child: Text(t.tr('addComponent'), style: GoogleFonts.cairo(
                    fontSize: 13, color: AppTheme.textMuted))),
                ),
              ),
              const SizedBox(height: 10),
              GoldenButton(label: t.tr('calculateQty'), icon: '🧮',
                isLoading: _isCalculating, onTap: _calculate),
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
        Text(t.tr('addProjectComponents'), style: GoogleFonts.cairo(
          fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textSub)),
        const SizedBox(height: 6),
        Text(t.tr('componentsExamples'), style: GoogleFonts.cairo(
          fontSize: 12, color: AppTheme.textMuted)),
      ]),
    );
  }
}

class _ComponentTile extends StatelessWidget {
  final BuildingComponent component;
  final VoidCallback onDelete;
  const _ComponentTile({required this.component, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return DarkCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentGlow, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(component.type.emoji,
            style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(component.name, style: GoogleFonts.cairo(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text(
            '${component.length}م × ${component.width}م × ${component.height}م'
            '${component.count > 1 ? ' × ${component.count} ${t.tr('units')}' : ''}',
            style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${component.volume.toStringAsFixed(3)} ${t.tr('perM3')}',
            style: GoogleFonts.cairo(
              fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.accent)),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.delete_outline, color: AppTheme.danger, size: 18))),
        ]),
      ]),
    );
  }
}

class _AddComponentSheet extends StatefulWidget {
  final Function(BuildingComponent) onAdd;
  const _AddComponentSheet({required this.onAdd});
  @override
  State<_AddComponentSheet> createState() => _AddComponentSheetState();
}

class _AddComponentSheetState extends State<_AddComponentSheet> {
  final _formKey    = GlobalKey<FormState>();
  ComponentType _type = ComponentType.column;
  final _lengthCtrl = TextEditingController();
  final _widthCtrl  = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _countCtrl  = TextEditingController(text: '1');

  @override
  void dispose() {
    _lengthCtrl.dispose(); _widthCtrl.dispose();
    _heightCtrl.dispose(); _countCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd(BuildingComponent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type, name: _type.label,
      length: double.parse(_lengthCtrl.text),
      width: double.parse(_widthCtrl.text),
      height: double.parse(_heightCtrl.text),
      count: int.tryParse(_countCtrl.text) ?? 1));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.border,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(t.tr('addComponentTitle'), style: GoogleFonts.cairo(
              fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 14),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: ComponentType.values.map((ct) {
                final sel = ct == _type;
                return GestureDetector(
                  onTap: () => setState(() => _type = ct),
                  child: AnimatedContainer(
                    duration: 150.ms,
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppTheme.accentGlow : AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? AppTheme.accent : AppTheme.border)),
                    child: Text('${ct.emoji} ${ct.label}', style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: sel ? AppTheme.accent : AppTheme.textMuted,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.normal))));
              }).toList()),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(child: _dimField(_lengthCtrl, t.tr('lengthDimLabel'), t)),
              const SizedBox(width: 10),
              Expanded(child: _dimField(_widthCtrl, t.tr('widthDimLabel'), t)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _dimField(_heightCtrl,
                _type == ComponentType.foundation
                  ? t.tr('depthLabel') : t.tr('heightDimLabel'), t)),
              const SizedBox(width: 10),
              Expanded(child: _dimField(_countCtrl, t.tr('countDimLabel'), t, isInt: true)),
            ]),
            const SizedBox(height: 16),

            GoldenButton(label: t.tr('addComponentBtn'), icon: '✓', onTap: _submit),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _dimField(TextEditingController ctrl, String label, BannaaLocalizations t,
      {bool isInt = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.cairo(
        fontSize: 11, color: AppTheme.textSub, fontWeight: FontWeight.w600)),
      const SizedBox(height: 5),
      TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
        validator: (v) {
          if (v == null || v.isEmpty) return t.tr('errRequired');
          final n = double.tryParse(v);
          if (n == null || n <= 0) return t.tr('errInvalidNumber');
          return null;
        }),
    ]);
  }
}
