import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../states/auth_state.dart';

final _log = AppLogger.getLogger('AuthNotifier');

final _authDataSourceProvider = Provider<IAuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(supabaseClientProvider)));

final _authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authDataSourceProvider)));

final _signInUseCaseProvider   = Provider((ref) => SignInUseCase(ref.watch(_authRepositoryProvider)));
final _signOutUseCaseProvider  = Provider((ref) => SignOutUseCase(ref.watch(_authRepositoryProvider)));
final _getCurrentUserProvider  = Provider((ref) => GetCurrentUserUseCase(ref.watch(_authRepositoryProvider)));

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    _log.info('Initializing auth state');
    final result = await ref.read(_getCurrentUserProvider).call(const NoParams());
    return result.fold(
      (failure) {
        _log.warning('Auth init failed: ${failure.message}');
        return const AuthUnauthenticated();
      },
      (user) {
        if (user != null && user.isAdmin) {
          _log.info('Auth initialized: admin user=${user.email}');
          return AuthAuthenticated(user);
        }
        _log.info('Auth initialized: no admin session');
        return const AuthUnauthenticated();
      },
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    _log.info('Sign-in flow started for email=$email');
    state = const AsyncLoading();
    final result = await ref.read(_signInUseCaseProvider)
        .call(SignInParams(email: email, password: password));
    state = result.fold(
      (f) {
        _log.warning('Sign-in flow failed: ${f.message}');
        return AsyncData(AuthError(f.message));
      },
      (user) {
        if (user.isAdmin) {
          _log.info('Sign-in flow completed: admin user=${user.email}');
          return AsyncData(AuthAuthenticated(user));
        }
        _log.warning('Non-admin sign-in rejected: email=$email');
        return const AsyncData(AuthError('Access denied: admin role required.'));
      },
    );
  }

  Future<void> signOut() async {
    _log.info('Sign-out flow started');
    await ref.read(_signOutUseCaseProvider).call(const NoParams());
    _log.info('Sign-out flow completed');
    state = const AsyncData(AuthUnauthenticated());
  }
}
