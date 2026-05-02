import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/widgets/responsive/adaptive_scaffold.dart';
import '../../../../core/widgets/responsive/adaptive_table.dart';
import '../../../../core/widgets/responsive/responsive_padding.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final ordersAsync = ref.watch(recentOrdersProvider);
    final currency = NumberFormat.currency(symbol: '\$');

    return AdaptiveScaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentOrdersProvider);
        },
        child: ListView(
          children: [
            ResponsivePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stat Cards ──────────────────────────────
                  statsAsync.when(
                    loading: () => const _StatsShimmer(),
                    error: (e, _) => _ErrorBanner('$e'),
                    data: (stats) =>
                        _StatsGrid(stats: stats, currency: currency),
                  ),

                  const SizedBox(height: 32),

                  // ── Recent Orders ───────────────────────────
                  _SectionHeader(
                    title: 'Recent Orders',
                    action: TextButton(
                      onPressed: () {},
                      child: const Text('View all'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  ordersAsync.when(
                    loading: () => const Center(
                        heightFactor: 3, child: CircularProgressIndicator(),),
                    error: (e, _) => _ErrorBanner('$e'),
                    data: (orders) => AdaptiveTable<Map<String, dynamic>>(
                      columns: const [
                        'Order ID',
                        'Customer',
                        'Status',
                        'Amount',
                        'Date',
                      ],
                      tabletColumns: const [
                        'Order ID',
                        'Status',
                        'Amount',
                      ],
                      items: orders,
                      desktopRow: (o, isTablet) {
                        final date =
                            DateTime.tryParse(o['created_at'] as String? ?? '');
                        final cells = isTablet
                            ? [
                                DataCell(
                                    Text((o['id'] as String).substring(0, 8)),),
                                DataCell(
                                    _StatusChip(o['status'] as String? ?? ''),),
                                DataCell(Text(currency.format(
                                    (o['total_amount'] as num?)?.toDouble() ??
                                        0,),),),
                              ]
                            : [
                                DataCell(
                                    Text((o['id'] as String).substring(0, 8)),),
                                DataCell(Text(
                                  ((o['users'] as Map?)?['email'] as String?) ??
                                      '—',
                                  overflow: TextOverflow.ellipsis,
                                ),),
                                DataCell(
                                    _StatusChip(o['status'] as String? ?? ''),),
                                DataCell(Text(currency.format(
                                    (o['total_amount'] as num?)?.toDouble() ??
                                        0,),),),
                                DataCell(Text(date != null
                                    ? DateFormat('MMM d, yyyy').format(date)
                                    : '—',),),
                              ];
                        return DataRow(cells: cells);
                      },
                      mobileCard: (o) {
                        final date =
                            DateTime.tryParse(o['created_at'] as String? ?? '');
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '#${(o['id'] as String).substring(0, 8)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,),
                                    ),
                                    _StatusChip(o['status'] as String? ?? ''),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ((o['users'] as Map?)?['email'] as String?) ??
                                      '—',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        currency.format(
                                            (o['total_amount'] as num?)
                                                    ?.toDouble() ??
                                                0,),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,),),
                                    Text(
                                      date != null
                                          ? DateFormat('MMM d').format(date)
                                          : '—',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.currency});
  final DashboardStats stats;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final cols = context.statColumns;
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio:
          context.responsiveWhen(mobile: 2.4, tablet: 2.6, desktop: 3.0),
      children: [
        StatCard(
            title: 'Total Orders',
            value: '${stats.totalOrders}',
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF4361EE),),
        StatCard(
            title: 'Total Revenue',
            value: currency.format(stats.totalRevenue),
            icon: Icons.attach_money_rounded,
            color: const Color(0xFF2DC653),),
        StatCard(
            title: 'Total Products',
            value: '${stats.totalProducts}',
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFFF4A261),),
        StatCard(
            title: 'Total Users',
            value: '${stats.totalUsers}',
            icon: Icons.people_rounded,
            color: const Color(0xFFE63946),),
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),),
        if (action != null) action!,
      ],
    );
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: context.statColumns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 3.0,
      children: List.generate(4, (_) => const Card(child: SizedBox.expand())),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message,
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'delivered' => (const Color(0xFFDCFCE7), const Color(0xFF166534)),
      'processing' => (const Color(0xFFFEF3C7), const Color(0xFF92400E)),
      'shipped' => (const Color(0xFFDBEAFE), const Color(0xFF1E40AF)),
      'cancelled' => (const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
      _ => (const Color(0xFFF3F4F6), const Color(0xFF374151)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),),
    );
  }
}
