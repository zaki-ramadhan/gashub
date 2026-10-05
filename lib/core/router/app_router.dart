import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/distribution/presentation/distribution_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/receivables/presentation/receivables_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'app_page_transitions.dart';
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
      pageBuilder: (context, state) => AppPageTransitions.fade(
        state: state,
        child: const SplashScreen(),
      ),
    ),
    StatefulShellRoute(
      pageBuilder: (context, state, navigationShell) => AppPageTransitions.fade(
        state: state,
        child: navigationShell,
      ),
      navigatorContainerBuilder: (context, navigationShell, children) {
        return AppShell(
          navigationShell: navigationShell,
          children: children,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => AppPageTransitions.slide(
                state: state,
                child: const DashboardScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/distribusi',
              pageBuilder: (context, state) => AppPageTransitions.slide(
                state: state,
                child: const DistributionScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stok',
              pageBuilder: (context, state) => AppPageTransitions.slide(
                state: state,
                child: const InventoryScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/laporan',
              pageBuilder: (context, state) {
                final tabParam = state.uri.queryParameters['tab'];
                final initialTab = int.tryParse(tabParam ?? '');
                return AppPageTransitions.slide(
                  state: state,
                  child: ReportsScreen(
                    key: ValueKey(state.uri.toString()),
                    initialTabIndex: initialTab,
                  ),
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
      pageBuilder: (context, state) => AppPageTransitions.slide(
        state: state,
        child: const ReceivablesScreen(),
      ),
    ),
    GoRoute(
      path: '/warung',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => AppPageTransitions.slide(
        state: state,
        child: const CustomersScreen(),
      ),
    ),
  ],
);
