import '../../core/error/failures.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Result<List<Product>>> getProducts({required String storeId});
  Future<Result<void>> updateStock({required String productId, required int stock});
  Future<Result<void>> importProducts({required String storeId, required List<Product> products});
}
