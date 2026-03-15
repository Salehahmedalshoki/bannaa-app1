import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── الألوان الداكنة (Default) ─────────────────────────────────
  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceDark2 = Color(0xFF0F172A);
  static const Color border = borderDark;
  static const Color backgroundDark = Color(0xFF0A0F1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLight2 = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFF1E293B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimary = textPrimaryDark;
  static const Color textSub = textSubDark;
  static const Color textMuted = textMutedDark;
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSubDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSubLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  // ── الألوان المشتركة ───────────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFCD34D);
  static const Color accentGlow = Color(0x26F59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── الحصول على الألوان بناءً على الوضع ─────────────────────────
  static Color backgroundColor(bool isDark) =>
      isDark ? backgroundDark : backgroundLight;
  static Color surfaceColor(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color surfaceColor2(bool isDark) =>
      isDark ? surfaceDark2 : surfaceLight2;
  static Color borderColor(bool isDark) => isDark ? borderDark : borderLight;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSubColor(bool isDark) => isDark ? textSubDark : textSubLight;
  static Color textMutedColor(bool isDark) =>
      isDark ? textMutedDark : textMutedLight;

  // ── الخط العربي ─────────────────────────────────────────────
  static TextTheme getTextTheme(bool isDark) {
    final primary = isDark ? textPrimaryDark : textPrimaryLight;
    final sub = isDark ? textSubDark : textSubLight;
    final muted = isDark ? textMutedDark : textMutedLight;

    return GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.cairo(
          color: primary, fontSize: 28, fontWeight: FontWeight.w800),
      headlineMedium: GoogleFonts.cairo(
          color: primary, fontSize: 20, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.cairo(
          color: primary, fontSize: 16, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.cairo(
          color: primary, fontSize: 14, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.cairo(color: sub, fontSize: 13),
      bodySmall: GoogleFonts.cairo(color: muted, fontSize: 11),
    );
  }

  // ── الثيم الداكن ─────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(true);

  // ── الثيم الفاتح ─────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(false);

  static ThemeData _buildTheme(bool isDark) {
    final bg = isDark ? backgroundDark : backgroundLight;
    final surf = isDark ? surfaceDark : surfaceLight;
    final bord = isDark ? borderDark : borderLight;
    final txtPrimary = isDark ? textPrimaryDark : textPrimaryLight;
    final txtMuted = isDark ? textMutedDark : textMutedLight;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accentDark,
        surface: surf,
        error: danger,
      ),
      textTheme: getTextTheme(isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
            color: txtPrimary, fontSize: 17, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: txtPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          textStyle:
              GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surf,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: bord)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: bord)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 1.5)),
        labelStyle: GoogleFonts.cairo(color: txtMuted),
        hintStyle: GoogleFonts.cairo(color: txtMuted, fontSize: 13),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: bord)),
      ),
    );
  }
}
