import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/product_table.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Future<List<Product>> productsByStore(String storeId) =>
      (select(products)..where((t) => t.storeId.equals(storeId))).get();

  Future<void> updateStock(String productId, int newStock) =>
      (update(products)..where((t) => t.id.equals(productId)))
          .write(ProductsCompanion(stock: Value(newStock)));

  Future<void> upsertAll(List<ProductsCompanion> entries) async {
    await batch((b) {
      for (final entry in entries) {
        b.insert(products, entry, onConflict: DoUpdate((_) => entry));
      }
    });
  }
}
