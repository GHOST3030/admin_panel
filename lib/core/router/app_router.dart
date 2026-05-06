import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/states/auth_state.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/category/presentation/pages/categories_page.dart';
import '../../features/product/presentation/pages/products_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/layout/widgets/admin_shell.dart';
import '../guards/unauthorized_page.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: _AuthNotifierListenable(ref),
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      if (authAsync is AsyncLoading) return null;

      final authState = authAsync.valueOrNull;
      final onLogin = state.matchedLocation == AppRoutes.login;

      if (authState is AuthUnauthenticated || authState == null) {
        return onLogin ? null : AppRoutes.login;
      }
      if (authState is AuthAuthenticated && !authState.user.isAdmin) {
        return AppRoutes.login;
      }
      if (authState is AuthAuthenticated && onLogin) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/unauthorized',
        builder: (_, __) => const UnauthorizedPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.categories,
            builder: (_, __) => const CategoriesPage(),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (_, __) => const ProductsPage(),
          ),
          GoRoute(
            path: AppRoutes.orders,
            builder: (_, __) => const OrdersPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});

/// Bridges Riverpod state changes to GoRouter's [Listenable] refresh.
class _AuthNotifierListenable extends ChangeNotifier {
  _AuthNotifierListenable( ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}
