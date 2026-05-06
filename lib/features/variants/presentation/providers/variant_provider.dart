import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../states/variant_state.dart';

final variantNotifierProvider = AsyncNotifierProviderFamily<VariantNotifier, VariantState, String>(
  VariantNotifier.new,
);

class VariantNotifier extends FamilyAsyncNotifier<VariantState, String> {
  @override
  Future<VariantState> build(String productId) async {
    await loadAll(productId);
    return state.valueOrNull ?? const VariantInitial();
  }

  Future<void> loadAll(String productId) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      final res = await client
          .from('product_variants')
          .select()
          .eq('product_id', productId)
          .order('sort_order');
      state = AsyncData(VariantLoaded(List<Map<String, dynamic>>.from(res as List)));
    } catch (e) { state = AsyncData(VariantError(e.toString())); }
  }

  Future<void> create(String productId, Map<String, dynamic> data) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('product_variants').insert({...data, 'product_id': productId});
      await loadAll(productId);
    } catch (e) { state = AsyncData(VariantError(e.toString())); }
  }

  Future<void> updatee(String productId, String variantId, Map<String, dynamic> data) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('product_variants').update(data).eq('id', variantId);
      await loadAll(productId);
    } catch (e) { state = AsyncData(VariantError(e.toString())); }
  }

  Future<void> deactivate(String productId, String variantId) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('product_variants').update({'is_active': false}).eq('id', variantId);
      await loadAll(productId);
    } catch (e) { state = AsyncData(VariantError(e.toString())); }
  }
}
