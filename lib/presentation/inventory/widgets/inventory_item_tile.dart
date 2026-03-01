import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/product.dart';
import 'stock_badge.dart';

class InventoryItemTile extends StatelessWidget {
  final Product product;
  final String currencyCode;
  final VoidCallback? onTap;

  const InventoryItemTile({
    super.key,
    required this.product,
    this.onTap,
    this.currencyCode = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final displayPrice = getIt<ExchangeRateService>()
            .convert(product.price, 'USD', currencyCode) ??
        product.price;
    final effectiveCode = displayPrice == product.price ? 'USD' : currencyCode;

    return ListTile(
      leading: CircleAvatar(
        child: Text(product.name[0]),
      ),
      title: Text(
        product.name,
        semanticsLabel: '${product.name}, stock ${product.stock}',
      ),
      subtitle: Text('${product.sku} · ${product.category}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StockBadge(stock: product.stock),
          const SizedBox(width: 8),
          Text(
            formatCurrency(displayPrice, effectiveCode),
            style: textTheme.bodyMedium,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
