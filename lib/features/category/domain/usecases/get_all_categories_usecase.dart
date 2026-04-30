import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/i_category_repository.dart';

class GetAllCategoriesUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  const GetAllCategoriesUseCase(this._repo);
  final ICategoryRepository _repo;
  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams p) => _repo.getAllCategories();
}
