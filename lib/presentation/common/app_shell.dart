import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'desktop_drawer.dart';
import 'nav_destinations.dart';

/// App shell with responsive navigation. Wraps all authenticated routes.
/// Mobile (<600px): bottom nav · Tablet (600–1024px): rail · Desktop (>1024px): drawer.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTap(int index) =>
      navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final isDesktop = width > 1024;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            DesktopDrawer(selectedIndex: navigationShell.currentIndex, onTap: _onTap),
          if (!isMobile && !isDesktop)
            _TabletRail(selectedIndex: navigationShell.currentIndex, onTap: _onTap),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: isMobile
          ? _MobileBottomNav(selectedIndex: navigationShell.currentIndex, onTap: _onTap)
          : null,
    );
  }
}

// -- Mobile: bottom navigation bar --

class _MobileBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _MobileBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (final d in navDestinations)
          NavigationDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: d.label,
          ),
      ],
    );
  }
}

// -- Tablet: navigation rail --

class _TabletRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _TabletRail({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final d in navDestinations)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
      ],
    );
  }
}
