import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/logging/app_logger.dart';
import '../states/variant_state.dart';

final _log = AppLogger.getLogger('VariantNotifier');

final variantNotifierProvider = AsyncNotifierProviderFamily<VariantNotifier, VariantState, String>(
  VariantNotifier.new,
);

class VariantNotifier extends FamilyAsyncNotifier<VariantState, String> {
  @override
  Future<VariantState> build(String productId) async {
    _log.info('Initializing variants for productId=$productId');
    await loadAll(productId);
    return state.valueOrNull ?? const VariantInitial();
  }

  Future<void> loadAll(String productId) async {
    _log.fine('Loading variants for productId=$productId');
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      final res = await client
          .from('product_variants')
          .select()
          .eq('product_id', productId)
          .order('sort_order');
      final list = List<Map<String, dynamic>>.from(res as List);
      _log.info('Variants loaded: productId=$productId, count=${list.length}');
      state = AsyncData(VariantLoaded(list));
    } catch (e, st) {
      _log.severe('Failed to load variants for productId=$productId', e, st);
      state = AsyncData(VariantError(e.toString()));
    }
  }

  Future<void> create(String productId, Map<String, dynamic> data) async {
    _log.info('Creating variant for productId=$productId');
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('product_variants').insert({...data, 'product_id': productId});
      _log.info('Variant created for productId=$productId');
      await loadAll(productId);
    } catch (e, st) {
      _log.severe('Failed to create variant for productId=$productId', e, st);
      state = AsyncData(VariantError(e.toString()));
    }
  }

  Future<void> updatee(String productId, String variantId, Map<String, dynamic> data) async {
    _log.info('Updating variant: variantId=$variantId, productId=$productId');
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('product_variants').update(data).eq('id', variantId);
      _log.info('Variant updated: variantId=$variantId');
      await loadAll(productId);
    } catch (e, st) {
      _log.severe('Failed to update variant: variantId=$variantId', e, st);
      state = AsyncData(VariantError(e.toString()));
    }
  }

  Future<void> deactivate(String productId, String variantId) async {
    _log.info('Deactivating variant: variantId=$variantId, productId=$productId');
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('product_variants').update({'is_active': false}).eq('id', variantId);
      _log.info('Variant deactivated: variantId=$variantId');
      await loadAll(productId);
    } catch (e, st) {
      _log.severe('Failed to deactivate variant: variantId=$variantId', e, st);
      state = AsyncData(VariantError(e.toString()));
    }
  }
}
