import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../domain/usecases/get_all_categories_usecase.dart';
import '../states/category_state.dart';

final _log = AppLogger.getLogger('CategoryNotifier');

final _catDsProvider   = Provider<ICategoryRemoteDataSource>((ref) => CategoryRemoteDataSource(ref.watch(supabaseClientProvider)));
final _catRepoProvider = Provider<ICategoryRepository>((ref) => CategoryRepositoryImpl(ref.watch(_catDsProvider)));
final _getAllCatProvider = Provider((ref) => GetAllCategoriesUseCase(ref.watch(_catRepoProvider)));

final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, CategoryState>(CategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<CategoryState> {
  @override
  Future<CategoryState> build() async {
    _log.info('Initializing categories');
    await loadAll();
    return state.valueOrNull ?? const CategoryInitial();
  }

  Future<void> loadAll() async {
    _log.fine('Loading all categories');
    state = const AsyncLoading();
    final res = await ref.read(_getAllCatProvider).call(const NoParams());
    state = res.fold(
      (f) {
        _log.severe('Failed to load categories: ${f.message}');
        return AsyncData(CategoryError(f.message));
      },
      (list) {
        _log.info('Categories loaded: count=${list.length}');
        return AsyncData(CategoryLoaded(list));
      },
    );
  }

  Future<void> create(CategoryEntity cat) async {
    _log.info('Creating category: name=${cat.nameEn}');
    final repo = ref.read(_catRepoProvider);
    final res = await repo.createCategory(cat);
    res.fold(
      (f) => _log.severe('Category creation failed: ${f.message}'),
      (_) {
        _log.info('Category created successfully');
        loadAll();
      },
    );
  }

  Future<void> updatee(CategoryEntity cat) async {
    _log.info('Updating category: id=${cat.id}');
    final repo = ref.read(_catRepoProvider);
    final res = await repo.updateCategory(cat);
    res.fold(
      (f) => _log.severe('Category update failed: ${f.message}'),
      (_) {
        _log.info('Category updated successfully');
        loadAll();
      },
    );
  }

  Future<void> deactivate(String id) async {
    _log.info('Deactivating category: id=$id');
    final repo = ref.read(_catRepoProvider);
    final res = await repo.deactivateCategory(id);
    res.fold(
      (f) => _log.severe('Category deactivation failed: ${f.message}'),
      (_) {
        _log.info('Category deactivated successfully');
        loadAll();
      },
    );
  }
}
