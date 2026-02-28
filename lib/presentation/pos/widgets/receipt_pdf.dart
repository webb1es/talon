import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../domain/entities/store.dart';
import '../../../domain/entities/transaction.dart';

/// Builds a receipt PDF from a [Transaction].
Future<Uint8List> buildReceiptPdf(Transaction txn, Store store) async {
  final pdf = pw.Document();
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  final font = await PdfGoogleFonts.robotoRegular();
  final fontBold = await PdfGoogleFonts.robotoBold();
  final theme = pw.ThemeData.withFont(base: font, bold: fontBold);

  // Fixed sections ~220pt + ~14pt per line item + 32pt margins.
  final pageHeight = 250.0 + txn.items.length * 14.0;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(72 * 2.8, pageHeight, marginAll: 16),
      theme: theme,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Header
          pw.Text('Talon', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(store.name, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(store.address, style: const pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 8),
          _divider(),
          pw.SizedBox(height: 4),

          // Meta
          _metaRow('Date', dateFormat.format(txn.createdAt)),
          _metaRow('Cashier', txn.cashierName),
          _metaRow('Receipt #', txn.id.substring(0, 8).toUpperCase()),
          pw.SizedBox(height: 4),
          _divider(),
          pw.SizedBox(height: 4),

          // Items
          for (final item in txn.items) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${item.quantity}x ${item.productName}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.Text(
                  '\$${item.lineTotal.toStringAsFixed(2)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
            pw.SizedBox(height: 2),
          ],
          pw.SizedBox(height: 4),
          _divider(),
          pw.SizedBox(height: 4),

          // Totals
          _totalRow('Subtotal', txn.subtotal),
          _totalRow('Tax (${(txn.taxRate * 100).toStringAsFixed(0)}%)', txn.taxAmount),
          pw.SizedBox(height: 4),
          _divider(),
          _totalRow('TOTAL', txn.total, bold: true),
          _divider(),
          pw.SizedBox(height: 4),

          // Payment
          _totalRow('Cash', txn.amountTendered),
          _totalRow('Change', txn.change),
          pw.SizedBox(height: 8),
          _divider(),
          pw.SizedBox(height: 8),

          // Footer
          pw.Text('Thank you!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );

  return pdf.save();
}

pw.Widget _divider() => pw.Container(
      width: double.infinity,
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
    );

pw.Widget _metaRow(String label, String value) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
      ],
    );

pw.Widget _totalRow(String label, double value, {bool bold = false}) {
  final style = pw.TextStyle(
    fontSize: bold ? 11 : 9,
    fontWeight: bold ? pw.FontWeight.bold : null,
  );
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    ),
  );
}
