import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection.dart';
import '../../common/macos_toolbar.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/repositories/store_repository.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../store/bloc/store_cubit.dart';
import '../bloc/currency_settings_cubit.dart';
import '../widgets/currency_settings.dart';
import '../widgets/theme_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storeState = context.watch<StoreCubit>().state;
    final store = storeState is StoreSelected ? storeState.store : null;
    final authState = context.watch<AuthCubit>().state;
    final role = authState is Authenticated ? authState.user.role : UserRole.cashier;

    return Scaffold(
      appBar: const MacosToolbar(title: AppStrings.settings),
      body: ListView(
        children: [
          _AccountSection(),
          const Divider(height: 32),
          if (store != null && role.canAccessCurrencySettings)
            BlocProvider(
              create: (_) => CurrencySettingsCubit(getIt<StoreRepository>())..load(store),
              child: CurrencySettings(storeId: store.id),
            ),
          if (store != null && role.canAccessCurrencySettings) const Divider(height: 32),
          const ThemeSelector(),
          const Divider(height: 32),
          _ActionsSection(),
        ],
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final storeState = context.watch<StoreCubit>().state;

    final userName = authState is Authenticated ? authState.user.name : '';
    final userEmail = authState is Authenticated ? authState.user.email : '';
    final userRole = authState is Authenticated ? authState.user.role.name : '';
    final storeName = storeState is StoreSelected ? storeState.store.name : '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.account, style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: theme.textTheme.titleMedium),
                        Text(
                          userEmail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _Chip(label: userRole),
                            if (storeName.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              _Chip(label: storeName),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthCubit>().state;
    final role = authState is Authenticated ? authState.user.role : UserRole.cashier;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (role.canSwitchStore)
            Semantics(
              label: AppStrings.switchStore,
              child: ListTile(
                leading: const Icon(Icons.store),
                title: const Text(AppStrings.switchStore),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<StoreCubit>().clearSelection();
                },
              ),
            ),
          Semantics(
            label: AppStrings.logout,
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                AppStrings.logout,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}
