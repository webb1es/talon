import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/user_role.dart';

typedef NavDestination = ({
  IconData icon,
  IconData selectedIcon,
  String label,
  String route,
});

const List<NavDestination> allNavDestinations = [
  (icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale, label: AppStrings.pos, route: '/pos'),
  (icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: AppStrings.inventory, route: '/inventory'),
  (icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: AppStrings.reports, route: '/reports'),
  (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: AppStrings.settings, route: '/settings'),
];

List<NavDestination> navDestinationsForRole(UserRole role) {
  return allNavDestinations.where((d) {
    if (d.route == '/reports') return role.canAccessReports;
    if (d.route == '/settings') return role.canAccessSettings;
    return true;
  }).toList();
}
