import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../bloc/report_cubit.dart';

class SummaryCards extends StatelessWidget {
  final ReportLoaded state;
  final int crossAxisCount;

  const SummaryCards({
    super.key,
    required this.state,
    required this.crossAxisCount,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryData(AppStrings.totalSales, '\$${state.totalSales.toStringAsFixed(2)}'),
      _SummaryData(AppStrings.transactionCount, '${state.transactionCount}'),
      _SummaryData(AppStrings.totalTax, '\$${state.totalTax.toStringAsFixed(2)}'),
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
