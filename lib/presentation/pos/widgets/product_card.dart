import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/product.dart';
import '../../common/hover_highlight.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String currencyCode;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.currencyCode = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final displayPrice = getIt<ExchangeRateService>()
            .convert(product.price, 'USD', currencyCode) ??
        product.price;
    final priceText = formatCurrency(
      displayPrice,
      displayPrice == product.price ? 'USD' : currencyCode,
    );

    final cardRadius = BorderRadius.circular(AppSpacing.radiusCard);
    return Semantics(
      label: '${product.name}, $priceText',
      button: true,
      child: HoverHighlight(
        borderRadius: cardRadius,
        child: Card(
          child: InkWell(
            borderRadius: cardRadius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.sku,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'JetBrains Mono',
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    priceText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
