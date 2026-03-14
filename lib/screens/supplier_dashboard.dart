// ══════════════════════════════════════════════════════════
//  screens/supplier_dashboard.dart — المرحلة الثالثة
//  🏪 لوحة تحكم المورّد — متصلة بـ Firestore فعلياً
//  ✅ الطلبات الواردة بـ Stream حقيقي
//  ✅ إمكانية الرد على كل طلب
//  ✅ تغيير حالة الطلب (مشاهَد ← مردود عليه)
// ══════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote_request_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'auth_wrapper.dart';

class SupplierDashboard extends StatefulWidget {
  const SupplierDashboard({super.key});
  @override
  State<SupplierDashboard> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboard> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<List<QuoteRequest>>(
        stream: FirestoreService.incomingQuotesStream(),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];
          final pending =
              requests.where((r) => r.status == QuoteStatus.pending).length;

          return IndexedStack(
            index: _currentTab,
            children: [
              _SupplierHomeTab(requests: requests),
              _SupplierOrdersTab(requests: requests),
              const _SupplierOffersTab(),
              const _SupplierProfileTab(),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return StreamBuilder<List<QuoteRequest>>(
      stream: FirestoreService.incomingQuotesStream(),
      builder: (context, snapshot) {
        final pending = (snapshot.data ?? [])
            .where((r) => r.status == QuoteStatus.pending)
            .length;

        final tabs = [
          _NavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'الرئيسية'),
          _NavItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'الطلبات',
              badge: pending),
          _NavItem(
              icon: Icons.inventory_2_outlined,
              activeIcon: Icons.inventory_2_rounded,
              label: 'عروضي'),
          _NavItem(
              icon: Icons.storefront_outlined,
              activeIcon: Icons.storefront_rounded,
              label: 'متجري'),
        ];

        return Container(
          decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border))),
          child: SafeArea(
            child: SizedBox(
              height: 62,
              child: Row(
                children: List.generate(tabs.length, (i) {
                  final isActive = _currentTab == i;
                  final tab = tabs[i];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentTab = i),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(alignment: Alignment.topCenter, children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: 220.ms,
                                width: isActive ? 48 : 38,
                                height: isActive ? 30 : 26,
                                decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF3B82F6)
                                            .withOpacity(0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Icon(
                                        isActive ? tab.activeIcon : tab.icon,
                                        size: isActive ? 20 : 18,
                                        color: isActive
                                            ? const Color(0xFF3B82F6)
                                            : AppTheme.textMuted)),
                              ),
                              const SizedBox(height: 3),
                              Text(tab.label,
                                  style: GoogleFonts.cairo(
                                      fontSize: isActive ? 10 : 9,
                                      fontWeight: isActive
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                      color: isActive
                                          ? const Color(0xFF3B82F6)
                                          : AppTheme.textMuted)),
                            ]),
                        // badge عدد الطلبات
                        if (tab.badge > 0)
                          Positioned(
                            top: 6,
                            right: 14,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                  color: AppTheme.danger,
                                  shape: BoxShape.circle),
                              child: Center(
                                  child: Text(
                                      '${tab.badge > 9 ? '9+' : tab.badge}',
                                      style: GoogleFonts.cairo(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800))),
                            ),
                          ),
                      ]),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      this.badge = 0});
}

// ══════════════════════════════════════════════════════════
//  تاب الرئيسية
// ══════════════════════════════════════════════════════════
class _SupplierHomeTab extends StatelessWidget {
  final List<QuoteRequest> requests;
  const _SupplierHomeTab({required this.requests});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'المورّد';
    final pending =
        requests.where((r) => r.status == QuoteStatus.pending).length;
    final total = requests.length;
    final replied = requests
        .where((r) =>
            r.status == QuoteStatus.responded ||
            r.status == QuoteStatus.accepted)
        .length;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),

          // الرأس
          Row(children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                    borderRadius: BorderRadius.circular(14)),
                child: const Center(
                    child: Text('🏪', style: TextStyle(fontSize: 24)))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('مرحباً، $name',
                      style: GoogleFonts.cairo(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  Text('لوحة تحكم المورّد',
                      style: GoogleFonts.cairo(
                          fontSize: 11, color: AppTheme.textMuted)),
                ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppTheme.success, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('نشط',
                    style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: AppTheme.success,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ]).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // إحصائيات فعلية
          Text('إحصائياتك',
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSub)),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.65,
            children: [
              _StatCard(
                  label: 'طلبات جديدة',
                  value: '$pending',
                  icon: Icons.notifications_active_outlined,
                  color: pending > 0 ? AppTheme.danger : AppTheme.textMuted),
              _StatCard(
                  label: 'إجمالي الطلبات',
                  value: '$total',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFF3B82F6)),
              _StatCard(
                  label: 'ردود مرسلة',
                  value: '$replied',
                  icon: Icons.reply_outlined,
                  color: AppTheme.success),
              _StatCard(
                  label: 'التقييم',
                  value: '—',
                  icon: Icons.star_outline,
                  color: AppTheme.accent),
            ],
          ).animate(delay: 200.ms).fadeIn(),

          // آخر طلب
          if (requests.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text('أحدث طلب',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSub)),
            const SizedBox(height: 10),
            _QuotePreviewCard(request: requests.first),
          ],

          const SizedBox(height: 28),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  تاب الطلبات — الطلبات الواردة كاملة
// ══════════════════════════════════════════════════════════
class _SupplierOrdersTab extends StatelessWidget {
  final List<QuoteRequest> requests;
  const _SupplierOrdersTab({required this.requests});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(children: [
            Text('الطلبات الواردة',
                style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const Spacer(),
            if (requests.isNotEmpty)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${requests.length} طلب',
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w700))),
          ]),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: requests.isEmpty
              ? _EmptyOrders()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: requests.length,
                  itemBuilder: (_, i) =>
                      _IncomingQuoteCard(request: requests[i], index: i),
                ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة طلب واحد — للمورّد
// ══════════════════════════════════════════════════════════
class _IncomingQuoteCard extends StatelessWidget {
  final QuoteRequest request;
  final int index;
  const _IncomingQuoteCard({required this.request, required this.index});

  @override
  Widget build(BuildContext context) {
    final isNew = request.status == QuoteStatus.pending;
    final statusColor = _statusColor(request.status);

    return GestureDetector(
      onTap: () {
        // وضع علامة "مشاهَد"
        if (isNew) {
          FirestoreService.markQuoteAsViewed(request.id);
        }
        _showReplySheet(context, request);
      },
      child: AnimatedContainer(
        duration: 300.ms,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: isNew ? AppTheme.danger.withOpacity(0.04) : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color:
                    isNew ? AppTheme.danger.withOpacity(0.3) : AppTheme.border,
                width: isNew ? 1.5 : 1)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // أيقونة المستخدم
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text(
                          request.userName.isNotEmpty
                              ? request.userName[0].toUpperCase()
                              : '؟',
                          style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF3B82F6))))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Text(request.userName,
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      if (isNew) ...[
                        const SizedBox(width: 6),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: AppTheme.danger,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text('جديد',
                                style: GoogleFonts.cairo(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800))),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text('${request.projectName} • ${request.city}',
                        style: GoogleFonts.cairo(
                            fontSize: 10, color: AppTheme.textMuted)),
                  ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(request.status.label,
                        style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: statusColor,
                            fontWeight: FontWeight.w700))),
                const SizedBox(height: 4),
                Text(_formatDate(request.createdAt),
                    style: GoogleFonts.cairo(
                        fontSize: 9, color: AppTheme.textMuted)),
              ]),
            ]),

            // المواد
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: request.materials
                  .take(3)
                  .map((m) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.border)),
                        child: Text(
                            '${m.icon} ${m.name}: ${m.quantity.toStringAsFixed(0)} ${m.unit}',
                            style: GoogleFonts.cairo(
                                fontSize: 10, color: AppTheme.textSub)),
                      ))
                  .toList(),
            ),

            // ملاحظة
            if (request.note != null && request.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes_outlined,
                          color: AppTheme.textMuted, size: 12),
                      const SizedBox(width: 5),
                      Expanded(
                          child: Text(request.note!,
                              style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                  fontStyle: FontStyle.italic))),
                    ]),
              ),

            // زر الرد
            if (request.status == QuoteStatus.pending ||
                request.status == QuoteStatus.viewed)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: double.infinity,
                  height: 38,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.reply_outlined,
                        color: Colors.white, size: 15),
                    const SizedBox(width: 6),
                    Text('ردّ على هذا الطلب',
                        style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ])),
                ),
              ),
          ]),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 70)).slideY(
        begin: 0.08,
        end: 0,
        delay: Duration(milliseconds: index * 70),
        duration: 300.ms);
  }

  Color _statusColor(QuoteStatus s) {
    switch (s) {
      case QuoteStatus.pending:
        return AppTheme.danger;
      case QuoteStatus.viewed:
        return AppTheme.info;
      case QuoteStatus.responded:
        return AppTheme.accent;
      case QuoteStatus.accepted:
        return AppTheme.success;
      case QuoteStatus.rejected:
        return AppTheme.textMuted;
    }
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes}د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours}س';
    return 'منذ ${diff.inDays}ي';
  }

  void _showReplySheet(BuildContext context, QuoteRequest request) {
    if (request.status != QuoteStatus.pending &&
        request.status != QuoteStatus.viewed) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReplySheet(request: request),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  Sheet الرد على الطلب
// ══════════════════════════════════════════════════════════
class _ReplySheet extends StatefulWidget {
  final QuoteRequest request;
  const _ReplySheet({required this.request});

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  final _replyCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_replyCtrl.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    await FirestoreService.respondToQuote(
      quoteId: widget.request.id,
      userId: widget.request.userId,
      response: _replyCtrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تم إرسال ردّك بنجاح ✓',
              style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // handle
          Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('الرد على طلب ${widget.request.userName}',
                  style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              Text('${widget.request.projectName} • ${widget.request.city}',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: AppTheme.textMuted)),
              const SizedBox(height: 16),
              TextField(
                controller: _replyCtrl,
                maxLines: 4,
                autofocus: true,
                style: GoogleFonts.cairo(
                    color: AppTheme.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                    hintText:
                        'مثال: يسعدنا خدمتكم، سعر الإسمنت 48 ريال/كيس والرمل 140 ريال/م³...',
                    hintStyle: GoogleFonts.cairo(
                        color: AppTheme.textMuted, fontSize: 11),
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppTheme.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF3B82F6), width: 1.5))),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _isSending ? null : _send,
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                      gradient: _isSending
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                      color: _isSending ? AppTheme.border : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _isSending
                          ? null
                          : [
                              BoxShadow(
                                  color:
                                      const Color(0xFF3B82F6).withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 5))
                            ]),
                  child: Center(
                    child: _isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white)))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('إرسال الرد',
                                style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ]),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  بطاقة معاينة آخر طلب (في الرئيسية)
// ══════════════════════════════════════════════════════════
class _QuotePreviewCard extends StatelessWidget {
  final QuoteRequest request;
  const _QuotePreviewCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isNew = request.status == QuoteStatus.pending;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: isNew ? AppTheme.danger.withOpacity(0.05) : AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color:
                  isNew ? AppTheme.danger.withOpacity(0.25) : AppTheme.border)),
      child: Row(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(11)),
            child: Center(
                child: const Icon(Icons.receipt_long_outlined,
                    color: Color(0xFF3B82F6), size: 20))),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(request.projectName,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text('${request.userName} • ${request.city}',
              style:
                  GoogleFonts.cairo(fontSize: 10, color: AppTheme.textMuted)),
        ])),
        if (isNew)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: AppTheme.danger,
                  borderRadius: BorderRadius.circular(6)),
              child: Text('جديد',
                  style: GoogleFonts.cairo(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w800))),
      ]),
    ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.05, end: 0);
  }
}

// ══════════════════════════════════════════════════════════
//  تاب العروض (placeholder)
// ══════════════════════════════════════════════════════════
class _SupplierOffersTab extends StatelessWidget {
  const _SupplierOffersTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(children: [
            Text('عروض المواد',
                style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.add, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text('إضافة',
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
        Expanded(child: _EmptyOffers()),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  تاب الملف الشخصي
// ══════════════════════════════════════════════════════════
class _SupplierProfileTab extends StatelessWidget {
  const _SupplierProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'المورّد';
    final email = user?.email ?? '';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(children: [
              Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                      borderRadius: BorderRadius.circular(22)),
                  child: const Center(
                      child: Text('🏪', style: TextStyle(fontSize: 38)))),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.edit,
                          size: 13, color: Colors.black))),
            ]),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          Text(email,
              style:
                  GoogleFonts.cairo(fontSize: 12, color: AppTheme.textMuted)),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF3B82F6).withOpacity(0.3))),
            child: Text('مورّد معتمد',
                style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 24),
          _profileItem(Icons.storefront_outlined, 'بيانات المتجر',
              'الاسم، العنوان، التواصل'),
          _profileItem(Icons.category_outlined, 'تصنيفات المواد',
              'حدّد المواد التي تبيعها'),
          _profileItem(
              Icons.location_on_outlined, 'منطقة التغطية', 'المدن التي تخدمها'),
          _profileItem(
              Icons.notifications_outlined, 'الإشعارات', 'إعدادات التنبيهات'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (_) => false);
              }
            },
            child: Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.danger.withOpacity(0.3))),
              child: Center(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.logout, color: AppTheme.danger, size: 18),
                const SizedBox(width: 8),
                Text('تسجيل الخروج',
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppTheme.danger,
                        fontWeight: FontWeight.w700)),
              ])),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _profileItem(IconData icon, String label, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF3B82F6), size: 20),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text(sub,
              style:
                  GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
        ])),
        const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppTheme.textMuted),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  Widgets مشتركة
// ══════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Icon(icon, color: color, size: 18),
              Text(value,
                  style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary)),
            ]),
            Text(label,
                style:
                    GoogleFonts.cairo(fontSize: 11, color: AppTheme.textMuted)),
          ]),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📋', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text('لا توجد طلبات بعد',
              style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSub)),
          const SizedBox(height: 8),
          Text('ستظهر هنا طلبات عروض الأسعار\nمن المستخدمين',
              style: GoogleFonts.cairo(
                  fontSize: 12, color: AppTheme.textMuted, height: 1.6),
              textAlign: TextAlign.center),
        ]),
      ).animate().fadeIn(delay: 200.ms);
}

class _EmptyOffers extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📦', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text('لا توجد عروض بعد',
              style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSub)),
          const SizedBox(height: 8),
          Text('أضف أسعار موادك ليراها المستخدمون',
              style: GoogleFonts.cairo(
                  fontSize: 12, color: AppTheme.textMuted, height: 1.6),
              textAlign: TextAlign.center),
        ]),
      ).animate().fadeIn(delay: 200.ms);
}
