import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String sku,
    required double price,
    required String currencyCode,
    required String category,
    required String storeId,
    @Default(0) int stock,
  }) = _Product;
}
