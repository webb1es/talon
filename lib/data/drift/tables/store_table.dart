import 'package:drift/drift.dart';

class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();

  @override
  Set<Column> get primaryKey => {id};
}
