import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../states/auth_state.dart';

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
    final result = await ref.read(_getCurrentUserProvider).call(const NoParams());
    return result.fold(
      (_) => const AuthUnauthenticated(),
      (user) => user != null && user.isAdmin
          ? AuthAuthenticated(user)
          : const AuthUnauthenticated(),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await ref.read(_signInUseCaseProvider)
        .call(SignInParams(email: email, password: password));
    state = result.fold(
      (f) => AsyncData(AuthError(f.message)),


       
      (user) => user.isAdmin
          ? AsyncData(AuthAuthenticated(user))
          : const AsyncData(AuthError('Access denied: admin role required.')),
    );
  }

  Future<void> signOut() async {
    await ref.read(_signOutUseCaseProvider).call(const NoParams());
    state = const AsyncData(AuthUnauthenticated());
  }
}
