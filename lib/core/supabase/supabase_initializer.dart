import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

abstract final class SupabaseInitializer {
  static Future<void> init() async {
    assert(AppConstants.supabaseUrl.isNotEmpty, 'SUPABASE_URL is missing.');
    assert(AppConstants.supabaseAnonKey.isNotEmpty,
        'SUPABASE_ANON_KEY is missing.');
    await Supabase.initialize(
      url: 'https://grwdxfhkhbcvyemxdqcu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdyd2R4ZmhraGJjdnllbXhkcWN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMDAwMDAsImV4cCI6MjA5Mjc3NjAwMH0.9pomNXh40cITUVo3nH9brwkNxatHt_YOnmtHJKsHngM',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      debug: kDebugMode,
    ); await Supabase.initialize(
      url: 'https://grwdxfhkhbcvyemxdqcu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdyd2R4ZmhraGJjdnllbXhkcWN1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcyMDAwMDAsImV4cCI6MjA5Mjc3NjAwMH0.9pomNXh40cITUVo3nH9brwkNxatHt_YOnmtHJKsHngM',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      debug: kDebugMode,
    );
  }
}
