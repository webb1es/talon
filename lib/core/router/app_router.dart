import 'package:go_router/go_router.dart';

import '../../presentation/auth/bloc/auth_cubit.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/common/app_shell.dart';
import '../../presentation/landing/screens/landing_screen.dart';
import '../../presentation/landing/screens/one_pager_screen.dart';
import '../../presentation/inventory/screens/inventory_screen.dart';
import '../../presentation/pos/screens/pos_screen.dart';
import '../../presentation/reports/screens/reports_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../../presentation/store/bloc/store_cubit.dart';
import '../../presentation/store/screens/store_selector_screen.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

abstract final class AppRoutes {
  static const landing = '/';
  static const onePager = '/one-pager';
  static const login = '/login';
  static const storeSelector = '/stores';
  static const pos = '/pos';
  static const inventory = '/inventory';
  static const reports = '/reports';
  static const settings = '/settings';
}

final router = GoRouter(
  initialLocation: AppRoutes.landing,
  refreshListenable: GoRouterRefreshStream([
    getIt<AuthCubit>().stream,
    getIt<StoreCubit>().stream,
  ]),
  redirect: (context, state) {
    final isLoggedIn = getIt<AuthCubit>().isAuthenticated;
    final hasStore = getIt<StoreCubit>().hasSelectedStore;
    final location = state.matchedLocation;

    // Allow unauthenticated access to landing and login
    final publicRoutes = {AppRoutes.landing, AppRoutes.onePager, AppRoutes.login};
    if (!isLoggedIn) {
      return publicRoutes.contains(location) ? null : AppRoutes.landing;
    }
    if (!hasStore) {
      return location == AppRoutes.storeSelector ? null : AppRoutes.storeSelector;
    }
    if (publicRoutes.contains(location) || location == AppRoutes.storeSelector) {
      return AppRoutes.pos;
    }

    // Role-based route guard
    final authState = getIt<AuthCubit>().state;
    if (authState is Authenticated) {
      final role = authState.user.role;
      final denied =
          (location == AppRoutes.inventory && !role.canAccessInventory) ||
          (location == AppRoutes.reports && !role.canAccessReports) ||
          (location == AppRoutes.settings && !role.canAccessSettings);
      if (denied) return AppRoutes.pos;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.landing,
      name: 'landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: AppRoutes.onePager,
      name: 'onePager',
      builder: (context, state) => const OnePagerScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.storeSelector,
      name: 'storeSelector',
      builder: (context, state) => const StoreSelectorScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.pos,
              name: 'pos',
              builder: (context, state) => const PosScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.inventory,
              name: 'inventory',
              builder: (context, state) => const InventoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.reports,
              name: 'reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
