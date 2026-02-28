import 'package:drift/drift.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  RealColumn get price => real()();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get category => text()();
  TextColumn get storeId => text()();

  @override
  Set<Column> get primaryKey => {id};
}
