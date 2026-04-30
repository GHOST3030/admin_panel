import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/admin_user_entity.dart';
import '../repositories/i_auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<AdminUserEntity?, NoParams> {
  const GetCurrentUserUseCase(this._repository);
  final IAuthRepository _repository;

  @override
  Future<Either<Failure, AdminUserEntity?>> call(NoParams params) =>
      _repository.getCurrentUser();
}
