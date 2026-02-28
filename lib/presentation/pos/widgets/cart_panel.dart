import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/exchange_rate_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/cart_item.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/cart_cubit.dart';
import '../screens/checkout_dialog.dart';
import '../screens/receipt_screen.dart';
import 'cart_footer.dart';

/// Cart panel showing items, quantities, and subtotal.
/// Used inline on desktop/tablet and in a bottom sheet on mobile.
class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeState = context.watch<StoreCubit>().state;
    final currencyCode = storeState is StoreSelected ? storeState.store.currencyCode : 'USD';

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.isEmpty) {
          return Center(
            child: Text(
              AppStrings.emptyCart,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        final exchangeRate = getIt<ExchangeRateService>();
        final displaySubtotal = exchangeRate.convert(state.subtotal, 'USD', currencyCode) ?? state.subtotal;

        return Column(
          children: [
            _CartHeader(itemCount: state.itemCount),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.items.length,
                itemBuilder: (context, index) =>
                    _CartItemTile(item: state.items[index], currencyCode: currencyCode),
              ),
            ),
            const Divider(height: 1),
            CartFooter(
              subtotal: displaySubtotal,
              currencyCode: displaySubtotal == state.subtotal ? 'USD' : currencyCode,
              onCheckout: () async {
                final txn = await showCheckoutDialog(context);
                if (txn != null && context.mounted) {
                  context.read<CartCubit>().clear();
                  final storeState = context.read<StoreCubit>().state;
                  if (storeState is StoreSelected) {
                    showReceiptDialog(context, txn, storeState.store);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  final int itemCount;

  const _CartHeader({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            '${AppStrings.cart} ($itemCount)',
            style: theme.textTheme.titleMedium,
          ),
          const Spacer(),
          Semantics(
            label: AppStrings.clearCart,
            child: TextButton(
              onPressed: context.read<CartCubit>().clear,
              child: const Text(AppStrings.clearCart),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final String currencyCode;

  const _CartItemTile({required this.item, this.currencyCode = 'USD'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lineTotal = item.product.price * item.quantity;
    final displayTotal = getIt<ExchangeRateService>()
            .convert(lineTotal, 'USD', currencyCode) ??
        lineTotal;
    final effectiveCode = displayTotal == lineTotal ? 'USD' : currencyCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatCurrency(displayTotal, effectiveCode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _QuantityControls(
            quantity: item.quantity,
            productId: item.product.id,
          ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final String productId;

  const _QuantityControls({required this.quantity, required this.productId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Decrease quantity',
          child: IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => cubit.updateQuantity(productId, quantity - 1),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Semantics(
          label: 'Increase quantity',
          child: IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => cubit.updateQuantity(productId, quantity + 1),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

