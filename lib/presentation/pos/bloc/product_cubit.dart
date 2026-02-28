import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

// -- State --

sealed class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductsLoading extends ProductState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductState {
  final List<Product> products;
  const ProductsLoaded(this.products);
}

class ProductError extends ProductState {
  final Failure failure;
  const ProductError(this.failure);
}

// -- Cubit --

@lazySingleton
class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _productRepository;

  ProductCubit(this._productRepository) : super(const ProductInitial());

  Future<void> loadProducts({required String storeId}) async {
    emit(const ProductsLoading());
    final result = await _productRepository.getProducts(storeId: storeId);
    switch (result) {
      case Success(:final data):
        emit(ProductsLoaded(data));
      case Fail(:final failure):
        emit(ProductError(failure));
    }
  }
}
