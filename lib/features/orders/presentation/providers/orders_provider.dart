import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../states/orders_state.dart';

final ordersNotifierProvider =
    AsyncNotifierProvider<OrdersNotifier, OrdersState>(OrdersNotifier.new);

class OrdersNotifier extends AsyncNotifier<OrdersState> {
  @override
  Future<OrdersState> build() async {
    await loadAll();
    return state.valueOrNull ?? const OrdersInitial();
  }

  Future<void> loadAll({String? statusFilter}) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      dynamic query = client
          .from('orders')
          .select('*, users(email, full_name)')
          .order('created_at', ascending: false);
      if (statusFilter != null) query = query.eq('status', statusFilter);
      final res = await query;
      state = AsyncData(OrdersLoaded(List<Map<String, dynamic>>.from(res as List)));
    } catch (e) { state = AsyncData(OrdersError(e.toString())); }
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.from('orders').update({'status': newStatus}).eq('id', orderId);
      await loadAll();
    } catch (e) { state = AsyncData(OrdersError(e.toString())); }
  }
}
