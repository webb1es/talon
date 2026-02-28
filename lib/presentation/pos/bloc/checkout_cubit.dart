import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/repositories/transaction_repository.dart';

// -- State --

sealed class CheckoutState {
  const CheckoutState();
}

class CheckoutIdle extends CheckoutState {
  const CheckoutIdle();
}

class CheckoutProcessing extends CheckoutState {
  const CheckoutProcessing();
}

class CheckoutComplete extends CheckoutState {
  final Transaction transaction;
  const CheckoutComplete(this.transaction);
}

class CheckoutError extends CheckoutState {
  final Failure failure;
  const CheckoutError(this.failure);
}

// -- Cubit --

@injectable
class CheckoutCubit extends Cubit<CheckoutState> {
  final TransactionRepository _transactionRepository;
  final ProductRepository _productRepository;

  CheckoutCubit(this._transactionRepository, this._productRepository)
      : super(const CheckoutIdle());

  static const taxRate = 0.15; // 15% VAT

  Future<void> processPayment({
    required List<CartItem> items,
    required double amountTendered,
    required String storeId,
    required String cashierId,
    required String cashierName,
    required String currencyCode,
  }) async {
    emit(const CheckoutProcessing());

    final transactionItems = items
        .map((item) => TransactionItem(
              productId: item.product.id,
              productName: item.product.name,
              sku: item.product.sku,
              unitPrice: item.product.price,
              quantity: item.quantity,
              lineTotal: item.product.price * item.quantity,
            ))
        .toList();

    final subtotal =
        items.fold(0.0, (sum, item) => sum + item.product.price * item.quantity);
    final taxAmount = subtotal * taxRate;
    final total = subtotal + taxAmount;

    final transaction = Transaction(
      id: const Uuid().v4(),
      storeId: storeId,
      cashierId: cashierId,
      cashierName: cashierName,
      items: transactionItems,
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      total: total,
      amountTendered: amountTendered,
      change: amountTendered - total,
      currencyCode: currencyCode,
      createdAt: DateTime.now(),
    );

    final result = await _transactionRepository.createTransaction(transaction);
    switch (result) {
      case Success(:final data):
        await _decrementStock(items);
        emit(CheckoutComplete(data));
      case Fail(:final failure):
        emit(CheckoutError(failure));
    }
  }

  Future<void> _decrementStock(List<CartItem> items) async {
    for (final item in items) {
      final newStock = (item.product.stock - item.quantity).clamp(0, 999999);
      await _productRepository.updateStock(
        productId: item.product.id,
        stock: newStock,
      );
    }
  }
}
