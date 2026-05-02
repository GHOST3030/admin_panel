import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/variant_provider.dart';
import '../states/variant_state.dart';

class VariantsPage extends ConsumerWidget {
  const VariantsPage(
      {super.key, required this.productId, required this.productName,});
  final String productId;
  final String productName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(variantNotifierProvider(productId));
    final currency = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text('Variants — $productName'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showForm(context, ref, productId, null),
            icon: const Icon(Icons.add),
            label: const Text('New Variant'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => switch (s) {
          VariantError() => Center(child: Text(s.message)),
          VariantLoading() => const Center(child: CircularProgressIndicator()),
          VariantLoaded() => Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('SKU')),
                    DataColumn(label: Text('Size')),
                    DataColumn(label: Text('Color EN')),
                    DataColumn(label: Text('Color AR')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Discount')),
                    DataColumn(label: Text('Stock')),
                    DataColumn(label: Text('Active')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: s.variants
                      .map(
                        (v) => DataRow(
                          cells: [
                            DataCell(Text(v['sku'] as String? ?? '—')),
                            DataCell(Text(v['size'] as String? ?? '—')),
                            DataCell(Text(v['color_en'] as String? ?? '—')),
                            DataCell(Text(v['color_ar'] as String? ?? '—')),
                            DataCell(Text(currency.format(
                                (v['price'] as num?)?.toDouble() ?? 0,),),),
                            DataCell(Text(v['discount_price'] != null
                                ? currency.format(
                                    (v['discount_price'] as num).toDouble(),)
                                : '—',),),
                            DataCell(Text('${v['stock'] ?? 0}')),
                            DataCell(Icon(
                              (v['is_active'] as bool? ?? false)
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: (v['is_active'] as bool? ?? false)
                                  ? Colors.green
                                  : Colors.red,
                            ),),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () =>
                                        _showForm(context, ref, productId, v),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red,),
                                    onPressed: () => ref
                                        .read(variantNotifierProvider(productId)
                                            .notifier,)
                                        .deactivate(
                                            productId, v['id'] as String,),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          VariantInitial() => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _showForm(BuildContext ctx, WidgetRef ref, String productId,
      Map<String, dynamic>? existing,) {
    showDialog(
      context: ctx,
      builder: (_) => _VariantFormDialog(
          productId: productId, existing: existing, ref: ref,),
    );
  }
}

class _VariantFormDialog extends StatefulWidget {
  const _VariantFormDialog(
      {required this.productId, this.existing, required this.ref,});
  final String productId;
  final Map<String, dynamic>? existing;
  final WidgetRef ref;
  @override
  State<_VariantFormDialog> createState() => _VariantFormDialogState();
}

class _VariantFormDialogState extends State<_VariantFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _sku =
      TextEditingController(text: widget.existing?['sku'] as String?);
  late final _size =
      TextEditingController(text: widget.existing?['size'] as String?);
  late final _colorEn =
      TextEditingController(text: widget.existing?['color_en'] as String?);
  late final _colorAr =
      TextEditingController(text: widget.existing?['color_ar'] as String?);
  late final _colorHex =
      TextEditingController(text: widget.existing?['color_hex'] as String?);
  late final _price =
      TextEditingController(text: '${widget.existing?['price'] ?? ''}');
  late final _discount = TextEditingController(
      text: '${widget.existing?['discount_price'] ?? ''}',);
  late final _stock =
      TextEditingController(text: '${widget.existing?['stock'] ?? 0}');

  @override
  void dispose() {
    _sku.dispose();
    _size.dispose();
    _colorEn.dispose();
    _colorAr.dispose();
    _colorHex.dispose();
    _price.dispose();
    _discount.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notifier =
        widget.ref.read(variantNotifierProvider(widget.productId).notifier);
    final data = {
      if (_sku.text.isNotEmpty) 'sku': _sku.text.trim(),
      if (_size.text.isNotEmpty) 'size': _size.text.trim(),
      if (_colorEn.text.isNotEmpty) 'color_en': _colorEn.text.trim(),
      if (_colorAr.text.isNotEmpty) 'color_ar': _colorAr.text.trim(),
      if (_colorHex.text.isNotEmpty) 'color_hex': _colorHex.text.trim(),
      'price': double.tryParse(_price.text) ?? 0,
      if (_discount.text.isNotEmpty)
        'discount_price': double.tryParse(_discount.text),
      'stock': int.tryParse(_stock.text) ?? 0,
      'is_active': true,
    };
    if (widget.existing == null) {
      notifier.create(widget.productId, data);
    } else {
      notifier.updatee(
          widget.productId, widget.existing!['id'] as String, data,);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New Variant' : 'Edit Variant'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: _sku,
                    decoration: const InputDecoration(labelText: 'SKU'),),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _size,
                    decoration: const InputDecoration(labelText: 'Size'),),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _colorEn,
                    decoration: const InputDecoration(labelText: 'Color EN'),),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _colorAr,
                    decoration: const InputDecoration(labelText: 'Color AR'),),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _colorHex,
                    decoration: const InputDecoration(
                        labelText: 'Color Hex (#ffffff)',),),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _price,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? 'Required'
                        : null,),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _discount,
                    decoration:
                        const InputDecoration(labelText: 'Discount Price'),
                    keyboardType: TextInputType.number,),
                const SizedBox(height: 12),
                TextFormField(
                    controller: _stock,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),),
        FilledButton(
            onPressed: _submit,
            child: Text(widget.existing == null ? 'Create' : 'Update'),),
      ],
    );
  }
}
