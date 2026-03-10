// ══════════════════════════════════════════════════════════
//  screens/forgot_password_screen.dart — مع الترجمة الكاملة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMsg;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await AuthService.resetPassword(_emailCtrl.text);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success) _emailSent = true;
      else _errorMsg = result.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            ScreenHeader(title: t.tr('forgotPasswordTitle')),
            const SizedBox(height: 32),
            if (_emailSent) _buildSuccessState(t) else _buildFormState(t),
          ]),
        ),
      ),
    );
  }

  Widget _buildFormState(BannaaLocalizations t) {
    return Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppTheme.accentGlow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.accent.withOpacity(0.3))),
          child: const Center(child: Text('🔑', style: TextStyle(fontSize: 38))),
        )).animate().scale(begin: const Offset(0.8, 0.8), duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(t.tr('resetPasswordTitle'), style: GoogleFonts.cairo(
          fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))
          .animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 8),
        Text(t.tr('resetInstructions'), style: GoogleFonts.cairo(
          fontSize: 12, color: AppTheme.textMuted, height: 1.6))
          .animate(delay: 150.ms).fadeIn(),
        const SizedBox(height: 28),

        if (_errorMsg != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.danger.withOpacity(0.4))),
            child: Row(children: [
              const Icon(Icons.error_outline, color: AppTheme.danger, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(_errorMsg!, style: GoogleFonts.cairo(
                fontSize: 12, color: AppTheme.danger))),
            ]),
          ).animate().shake(),

        Text(t.tr('emailLabel'), style: GoogleFonts.cairo(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSub)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'example@email.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20)),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return t.tr('errEnterEmail');
            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v.trim()))
              return t.tr('errInvalidEmail');
            return null;
          },
        ).animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: 24),

        GoldenButton(label: t.tr('sendResetLinkBtn'), icon: '📧',
          isLoading: _isLoading, onTap: _sendReset)
          .animate(delay: 250.ms).fadeIn().slideY(begin: 0.2, end: 0),
      ]),
    );
  }

  Widget _buildSuccessState(BannaaLocalizations t) {
    return Column(children: [
      const SizedBox(height: 20),
      Center(child: Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.success.withOpacity(0.3), width: 2)),
        child: const Center(child: Text('✉️', style: TextStyle(fontSize: 42))),
      )).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
      const SizedBox(height: 24),
      Text(t.tr('linkSent'), style: GoogleFonts.cairo(
        fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.success),
        textAlign: TextAlign.center).animate(delay: 200.ms).fadeIn(),
      const SizedBox(height: 10),
      Text('${t.tr('checkEmailReset')}${_emailCtrl.text.trim()}\n${t.tr('resetClickLink')}',
        style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted, height: 1.7),
        textAlign: TextAlign.center).animate(delay: 300.ms).fadeIn(),
      const SizedBox(height: 32),
      GoldenButton(
        label: t.tr('resendLink'), outline: true, icon: '🔄',
        onTap: () => setState(() { _emailSent = false; _emailCtrl.clear(); }))
        .animate(delay: 400.ms).fadeIn(),
      const SizedBox(height: 14),
      GoldenButton(label: t.tr('backToLogin'),
        onTap: () => Navigator.pop(context))
        .animate(delay: 450.ms).fadeIn(),
    ]);
  }
}
