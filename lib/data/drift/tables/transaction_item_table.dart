import 'package:drift/drift.dart';

class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionId => text()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  TextColumn get sku => text()();
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get lineTotal => real()();
}
