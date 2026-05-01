import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

abstract final class SupabaseInitializer {
  static final _log = AppLogger.getLogger('SupabaseInitializer');

  static Future<void> init() async {
    _log.info('Supabase initialization started');

    assert(AppConstants.supabaseUrl.isNotEmpty, 'SUPABASE_URL is missing.');
    assert(AppConstants.supabaseAnonKey.isNotEmpty,
        'SUPABASE_ANON_KEY is missing.');

    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
        debug: kDebugMode,
      );
      _log.info('Supabase initialization completed');
    } catch (e, st) {
      _log.shout('Supabase initialization failed: $e', e, st);
      rethrow;
    }
  }
}
