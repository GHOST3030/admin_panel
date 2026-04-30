import 'package:envied/envied.dart';

part 'app_env.g.dart';

/// Compile-time environment variable injection via Envied.
///
/// Usage:
///   flutter run --dart-define-from-file=.env.development
///   flutter run --dart-define-from-file=.env.staging
///   flutter build apk --dart-define-from-file=.env.production
@Envied(path: '.env.development')
abstract class AppEnv {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrll = _AppEnv.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', obfuscate: true)
  static final String supabaseAnonKey = _AppEnv.supabaseAnonKey;

  @EnviedField(varName: 'APP_ENV', defaultValue: 'development')
  static const String appEnv = _AppEnv.appEnv;

  @EnviedField(varName: 'APP_NAME', defaultValue: 'Flutter Ecommerce')
  static const String appName = _AppEnv.appName;

  static bool get isProduction => appEnv == 'production';
  static bool get isStaging => appEnv == 'staging';
  static bool get isDevelopment => appEnv == 'development';
}
