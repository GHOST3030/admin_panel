import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._remote);
  final IAuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, AdminUserEntity>> signIn({required String email, required String password}) async {
    try { return Right(await _remote.signIn(email: email, password: password)); }
    on AuthException catch (e) { return Left(AuthFailure(message: e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try { await _remote.signOut(); return const Right(null); }
    on AuthException catch (e) { return Left(AuthFailure(message: e.message)); }
  }

  @override
  Future<Either<Failure, AdminUserEntity?>> getCurrentUser() async {
    try { return Right(await _remote.getCurrentUser()); }
    on AuthException catch (e) { return Left(AuthFailure(message: e.message)); }
  }
}
