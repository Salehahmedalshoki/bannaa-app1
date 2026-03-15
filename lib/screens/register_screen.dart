// ══════════════════════════════════════════════════════════
//  screens/register_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة (إضافةً لما كان موجوداً):
//  ✅ #4  mounted check قبل _showSuccessDialog() مباشرة
//  ✅ #5  dialog: guard ضد الضغط المتكرر على زر الانتقال
//  ✅ #6  dialog: barrierColor داكن يتناسب مع ثيم التطبيق
//  ✅ #7  جميع النصوص المُضمَّنة نُقلت لنظام الترجمة t.tr()
//  ✅ #8  _passStrength تُحسب مرة في onChanged وتُخزَّن في state
//  ✅ #9  textInputAction على جميع الحقول (Next → Next → Next → Done)
//  ✅ #10 حقل كلمة المرور يُعيد validate الحقل الثاني لحظيًا
//  ✅ #11 AutovalidateMode.onUserInteraction للـ Form
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'main_nav.dart';
import 'supplier_dashboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // ✅ #9 — FocusNodes للتنقل بين الحقول
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String _userType = 'user';
  String? _errorMsg;

  // ✅ #8 — قوة كلمة المرور تُحسب مرة وتُخزَّن
  double _passStrength = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════
  //  منطق قوة كلمة المرور
  // ══════════════════════════════════════════════════════
  double _calcStrength(String pass) {
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
    if (s <= 0.50) return Colors.orange;
    if (s <= 0.75) return Colors.yellow;
    return AppTheme.success;
  }

  String _strengthLabel(double s, BannaaLocalizations t) {
    if (s <= 0.25) return t.tr('passStrengthWeak2');
    if (s <= 0.50) return t.tr('passStrengthWeak');
    if (s <= 0.75) return t.tr('passStrengthMedium');
    return t.tr('passStrengthStrong');
  }

  // ══════════════════════════════════════════════════════
  //  التسجيل
  // ══════════════════════════════════════════════════════
  Future<void> _register() async {
    final t = BannaaLocalizations.of(context);
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() => _errorMsg = t.tr('errAgreeTerms'));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await AuthService.registerWithEmail(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      userType: _userType,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (!mounted) return; // ✅ #4
      _showSuccessDialog();
    } else {
      setState(() => _errorMsg = result.errorMessage);
    }
  }

  // ══════════════════════════════════════════════════════
  //  ✅ #5 #6 #7 — dialog النجاح المُصحَّح
  // ══════════════════════════════════════════════════════
  void _showSuccessDialog() {
    final t = BannaaLocalizations.of(context);
    final isSupplier = _userType == 'supplier';
    final userName = _nameCtrl.text.trim();
    bool _navigating = false; // ✅ #5 guard داخل الـ dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75), // ✅ #6
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              isSupplier ? '🏪' : '✅',
              style: const TextStyle(fontSize: 52),
            ),
            const SizedBox(height: 14),
            Text(
              // ✅ #7
              isSupplier
                  ? t.tr('successSupplierTitle')
                  : t.tr('successUserTitle'),
              style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              // ✅ #7 — اسم المستخدم يُمرَّر عبر replaceAll
              isSupplier
                  ? t.tr('successSupplierBody')
                  : t.tr('successUserBody').replaceAll('{name}', userName),
              style: GoogleFonts.cairo(
                  fontSize: 12, color: AppTheme.textMuted, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GoldenButton(
              // ✅ #7
              label: isSupplier ? t.tr('goDashboardBtn') : t.tr('startNowBtn'),
              onTap: () {
                // ✅ #5 — منع الضغط المتكرر
                if (_navigating) return;
                _navigating = true;
                Navigator.pushAndRemoveUntil(
                  // استخدام dialogCtx لضمان context صحيح
                  dialogCtx,
                  MaterialPageRoute(
                    builder: (_) => isSupplier
                        ? const SupplierDashboard()
                        : const MainNav(),
                  ),
                  (_) => false,
                );
              },
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  البناء
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              ScreenHeader(title: t.tr('createAccount'))
                  .animate()
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 24),

              Text(t.tr('welcomeRegister'),
                      style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary))
                  .animate(delay: 100.ms)
                  .fadeIn(),
              Text(t.tr('registerSubtitle'),
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: AppTheme.textMuted))
                  .animate(delay: 150.ms)
                  .fadeIn(),

              const SizedBox(height: 24),

              // ── اختيار نوع الحساب ──────────────────────
              // ✅ #7
              Text(t.tr('accountTypeLabel'),
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSub))
                  .animate(delay: 170.ms)
                  .fadeIn(),
              const SizedBox(height: 10),

              Row(children: [
                Expanded(
                  child: _UserTypeCard(
                    emoji: '👤',
                    title: t.tr('badgeUser'), // ✅ #7
                    subtitle: t.tr('userCardSub'), // ✅ #7
                    isSelected: _userType == 'user',
                    accentColor: AppTheme.accent,
                    onTap: () => setState(() {
                      _userType = 'user';
                      _errorMsg = null;
                    }),
                  ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.1, end: 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _UserTypeCard(
                    emoji: '🏪',
                    title: t.tr('badgeSupplier'), // ✅ #7
                    subtitle: t.tr('supplierCardSub'), // ✅ #7
                    isSelected: _userType == 'supplier',
                    accentColor: const Color(0xFF3B82F6),
                    onTap: () => setState(() {
                      _userType = 'supplier';
                      _errorMsg = null;
                    }),
                  ).animate(delay: 240.ms).fadeIn().slideX(begin: 0.1, end: 0),
                ),
              ]),

              const SizedBox(height: 24),

              // ✅ #11 — AutovalidateMode للـ Form
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(children: [
                  if (_errorMsg != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppTheme.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.danger.withValues(alpha: 0.4))),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.danger, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_errorMsg!,
                                style: GoogleFonts.cairo(
                                    fontSize: 12, color: AppTheme.danger))),
                      ]),
                    ).animate().shake(),

                  // ── حقل الاسم ──────────────────────────
                  _buildField(
                    label: _userType == 'supplier'
                        ? t.tr('supplierNameLabel') // ✅ #7
                        : t.tr('fullName'),
                    hint: _userType == 'supplier'
                        ? t.tr('supplierNameHint') // ✅ #7
                        : t.tr('fullNameHint'),
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    icon: _userType == 'supplier'
                        ? Icons.storefront_outlined
                        : Icons.person_outline,
                    textInputAction: TextInputAction.next, // ✅ #9
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocus),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? t.tr('errNameLength')
                        : null,
                    delay: 280,
                  ),
                  const SizedBox(height: 14),

                  // ── حقل الإيميل ─────────────────────────
                  _buildField(
                    label: t.tr('emailLabel'),
                    hint: 'example@email.com',
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isLtr: true,
                    textInputAction: TextInputAction.next, // ✅ #9
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passFocus),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return t.tr('errEnterEmail');
                      if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.+-]+$')
                          .hasMatch(v.trim())) return t.tr('errInvalidEmail');
                      return null;
                    },
                    delay: 320,
                  ),
                  const SizedBox(height: 14),

                  // ── حقل كلمة المرور ─────────────────────
                  _buildField(
                    label: t.tr('passwordLabel'),
                    hint: '••••••••',
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscure: _obscurePass,
                    onToggleObscure: () =>
                        setState(() => _obscurePass = !_obscurePass),
                    textInputAction: TextInputAction.next, // ✅ #9
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_confirmFocus),
                    // ✅ #8 #10 — حساب القوة + إعادة validate الحقل الثاني
                    onChanged: (v) {
                      setState(() => _passStrength = _calcStrength(v));
                      // أعد التحقق من حقل التأكيد فوراً
                      _formKey.currentState?.validate();
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return t.tr('errEnterPassword');
                      if (v.length < 6) return t.tr('errPasswordLength');
                      return null;
                    },
                    delay: 360,
                  ),

                  // ── مؤشر قوة كلمة المرور ────────────────
                  if (_passCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                  value: _passStrength, // ✅ #8 من state
                                  minHeight: 4,
                                  backgroundColor: AppTheme.border,
                                  valueColor: AlwaysStoppedAnimation(
                                      _strengthColor(_passStrength))))),
                      const SizedBox(width: 8),
                      Text(_strengthLabel(_passStrength, t),
                          style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: _strengthColor(_passStrength))),
                    ]),
                  ],
                  const SizedBox(height: 14),

                  // ── حقل تأكيد كلمة المرور ───────────────
                  _buildField(
                    label: t.tr('confirmPassword'),
                    hint: '••••••••',
                    controller: _confirmCtrl,
                    focusNode: _confirmFocus,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscure: _obscureConfirm,
                    onToggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    textInputAction: TextInputAction.done, // ✅ #9
                    onSubmitted: (_) => _isLoading ? null : _register(),
                    // ✅ #10 — مقارنة صحيحة دائماً
                    validator: (v) =>
                        v != _passCtrl.text ? t.tr('errPasswordMatch') : null,
                    delay: 400,
                  ),
                  const SizedBox(height: 16),

                  // ── الموافقة على الشروط ─────────────────
                  GestureDetector(
                    onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                              duration: 200.ms,
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: _agreeToTerms
                                      ? AppTheme.accent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: _agreeToTerms
                                          ? AppTheme.accent
                                          : AppTheme.border)),
                              child: _agreeToTerms
                                  ? const Icon(Icons.check,
                                      color: Colors.black, size: 14)
                                  : null),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(t.tr('agreeToTerms'),
                                  style: GoogleFonts.cairo(
                                      fontSize: 12, color: AppTheme.textSub))),
                        ]),
                  ).animate(delay: 440.ms).fadeIn(),
                  const SizedBox(height: 24),

                  // ── زر التسجيل ──────────────────────────
                  GoldenButton(
                    // ✅ #7
                    label: _userType == 'supplier'
                        ? t.tr('registerSupplierBtn')
                        : t.tr('registerBtn'),
                    icon: '✓',
                    isLoading: _isLoading,
                    onTap: _isLoading ? null : _register,
                  ).animate(delay: 480.ms).fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),

                  // ── رابط تسجيل الدخول ───────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.tr('hasAccount'),
                          style: GoogleFonts.cairo(
                              fontSize: 13, color: AppTheme.textMuted)),
                      GestureDetector(
                          onTap:
                              _isLoading ? null : () => Navigator.pop(context),
                          child: Text(t.tr('goToLogin'),
                              style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: _isLoading
                                      ? AppTheme.textMuted
                                      : AppTheme.accent,
                                  fontWeight: FontWeight.w700))),
                    ],
                  ).animate(delay: 520.ms).fadeIn(),
                  const SizedBox(height: 24),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  دالة بناء الحقول المشتركة
  // ══════════════════════════════════════════════════════
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    bool isPassword = false,
    bool isLtr = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    void Function(String)? onChanged,
    required int delay,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSub)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscure,
        textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
        textAlign: isLtr ? TextAlign.left : TextAlign.right,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        onChanged: onChanged,
        style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
        validator: validator,
        decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
            suffixIcon: isPassword && onToggleObscure != null
                ? IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted,
                        size: 20))
                : null),
      ),
    ])
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn()
        .slideY(begin: 0.15, end: 0);
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة نوع الحساب
// ══════════════════════════════════════════════════════════
class _UserTypeCard extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.10)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : AppTheme.border,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: accentColor.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? accentColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? accentColor : AppTheme.border,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 13)
                    : null,
              ),
            ]),
            const SizedBox(height: 10),
            Text(title,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? accentColor : AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: AppTheme.textMuted, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
