import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class CartFooter extends StatelessWidget {
  final double subtotal;
  final VoidCallback? onCheckout;

  const CartFooter({super.key, required this.subtotal, this.onCheckout});

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
                '\$${subtotal.toStringAsFixed(2)}',
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
