import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/logging/app_logger.dart';

final _log = AppLogger.getLogger('Dashboard');

class DashboardStats {
  const DashboardStats({
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalProducts,
    required this.totalUsers,
  });
  final int totalOrders;
  final double totalRevenue;
  final int totalProducts;
  final int totalUsers;
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  _log.fine('Loading dashboard stats');
  final client = ref.watch(supabaseClientProvider);

  try {
    final results = await Future.wait([
      client.from('orders').count(),
      client.from('orders').select('total_amount').eq('status', 'delivered'),
      client.from('products').count(),
      client.from('users').count(),
    ]);

    final ordersCount = results[0] as int;
    final revenueRes = results[1] as List;
    final productsCount = results[2] as int;
    final usersCount = results[3] as int;

    final revenue = revenueRes.fold<double>(
        0, (sum, row) => sum + ((row['total_amount'] as num?)?.toDouble() ?? 0));

    _log.info(
        'Dashboard stats loaded: orders=$ordersCount, revenue=$revenue, '
        'products=$productsCount, users=$usersCount');

    return DashboardStats(
      totalOrders: ordersCount,
      totalRevenue: revenue,
      totalProducts: productsCount,
      totalUsers: usersCount,
    );
  } catch (e, st) {
    _log.severe('Failed to load dashboard stats', e, st);
    rethrow;
  }
});

final recentOrdersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  _log.fine('Loading recent orders');
  final client = ref.watch(supabaseClientProvider);
  try {
    final res = await client
        .from('orders')
        .select('id, status, total_amount, created_at, users(email)')
        .order('created_at', ascending: false)
        .limit(10);
    _log.info('Recent orders loaded: count=${res.length}');
    return res;
  } catch (e, st) {
    _log.severe('Failed to load recent orders', e, st);
    rethrow;
  }
});
