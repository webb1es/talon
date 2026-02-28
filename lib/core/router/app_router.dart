import 'package:go_router/go_router.dart';

import '../../presentation/auth/bloc/auth_cubit.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/common/app_shell.dart';
import '../../presentation/common/placeholder_screen.dart';
import '../../presentation/store/bloc/store_cubit.dart';
import '../../presentation/store/screens/store_selector_screen.dart';
import '../di/injection.dart';
import 'go_router_refresh_stream.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const storeSelector = '/stores';
  static const pos = '/pos';
  static const inventory = '/inventory';
  static const reports = '/reports';
  static const settings = '/settings';
}

final router = GoRouter(
  initialLocation: AppRoutes.pos,
  refreshListenable: GoRouterRefreshStream([
    getIt<AuthCubit>().stream,
    getIt<StoreCubit>().stream,
  ]),
  redirect: (context, state) {
    final isLoggedIn = getIt<AuthCubit>().isAuthenticated;
    final hasStore = getIt<StoreCubit>().hasSelectedStore;
    final location = state.matchedLocation;

    if (!isLoggedIn) {
      return location == AppRoutes.login ? null : AppRoutes.login;
    }
    if (!hasStore) {
      return location == AppRoutes.storeSelector ? null : AppRoutes.storeSelector;
    }
    if (location == AppRoutes.login || location == AppRoutes.storeSelector) {
      return AppRoutes.pos;
    }
    return null;
  },
  routes: [
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
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'POS'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.inventory,
              name: 'inventory',
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Inventory'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.reports,
              name: 'reports',
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Reports'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              name: 'settings',
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'Settings'),
            ),
          ],
        ),
      ],
    ),
  ],
);
