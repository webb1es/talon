import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/product.dart';

// -- State --

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);

  int get itemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;
}

// -- Cubit --

@lazySingleton
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addProduct(Product product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }
    emit(CartState(items: items));
  }

  void removeItem(String productId) {
    final items = state.items.where((i) => i.product.id != productId).toList();
    emit(CartState(items: items));
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) return removeItem(productId);
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: quantity);
      emit(CartState(items: items));
    }
  }

  void clear() => emit(const CartState());
}
