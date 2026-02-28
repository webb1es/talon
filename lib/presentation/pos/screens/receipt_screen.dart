import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/store.dart';
import '../../../domain/entities/transaction.dart';
import '../widgets/receipt_pdf.dart';
import '../widgets/summary_row.dart';

/// Shows the receipt dialog. Fullscreen on mobile, modal on desktop.
Future<void> showReceiptDialog(
  BuildContext context,
  Transaction transaction,
  Store store,
) {
  final isMobile = MediaQuery.sizeOf(context).width < 600;

  return showDialog<void>(
    context: context,
    useSafeArea: !isMobile,
    builder: (_) => isMobile
        ? Dialog.fullscreen(
            child: _ReceiptContent(transaction: transaction, store: store),
          )
        : Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _ReceiptContent(transaction: transaction, store: store),
            ),
          ),
  );
}

class _ReceiptContent extends StatelessWidget {
  final Transaction transaction;
  final Store store;

  const _ReceiptContent({required this.transaction, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(AppStrings.appName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(store.name, style: theme.textTheme.titleSmall),
          Text(store.address, style: theme.textTheme.bodySmall),
          const SizedBox(height: 16),
          const Divider(),

          // Meta
          _MetaRow(label: AppStrings.date, value: dateFormat.format(transaction.createdAt)),
          _MetaRow(label: AppStrings.cashier, value: transaction.cashierName),
          _MetaRow(
            label: AppStrings.receipt,
            value: '#${transaction.id.substring(0, 8).toUpperCase()}',
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Items
          for (final item in transaction.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.productName}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Divider(),

          // Totals
          SummaryRow(label: AppStrings.subtotal, value: transaction.subtotal),
          const SizedBox(height: 4),
          SummaryRow(label: AppStrings.tax, value: transaction.taxAmount),
          const Divider(),
          SummaryRow(label: AppStrings.total, value: transaction.total, bold: true),
          const Divider(),
          const SizedBox(height: 4),
          SummaryRow(label: AppStrings.cash, value: transaction.amountTendered),
          SummaryRow(label: AppStrings.change, value: transaction.change),
          const SizedBox(height: 24),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.print, size: 18),
                label: const Text(AppStrings.print),
                onPressed: () async {
                  final bytes = await buildReceiptPdf(transaction, store);
                  await Printing.sharePdf(bytes: bytes, filename: 'receipt.pdf');
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(AppStrings.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
