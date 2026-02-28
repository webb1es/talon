import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/report_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.todaysSales),
        actions: [
          Semantics(
            label: AppStrings.refresh,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final storeState = context.read<StoreCubit>().state;
                if (storeState is StoreSelected) {
                  context.read<ReportCubit>().loadToday(
                    storeId: storeState.store.id,
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) => switch (state) {
          ReportLoading() => const Center(child: CircularProgressIndicator()),
          ReportLoaded(:final transactions) when transactions.isEmpty =>
            Center(
              child: Text(
                AppStrings.noTransactions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ReportLoaded() => _ReportBody(state: state),
          ReportError(:final failure) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(failure.message),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    final storeState = context.read<StoreCubit>().state;
                    if (storeState is StoreSelected) {
                      context.read<ReportCubit>().loadToday(
                        storeId: storeState.store.id,
                      );
                    }
                  },
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
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      children: [
        _SummaryCards(state: state, crossAxisCount: isMobile ? 1 : 3),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.transactions.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) =>
                TransactionTile(transaction: state.transactions[index]),
          ),
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final ReportLoaded state;
  final int crossAxisCount;

  const _SummaryCards({required this.state, required this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryData(AppStrings.totalSales, '\$${state.totalSales.toStringAsFixed(2)}'),
      _SummaryData(AppStrings.transactionCount, '${state.transactionCount}'),
      _SummaryData(AppStrings.totalTax, '\$${state.totalTax.toStringAsFixed(2)}'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: crossAxisCount == 1
          ? Column(
              children: [for (final c in cards) _SummaryCard(data: c)],
            )
          : Row(
              children: [
                for (final c in cards) Expanded(child: _SummaryCard(data: c)),
              ],
            ),
    );
  }
}

class _SummaryData {
  final String label;
  final String value;
  const _SummaryData(this.label, this.value);
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              data.value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

