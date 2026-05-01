import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

final _log = AppLogger.getLogger('CategoryRepository');

class CategoryRepositoryImpl implements ICategoryRepository {
  const CategoryRepositoryImpl(this._remote);
  final ICategoryRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      return Right(await _remote.getAllCategories());
    } on ServerException catch (e) {
      _log.severe('Server failure fetching categories: ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }
  @override
  Future<Either<Failure, CategoryEntity>> createCategory(CategoryEntity c) async {
    try {
      return Right(await _remote.createCategory(CategoryModel.fromEntity(c)));
    } on ServerException catch (e) {
      _log.severe('Server failure creating category: ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }
  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity c) async {
    try {
      return Right(await _remote.updateCategory(CategoryModel.fromEntity(c)));
    } on ServerException catch (e) {
      _log.severe('Server failure updating category: ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }
  @override
  Future<Either<Failure, void>> deactivateCategory(String id) async {
    try {
      await _remote.deactivateCategory(id);
      return const Right(null);
    } on ServerException catch (e) {
      _log.severe('Server failure deactivating category: ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }
}
