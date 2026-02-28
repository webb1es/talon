import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/utils/currency_formatter.dart';

class CashierBreakdown extends StatelessWidget {
  final List<({String name, double sales, int count})> data;
  final String currencyCode;

  const CashierBreakdown({super.key, required this.data, this.currencyCode = 'USD'});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            AppStrings.salesByCashier,
            style: theme.textTheme.titleSmall,
          ),
        ),
        for (final entry in data)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  child: Text(entry.name[0], style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(entry.name, style: theme.textTheme.bodyMedium),
                ),
                Text(
                  '${entry.count} txn',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatCurrency(
                    getIt<ExchangeRateService>().convert(entry.sales, 'USD', currencyCode) ?? entry.sales,
                    currencyCode,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 24),
      ],
    );
  }
}
