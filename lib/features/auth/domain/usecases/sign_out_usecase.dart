import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/i_auth_repository.dart';

class SignOutUseCase implements UseCase<void, NoParams> {
  const SignOutUseCase(this._repository);
  final IAuthRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repository.signOut();
}
