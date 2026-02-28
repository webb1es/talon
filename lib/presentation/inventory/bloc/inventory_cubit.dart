import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

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

  const InventoryLoaded({required this.products, this.selectedCategory});

  List<String> get categories =>
      {...products.map((p) => p.category)}.toList()..sort();

  List<Product> get filtered => selectedCategory == null
      ? products
      : products.where((p) => p.category == selectedCategory).toList();

  int get lowStockCount => products.where((p) => p.stock < 10).length;
  int get outOfStockCount => products.where((p) => p.stock == 0).length;
}

class InventoryError extends InventoryState {
  final Failure failure;
  const InventoryError(this.failure);
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
}
