// ══════════════════════════════════════════════════════════
//  screens/login_screen.dart  ✅ نسخة مُصحَّحة
//
//  الإصلاحات المطبّقة (إضافةً لما كان موجوداً):
//  ✅ #7 try/catch + timeout في _routeByUserType() — لا تجميد
//  ✅ #8 شاشة _isRouting مستخرجة كـ widget ثابت — لا وميض
//  ✅ #9 نصوص البادجات عبر نظام الترجمة t.tr()
//  ✅ #10 حقل كلمة المرور يُرسل النموذج عند الضغط على Done
// ══════════════════════════════════════════════════════════

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'main_nav.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'supplier_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isRouting = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  bool get _anyLoading => _isLoading || _isGoogleLoading || _isRouting;

  // ══════════════════════════════════════════════════════
  //  تسجيل الدخول بالإيميل
  // ══════════════════════════════════════════════════════
  Future<void> _login() async {
    if (_anyLoading) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final result = await AuthService.loginWithEmail(
        email: _emailCtrl.text, password: _passCtrl.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      await _routeByUserType();
    } else {
      setState(() => _errorMsg = result.errorMessage);
    }
  }

  // ══════════════════════════════════════════════════════
  //  تسجيل الدخول بـ Google
  // ══════════════════════════════════════════════════════
  Future<void> _loginWithGoogle() async {
    if (_anyLoading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isGoogleLoading = true;
      _errorMsg = null;
    });

    final result = await AuthService.loginWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (result.success) {
      await _routeByUserType();
    } else {
      if (result.errorMessage != 'cancelled') {
        setState(() => _errorMsg = result.errorMessage);
      }
    }
  }

  // ══════════════════════════════════════════════════════
  //  ✅ #7 التوجيه بعد النجاح — محمي بـ try/catch + timeout
  // ══════════════════════════════════════════════════════
  Future<void> _routeByUserType() async {
    setState(() => _isRouting = true);

    try {
      final userType = await FirestoreService.getUserType()
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => userType == 'supplier'
                ? const SupplierDashboard()
                : const MainNav()),
        (_) => false,
      );
    } catch (_) {
      // ✅ فشل جلب النوع → fallback آمن كـ MainNav + رسالة خطأ
      if (!mounted) return;
      setState(() {
        _isRouting = false;
        _errorMsg = 'تعذّر الاتصال — تحقق من الإنترنت وحاول مجدداً';
      });
    }
  }

  // ══════════════════════════════════════════════════════
  //  البناء
  // ══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);

    // ✅ #8 — widget ثابت لا يُعاد بناؤه عند كل setState
    if (_isRouting) return const _RoutingLoader();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(t),
              const SizedBox(height: 36),
              Form(
                key: _formKey,
                child: Column(children: [
                  if (_errorMsg != null) _buildErrorBanner(),
                  _buildEmailField(t),
                  const SizedBox(height: 14),
                  _buildPasswordField(t),
                  const SizedBox(height: 10),
                  _buildForgotPassword(t),
                  const SizedBox(height: 24),
                  GoldenButton(
                      label: t.tr('loginBtn'),
                      isLoading: _isLoading,
                      onTap: _anyLoading ? null : _login),
                  const SizedBox(height: 20),
                  _buildDivider(t),
                  const SizedBox(height: 20),
                  _buildGoogleButton(t),
                  const SizedBox(height: 28),
                  _buildRegisterLink(t),
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
  //  الرأس
  // ══════════════════════════════════════════════════════
  Widget _buildHeader(BannaaLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentDark]),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6))
              ]),
          child:
              const Center(child: Text('🏗️', style: TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.tr('appName'),
              style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary)),
          Text(t.tr('appSubtitle'),
              style:
                  GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ]).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
      const SizedBox(height: 32),
      Text(t.tr('welcomeBack'),
              style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary))
          .animate(delay: 100.ms)
          .fadeIn()
          .slideY(begin: 0.2, end: 0),
      const SizedBox(height: 4),
      Text(t.tr('loginSubtitle'),
              style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.textMuted))
          .animate(delay: 150.ms)
          .fadeIn(),
      const SizedBox(height: 16),
      // ✅ #9 — نصوص البادجات عبر الترجمة
      Row(children: [
        _LoginBadge(
            icon: Icons.person_outline,
            label: t.tr('badgeUser'),
            color: AppTheme.accent),
        const SizedBox(width: 8),
        _LoginBadge(
            icon: Icons.storefront_outlined,
            label: t.tr('badgeSupplier'),
            color: const Color(0xFF3B82F6)),
      ]).animate(delay: 200.ms).fadeIn(),
    ]);
  }

  // ══════════════════════════════════════════════════════
  //  بانر الخطأ
  // ══════════════════════════════════════════════════════
  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.danger.withValues(alpha: 0.4))),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(_errorMsg!,
                style:
                    GoogleFonts.cairo(fontSize: 12, color: AppTheme.danger))),
      ]),
    ).animate().shake(duration: 400.ms);
  }

  // ══════════════════════════════════════════════════════
  //  حقل الإيميل
  // ══════════════════════════════════════════════════════
  Widget _buildEmailField(BannaaLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t.tr('emailLabel'),
          style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSub)),
      const SizedBox(height: 6),
      TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        // ✅ #10 — الانتقال لحقل كلمة المرور بـ Tab/Next
        textInputAction: TextInputAction.next,
        style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
        decoration: const InputDecoration(
            hintText: 'example@email.com',
            prefixIcon: Icon(Icons.email_outlined,
                color: AppTheme.textMuted, size: 20)),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return t.tr('errEnterEmail');
          if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.+-]+$').hasMatch(v.trim())) {
            return t.tr('errInvalidEmail');
          }
          return null;
        },
      ),
    ]).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }

  // ══════════════════════════════════════════════════════
  //  حقل كلمة المرور
  // ══════════════════════════════════════════════════════
  Widget _buildPasswordField(BannaaLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t.tr('passwordLabel'),
          style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSub)),
      const SizedBox(height: 6),
      TextFormField(
        controller: _passCtrl,
        obscureText: _obscurePass,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        // ✅ #10 — الضغط على Done يُرسل النموذج مباشرة
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _anyLoading ? null : _login(),
        style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline,
                color: AppTheme.textMuted, size: 20),
            suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                icon: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textMuted,
                    size: 20))),
        validator: (v) {
          if (v == null || v.isEmpty) return t.tr('errEnterPassword');
          if (v.length < 6) return t.tr('errPasswordLength');
          return null;
        },
      ),
    ]).animate(delay: 250.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }

  // ══════════════════════════════════════════════════════
  //  نسيت كلمة المرور
  // ══════════════════════════════════════════════════════
  Widget _buildForgotPassword(BannaaLocalizations t) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: _anyLoading
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen())),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(t.tr('forgotPassword'),
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: _anyLoading ? AppTheme.textMuted : AppTheme.accent,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    ).animate(delay: 300.ms).fadeIn();
  }

  // ══════════════════════════════════════════════════════
  //  الفاصل
  // ══════════════════════════════════════════════════════
  Widget _buildDivider(BannaaLocalizations t) {
    return Row(children: [
      const Expanded(child: Divider(color: AppTheme.border)),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(t.tr('orDivider'),
              style:
                  GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted))),
      const Expanded(child: Divider(color: AppTheme.border)),
    ]);
  }

  // ══════════════════════════════════════════════════════
  //  زر Google
  // ══════════════════════════════════════════════════════
  Widget _buildGoogleButton(BannaaLocalizations t) {
    return GestureDetector(
      onTap: _anyLoading ? null : _loginWithGoogle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _anyLoading
                    ? AppTheme.border.withValues(alpha: 0.4)
                    : AppTheme.border)),
        child: Center(
          child: _isGoogleLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppTheme.accent))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  const _GoogleIcon(),
                  const SizedBox(width: 10),
                  Text(t.tr('googleSignInBtn'),
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: _anyLoading
                              ? AppTheme.textMuted
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600)),
                ]),
        ),
      ),
    ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  // ══════════════════════════════════════════════════════
  //  رابط إنشاء حساب
  // ══════════════════════════════════════════════════════
  Widget _buildRegisterLink(BannaaLocalizations t) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(t.tr('noAccount'),
          style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.textMuted)),
      GestureDetector(
        onTap: _anyLoading
            ? null
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RegisterScreen())),
        child: Text(t.tr('createNewAccount'),
            style: GoogleFonts.cairo(
                fontSize: 13,
                color: _anyLoading ? AppTheme.textMuted : AppTheme.accent,
                fontWeight: FontWeight.w700)),
      ),
    ]).animate(delay: 400.ms).fadeIn();
  }
}

// ══════════════════════════════════════════════════════════
//  ✅ #8 شاشة التوجيه — widget ثابت لا يُعاد بناء أنيميشنه
// ══════════════════════════════════════════════════════════
class _RoutingLoader extends StatelessWidget {
  const _RoutingLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accentDark]),
                borderRadius: BorderRadius.circular(20)),
            child: const Center(
                child: Text('🏗️', style: TextStyle(fontSize: 34))),
          ).animate().scale(
              begin: const Offset(0.8, 0.8),
              duration: 600.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppTheme.accent))),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  Badge نوع الحساب
// ══════════════════════════════════════════════════════════
class _LoginBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _LoginBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  أيقونة Google الحقيقية بالألوان الأربعة
// ══════════════════════════════════════════════════════════
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 22, height: 22, child: CustomPaint(painter: _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = const Color(0xFFDDDDDD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5);

    const blue = Color(0xFF4285F4);
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);

    final strokeW = size.width * 0.14;
    final innerR = r - strokeW / 2 - 1.5;

    Paint arcPaint(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: innerR);
    canvas.drawArc(rect, -math.pi / 4, math.pi * 1.5, false, arcPaint(blue));
    canvas.drawArc(rect, -math.pi * 5 / 4, math.pi / 2, false, arcPaint(red));
    canvas.drawArc(
        rect, -math.pi * 3 / 4, math.pi / 4, false, arcPaint(yellow));
    canvas.drawArc(rect, -math.pi / 2, math.pi * 3 / 4, false, arcPaint(green));

    canvas.drawLine(
        Offset(cx + 0.5, cy),
        Offset(cx + r - strokeW * 0.3, cy),
        Paint()
          ..color = blue
          ..strokeWidth = strokeW * 0.85
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_GooglePainter old) => false;
}
