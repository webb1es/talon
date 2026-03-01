import 'package:drift/drift.dart';

class PaymentEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionId => text()();
  TextColumn get method => text()();
  TextColumn get currencyCode => text()();
  RealColumn get amount => real()();
  RealColumn get amountInBaseCurrency => real()();
  RealColumn get exchangeRate => real()();
}
