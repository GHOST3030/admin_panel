import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../states/category_state.dart';

final _catDsProvider   = Provider<ICategoryRemoteDataSource>((ref) => CategoryRemoteDataSource(ref.watch(supabaseClientProvider)));
final _catRepoProvider = Provider<ICategoryRepository>((ref) => CategoryRepositoryImpl(ref.watch(_catDsProvider)));
final _getAllCatProvider = Provider((ref) => GetAllCategoriesUseCase(ref.watch(_catRepoProvider)));

final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, CategoryState>(CategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<CategoryState> {
  @override
  Future<CategoryState> build() async {
    await loadAll();
    return state.valueOrNull ?? const CategoryInitial();
  }

  Future<void> loadAll() async {
    state = const AsyncLoading();
    final res = await ref.read(_getAllCatProvider).call(const NoParams());
    state = res.fold(
      (f) => AsyncData(CategoryError(f.message)),
      (list) => AsyncData(CategoryLoaded(list)),
    );
  }

  Future<void> create(CategoryEntity cat) async {
    final repo = ref.read(_catRepoProvider);
    final res = await repo.createCategory(cat);
    res.fold((_) {}, (_) => loadAll());
  }


  Future<void> updatee(CategoryEntity cat) async {
    final repo = ref.read(_catRepoProvider);
    final res = await repo.updateCategory(cat);
    res.fold((_) {}, (_) => loadAll());
  }

  Future<void> deactivate(String id) async {
    final repo = ref.read(_catRepoProvider);
    final res = await repo.deactivateCategory(id);
    res.fold((_) {}, (_) => loadAll());
  }
}
