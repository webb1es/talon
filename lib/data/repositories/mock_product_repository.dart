import '../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class MockProductRepository implements ProductRepository {
  @override
  Future<Result<List<Product>>> getProducts({required String storeId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return Success(_mockProducts.map((p) => p.copyWith(storeId: storeId)).toList());
  }

  @override
  Future<Result<void>> updateStock({required String productId, required int stock}) async {
    return const Success(null);
  }
}

const _mockProducts = [
  // Beverages
  Product(id: 'p1', name: 'Coca-Cola 500ml', sku: 'BEV-001', price: 1.50, currencyCode: 'USD', category: 'Beverages', storeId: ''),
  Product(id: 'p2', name: 'Mazoe Orange 2L', sku: 'BEV-002', price: 3.50, currencyCode: 'USD', category: 'Beverages', storeId: ''),
  Product(id: 'p3', name: 'Tanganda Tea 100g', sku: 'BEV-003', price: 2.20, currencyCode: 'USD', category: 'Beverages', storeId: ''),

  // Groceries
  Product(id: 'p4', name: 'Lobels Bread White', sku: 'GRO-001', price: 1.80, currencyCode: 'USD', category: 'Groceries', storeId: ''),
  Product(id: 'p5', name: 'Sugar 2kg', sku: 'GRO-002', price: 3.00, currencyCode: 'USD', category: 'Groceries', storeId: ''),
  Product(id: 'p6', name: 'Cooking Oil 750ml', sku: 'GRO-003', price: 4.50, currencyCode: 'USD', category: 'Groceries', storeId: ''),
  Product(id: 'p7', name: 'Roller Meal 10kg', sku: 'GRO-004', price: 8.00, currencyCode: 'USD', category: 'Groceries', storeId: ''),

  // Snacks
  Product(id: 'p8', name: 'Willards Chips 125g', sku: 'SNK-001', price: 1.20, currencyCode: 'USD', category: 'Snacks', storeId: ''),
  Product(id: 'p9', name: 'Bakers Biscuits', sku: 'SNK-002', price: 2.00, currencyCode: 'USD', category: 'Snacks', storeId: ''),

  // Electronics
  Product(id: 'p10', name: 'USB-C Cable 1m', sku: 'ELE-001', price: 5.00, currencyCode: 'USD', category: 'Electronics', storeId: ''),
  Product(id: 'p11', name: 'Earphones Wired', sku: 'ELE-002', price: 3.50, currencyCode: 'USD', category: 'Electronics', storeId: ''),
  Product(id: 'p12', name: 'Power Bank 10000mAh', sku: 'ELE-003', price: 15.00, currencyCode: 'USD', category: 'Electronics', storeId: ''),
];
