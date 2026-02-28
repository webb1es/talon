import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';

class SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String currencyCode;
  final bool bold;
  final Color? color;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.currencyCode = 'USD',
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color)
        : Theme.of(context).textTheme.bodyLarge?.copyWith(color: color);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(formatCurrency(value, currencyCode), style: style),
      ],
    );
  }
}
