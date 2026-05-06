import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive/adaptive_scaffold.dart';
import '../../../../core/widgets/responsive/adaptive_table.dart';
import '../../../../core/widgets/responsive/responsive_padding.dart';
import '../../../../core/widgets/shared/status_badge.dart';
import '../providers/orders_provider.dart';
import '../states/orders_state.dart';
import 'order_detail_page.dart';

const _statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});
  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  String? _filterStatus;
  final _currency = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersNotifierProvider);

    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          _StatusFilter(
            value: _filterStatus,
            onChanged: (v) {
              setState(() => _filterStatus = v);
              ref.read(ordersNotifierProvider.notifier)
                  .loadAll(statusFilter: v);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('$e')),
        data: (s) => switch (s) {
          OrdersError()   => Center(child: Text(s.message)),
          OrdersLoading() => const Center(child: CircularProgressIndicator()),
          OrdersInitial() => const SizedBox.shrink(),
          OrdersLoaded()  => ResponsivePadding(
            child: AdaptiveTable<Map<String, dynamic>>(
              columns: const [
                'Order ID', 'Customer', 'Total', 'Status', 'Date', 'View',
              ],
              tabletColumns: const ['Order ID', 'Total', 'Status', 'View'],
              items: s.orders,
              desktopRow: (o, isTablet) {
                final date = DateTime.tryParse(
                    o['created_at'] as String? ?? '');
                final id = (o['id'] as String).substring(0, 8);
                final amount = _currency.format(
                    (o['total_amount'] as num?)?.toDouble() ?? 0);

                return DataRow(cells: isTablet
                    ? [
                        DataCell(Text('#$id')),
                        DataCell(Text(amount)),
                        DataCell(_StatusDropdown(
                          orderId: o['id'] as String,
                          current: o['status'] as String? ?? 'pending',
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.visibility_outlined,
                              size: 18, color: context.secondary),
                          onPressed: () => _openDetail(context, o['id'] as String),
                        )),
                      ]
                    : [
                        DataCell(Text('#$id')),
                        DataCell(Text(
                          ((o['users'] as Map?)?['email'] as String?) ?? '—',
                          overflow: TextOverflow.ellipsis,
                        )),
                        DataCell(Text(amount)),
                        DataCell(_StatusDropdown(
                          orderId: o['id'] as String,
                          current: o['status'] as String? ?? 'pending',
                        )),
                        DataCell(Text(date != null
                            ? DateFormat('MMM d, y').format(date)
                            : '—')),
                        DataCell(IconButton(
                          icon: Icon(Icons.visibility_outlined,
                              size: 18, color: context.secondary),
                          onPressed: () => _openDetail(context, o['id'] as String),
                        )),
                      ]);
              },
              mobileCard: (o) => _OrderCard(
                order: o,
                currency: _currency,
                onView: () => _openDetail(context, o['id'] as String),
              ),
            ),
          ),
        },
      ),
    );
  }

  void _openDetail(BuildContext ctx, String orderId) => Navigator.push(
    ctx,
    MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: orderId)),
  );
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: value,
      hint: Text('All Statuses',
          style: context.bodySmall.copyWith(color: context.mutedText)),
      borderRadius: BorderRadius.circular(8),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text('All Statuses', style: context.bodySmall),
        ),
        ..._statuses.map((s) =>
            DropdownMenuItem(value: s, child: Text(s, style: context.bodySmall))),
      ],
      onChanged: onChanged,
    ),
  );
}

class _StatusDropdown extends ConsumerWidget {
  const _StatusDropdown({required this.orderId, required this.current});
  final String orderId;
  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:fg, :bg) = context.statusColors(current);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current,
        style: context.bodySmall
            .copyWith(color: fg, fontWeight: FontWeight.w600),
        borderRadius: BorderRadius.circular(8),
        items: _statuses.map((s) =>
            DropdownMenuItem(value: s,
                child: Text(s, style: context.bodySmall))).toList(),
        onChanged: (v) {
          if (v != null && v != current) {
            ref.read(ordersNotifierProvider.notifier)
                .updateStatus(orderId, v);
          }
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard(
      {required this.order, required this.currency, required this.onView});
  final Map<String, dynamic> order;
  final NumberFormat currency;
  final VoidCallback onView;

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
            Text(((order['users'] as Map?)?['email'] as String?) ?? '—',
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
                Row(children: [
                  Text(
                      date != null
                          ? DateFormat('MMM d').format(date)
                          : '—',
                      style: context.bodySmall
                          .copyWith(color: context.mutedText)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.visibility_outlined,
                        size: 18, color: context.secondary),
                    onPressed: onView,
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
