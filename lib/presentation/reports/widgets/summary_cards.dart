import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../bloc/report_cubit.dart';

class SummaryCards extends StatelessWidget {
  final ReportLoaded state;
  final int crossAxisCount;
  final String currencyCode;

  const SummaryCards({
    super.key,
    required this.state,
    required this.crossAxisCount,
    this.currencyCode = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final exchange = getIt<ExchangeRateService>();
    double toDisplay(double usd) => exchange.convert(usd, 'USD', currencyCode) ?? usd;

    final cards = [
      _SummaryData(AppStrings.totalSales, formatCurrency(toDisplay(state.totalSales), currencyCode)),
      _SummaryData(AppStrings.transactionCount, '${state.transactionCount}'),
      _SummaryData(AppStrings.totalTax, formatCurrency(toDisplay(state.totalTax), currencyCode)),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: crossAxisCount == 1
          ? Column(
              children: [for (final c in cards) _SummaryCard(data: c)],
            )
          : Row(
              children: [
                for (final c in cards) Expanded(child: _SummaryCard(data: c)),
              ],
            ),
    );
  }
}

class _SummaryData {
  final String label;
  final String value;
  const _SummaryData(this.label, this.value);
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              data.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
