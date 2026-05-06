import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../router/app_routes.dart';
import '../theme/app_text_styles.dart';

class UnauthorizedPage extends ConsumerWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.lock_outline_rounded, size: 80, color: context.error),
        const SizedBox(height: 16),
        Text('Access Denied',
            style: context.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('You do not have admin privileges.',
            style: context.bodyMedium.copyWith(color: context.mutedText)),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
            if (context.mounted) context.go(AppRoutes.login);
          },
          child: const Text('Sign Out'),
        ),
      ]),
    ),
  );
}
