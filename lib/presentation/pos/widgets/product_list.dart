import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/product.dart';
import '../../common/search_field.dart';
import '../../store/bloc/store_cubit.dart';
import 'product_card.dart';

/// Product list with category filter chips and responsive grid.
class ProductList extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<Product> onProductTap;

  const ProductList({super.key, required this.products, required this.onProductTap});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filtered {
    var result = widget.products;
    if (_selectedCategory != null) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.products.map((p) => p.category).toSet().toList()..sort();
    final filtered = _filtered;
    final storeState = context.watch<StoreCubit>().state;
    final currencyCode = storeState is StoreSelected ? storeState.store.currencyCode : 'USD';

    return Column(
      children: [
        SearchField(
          controller: _searchController,
          showClear: _query.isNotEmpty,
          onChanged: (v) => setState(() => _query = v),
          onClear: () {
            _searchController.clear();
            setState(() => _query = '');
          },
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text(AppStrings.allCategories),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
              ),
              for (final category in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) => setState(() {
                      _selectedCategory = _selectedCategory == category ? null : category;
                    }),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text(AppStrings.noProducts))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => ProductCard(
                    product: filtered[index],
                    currencyCode: currencyCode,
                    onTap: () => widget.onProductTap(filtered[index]),
                  ),
                ),
        ),
      ],
    );
  }
}
