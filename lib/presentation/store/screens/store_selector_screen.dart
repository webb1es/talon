import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../domain/entities/store.dart';
import '../bloc/store_cubit.dart';

class StoreSelectorScreen extends StatefulWidget {
  const StoreSelectorScreen({super.key});

  @override
  State<StoreSelectorScreen> createState() => _StoreSelectorScreenState();
}

class _StoreSelectorScreenState extends State<StoreSelectorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StoreCubit>().loadStores();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeType = context.read<ThemeCubit>().state.themeType;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.appName, style: theme.textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(AppStrings.selectStore, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 32),
                Flexible(
                  child: BlocBuilder<StoreCubit, StoreState>(
                    builder: (context, state) => switch (state) {
                      StoresLoading() => const CircularProgressIndicator(),
                      StoresLoaded(:final stores) => _StoreList(stores: stores),
                      StoreError(:final failure) => _ErrorView(
                        message: AppStrings.error(themeType, failure.message),
                        onRetry: context.read<StoreCubit>().loadStores,
                      ),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreList extends StatelessWidget {
  final List<Store> stores;

  const _StoreList({required this.stores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      itemCount: stores.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final store = stores[index];
        return Semantics(
          label: '${store.name}, ${store.address}',
          button: true,
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => context.read<StoreCubit>().selectStore(store),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(Icons.store_outlined, color: colors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(store.name, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(store.address, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: onRetry,
          child: const Text(AppStrings.retry),
        ),
      ],
    );
  }
}
