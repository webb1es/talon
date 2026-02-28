import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/currency_formatter.dart';

class CartFooter extends StatelessWidget {
  final double subtotal;
  final String currencyCode;
  final VoidCallback? onCheckout;

  const CartFooter({
    super.key,
    required this.subtotal,
    this.currencyCode = 'USD',
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.subtotal, style: theme.textTheme.titleSmall),
              Text(
                formatCurrency(subtotal, currencyCode),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onCheckout,
              child: const Text(AppStrings.checkout),
            ),
          ),
        ],
      ),
    );
  }
}
