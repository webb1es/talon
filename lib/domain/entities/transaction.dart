import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

/// Immutable snapshot of a line item at time of sale.
@freezed
abstract class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    required String productId,
    required String productName,
    required String sku,
    required double unitPrice,
    required int quantity,
    required double lineTotal,
  }) = _TransactionItem;
}

/// Immutable sale record. Append-only — never overwritten.
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String storeId,
    required String cashierId,
    required String cashierName,
    required List<TransactionItem> items,
    required double subtotal,
    required double taxRate,
    required double taxAmount,
    required double total,
    required double amountTendered,
    required double change,
    required String currencyCode,
    required DateTime createdAt,
  }) = _Transaction;
}
