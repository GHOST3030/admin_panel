import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive/adaptive_scaffold.dart';
import '../../../../core/widgets/responsive/adaptive_table.dart';
import '../../../../core/widgets/responsive/responsive_padding.dart';
import '../../../../core/widgets/shared/error_banner.dart';
import '../../../../core/widgets/shared/section_header.dart';
import '../../../../core/widgets/shared/status_badge.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync  = ref.watch(dashboardStatsProvider);
    final ordersAsync = ref.watch(recentOrdersProvider);
    final currency    = NumberFormat.currency(symbol: '\$');

    return AdaptiveScaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentOrdersProvider);
        },
        child: ListView(children: [
          ResponsivePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Stats ─────────────────────────────────────
                statsAsync.when(
                  loading: () => _StatsShimmer(cols: context.statColumns),
                  error:   (e, _) => ErrorBanner('$e'),
                  data: (s) => _StatsGrid(stats: s, currency: currency),
                ),

                const SizedBox(height: 32),

                // ── Recent orders ─────────────────────────────
                SectionHeader(
                  title: 'Recent Orders',
                  action: TextButton(
                    onPressed: () {},
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 12),

                ordersAsync.when(
                  loading: () => const Center(
                      heightFactor: 3,
                      child: CircularProgressIndicator()),
                  error: (e, _) => ErrorBanner('$e'),
                  data: (orders) =>
                      AdaptiveTable<Map<String, dynamic>>(
                    columns: const [
                      'Order ID', 'Customer', 'Status', 'Amount', 'Date',
                    ],
                    tabletColumns: const ['Order ID', 'Status', 'Amount'],
                    items: orders,
                    desktopRow: (o, isTablet) {
                      final date = DateTime.tryParse(
                          o['created_at'] as String? ?? '');
                      final amount = currency.format(
                          (o['total_amount'] as num?)?.toDouble() ?? 0);
                      final id = (o['id'] as String).substring(0, 8);

                      return DataRow(cells: isTablet
                          ? [
                              DataCell(Text('#$id')),
                              DataCell(StatusBadge(
                                  o['status'] as String? ?? '')),
                              DataCell(Text(amount)),
                            ]
                          : [
                              DataCell(Text('#$id')),
                              DataCell(Text(
                                ((o['users'] as Map?)?['email'] as String?) ?? '—',
                                overflow: TextOverflow.ellipsis,
                              )),
                              DataCell(StatusBadge(
                                  o['status'] as String? ?? '')),
                              DataCell(Text(amount)),
                              DataCell(Text(date != null
                                  ? DateFormat('MMM d, y').format(date)
                                  : '—')),
                            ]);
                    },
                    mobileCard: (o) => _OrderCard(order: o, currency: currency),
                  ),
                ),
              ],
            ),
          ),
        ]),
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
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: context.statColumns,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: context.responsiveWhen(
        mobile: 2.4, tablet: 2.6, desktop: 3.0),
    children: [
      StatCard(title: 'Total Orders',   value: '${stats.totalOrders}',
          icon: Icons.receipt_long_rounded, color: context.secondary),
      StatCard(title: 'Total Revenue',  value: currency.format(stats.totalRevenue),
          icon: Icons.attach_money_rounded, color: context.successColor),
      StatCard(title: 'Total Products', value: '${stats.totalProducts}',
          icon: Icons.inventory_2_rounded, color: context.warningColor),
      StatCard(title: 'Total Users',    value: '${stats.totalUsers}',
          icon: Icons.people_rounded, color: context.error),
    ],
  );
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer({required this.cols});
  final int cols;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: cols,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 3.0,
    children: List.generate(4, (_) => Card(
      child: Container(color: context.surfaceContainerLow))),
  );
}

// ── Mobile order card ─────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.currency});
  final Map<String, dynamic> order;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(order['created_at'] as String? ?? '');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('#${(order['id'] as String).substring(0, 8)}',
                    style: context.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                StatusBadge(order['status'] as String? ?? ''),
              ],
            ),
            const SizedBox(height: 8),
            Text(
                ((order['users'] as Map?)?['email'] as String?) ?? '—',
                style: context.bodySmall.copyWith(color: context.mutedText)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    currency.format(
                        (order['total_amount'] as num?)?.toDouble() ?? 0),
                    style: context.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(
                    date != null
                        ? DateFormat('MMM d').format(date)
                        : '—',
                    style: context.bodySmall
                        .copyWith(color: context.mutedText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
