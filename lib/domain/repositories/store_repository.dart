import '../../core/error/failures.dart';
import '../entities/store.dart';

abstract class StoreRepository {
  Future<Result<List<Store>>> getStores();

  Future<Result<void>> updateStoreSettings(
    String storeId, {
    List<String>? supportedCurrencies,
    String? defaultCurrencyCode,
  });
}
