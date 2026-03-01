import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../store/bloc/store_cubit.dart';
import '../../sync/widgets/sync_status_indicator.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/product_cubit.dart';
import '../widgets/cart_panel.dart';
import '../widgets/product_list.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<ProductCubit>()),
        BlocProvider.value(value: getIt<CartCubit>()),
      ],
      child: const _PosView(),
    );
  }
}

class _PosView extends StatefulWidget {
  const _PosView();

  @override
  State<_PosView> createState() => _PosViewState();
}

class _PosViewState extends State<_PosView> {
  @override
  void initState() {
    super.initState();
    final storeState = context.read<StoreCubit>().state;
    if (storeState is StoreSelected) {
      context.read<ProductCubit>().loadProducts(storeId: storeState.store.id);
    }
  }

  void _showMobileCart() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) => const CartPanel(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeState = context.watch<StoreCubit>().state;
    final storeName = storeState is StoreSelected ? storeState.store.name : '';
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(storeName),
        actions: const [SyncStatusIndicator()],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) => switch (state) {
          ProductsLoading() => const Center(child: CircularProgressIndicator()),
          ProductsLoaded(:final products) => isMobile
              ? ProductList(
                  products: products,
                  onProductTap: context.read<CartCubit>().addProduct,
                )
              : Row(
                  children: [
                    Expanded(
                      child: ProductList(
                        products: products,
                        onProductTap: context.read<CartCubit>().addProduct,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    const SizedBox(width: 320, child: CartPanel()),
                  ],
                ),
          ProductError(:final failure) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failure.message),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    if (storeState is StoreSelected) {
                      context.read<ProductCubit>().loadProducts(
                        storeId: storeState.store.id,
                      );
                    }
                  },
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
      floatingActionButton: isMobile
          ? BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) => cartState.isEmpty
                  ? const SizedBox.shrink()
                  : FloatingActionButton.extended(
                      onPressed: _showMobileCart,
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        '${AppStrings.cart} (${cartState.itemCount})',
                      ),
                    ),
            )
          : null,
    );
  }
}
