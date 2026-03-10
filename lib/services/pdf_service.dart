// ══════════════════════════════════════════════════════════
//  services/pdf_service.dart
//  تصدير التقرير كملف PDF
// ══════════════════════════════════════════════════════════

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/project_model.dart';

class PdfService {
  static Future<void> generateAndShare(Project project) async {
    final pdf = pw.Document();
    final materials = project.calculateMaterials();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          textDirection: pw.TextDirection.rtl,
        ),
        build: (context) => [
          // ── العنوان ───────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF59E0B),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('تقرير كميات البناء',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black)),
                    pw.SizedBox(height: 4),
                    pw.Text(project.name,
                      style: const pw.TextStyle(
                        fontSize: 14, color: PdfColors.black)),
                  ],
                ),
                pw.Text('بنّاء 🏗️',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black)),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── معلومات المشروع ───────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: const PdfColor.fromInt(0xFF1E293B)),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _infoCell('نوع المنشأ', project.buildingType.label),
                _infoCell('عدد الطوابق', '${project.floors}'),
                _infoCell('المدينة', project.city),
                _infoCell('التاريخ', _formatDate(project.createdAt)),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // ── ملخص الحجم ───────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0x20F59E0B),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('إجمالي حجم الخرسانة',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('${project.totalVolume.toStringAsFixed(2)} م³',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFFF59E0B))),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── جدول المكوّنات ────────────────────────────────
          pw.Text('مكوّنات المشروع',
            style: pw.TextStyle(
              fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0xFF1E293B)),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0F172A)),
                children: ['المكوّن', 'الأبعاد (م)', 'العدد', 'الحجم (م³)']
                  .map((h) => _tableHeader(h))
                  .toList(),
              ),
              ...project.components.map((c) => pw.TableRow(
                children: [
                  _tableCell('${c.type.emoji} ${c.name}'),
                  _tableCell('${c.length}×${c.width}×${c.height}'),
                  _tableCell('${c.count}'),
                  _tableCell(c.volume.toStringAsFixed(3)),
                ],
              )),
            ],
          ),

          pw.SizedBox(height: 20),

          // ── جدول المواد ───────────────────────────────────
          pw.Text('قائمة المواد والتكاليف',
            style: pw.TextStyle(
              fontSize: 15, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(
              color: const PdfColor.fromInt(0xFF1E293B)),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0F172A)),
                children: ['المادة', 'الكمية', 'الوحدة', 'سعر الوحدة', 'الإجمالي (ر.س)']
                  .map((h) => _tableHeader(h))
                  .toList(),
              ),
              ...materials.map((m) => pw.TableRow(
                children: [
                  _tableCell('${m.icon} ${m.name}'),
                  _tableCell(m.quantity.toStringAsFixed(1)),
                  _tableCell(m.unit),
                  _tableCell('${m.unitPrice}'),
                  _tableCell(m.totalCost.toStringAsFixed(0),
                    bold: true,
                    color: const PdfColor.fromInt(0xFFF59E0B)),
                ],
              )),
              // صف الإجمالي
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0x20F59E0B)),
                children: [
                  _tableCell('الإجمالي الكلي',
                    bold: true, span: true),
                  _tableCell(''),
                  _tableCell(''),
                  _tableCell(''),
                  _tableCell(
                    '${project.totalCost.toStringAsFixed(0)} ر.س',
                    bold: true,
                    color: const PdfColor.fromInt(0xFFF59E0B)),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          // ── ملاحظة ────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0x153B82F6),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              '⚠️ الأسعار تقديرية وقد تختلف حسب المورد والمنطقة الجغرافية. '
              'يُنصح بمراجعة مهندس مختص للتحقق من الكميات.',
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'تقرير_${project.name}.pdf',
    );
  }

  static pw.Widget _infoCell(String label, String value) =>
    pw.Column(children: [
      pw.Text(label,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      pw.SizedBox(height: 3),
      pw.Text(value,
        style: pw.TextStyle(
          fontSize: 12, fontWeight: pw.FontWeight.bold)),
    ]);

  static pw.Widget _tableHeader(String text) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, fontSize: 11),
        textAlign: pw.TextAlign.center),
    );

  static pw.Widget _tableCell(String text,
    {bool bold = false, PdfColor? color, bool span = false}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color),
        textAlign: pw.TextAlign.center),
    );

  static String _formatDate(DateTime d) =>
    '${d.day}/${d.month}/${d.year}';
}
