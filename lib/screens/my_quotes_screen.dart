// ══════════════════════════════════════════════════════════
//  screens/my_quotes_screen.dart — المرحلة الثالثة
//  📋 شاشة طلبات عروض الأسعار للمستخدم العادي
//  ✅ Stream مباشر من Firestore
//  ✅ حالة الطلب (انتظار / مشاهَد / مردود عليه)
//  ✅ عرض رد المورّد مع إمكانية القبول / الرفض
// ══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote_request_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class MyQuotesScreen extends StatelessWidget {
  const MyQuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(children: [
          // ── الرأس ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border)),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: AppTheme.textMuted, size: 14)),
              ),
              const SizedBox(width: 12),
              Text('طلبات عروض الأسعار',
                  style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
            ]),
          ),
          const SizedBox(height: 4),

          // ── المحتوى ──
          Expanded(
            child: StreamBuilder<List<QuoteRequest>>(
              stream: FirestoreService.myQuoteRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(AppTheme.accent)));
                }
                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return _EmptyQuotes();
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                  itemCount: requests.length,
                  itemBuilder: (_, i) => _QuoteCard(
                    request: requests[i],
                    index: i,
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة طلب واحد
// ══════════════════════════════════════════════════════════
class _QuoteCard extends StatelessWidget {
  final QuoteRequest request;
  final int index;

  const _QuoteCard({required this.request, required this.index});

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    final statusColor = _statusColor(status);
    final hasReply = status == QuoteStatus.responded ||
        status == QuoteStatus.accepted ||
        status == QuoteStatus.rejected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasReply
                  ? statusColor.withValues(alpha: 0.35)
                  : AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── رأس البطاقة ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(children: [
            // أيقونة المشروع
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: AppTheme.accentGlow,
                    borderRadius: BorderRadius.circular(12)),
                child: const Center(
                    child: Text('📋', style: TextStyle(fontSize: 20)))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(request.projectName,
                      style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(request.city,
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted)),
                ])),
            // بادج الحالة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(status.label,
                    style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ),

        // ── قائمة المواد المطلوبة ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: request.materials
                .take(4)
                .map((m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(m.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text('${m.quantity.toStringAsFixed(0)} ${m.unit}',
                            style: GoogleFonts.cairo(
                                fontSize: 10, color: AppTheme.textSub)),
                      ]),
                    ))
                .toList(),
          ),
        ),

        // ── ملاحظة المستخدم ──
        if (request.note != null && request.note!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.notes_outlined,
                    color: AppTheme.textMuted, size: 14),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(request.note!,
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: AppTheme.textMuted))),
              ]),
            ),
          ),

        // ── رد المورّد ──
        if (hasReply && request.supplierResponse != null) ...[
          const Padding(
              padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Divider(color: AppTheme.border, height: 1)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle),
                    child: Icon(Icons.storefront_outlined,
                        color: statusColor, size: 13)),
                const SizedBox(width: 8),
                Text('رد المورّد',
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor)),
              ]),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.2))),
                child: Text(request.supplierResponse!,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.5)),
              ),
            ]),
          ),

          // أزرار القبول / الرفض
          if (status == QuoteStatus.responded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(children: [
                Expanded(
                    child: _ActionButton(
                  label: 'قبول العرض',
                  color: AppTheme.success,
                  icon: Icons.check_circle_outline,
                  onTap: () {},
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _ActionButton(
                  label: 'رفض',
                  color: AppTheme.danger,
                  icon: Icons.cancel_outlined,
                  onTap: () {},
                )),
              ]),
            ),
        ],

        // ── التذييل: التاريخ ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: Text(_formatDate(request.createdAt),
              style:
                  GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
        ),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 80)).slideY(
        begin: 0.1,
        end: 0,
        delay: Duration(milliseconds: index * 80),
        duration: 350.ms);
  }

  Color _statusColor(QuoteStatus s) {
    switch (s) {
      case QuoteStatus.pending:
        return AppTheme.textMuted;
      case QuoteStatus.viewed:
        return AppTheme.info;
      case QuoteStatus.responded:
        return AppTheme.accent;
      case QuoteStatus.accepted:
        return AppTheme.success;
      case QuoteStatus.rejected:
        return AppTheme.danger;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ══════════════════════════════════════════════════════════
//  زر القبول / الرفض
// ══════════════════════════════════════════════════════════
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  حالة فارغة
// ══════════════════════════════════════════════════════════
class _EmptyQuotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📬', style: TextStyle(fontSize: 52))
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
                begin: const Offset(0.92, 0.92),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
                curve: Curves.easeInOut),
        const SizedBox(height: 16),
        Text('لا توجد طلبات بعد',
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSub)),
        const SizedBox(height: 8),
        Text('اطلب عرض سعر من شاشة النتائج\nبعد حساب كميات مشروعك',
            style: GoogleFonts.cairo(
                fontSize: 12, color: AppTheme.textMuted, height: 1.6),
            textAlign: TextAlign.center),
      ]),
    ).animate().fadeIn(delay: 200.ms);
  }
}
