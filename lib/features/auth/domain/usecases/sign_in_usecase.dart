import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/admin_user_entity.dart';
import '../repositories/i_auth_repository.dart';

class SignInParams {
  const SignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

class SignInUseCase implements UseCase<AdminUserEntity, SignInParams> {
  const SignInUseCase(this._repository);
  final IAuthRepository _repository;

  @override
  Future<Either<Failure, AdminUserEntity>> call(SignInParams params) =>
      _repository.signIn(email: params.email, password: params.password);
}
