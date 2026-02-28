import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../common/search_field.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/inventory_cubit.dart';
import '../widgets/category_filter.dart';
import '../widgets/inventory_item_tile.dart';
import '../widgets/stock_adjust_dialog.dart';
import '../widgets/summary_chip.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<InventoryCubit>(),
      child: const _InventoryView(),
    );
  }
}

class _InventoryView extends StatefulWidget {
  const _InventoryView();

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    final storeState = context.read<StoreCubit>().state;
    if (storeState is StoreSelected) {
      context.read<InventoryCubit>().load(storeId: storeState.store.id);
    }
  }

  Future<void> _adjustStock(BuildContext context, product) async {
    final newStock = await showDialog<int>(
      context: context,
      builder: (_) => StockAdjustDialog(product: product),
    );
    if (newStock == null || !context.mounted) return;

    final storeState = context.read<StoreCubit>().state;
    if (storeState is StoreSelected) {
      await context.read<InventoryCubit>().adjustStock(
            productId: product.id,
            newStock: newStock,
            storeId: storeState.store.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.inventory),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppStrings.refresh,
            onPressed: _load,
          ),
        ],
      ),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) => switch (state) {
          InventoryLoading() =>
            const Center(child: CircularProgressIndicator()),
          InventoryLoaded() => _InventoryBody(
              state: state,
              searchController: _searchController,
              onAdjust: (p) => _adjustStock(context, p),
            ),
          InventoryError(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(failure.message),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _load,
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _InventoryBody extends StatelessWidget {
  final InventoryLoaded state;
  final TextEditingController searchController;
  final ValueChanged<dynamic> onAdjust;

  const _InventoryBody({
    required this.state,
    required this.searchController,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InventoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SearchField(
          controller: searchController,
          showClear: state.searchQuery.isNotEmpty,
          onChanged: cubit.search,
          onClear: () {
            searchController.clear();
            cubit.search('');
          },
        ),
        // Summary chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SummaryChip(
                label: '${state.products.length} ${AppStrings.totalItems}',
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              SummaryChip(
                label: '${state.lowStockCount} ${AppStrings.lowStockLabel}',
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              SummaryChip(
                label: '${state.outOfStockCount} ${AppStrings.outOfStock}',
                color: colorScheme.error,
              ),
            ],
          ),
        ),
        CategoryFilter(
          categories: state.categories,
          selected: state.selectedCategory,
          onSelected: cubit.filterByCategory,
        ),
        const Divider(),
        // Product list
        Expanded(
          child: state.filtered.isEmpty
              ? const Center(child: Text(AppStrings.noProducts))
              : ListView.builder(
                  itemCount: state.filtered.length,
                  itemBuilder: (context, i) {
                    final product = state.filtered[i];
                    return InventoryItemTile(
                      product: product,
                      onTap: () => onAdjust(product),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
