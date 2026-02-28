import 'package:flutter/material.dart';

import '../../../domain/entities/product.dart';
import 'stock_badge.dart';

class InventoryItemTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const InventoryItemTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            '\$${product.price.toStringAsFixed(2)}',
            style: textTheme.bodyMedium,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
