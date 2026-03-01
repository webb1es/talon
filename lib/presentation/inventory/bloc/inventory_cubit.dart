import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

// -- State --

sealed class InventoryState {
  const InventoryState();
}

class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

class InventoryLoaded extends InventoryState {
  final List<Product> products;
  final String? selectedCategory;
  final String searchQuery;

  const InventoryLoaded({
    required this.products,
    this.selectedCategory,
    this.searchQuery = '',
  });

  List<String> get categories =>
      {...products.map((p) => p.category)}.toList()..sort();

  List<Product> get filtered {
    var result = selectedCategory == null
        ? products
        : products.where((p) => p.category == selectedCategory).toList();
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.sku.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  int get lowStockCount => products.where((p) => p.stock < 10).length;
  int get outOfStockCount => products.where((p) => p.stock == 0).length;
}

class InventoryError extends InventoryState {
  final Failure failure;
  const InventoryError(this.failure);
}

class InventoryImportResult extends InventoryState {
  final int count;
  final String? error;
  const InventoryImportResult({required this.count, this.error});
}

// -- Cubit --

@injectable
class InventoryCubit extends Cubit<InventoryState> {
  final ProductRepository _productRepository;

  InventoryCubit(this._productRepository) : super(const InventoryInitial());

  Future<void> load({required String storeId}) async {
    emit(const InventoryLoading());
    final result = await _productRepository.getProducts(storeId: storeId);
    switch (result) {
      case Success(:final data):
        emit(InventoryLoaded(products: data));
      case Fail(:final failure):
        emit(InventoryError(failure));
    }
  }

  void filterByCategory(String? category) {
    final current = state;
    if (current is InventoryLoaded) {
      emit(InventoryLoaded(
        products: current.products,
        selectedCategory: category,
        searchQuery: current.searchQuery,
      ));
    }
  }

  void search(String query) {
    final current = state;
    if (current is InventoryLoaded) {
      emit(InventoryLoaded(
        products: current.products,
        selectedCategory: current.selectedCategory,
        searchQuery: query,
      ));
    }
  }

  Future<void> adjustStock({
    required String productId,
    required int newStock,
    required String storeId,
  }) async {
    final result = await _productRepository.updateStock(
      productId: productId,
      stock: newStock,
    );
    if (result is Success) {
      await load(storeId: storeId);
    }
  }

  String exportCsv() {
    final current = state;
    if (current is! InventoryLoaded) return '';
    return _buildCsv(current.products);
  }

  Future<void> importCsv({
    required String storeId,
    required String csvContent,
  }) async {
    try {
      final products = _parseCsv(csvContent, storeId);
      if (products.isEmpty) {
        emit(const InventoryImportResult(count: 0, error: 'No valid rows'));
        return;
      }
      final result = await _productRepository.importProducts(
        storeId: storeId,
        products: products,
      );
      switch (result) {
        case Success():
          emit(InventoryImportResult(count: products.length));
          await load(storeId: storeId);
        case Fail(:final failure):
          emit(InventoryImportResult(count: 0, error: failure.message));
      }
    } catch (e) {
      emit(InventoryImportResult(count: 0, error: e.toString()));
    }
  }

  String _buildCsv(List<Product> products) {
    final buf = StringBuffer()
      ..writeln('id,name,sku,price,currency_code,category,stock');
    for (final p in products) {
      buf.writeln(
        '${p.id},'
        '"${p.name}",'
        '${p.sku},'
        '${p.price.toStringAsFixed(2)},'
        '${p.currencyCode},'
        '${p.category},'
        '${p.stock}',
      );
    }
    return buf.toString();
  }

  static const _uuid = Uuid();

  List<Product> _parseCsv(String csv, String storeId) {
    final lines = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return [];

    final products = <Product>[];
    // Skip header row
    for (var i = 1; i < lines.length; i++) {
      final fields = lines[i].split(',').map((f) => f.trim().replaceAll('"', '')).toList();
      if (fields.length < 6) continue;

      // Support both with-id (7 fields) and without-id (6 fields) formats
      final hasId = fields.length >= 7;
      final offset = hasId ? 1 : 0;

      final price = double.tryParse(fields[offset + 2]);
      final stock = int.tryParse(fields[offset + 5]);
      if (price == null || stock == null) continue;

      products.add(Product(
        id: _uuid.v4(),
        name: fields[offset],
        sku: fields[offset + 1],
        price: price,
        currencyCode: fields[offset + 3],
        category: fields[offset + 4],
        storeId: storeId,
        stock: stock,
      ));
    }
    return products;
  }
}
