import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/category_entity.dart';

abstract interface class ICategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();
  Future<Either<Failure, CategoryEntity>> createCategory(CategoryEntity c);
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity c);
  Future<Either<Failure, void>> deactivateCategory(String id);
}
