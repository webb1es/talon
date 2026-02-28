import '../../core/error/failures.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/store_repository.dart';

class MockStoreRepository implements StoreRepository {
  @override
  Future<Result<List<Store>>> getStores() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return const Success([
      Store(id: '1', name: 'Downtown Branch', address: '12 Samora Machel Ave, Harare'),
      Store(id: '2', name: 'Mall Outlet', address: '45 Jason Moyo St, Bulawayo'),
      Store(id: '3', name: 'Airport Kiosk', address: 'Terminal 2, RGM Airport'),
    ]);
  }
}
