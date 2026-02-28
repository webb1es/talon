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
  final List<Transaction> transactions;
  final double totalSales;
  final double totalTax;

  const ReportLoaded({
    required this.transactions,
    required this.totalSales,
    required this.totalTax,
  });

  int get transactionCount => transactions.length;
}

class ReportError extends ReportState {
  final Failure failure;
  const ReportError(this.failure);
}

// -- Cubit --

@injectable
class ReportCubit extends Cubit<ReportState> {
  final TransactionRepository _transactionRepository;

  ReportCubit(this._transactionRepository) : super(const ReportInitial());

  Future<void> loadToday({required String storeId}) async {
    emit(const ReportLoading());
    final result = await _transactionRepository.getTransactions(
      storeId: storeId,
      date: DateTime.now(),
    );
    switch (result) {
      case Success(:final data):
        final totalSales = data.fold<double>(0, (sum, t) => sum + t.total);
        final totalTax = data.fold<double>(0, (sum, t) => sum + t.taxAmount);
        emit(ReportLoaded(
          transactions: data,
          totalSales: totalSales,
          totalTax: totalTax,
        ));
      case Fail(:final failure):
        emit(ReportError(failure));
    }
  }
}
