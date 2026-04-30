import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

final class AuthInitial         extends AuthState { const AuthInitial(); }
final class AuthLoading         extends AuthState { const AuthLoading(); }
final class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AdminUserEntity user;
  @override List<Object?> get props => [user];
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}
