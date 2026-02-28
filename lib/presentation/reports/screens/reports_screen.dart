import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/report_cubit.dart';
import '../widgets/cashier_breakdown.dart';
import '../widgets/date_range_chips.dart';
import '../widgets/summary_cards.dart';
import '../widgets/transaction_tile.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ReportCubit>();
        final storeState = context.read<StoreCubit>().state;
        if (storeState is StoreSelected) {
          cubit.loadToday(storeId: storeState.store.id);
        }
        return cubit;
      },
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  void _refresh(BuildContext context) {
    final storeState = context.read<StoreCubit>().state;
    if (storeState is StoreSelected) {
      context.read<ReportCubit>().loadToday(storeId: storeState.store.id);
    }
  }

  Future<void> _exportCsv(BuildContext context) async {
    final csv = context.read<ReportCubit>().toCsv();
    if (csv.isEmpty) return;
    await Printing.sharePdf(
      bytes: utf8.encode(csv),
      filename: 'sales-report.csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.salesReport),
        actions: [
          Semantics(
            label: AppStrings.exportCsv,
            child: IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: AppStrings.exportCsv,
              onPressed: () => _exportCsv(context),
            ),
          ),
          Semantics(
            label: AppStrings.refresh,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: AppStrings.refresh,
              onPressed: () => _refresh(context),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) => switch (state) {
          ReportLoading() =>
            const Center(child: CircularProgressIndicator()),
          ReportLoaded() => _ReportBody(state: state),
          ReportError(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(failure.message),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _refresh(context),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  final ReportLoaded state;

  const _ReportBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReportCubit>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      children: [
        const SizedBox(height: 8),
        DateRangeChips(
          from: state.from,
          to: state.to,
          onChanged: (range) => cubit.changeDateRange(range.$1, range.$2),
        ),
        // Cashier filter
        if (state.cashiers.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text(AppStrings.allCashiers),
                    selected: state.cashierFilter == null,
                    onSelected: (_) => cubit.filterByCashier(null),
                  ),
                  const SizedBox(width: 8),
                  for (final name in state.cashiers) ...[
                    FilterChip(
                      label: Text(name),
                      selected: state.cashierFilter == name,
                      onSelected: (_) => cubit.filterByCashier(name),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        SummaryCards(state: state, crossAxisCount: isMobile ? 1 : 3),
        if (state.transactions.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                AppStrings.noTransactions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              children: [
                CashierBreakdown(data: state.salesByCashier),
                ...state.transactions.map((t) => TransactionTile(transaction: t)),
              ],
            ),
          ),
      ],
    );
  }
}
