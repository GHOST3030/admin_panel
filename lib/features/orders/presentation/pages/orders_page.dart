import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/orders_provider.dart';
import '../states/orders_state.dart';
import 'order_detail_page.dart';

const _statuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});
  @override ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  String? _filterStatus;
  final _currency = NumberFormat.currency(symbol: '\$');

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          DropdownButton<String>(
            value: _filterStatus,
            hint: const Text('All Statuses'),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Statuses')),
              ..._statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
            ],
            onChanged: (v) {
              setState(() => _filterStatus = v);
              ref.read(ordersNotifierProvider.notifier).loadAll(statusFilter: v);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => switch (s) {
          OrdersError()   => Center(child: Text(s.message)),
          OrdersLoading() => const Center(child: CircularProgressIndicator()),
          OrdersLoaded()  => Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: s.orders.map((o) {
                  final date = DateTime.tryParse(o['created_at'] as String? ?? '');
                  return DataRow(cells: [
                    DataCell(Text((o['id'] as String).substring(0, 8))),
                    DataCell(Text(
                      ((o['users'] as Map?)?['email'] as String?) ?? '—',
                      overflow: TextOverflow.ellipsis,
                    )),
                    DataCell(Text(_currency.format((o['total_amount'] as num?)?.toDouble() ?? 0))),
                    DataCell(_StatusDropdown(
                      orderId: o['id'] as String,
                      current: o['status'] as String? ?? 'pending',
                      ref: ref,
                    )),
                    DataCell(Text(date != null ? DateFormat('MMM d, yyyy').format(date) : '—')),
                    DataCell(IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailPage(orderId: o['id'] as String),
                        ),
                      ),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
          OrdersInitial() => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.orderId, required this.current, required this.ref});
  final String orderId;
  final String current;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final color = switch (current) {
      'delivered'  => Colors.green,
      'processing' => Colors.orange,
      'shipped'    => Colors.blue,
      'cancelled'  => Colors.red,
      _            => Colors.grey,
    };
    return DropdownButton<String>(
      value: current,
      underline: const SizedBox(),
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) {
        if (v != null && v != current) {
          ref.read(ordersNotifierProvider.notifier).updateStatus(orderId, v);
        }
      },
    );
  }
}
