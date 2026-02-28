import 'package:drift/drift.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get cashierId => text()();
  TextColumn get cashierName => text()();
  RealColumn get subtotal => real()();
  RealColumn get taxRate => real()();
  RealColumn get taxAmount => real()();
  RealColumn get total => real()();
  RealColumn get amountTendered => real()();
  RealColumn get change => real()();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
