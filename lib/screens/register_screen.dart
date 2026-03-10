// ══════════════════════════════════════════════════════════
//  screens/register_screen.dart — مع الترجمة الكاملة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'main_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  bool _agreeToTerms   = false;
  String? _errorMsg;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final t = BannaaLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() => _errorMsg = t.tr('errAgreeTerms'));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await AuthService.registerWithEmail(
      name: _nameCtrl.text, email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) _showVerificationDialog();
    else setState(() => _errorMsg = result.errorMessage);
  }

  void _showVerificationDialog() {
    final t = BannaaLocalizations.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('📧', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 14),
            Text(t.tr('checkEmail'), style: GoogleFonts.cairo(
              fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('${t.tr('verifyEmailSent')}\n${_emailCtrl.text.trim()}',
              style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted, height: 1.6),
              textAlign: TextAlign.center),
            const SizedBox(height: 20),
            GoldenButton(
              label: t.tr('goToHome'),
              onTap: () => Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const MainNav()), (_) => false)),
          ]),
        ),
      ),
    );
  }

  double _passwordStrength(String pass) {
    if (pass.isEmpty) return 0;
    double s = 0;
    if (pass.length >= 6) s += 0.25;
    if (pass.length >= 10) s += 0.25;
    if (pass.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (pass.contains(RegExp(r'[0-9!@#\$%^&*]'))) s += 0.25;
    return s;
  }

  Color _strengthColor(double s) {
    if (s <= 0.25) return AppTheme.danger;
    if (s <= 0.5) return Colors.orange;
    if (s <= 0.75) return Colors.yellow;
    return AppTheme.success;
  }

  String _strengthLabel(double s, BannaaLocalizations t) {
    if (s <= 0.25) return t.tr('passStrengthWeak2');
    if (s <= 0.5)  return t.tr('passStrengthWeak');
    if (s <= 0.75) return t.tr('passStrengthMedium');
    return t.tr('passStrengthStrong');
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    final passStr = _passwordStrength(_passCtrl.text);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            ScreenHeader(title: t.tr('createAccount')).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 24),
            Text(t.tr('welcomeRegister'), style: GoogleFonts.cairo(
              fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))
              .animate(delay: 100.ms).fadeIn(),
            Text(t.tr('registerSubtitle'), style: GoogleFonts.cairo(
              fontSize: 12, color: AppTheme.textMuted))
              .animate(delay: 150.ms).fadeIn(),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(children: [
                // رسالة الخطأ
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

                _buildField(label: t.tr('fullName'), hint: t.tr('fullNameHint'),
                  controller: _nameCtrl, icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().length < 3) ? t.tr('errNameLength') : null,
                  delay: 200),
                const SizedBox(height: 14),

                _buildField(label: t.tr('emailLabel'), hint: 'example@email.com',
                  controller: _emailCtrl, icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress, isLtr: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return t.tr('errEnterEmail');
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(v.trim()))
                      return t.tr('errInvalidEmail');
                    return null;
                  }, delay: 250),
                const SizedBox(height: 14),

                _buildField(label: t.tr('passwordLabel'), hint: '••••••••',
                  controller: _passCtrl, icon: Icons.lock_outline,
                  isPassword: true, obscure: _obscurePass,
                  onToggleObscure: () => setState(() => _obscurePass = !_obscurePass),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return t.tr('errEnterPassword');
                    if (v.length < 6) return t.tr('errPasswordLength');
                    return null;
                  }, delay: 300),

                if (_passCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: passStr, minHeight: 4,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation(_strengthColor(passStr))))),
                    const SizedBox(width: 8),
                    Text(_strengthLabel(passStr, t), style: GoogleFonts.cairo(
                      fontSize: 10, color: _strengthColor(passStr))),
                  ]),
                ],
                const SizedBox(height: 14),

                _buildField(label: t.tr('confirmPassword'), hint: '••••••••',
                  controller: _confirmCtrl, icon: Icons.lock_outline,
                  isPassword: true, obscure: _obscureConfirm,
                  onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) => v != _passCtrl.text ? t.tr('errPasswordMatch') : null,
                  delay: 350),
                const SizedBox(height: 16),

                // الموافقة على الشروط
                GestureDetector(
                  onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AnimatedContainer(
                      duration: 200.ms, width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: _agreeToTerms ? AppTheme.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _agreeToTerms ? AppTheme.accent : AppTheme.border)),
                      child: _agreeToTerms
                        ? const Icon(Icons.check, color: Colors.black, size: 14) : null),
                    const SizedBox(width: 10),
                    Expanded(child: Text(t.tr('agreeToTerms'), style: GoogleFonts.cairo(
                      fontSize: 12, color: AppTheme.textSub))),
                  ]),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 24),

                GoldenButton(label: t.tr('registerBtn'), icon: '✓',
                  isLoading: _isLoading, onTap: _register)
                  .animate(delay: 450.ms).fadeIn().slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(t.tr('hasAccount'), style: GoogleFonts.cairo(
                    fontSize: 13, color: AppTheme.textMuted)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(t.tr('goToLogin'), style: GoogleFonts.cairo(
                      fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w700))),
                ]).animate(delay: 500.ms).fadeIn(),
                const SizedBox(height: 24),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label, required String hint,
    required TextEditingController controller, required IconData icon,
    String? Function(String?)? validator, TextInputType? keyboardType,
    bool isPassword = false, bool isLtr = false, bool obscure = false,
    VoidCallback? onToggleObscure, Function(String)? onChanged, required int delay,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.cairo(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSub)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller, keyboardType: keyboardType,
        obscureText: obscure,
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        textAlign: isLtr ? TextAlign.left : TextAlign.right,
        onChanged: onChanged,
        style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
          suffixIcon: isPassword && onToggleObscure != null
            ? IconButton(
                onPressed: onToggleObscure,
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.textMuted, size: 20))
            : null),
      ),
    ]).animate(delay: Duration(milliseconds: delay)).fadeIn().slideY(begin: 0.15, end: 0);
  }
}
