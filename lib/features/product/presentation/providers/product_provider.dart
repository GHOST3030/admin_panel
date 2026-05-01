import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/logging/app_logger.dart';
import '../states/product_state.dart';

final _log = AppLogger.getLogger('ProductNotifier');

final productNotifierProvider =
    AsyncNotifierProvider<ProductNotifier, ProductState>(ProductNotifier.new);

class ProductNotifier extends AsyncNotifier<ProductState> {
  @override
  Future<ProductState> build() async {
    _log.info('Initializing products');
    await loadAll();
    return state.valueOrNull ?? const ProductInitial();
  }

  Future<void> loadAll({String? categoryId}) async {
    _log.fine('Loading products${categoryId != null ? ", categoryId=$categoryId" : ""}');
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      var query = client.from('products').select('*, categories(name_en)');
      if (categoryId != null) query = query.eq('category_id', categoryId);
      final res = await query.order('sort_order');
      final list = List<Map<String, dynamic>>.from(res as List);
      _log.info('Products loaded: count=${list.length}');
      state = AsyncData(ProductLoaded(list));
    } catch (e, st) {
      _log.severe('Failed to load products', e, st);
      state = AsyncData(ProductError(e.toString()));
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    _log.info('Creating product');
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('products').insert(data);
      _log.info('Product created successfully');
      await loadAll();
    } catch (e, st) {
      _log.severe('Failed to create product', e, st);
      state = AsyncData(ProductError(e.toString()));
    }
  }

  Future<void> updatee(String id, Map<String, dynamic> data) async {
    _log.info('Updating product: id=$id');
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('products').update(data).eq('id', id);
      _log.info('Product updated: id=$id');
      await loadAll();
    } catch (e, st) {
      _log.severe('Failed to update product: id=$id', e, st);
      state = AsyncData(ProductError(e.toString()));
    }
  }

  Future<void> deactivate(String id) async {
    _log.info('Deactivating product: id=$id');
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('products').update({'is_active': false}).eq('id', id);
      _log.info('Product deactivated: id=$id');
      await loadAll();
    } catch (e, st) {
      _log.severe('Failed to deactivate product: id=$id', e, st);
      state = AsyncData(ProductError(e.toString()));
    }
  }
}
