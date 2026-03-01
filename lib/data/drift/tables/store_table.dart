import 'package:drift/drift.dart';

class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  TextColumn get supportedCurrencies => text().withDefault(const Constant('USD'))();

  @override
  Set<Column> get primaryKey => {id};
}
