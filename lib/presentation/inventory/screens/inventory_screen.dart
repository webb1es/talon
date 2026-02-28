import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/inventory_cubit.dart';
import '../widgets/inventory_item_tile.dart';
import '../widgets/stock_adjust_dialog.dart';

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
  @override
  void initState() {
    super.initState();
    _load();
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
  final ValueChanged<dynamic> onAdjust;

  const _InventoryBody({required this.state, required this.onAdjust});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InventoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Summary chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _SummaryChip(
                label: '${state.products.length} ${AppStrings.totalItems}',
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: '${state.lowStockCount} ${AppStrings.lowStockLabel}',
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: 8),
              _SummaryChip(
                label: '${state.outOfStockCount} ${AppStrings.outOfStock}',
                color: colorScheme.error,
              ),
            ],
          ),
        ),
        // Category filter
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FilterChip(
                label: const Text(AppStrings.allCategories),
                selected: state.selectedCategory == null,
                onSelected: (_) => cubit.filterByCategory(null),
              ),
              const SizedBox(width: 8),
              for (final cat in state.categories) ...[
                FilterChip(
                  label: Text(cat),
                  selected: state.selectedCategory == cat,
                  onSelected: (_) => cubit.filterByCategory(cat),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
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

class _SummaryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SummaryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.08),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
