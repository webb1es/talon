import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/sync/sync_engine.dart';
import '../bloc/sync_cubit.dart';

/// Compact sync status indicator for the app bar.
/// Shows connection/sync state. Tap to force manual sync.
class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncState>(
      builder: (context, state) {
        final (icon, color, tooltip) = switch (state.status) {
          SyncStatus.idle when state.pendingCount == 0 => (
              Icons.cloud_done_outlined,
              Theme.of(context).colorScheme.primary,
              AppStrings.syncComplete,
            ),
          SyncStatus.idle => (
              Icons.cloud_upload_outlined,
              Theme.of(context).colorScheme.tertiary,
              '${state.pendingCount} ${AppStrings.syncPending}',
            ),
          SyncStatus.syncing => (
              Icons.cloud_sync_outlined,
              Theme.of(context).colorScheme.tertiary,
              AppStrings.syncing,
            ),
          SyncStatus.error => (
              Icons.cloud_off_outlined,
              Theme.of(context).colorScheme.error,
              AppStrings.syncError,
            ),
          SyncStatus.offline => (
              Icons.wifi_off_outlined,
              Theme.of(context).colorScheme.onSurfaceVariant,
              AppStrings.offline,
            ),
        };

        return Semantics(
          label: tooltip,
          child: IconButton(
            icon: Badge(
              isLabelVisible: state.pendingCount > 0,
              label: Text('${state.pendingCount}'),
              child: Icon(icon, color: color, size: 22),
            ),
            tooltip: tooltip,
            onPressed: state.status != SyncStatus.offline
                ? () => context.read<SyncCubit>().manualSync()
                : null,
          ),
        );
      },
    );
  }
}
