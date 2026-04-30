import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/providers.dart';

final _orderDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final client = ref.watch(supabaseClientProvider);
  final order = await client
      .from('orders')
      .select('*, users(email, full_name, phone)')
      .eq('id', orderId)
      .single();
  final items = await client
      .from('order_items')
      .select('*, product_variants(*, products(name_en, name_ar))')
      .eq('order_id', orderId);
  return {'order': order, 'items': items};
});

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_orderDetailProvider(orderId));
    final currency = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: Text('Order ${orderId.substring(0, 8)}')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) {
          final order = data['order'] as Map<String, dynamic>;
          final items = data['items'] as List;
          final user  = order['users'] as Map? ?? {};
          final date  = DateTime.tryParse(order['created_at'] as String? ?? '');

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Order info
              Card(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Order Info', style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _InfoRow('Status', order['status'] as String? ?? '—'),
                  _InfoRow('Total', currency.format((order['total_amount'] as num?)?.toDouble() ?? 0)),
                  _InfoRow('Date', date != null ? DateFormat('MMM d, yyyy HH:mm').format(date) : '—'),
                ]),
              )),
              const SizedBox(height: 16),
              // Customer info
              Card(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Customer', style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  _InfoRow('Name',  user['full_name'] as String? ?? '—'),
                  _InfoRow('Email', user['email']     as String? ?? '—'),
                  _InfoRow('Phone', user['phone']     as String? ?? '—'),
                ]),
              )),
              const SizedBox(height: 16),
              // Items
              Card(child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Items', style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  DataTable(
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Size')),
                      DataColumn(label: Text('Color')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Unit Price')),
                      DataColumn(label: Text('Subtotal')),
                    ],
                    rows: (items).map((item) {
                      final variant  = item['product_variants'] as Map? ?? {};
                      final product  = variant['products']      as Map? ?? {};
                      final qty      = (item['quantity']   as num?)?.toInt() ?? 1;
                      final price    = (item['unit_price'] as num?)?.toDouble() ?? 0;
                      return DataRow(cells: [
                        DataCell(Text(product['name_en'] as String? ?? '—')),
                        DataCell(Text(variant['size']     as String? ?? '—')),
                        DataCell(Text(variant['color_en'] as String? ?? '—')),
                        DataCell(Text('$qty')),
                        DataCell(Text(currency.format(price))),
                        DataCell(Text(currency.format(price * qty))),
                      ]);
                    }).toList(),
                  ),
                ]),
              )),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
