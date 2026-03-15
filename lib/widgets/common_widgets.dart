// ══════════════════════════════════════════════════════════
//  widgets/common_widgets.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة:
//  ✅ #1 ScreenHeader — سهم الرجوع يتكيف مع RTL/LTR تلقائياً
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── زر رئيسي بتدرج ذهبي ──────────────────────────────────
class GoldenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String? icon;
  final bool isLoading;
  final bool outline;

  const GoldenButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: outline
              ? null
              : const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark],
                ),
          borderRadius: BorderRadius.circular(14),
          border: outline ? Border.all(color: AppTheme.border) : null,
          boxShadow: outline
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Text(icon!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.cairo(
                        color: outline ? AppTheme.textPrimary : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── بطاقة داكنة ───────────────────────────────────────────
class DarkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool highlighted;

  const DarkCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? AppTheme.accent : AppTheme.border,
            width: highlighted ? 1.5 : 1,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

// ── حقل إدخال مخصص ───────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? suffixText;
  final Widget? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  // ✅ إضافات للتنقل بين الحقول
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
    this.suffixText,
    this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSub,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
            suffixStyle:
                GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 12),
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}

// ── شريط تقدم خطوات ──────────────────────────────────────
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepLabel;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            totalSteps,
            (i) => Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(left: i < totalSteps - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < currentStep ? AppTheme.accent : AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'الخطوة $currentStep من $totalSteps — $stepLabel',
          style: GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}

// ── رأس شاشة مع زر رجوع ──────────────────────────────────
class ScreenHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const ScreenHeader({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ #1 — السهم يتكيف مع اتجاه التطبيق RTL/LTR
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Icon(
              // ✅ في RTL (عربي): السهم يشير لليمين ← للرجوع
              // ✅ في LTR (إنجليزي): السهم يشير لليسار → للرجوع
              isRtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}

// ── ودجت إحصاء صغيرة ─────────────────────────────────────
class StatChip extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const StatChip({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DarkCard(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.accent,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(fontSize: 9, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
