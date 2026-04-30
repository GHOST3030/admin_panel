import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/states/auth_state.dart';
import '../router/app_routes.dart';

/// GoRouter redirect guard — runs on every navigation event.
/// Returns null (allow) or a redirect path (block).
String? adminRoleGuard(BuildContext context, GoRouterState state, WidgetRef ref) {
  final authAsync = ref.read(authNotifierProvider);

  // Still loading — allow through; shell will show splash
  if (authAsync is AsyncLoading) return null;

  final authState = authAsync.valueOrNull;

  final isOnLoginPage = state.matchedLocation == AppRoutes.login;

  // Not authenticated → redirect to login
  if (authState is AuthUnauthenticated || authState == null) {
    return isOnLoginPage ? null : AppRoutes.login;
  }

  // Authenticated but not admin → force sign out + redirect
  if (authState is AuthAuthenticated && !authState.user.isAdmin) {
    return AppRoutes.login;
  }

  // Authenticated admin on login page → redirect to dashboard
  if (authState is AuthAuthenticated && isOnLoginPage) {
    return AppRoutes.dashboard;
  }

  return null; // allow
}
