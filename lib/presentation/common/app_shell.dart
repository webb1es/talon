import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user_role.dart';
import '../auth/bloc/auth_cubit.dart';
import 'desktop_drawer.dart';
import 'nav_destinations.dart';

/// App shell with responsive navigation. Wraps all authenticated routes.
/// Mobile (<600px): bottom nav · Tablet (600–1024px): rail · Desktop (>1024px): drawer.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final role = authState is Authenticated ? authState.user.role : UserRole.cashier;
    final destinations = navDestinationsForRole(role);

    // Map visible destination index to shell branch index
    void onTap(int visibleIndex) {
      final route = destinations[visibleIndex].route;
      final branchIndex = allNavDestinations.indexWhere((d) => d.route == route);
      navigationShell.goBranch(branchIndex,
          initialLocation: branchIndex == navigationShell.currentIndex);
    }

    // Map current branch index to visible index
    final currentRoute = allNavDestinations[navigationShell.currentIndex].route;
    final visibleIndex = destinations.indexWhere((d) => d.route == currentRoute);
    final safeIndex = visibleIndex.clamp(0, destinations.length - 1);

    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final isDesktop = width > 1024;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            DesktopDrawer(
              destinations: destinations,
              selectedIndex: safeIndex,
              onTap: onTap,
            ),
          if (!isMobile && !isDesktop)
            _TabletRail(
              destinations: destinations,
              selectedIndex: safeIndex,
              onTap: onTap,
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: isMobile
          ? _MobileBottomNav(
              destinations: destinations,
              selectedIndex: safeIndex,
              onTap: onTap,
            )
          : null,
    );
  }
}

// -- Mobile: bottom navigation bar --

class _MobileBottomNav extends StatelessWidget {
  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _MobileBottomNav({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (final d in destinations)
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
  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _TabletRail({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Icon(d.icon),
            selectedIcon: Icon(d.selectedIcon),
            label: Text(d.label),
          ),
      ],
    );
  }
}
