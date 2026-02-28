import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

typedef NavDestination = ({IconData icon, IconData selectedIcon, String label});

const List<NavDestination> navDestinations = [
  (icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale, label: AppStrings.pos),
  (icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: AppStrings.inventory),
  (icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: AppStrings.reports),
  (icon: Icons.settings_outlined, selectedIcon: Icons.settings, label: AppStrings.settings),
];
