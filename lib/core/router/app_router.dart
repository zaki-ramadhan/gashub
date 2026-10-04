import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/customers/presentation/customers_screen.dart'; // Customer directory
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/distribution/presentation/distribution_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/receivables/presentation/receivables_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/distribusi',
              builder: (context, state) => const DistributionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stok',
              builder: (context, state) => const InventoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/laporan',
              builder: (context, state) {
                final tabParam = state.uri.queryParameters['tab'];
                final initialTab = int.tryParse(tabParam ?? '');
                return ReportsScreen(
                  key: ValueKey(state.uri.toString()),
                  initialTabIndex: initialTab,
                );
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/piutang',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReceivablesScreen(),
    ),
    GoRoute(
      path: '/warung',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CustomersScreen(),
    ),
  ],
);
