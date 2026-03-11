import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── الألوان الرئيسية ──────────────────────────────────────────
  static const Color background = Color(0xFF0A0F1E);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color border = Color(0xFF1E293B);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFFCD34D);
  static const Color accentGlow = Color(0x26F59E0B);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSub = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── الخط العربي ──────────────────────────────────────────────
  static TextTheme get textTheme => GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(
            color: textPrimary, fontSize: 28, fontWeight: FontWeight.w800),
        headlineMedium: GoogleFonts.cairo(
            color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.cairo(
            color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.cairo(
            color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        bodyMedium: GoogleFonts.cairo(color: textSub, fontSize: 13),
        bodySmall: GoogleFonts.cairo(color: textMuted, fontSize: 11),
      );

  // ── الثيم الكامل ─────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentDark,
          surface: surface,
          error: danger,
        ),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.cairo(
              color: textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
          iconTheme: const IconThemeData(color: textPrimary),
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
          fillColor: surface,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accent, width: 1.5)),
          labelStyle: GoogleFonts.cairo(color: textMuted),
          hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 13),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: border)),
        ),
      );
}
