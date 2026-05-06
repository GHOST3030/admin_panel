import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive/adaptive_scaffold.dart';
import '../../../../core/widgets/responsive/responsive_padding.dart';
import '../../../../core/widgets/shared/status_badge.dart';

final _orderDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, orderId) async {
  final client = ref.watch(supabaseClientProvider);
  final order  = await client
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
    final async    = ref.watch(_orderDetailProvider(orderId));
    final currency = NumberFormat.currency(symbol: '\$');

    return AdaptiveScaffold(
      appBar: AppBar(title: Text('Order #${orderId.substring(0, 8)}')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('$e')),
        data: (data) {
          final order = data['order'] as Map<String, dynamic>;
          final items = data['items'] as List;
          final user  = order['users'] as Map? ?? {};
          final date  =
              DateTime.tryParse(order['created_at'] as String? ?? '');

          return ListView(children: [
            ResponsivePadding(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order info ───────────────────────────────
                  _InfoCard(title: 'Order Info', rows: [
                    _InfoRow('Status',
                        child: StatusBadge(order['status'] as String? ?? '')),
                    _InfoRow('Total',
                        text: currency.format(
                            (order['total_amount'] as num?)?.toDouble() ?? 0)),
                    _InfoRow('Date',
                        text: date != null
                            ? DateFormat('MMM d, y HH:mm').format(date)
                            : '—'),
                  ]),
                  const SizedBox(height: 16),

                  // ── Customer info ────────────────────────────
                  _InfoCard(title: 'Customer', rows: [
                    _InfoRow('Name',  text: user['full_name'] as String? ?? '—'),
                    _InfoRow('Email', text: user['email']     as String? ?? '—'),
                    _InfoRow('Phone', text: user['phone']     as String? ?? '—'),
                  ]),
                  const SizedBox(height: 16),

                  // ── Items ────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Items',
                              style: context.titleMedium
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Product')),
                                DataColumn(label: Text('Size')),
                                DataColumn(label: Text('Color')),
                                DataColumn(label: Text('Qty')),
                                DataColumn(label: Text('Unit Price')),
                                DataColumn(label: Text('Subtotal')),
                              ],
                              rows: items.map((item) {
                                final variant =
                                    item['product_variants'] as Map? ?? {};
                                final product =
                                    variant['products'] as Map? ?? {};
                                final qty =
                                    (item['quantity'] as num?)?.toInt() ?? 1;
                                final price =
                                    (item['unit_price'] as num?)?.toDouble() ??
                                        0;
                                return DataRow(cells: [
                                  DataCell(Text(
                                      product['name_en'] as String? ?? '—')),
                                  DataCell(Text(
                                      variant['size'] as String? ?? '—')),
                                  DataCell(Text(
                                      variant['color_en'] as String? ?? '—')),
                                  DataCell(Text('$qty')),
                                  DataCell(Text(currency.format(price))),
                                  DataCell(Text(
                                      currency.format(price * qty))),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});
  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: context.titleMedium
                  .copyWith(fontWeight: FontWeight.bold)),
          Divider(height: 24, color: context.dividerColor),
          ...rows,
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, {this.text, this.child});
  final String label;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(
        width: 90,
        child: Text(label,
            style: context.bodySmall.copyWith(color: context.mutedText)),
      ),
      child ?? Text(text ?? '—',
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
    ]),
  );
}
