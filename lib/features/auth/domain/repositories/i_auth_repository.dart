import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/admin_user_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AdminUserEntity>> signIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, AdminUserEntity?>> getCurrentUser();
}
