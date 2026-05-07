import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/admin_form_actions.dart';
import '../../../../core/widgets/admin_form_field.dart';
import '../../../../core/widgets/responsive/adaptive_scaffold.dart';
import '../../../../core/widgets/responsive/adaptive_table.dart';
import '../../../../core/widgets/responsive/responsive_form.dart';
import '../../../../core/widgets/responsive/responsive_padding.dart';
import '../../../../core/widgets/shared/active_badge.dart';
import '../../../../core/widgets/shared/row_actions.dart';
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
                desktopRow: (p, isTablet) => DataRow(
                  cells: isTablet
                      ? [
                          DataCell(Text(p['name_en'] as String? ?? '')),
                          DataCell(
                            Text(
                              currency.format(
                                (p['price'] as num?)?.toDouble() ?? 0,
                              ),
                            ),
                          ),
                          DataCell(
                            ActiveBadge(
                              isActive: p['is_active'] as bool? ?? false,
                            ),
                          ),
                          DataCell(
                            RowActions(
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
                                (p['price'] as num?)?.toDouble() ?? 0,
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
                                  ? context.warningColor
                                  : context.mutedText,
                            ),
                          ),
                          DataCell(
                            ActiveBadge(
                              isActive: p['is_active'] as bool? ?? false,
                            ),
                          ),
                          DataCell(
                            RowActions(
                              onEdit: () => _showForm(context, ref, p),
                              onDelete: () => ref
                                  .read(productNotifierProvider.notifier)
                                  .deactivate(p['id'] as String),
                            ),
                          ),
                        ],
                ),
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
      BuildContext ctx, WidgetRef ref, Map<String, dynamic>? existing) {
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
  Widget build(BuildContext context) => Card(
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
                      style: context.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ActiveBadge(isActive: product['is_active'] as bool? ?? false),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currency.format((product['price'] as num?)?.toDouble() ?? 0),
                style: context.titleSmall.copyWith(
                  color: context.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RowActions(onEdit: onEdit, onDelete: onDelete),
                ],
              ),
            ],
          ),
        ),
      );
}

// ── Form dialog ───────────────────────────────────────────────
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
      text: widget.existing?['description_en'] as String?);
  late final _descAr = TextEditingController(
      text: widget.existing?['description_ar'] as String?);
  late final _price =
      TextEditingController(text: '${widget.existing?['base_price'] ?? ''}');
  late final _discount = TextEditingController(
      text: '${widget.existing?['discount_price'] ?? ''}');
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
    widget.existing == null
        ? notifier.create(data)
        : notifier.updatee(widget.existing!['id'] as String, data);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.existing == null ? 'New Product' : 'Edit Product'),
        content: SizedBox(
          width: context.isDesktop ? 680 : 440,
          child: SingleChildScrollView(
            child: ResponsiveForm(
              formKey: _formKey,
              fields: [
                AdminFormField(
                    controller: _nameEn,
                    label: 'Name (EN)',
                    validator: Validators.required),
                AdminFormField(
                    controller: _nameAr,
                    label: 'Name (AR)',
                    validator: Validators.required),
                AdminFormField(
                    controller: _descEn,
                    label: 'Description (EN)',
                    maxLines: 2),
                AdminFormField(
                    controller: _descAr,
                    label: 'Description (AR)',
                    maxLines: 2),
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
                    validator: Validators.required),
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
