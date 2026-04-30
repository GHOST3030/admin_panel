import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/di/providers.dart';

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
  final client = ref.watch(supabaseClientProvider);

  final results = await Future.wait([
    client.from('orders').select('id'),
    client.from('orders').select('total_amount').eq('status', 'delivered'),
    client.from('products').select('id'),
    client.from('users').select('id'),
  ]);
  

  final ordersRes   = results[0] as PostgrestResponse;
  final revenueRes  = results[1] as List;
  final productsRes = results[2] as PostgrestResponse;
  final usersRes    = results[3] as PostgrestResponse;

  final revenue = revenueRes.fold<double>(
    0, (sum, row) => sum + ((row['total_amount'] as num?)?.toDouble() ?? 0));

  return DashboardStats(
    totalOrders:   ordersRes.count ?? 0,
    totalRevenue:  revenue,
    totalProducts: productsRes.count ?? 0,
    totalUsers:    usersRes.count ?? 0,
  );
});

final recentOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final res = await client
      .from('orders')
      .select('id, status, total_amount, created_at, users(email)')
      .order('created_at', ascending: false)
      .limit(10);
  return List<Map<String, dynamic>>.from(res as List);
});
