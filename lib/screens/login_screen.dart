// ══════════════════════════════════════════════════════════
//  screens/login_screen.dart — مع الترجمة الكاملة
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/common_widgets.dart';
import 'main_nav.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass     = true;
  bool _isLoading       = false;
  bool _isGoogleLoading = false;
  String? _errorMsg;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _errorMsg = null; });
    final result = await AuthService.loginWithEmail(
      email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) _goHome(); else setState(() => _errorMsg = result.errorMessage);
  }

  Future<void> _loginWithGoogle() async {
    setState(() { _isGoogleLoading = true; _errorMsg = null; });
    final result = await AuthService.loginWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    if (result.success) _goHome(); else setState(() => _errorMsg = result.errorMessage);
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const MainNav()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final t = BannaaLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                GoldenButton(label: t.tr('loginBtn'), isLoading: _isLoading, onTap: _login),
                const SizedBox(height: 20),
                _buildDivider(t),
                const SizedBox(height: 20),
                _buildGoogleButton(t),
                const SizedBox(height: 28),
                _buildRegisterLink(t),
                const SizedBox(height: 24),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BannaaLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.accent, AppTheme.accentDark]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(
              color: AppTheme.accent.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))]),
          child: const Center(child: Text('🏗️', style: TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.tr('appName'), style: GoogleFonts.cairo(
            fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
          Text(t.tr('appSubtitle'), style: GoogleFonts.cairo(
            fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ]).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
      const SizedBox(height: 32),
      Text(t.tr('welcomeBack'), style: GoogleFonts.cairo(
        fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))
        .animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),
      const SizedBox(height: 4),
      Text(t.tr('loginSubtitle'), style: GoogleFonts.cairo(
        fontSize: 13, color: AppTheme.textMuted))
        .animate(delay: 150.ms).fadeIn(),
    ]);
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withOpacity(0.4))),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(_errorMsg!, style: GoogleFonts.cairo(
          fontSize: 12, color: AppTheme.danger))),
      ]),
    ).animate().shake(duration: 400.ms);
  }

  Widget _buildEmailField(BannaaLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ),
    ]).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }

  Widget _buildPasswordField(BannaaLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t.tr('passwordLabel'), style: GoogleFonts.cairo(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSub)),
      const SizedBox(height: 6),
      TextFormField(
        controller: _passCtrl,
        obscureText: _obscurePass,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscurePass = !_obscurePass),
            icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppTheme.textMuted, size: 20))),
        validator: (v) {
          if (v == null || v.isEmpty) return t.tr('errEnterPassword');
          if (v.length < 6) return t.tr('errPasswordLength');
          return null;
        },
      ),
    ]).animate(delay: 250.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }

  Widget _buildForgotPassword(BannaaLocalizations t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
        child: Text(t.tr('forgotPassword'), style: GoogleFonts.cairo(
          fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600)),
      ),
    ).animate(delay: 300.ms).fadeIn();
  }

  Widget _buildDivider(BannaaLocalizations t) {
    return Row(children: [
      const Expanded(child: Divider(color: AppTheme.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(t.tr('orDivider'), style: GoogleFonts.cairo(
          fontSize: 12, color: AppTheme.textMuted))),
      const Expanded(child: Divider(color: AppTheme.border)),
    ]);
  }

  Widget _buildGoogleButton(BannaaLocalizations t) {
    return GestureDetector(
      onTap: _isGoogleLoading ? null : _loginWithGoogle,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border)),
        child: Center(
          child: _isGoogleLoading
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                _GoogleIcon(),
                const SizedBox(width: 10),
                Text(t.tr('googleSignInBtn'), style: GoogleFonts.cairo(
                  fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
              ]),
        ),
      ),
    ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildRegisterLink(BannaaLocalizations t) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(t.tr('noAccount'), style: GoogleFonts.cairo(
        fontSize: 13, color: AppTheme.textMuted)),
      GestureDetector(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const RegisterScreen())),
        child: Text(t.tr('createNewAccount'), style: GoogleFonts.cairo(
          fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w700)),
      ),
    ]).animate(delay: 400.ms).fadeIn();
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    SizedBox(width: 22, height: 22, child: CustomPaint(painter: _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(center, r, Paint()..color = Colors.white.withOpacity(0.08));
    final tp = TextPainter(
      text: const TextSpan(text: 'G',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(center.dx - tp.width/2, center.dy - tp.height/2));
  }
  @override
  bool shouldRepaint(_) => false;
}
