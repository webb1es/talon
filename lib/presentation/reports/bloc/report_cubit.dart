import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';

// -- State --

sealed class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final List<Transaction> allTransactions;
  final DateTime from;
  final DateTime to;
  final String? cashierFilter;

  const ReportLoaded({
    required this.allTransactions,
    required this.from,
    required this.to,
    this.cashierFilter,
  });

  List<Transaction> get transactions => cashierFilter == null
      ? allTransactions
      : allTransactions.where((t) => t.cashierName == cashierFilter).toList();

  int get transactionCount => transactions.length;

  double get totalSales =>
      transactions.fold<double>(0, (sum, t) => sum + t.total);

  double get totalTax =>
      transactions.fold<double>(0, (sum, t) => sum + t.taxAmount);

  List<String> get cashiers =>
      {...allTransactions.map((t) => t.cashierName)}.toList()..sort();

  List<({String name, double sales, int count})> get salesByCashier {
    final map = <String, (double, int)>{};
    for (final t in allTransactions) {
      final (sales, count) = map[t.cashierName] ?? (0.0, 0);
      map[t.cashierName] = (sales + t.total, count + 1);
    }
    return map.entries
        .map((e) => (name: e.key, sales: e.value.$1, count: e.value.$2))
        .toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));
  }
}

class ReportError extends ReportState {
  final Failure failure;
  const ReportError(this.failure);
}

// -- Cubit --

@injectable
class ReportCubit extends Cubit<ReportState> {
  final TransactionRepository _transactionRepository;
  String? _storeId;

  ReportCubit(this._transactionRepository) : super(const ReportInitial());

  Future<void> load({
    required String storeId,
    required DateTime from,
    required DateTime to,
  }) async {
    _storeId = storeId;
    emit(const ReportLoading());
    final result = await _transactionRepository.getTransactions(
      storeId: storeId,
      from: from,
      to: to,
    );
    switch (result) {
      case Success(:final data):
        emit(ReportLoaded(allTransactions: data, from: from, to: to));
      case Fail(:final failure):
        emit(ReportError(failure));
    }
  }

  Future<void> loadToday({required String storeId}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await load(storeId: storeId, from: today, to: today);
  }

  void filterByCashier(String? cashierName) {
    final current = state;
    if (current is ReportLoaded) {
      emit(ReportLoaded(
        allTransactions: current.allTransactions,
        from: current.from,
        to: current.to,
        cashierFilter: cashierName,
      ));
    }
  }

  Future<void> changeDateRange(DateTime from, DateTime to) async {
    if (_storeId != null) {
      await load(storeId: _storeId!, from: from, to: to);
    }
  }

  String toCsv() {
    final current = state;
    if (current is! ReportLoaded) return '';
    final buf = StringBuffer()
      ..writeln('ID,Date,Cashier,Items,Subtotal,Tax,Total');
    for (final t in current.transactions) {
      buf.writeln(
        '${t.id},'
        '${t.createdAt.toIso8601String()},'
        '${t.cashierName},'
        '${t.items.length},'
        '${t.subtotal.toStringAsFixed(2)},'
        '${t.taxAmount.toStringAsFixed(2)},'
        '${t.total.toStringAsFixed(2)}',
      );
    }
    return buf.toString();
  }
}
