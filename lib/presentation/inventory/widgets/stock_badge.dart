import 'package:flutter/material.dart';

class StockBadge extends StatelessWidget {
  final int stock;

  const StockBadge({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (color, label) = switch (stock) {
      0 => (colorScheme.error, 'Out of stock'),
      < 10 => (colorScheme.tertiary, 'Low: $stock'),
      _ => (colorScheme.primary, '$stock'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
