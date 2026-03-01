import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/product.dart' as entity;
import '../../domain/repositories/product_repository.dart';
import '../drift/app_database.dart';
import '../drift/daos/product_dao.dart';
import '../drift/daos/sync_queue_dao.dart';

class DriftProductRepository implements ProductRepository {
  final ProductDao _dao;
  final SyncQueueDao _syncDao;

  DriftProductRepository(this._dao, this._syncDao);

  @override
  Future<Result<List<entity.Product>>> getProducts({
    required String storeId,
  }) async {
    try {
      final rows = await _dao.productsByStore(storeId);
      final products = rows
          .map((r) => entity.Product(
                id: r.id,
                name: r.name,
                sku: r.sku,
                price: r.price,
                currencyCode: r.currencyCode,
                category: r.category,
                storeId: r.storeId,
                stock: r.stock,
              ))
          .toList();
      return Success(products);
    } catch (e) {
      return Fail(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> importProducts({
    required String storeId,
    required List<entity.Product> products,
  }) async {
    try {
      final entries = products
          .map((p) => ProductsCompanion.insert(
                id: p.id,
                name: p.name,
                sku: p.sku,
                price: p.price,
                category: p.category,
                storeId: storeId,
                stock: Value(p.stock),
              ))
          .toList();
      await _dao.upsertAll(entries);

      for (final p in products) {
        await _syncDao.enqueue(
          entityTable: 'products',
          recordId: p.id,
          operation: 'upsert',
          payload: jsonEncode({
            'name': p.name,
            'sku': p.sku,
            'price': p.price,
            'currency_code': p.currencyCode,
            'category': p.category,
            'stock': p.stock,
          }),
        );
      }

      return const Success(null);
    } catch (e) {
      return Fail(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateStock({
    required String productId,
    required int stock,
  }) async {
    try {
      await _dao.updateStock(productId, stock);

      // Enqueue for Supabase sync
      await _syncDao.enqueue(
        entityTable: 'products',
        recordId: productId,
        operation: 'update',
        payload: jsonEncode({'stock': stock}),
      );

      return const Success(null);
    } catch (e) {
      return Fail(CacheFailure(e.toString()));
    }
  }
}

/// Seeds the products table with initial data if empty.
Future<void> seedProducts(ProductDao dao) async {
  final existing = await dao.productsByStore('1');
  if (existing.isNotEmpty) return;

  const storeIds = ['1', '2', '3'];
  final entries = <ProductsCompanion>[];

  for (final storeId in storeIds) {
    for (final p in _seedProducts) {
      entries.add(ProductsCompanion.insert(
        id: '${p.id}-$storeId',
        name: p.name,
        sku: p.sku,
        price: p.price,
        category: p.category,
        storeId: storeId,
        stock: Value(p.stock),
      ));
    }
  }
  await dao.upsertAll(entries);
}

const _seedProducts = [
  // Beverages
  (id: 'p1', name: 'Coca-Cola 500ml', sku: 'BEV-001', price: 1.50, category: 'Beverages', stock: 48),
  (id: 'p2', name: 'Mazoe Orange 2L', sku: 'BEV-002', price: 3.50, category: 'Beverages', stock: 24),
  (id: 'p3', name: 'Tanganda Tea 100g', sku: 'BEV-003', price: 2.20, category: 'Beverages', stock: 36),
  // Groceries
  (id: 'p4', name: 'Lobels Bread White', sku: 'GRO-001', price: 1.80, category: 'Groceries', stock: 20),
  (id: 'p5', name: 'Sugar 2kg', sku: 'GRO-002', price: 3.00, category: 'Groceries', stock: 15),
  (id: 'p6', name: 'Cooking Oil 750ml', sku: 'GRO-003', price: 4.50, category: 'Groceries', stock: 30),
  (id: 'p7', name: 'Roller Meal 10kg', sku: 'GRO-004', price: 8.00, category: 'Groceries', stock: 10),
  // Snacks
  (id: 'p8', name: 'Willards Chips 125g', sku: 'SNK-001', price: 1.20, category: 'Snacks', stock: 60),
  (id: 'p9', name: 'Bakers Biscuits', sku: 'SNK-002', price: 2.00, category: 'Snacks', stock: 40),
  // Electronics
  (id: 'p10', name: 'USB-C Cable 1m', sku: 'ELE-001', price: 5.00, category: 'Electronics', stock: 12),
  (id: 'p11', name: 'Earphones Wired', sku: 'ELE-002', price: 3.50, category: 'Electronics', stock: 8),
  (id: 'p12', name: 'Power Bank 10000mAh', sku: 'ELE-003', price: 15.00, category: 'Electronics', stock: 5),
];
