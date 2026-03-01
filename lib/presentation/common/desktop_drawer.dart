import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_animations.dart';
import '../sync/widgets/sync_status_indicator.dart';
import 'hover_highlight.dart';
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
    final sidebarBg = theme.navigationRailTheme.backgroundColor ??
        theme.colorScheme.surfaceContainerLow;

    return Container(
      width: AppSpacing.sidebarWidth,
      color: sidebarBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.appName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SyncStatusIndicator(),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: [
                for (var i = 0; i < destinations.length; i++)
                  _SidebarItem(
                    icon: i == selectedIndex
                        ? destinations[i].selectedIcon
                        : destinations[i].icon,
                    label: destinations[i].label,
                    selected: i == selectedIndex,
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

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final selectionColor = primaryColor.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: HoverHighlight(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          curve: AppAnimations.spring,
          decoration: BoxDecoration(
            color: selected ? selectionColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              onTap: onTap,
              child: Semantics(
                label: label,
                selected: selected,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: selected
                            ? primaryColor
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: selected ? primaryColor : null,
                          fontWeight: selected ? FontWeight.w500 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
