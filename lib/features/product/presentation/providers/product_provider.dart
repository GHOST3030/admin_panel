import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../states/product_state.dart';

final productNotifierProvider =
    AsyncNotifierProvider<ProductNotifier, ProductState>(ProductNotifier.new);

class ProductNotifier extends AsyncNotifier<ProductState> {
  @override
  Future<ProductState> build() async {
    await loadAll();
    return state.valueOrNull ?? const ProductInitial();
  }

  Future<void> loadAll({String? categoryId}) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      var query = client.from('products').select('*, categories(name_en)');
      if (categoryId != null) query = query.eq('category_id', categoryId);
      final res = await query.order('sort_order');
      state = AsyncData(ProductLoaded(List<Map<String, dynamic>>.from(res as List)));
    } catch (e) {
      state = AsyncData(ProductError(e.toString()));
    }
  }

  Future<void> create(Map<String, dynamic> data) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('products').insert(data);
      await loadAll();
    } catch (e) { state = AsyncData(ProductError(e.toString())); }
  }

  Future<void> updatee(String id, Map<String, dynamic> data) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('products').update(data).eq('id', id);
      await loadAll();
    } catch (e) { state = AsyncData(ProductError(e.toString())); }
  }

  Future<void> deactivate(String id) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('products').update({'is_active': false}).eq('id', id);
      await loadAll();
    } catch (e) { state = AsyncData(ProductError(e.toString())); }
  }
}
