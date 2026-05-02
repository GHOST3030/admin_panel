import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/widgets/admin_form_actions.dart';
import '../../../../core/widgets/admin_form_field.dart';
import '../../../../core/widgets/responsive/adaptive_scaffold.dart';
import '../../../../core/widgets/responsive/adaptive_table.dart';
import '../../../../core/widgets/responsive/responsive_form.dart';
import '../../../../core/widgets/responsive/responsive_padding.dart';
import '../../../../core/utils/validators.dart';
import '../providers/product_provider.dart';
import '../states/product_state.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productNotifierProvider);
    final currency = NumberFormat.currency(symbol: '\$');

    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showForm(context, ref, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Product'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => switch (s) {
          ProductError() => Center(child: Text(s.message)),
          ProductLoading() => const Center(child: CircularProgressIndicator()),
          ProductInitial() => const SizedBox.shrink(),
          ProductLoaded() => ResponsivePadding(
              child: AdaptiveTable<Map<String, dynamic>>(
                columns: const [
                  'Name',
                  'Category',
                  'Price',
                  'Discount',
                  'Featured',
                  'Active',
                  'Actions',
                ],
                tabletColumns: const ['Name', 'Price', 'Active', 'Actions'],
                items: s.products,
                desktopRow: (p, isTablet) {
                  final cells = isTablet
                      ? [
                          DataCell(Text(p['name_en'] as String? ?? '')),
                          DataCell(
                            Text(
                              currency.format(
                                (p['base_price'] as num?)?.toDouble() ?? 0,
                              ),
                            ),
                          ),
                          DataCell(
                            _ActiveBadge(p['is_active'] as bool? ?? false),
                          ),
                          DataCell(
                            _RowActions(
                              onEdit: () => _showForm(context, ref, p),
                              onDelete: () => ref
                                  .read(productNotifierProvider.notifier)
                                  .deactivate(p['id'] as String),
                            ),
                          ),
                        ]
                      : [
                          DataCell(
                            Text(
                              p['name_en'] as String? ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Text(
                              ((p['categories'] as Map?)?['name_en']
                                      as String?) ??
                                  '—',
                            ),
                          ),
                          DataCell(
                            Text(
                              currency.format(
                                (p['base_price'] as num?)?.toDouble() ?? 0,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              p['discount_price'] != null
                                  ? currency.format(
                                      (p['discount_price'] as num).toDouble(),
                                    )
                                  : '—',
                            ),
                          ),
                          DataCell(
                            Icon(
                              (p['is_featured'] as bool? ?? false)
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 18,
                              color: (p['is_featured'] as bool? ?? false)
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                          DataCell(
                            _ActiveBadge(p['is_active'] as bool? ?? false),
                          ),
                          DataCell(
                            _RowActions(
                              onEdit: () => _showForm(context, ref, p),
                              onDelete: () => ref
                                  .read(productNotifierProvider.notifier)
                                  .deactivate(p['id'] as String),
                            ),
                          ),
                        ];
                  return DataRow(cells: cells);
                },
                mobileCard: (p) => _ProductCard(
                  product: p,
                  currency: currency,
                  onEdit: () => _showForm(context, ref, p),
                  onDelete: () => ref
                      .read(productNotifierProvider.notifier)
                      .deactivate(p['id'] as String),
                ),
              ),
            ),
        },
      ),
    );
  }

  void _showForm(
    BuildContext ctx,
    WidgetRef ref,
    Map<String, dynamic>? existing,
  ) {
    showDialog(
      context: ctx,
      builder: (_) => _ProductFormDialog(existing: existing, ref: ref),
    );
  }
}

// ── Mobile card ───────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });
  final Map<String, dynamic> product;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product['name_en'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _ActiveBadge(product['is_active'] as bool? ?? false),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currency.format(
                (product['base_price'] as num?)?.toDouble() ?? 0,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4361EE),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Row actions ───────────────────────────────────────────────
class _RowActions extends StatelessWidget {
  const _RowActions({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          tooltip: 'Edit',
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
          tooltip: 'Deactivate',
          onPressed: onDelete,
        ),
      ],
    );
  }
}

// ── Active badge ──────────────────────────────────────────────
class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge(this.active);
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: active ? const Color(0xFF166534) : const Color(0xFF991B1B),
        ),
      ),
    );
  }
}

// ── Product form dialog ───────────────────────────────────────
class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({this.existing, required this.ref});
  final Map<String, dynamic>? existing;
  final WidgetRef ref;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameEn =
      TextEditingController(text: widget.existing?['name_en'] as String?);
  late final _nameAr =
      TextEditingController(text: widget.existing?['name_ar'] as String?);
  late final _descEn = TextEditingController(
    text: widget.existing?['description_en'] as String?,
  );
  late final _descAr = TextEditingController(
    text: widget.existing?['description_ar'] as String?,
  );
  late final _price =
      TextEditingController(text: '${widget.existing?['base_price'] ?? ''}');
  late final _discount = TextEditingController(
    text: '${widget.existing?['discount_price'] ?? ''}',
  );
  late final _catId =
      TextEditingController(text: widget.existing?['category_id'] as String?);

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _descEn.dispose();
    _descAr.dispose();
    _price.dispose();
    _discount.dispose();
    _catId.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = widget.ref.read(productNotifierProvider.notifier);
    final data = {
      'name_en': _nameEn.text.trim(),
      'name_ar': _nameAr.text.trim(),
      if (_descEn.text.isNotEmpty) 'description_en': _descEn.text.trim(),
      if (_descAr.text.isNotEmpty) 'description_ar': _descAr.text.trim(),
      'base_price': double.tryParse(_price.text) ?? 0,
      if (_discount.text.isNotEmpty)
        'discount_price': double.tryParse(_discount.text),
      'category_id': _catId.text.trim(),
      'is_active': true,
    };
    if (widget.existing == null) {
      notifier.create(data);
    } else {
      notifier.updatee(widget.existing!['id'] as String, data);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    return AlertDialog(
      title: Text(widget.existing == null ? 'New Product' : 'Edit Product'),
      content: SizedBox(
        width: isDesktop ? 680 : 480,
        child: SingleChildScrollView(
          child: ResponsiveForm(
            formKey: _formKey,
            fields: [
              AdminFormField(
                controller: _nameEn,
                label: 'Name (EN)',
                validator: Validators.required,
              ),
              AdminFormField(
                controller: _nameAr,
                label: 'Name (AR)',
                validator: Validators.required,
              ),
              AdminFormField(
                controller: _descEn,
                label: 'Description (EN)',
                maxLines: 2,
              ),
              AdminFormField(
                controller: _descAr,
                label: 'Description (AR)',
                maxLines: 2,
              ),
              AdminFormField(
                controller: _price,
                label: 'Base Price',
                keyboardType: TextInputType.number,
                validator: Validators.positiveNumber,
              ),
              AdminFormField(
                controller: _discount,
                label: 'Discount Price (optional)',
                keyboardType: TextInputType.number,
              ),
              AdminFormField(
                controller: _catId,
                label: 'Category ID',
                validator: Validators.required,
              ),
            ],
          ),
        ),
      ),
      actions: [
        AdminFormActions(
          onCancel: () => Navigator.pop(context),
          onSubmit: _submit,
          submitLabel: widget.existing == null ? 'Create' : 'Update',
        ),
      ],
    );
  }
}
