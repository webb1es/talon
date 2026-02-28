import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../core/config/supabase_config.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../repositories/drift_product_repository.dart';
import '../repositories/drift_store_repository.dart';
import '../repositories/drift_transaction_repository.dart';
import '../repositories/mock_auth_repository.dart';
import '../repositories/supabase_auth_repository.dart';
import '../sync/sync_engine.dart';
import 'app_database.dart';

@module
abstract class DatabaseModule {
  @lazySingleton
  AppDatabase get db => AppDatabase();

  @lazySingleton
  AuthRepository authRepo(AppDatabase db) => SupabaseConfig.isConfigured
      ? SupabaseAuthRepository(sb.Supabase.instance.client)
      : MockAuthRepository();

  @lazySingleton
  StoreRepository storeRepo(AppDatabase db) =>
      DriftStoreRepository(db.storeDao);

  @lazySingleton
  ProductRepository productRepo(AppDatabase db) =>
      DriftProductRepository(db.productDao);

  @lazySingleton
  TransactionRepository transactionRepo(AppDatabase db) =>
      DriftTransactionRepository(db.transactionDao);

  @lazySingleton
  SyncEngine syncEngine(AppDatabase db) => SyncEngine(db.syncQueueDao);
}
