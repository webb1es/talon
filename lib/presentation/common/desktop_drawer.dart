import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../sync/widgets/sync_status_indicator.dart';
import 'nav_destinations.dart';

class DesktopDrawer extends StatelessWidget {
  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const DesktopDrawer({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      width: 240,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.appName,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SyncStatusIndicator(),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (var i = 0; i < destinations.length; i++)
                  _DrawerItem(
                    icon: i == selectedIndex
                        ? destinations[i].selectedIcon
                        : destinations[i].icon,
                    label: destinations[i].label,
                    selected: i == selectedIndex,
                    selectedColor: colors.primary,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? selectedColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Semantics(
            label: label,
            selected: selected,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: selected ? selectedColor : theme.iconTheme.color),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected ? selectedColor : null,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
