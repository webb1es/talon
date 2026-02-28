import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_strings.dart';

/// Builds a single-page marketing PDF for Talon™.
Future<Uint8List> buildOnePagerPdf() async {
  final pdf = pw.Document();
  final font = await PdfGoogleFonts.robotoRegular();
  final fontBold = await PdfGoogleFonts.robotoBold();
  final theme = pw.ThemeData.withFont(base: font, bold: fontBold);

  const accent = PdfColor.fromInt(0xFFE67E22);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      theme: theme,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Talon',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: accent,
                ),
              ),
              pw.Text(
                AppStrings.tagline,
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            width: double.infinity,
            height: 2,
            color: accent,
          ),
          pw.SizedBox(height: 20),

          // Headline
          pw.Text(
            'Complete control. Complete confidence.',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            AppStrings.heroSubtitle,
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 24),

          // Why Talon
          _sectionTitle(AppStrings.onePagerWhy),
          pw.SizedBox(height: 8),
          pw.Text(
            AppStrings.onePagerWhyBody,
            style: const pw.TextStyle(fontSize: 10, lineSpacing: 4),
          ),
          pw.SizedBox(height: 24),

          // Key Benefits
          _sectionTitle('Key Benefits'),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _benefitColumn(_leftBenefits)),
              pw.SizedBox(width: 24),
              pw.Expanded(child: _benefitColumn(_rightBenefits)),
            ],
          ),
          pw.SizedBox(height: 24),

          // Features at a glance
          _sectionTitle('Features at a Glance'),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              for (final f in _features) ...[
                pw.Expanded(child: _featureBox(f.title, f.desc)),
                if (f != _features.last) pw.SizedBox(width: 12),
              ],
            ],
          ),

          pw.Spacer(),

          // Footer
          pw.Container(
            width: double.infinity,
            height: 1,
            color: PdfColors.grey300,
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Talon  |  ${AppStrings.onePagerContact}',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                AppStrings.ctaSubtitle,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  return pdf.save();
}

pw.Widget _sectionTitle(String text) => pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: const PdfColor.fromInt(0xFFE67E22),
      ),
    );

pw.Widget _bulletItem(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('\u2022  ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );

pw.Widget _benefitColumn(List<String> items) =>
    pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: items.map(_bulletItem).toList());

const _leftBenefits = [
  AppStrings.onePagerBenefitSpeed,
  AppStrings.onePagerBenefitOffline,
  AppStrings.onePagerBenefitMultiStore,
  AppStrings.onePagerBenefitReports,
];

const _rightBenefits = [
  AppStrings.onePagerBenefitThemes,
  AppStrings.onePagerBenefitSecurity,
  AppStrings.onePagerBenefitCurrency,
  AppStrings.onePagerBenefitPlatform,
];

const _features = [
  (title: 'POS', desc: 'Fast checkout with tax calculation and receipt printing.'),
  (title: 'Inventory', desc: 'Real-time stock tracking across all locations.'),
  (title: 'Reports', desc: 'Daily sales, tax summaries, and cashier performance.'),
];

pw.Widget _featureBox(String title, String desc) => pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(desc, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        ],
      ),
    );
