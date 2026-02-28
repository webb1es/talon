import '../../core/error/failures.dart';
import '../entities/store.dart';

abstract class StoreRepository {
  Future<Result<List<Store>>> getStores();
}
