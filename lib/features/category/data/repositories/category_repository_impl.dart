import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  const CategoryRepositoryImpl(this._remote);
  final ICategoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try { return Right(await _remote.getAllCategories()); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
  @override
  Future<Either<Failure, CategoryEntity>> createCategory(CategoryEntity c) async {
    try { return Right(await _remote.createCategory(CategoryModel.fromEntity(c))); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity c) async {
    try { return Right(await _remote.updateCategory(CategoryModel.fromEntity(c))); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
  @override
  Future<Either<Failure, void>> deactivateCategory(String id) async {
    try { await _remote.deactivateCategory(id); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(message: e.message)); }
  }
}
