import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/logging/app_logger.dart';
import 'core/router/app_router.dart';
import 'core/supabase/supabase_initializer.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  final log = AppLogger.getLogger('Main');

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppLogger.init();

    log.info('Application starting');

    FlutterError.onError = (details) {
      log.shout('Unhandled Flutter error: ${details.exceptionAsString()}');
      if (details.stack != null) {
        log.shout('Stack trace:\n${details.stack}');
      }
    };

    await SupabaseInitializer.init();
    log.info('Application initialized successfully');

    runApp(const ProviderScope(child: AdminApp()));
  }, (error, stackTrace) {
    log.shout('Unhandled async error: $error');
    log.shout('Stack trace:\n$stackTrace');
  });
}

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'E-Commerce Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
