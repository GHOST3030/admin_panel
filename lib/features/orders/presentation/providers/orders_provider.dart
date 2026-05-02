import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/logging/app_logger.dart';
import '../states/orders_state.dart';

final _log = AppLogger.getLogger('OrdersNotifier');

final ordersNotifierProvider =
    AsyncNotifierProvider<OrdersNotifier, OrdersState>(OrdersNotifier.new);

class OrdersNotifier extends AsyncNotifier<OrdersState> {
  @override
  Future<OrdersState> build() async {
    _log.info('Initializing orders');
    await loadAll();
    return state.valueOrNull ?? const OrdersInitial();
  }

  Future<void> loadAll({String? statusFilter}) async {
    _log.fine(
      'Loading orders${statusFilter != null ? ", statusFilter=$statusFilter" : ""}',
    );
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      dynamic query = client
          .from('orders')
          .select('*, users(email, full_name)')
          .order('created_at', ascending: false);
      // ignore: avoid_dynamic_calls
      if (statusFilter != null) query = query.eq('status', statusFilter);
      final res = await query;
      final list = List<Map<String, dynamic>>.from(res as List);
      _log.info('Orders loaded: count=${list.length}');
      state = AsyncData(OrdersLoaded(list));
    } catch (e, st) {
      _log.severe('Failed to load orders', e, st);
      state = AsyncData(OrdersError(e.toString()));
    }
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    _log.info('Updating order status: orderId=$orderId, newStatus=$newStatus');
    try {
      final client = ref.read(supabaseClientProvider);
      await client
          .from('orders')
          .update({'status': newStatus}).eq('id', orderId);
      _log.info('Order status updated: orderId=$orderId, status=$newStatus');
      await loadAll();
    } catch (e, st) {
      _log.severe('Failed to update order status: orderId=$orderId', e, st);
      state = AsyncData(OrdersError(e.toString()));
    }
  }
}
