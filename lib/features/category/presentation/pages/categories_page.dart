import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../domain/entities/category_entity.dart';
import '../providers/category_provider.dart';
import '../states/category_state.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryNotifierProvider);

    return AdaptiveScaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showForm(context, ref, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Category'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('$e')),
        data: (s) => switch (s) {
          CategoryError()   => Center(child: Text(s.message)),
          CategoryLoading() => const Center(child: CircularProgressIndicator()),
          CategoryInitial() => const SizedBox.shrink(),
          CategoryLoaded()  => ResponsivePadding(
            child: AdaptiveTable<CategoryEntity>(
              columns: const [
                'Name (EN)', 'Name (AR)', 'Slug', 'Active', 'Order', 'Actions',
              ],
              tabletColumns: const ['Name (EN)', 'Slug', 'Active', 'Actions'],
              items: s.categories,
              desktopRow: (c, isTablet) => DataRow(
                cells: isTablet
                    ? [
                        DataCell(Text(c.nameEn)),
                        DataCell(Text(c.slug)),
                        DataCell(ActiveBadge(isActive: c.isActive)),
                        DataCell(RowActions(
                          onEdit: () => _showForm(context, ref, c),
                          onDelete: () => ref
                              .read(categoryNotifierProvider.notifier)
                              .deactivate(c.id),
                        )),
                      ]
                    : [
                        DataCell(Text(c.nameEn)),
                        DataCell(Text(c.nameAr)),
                        DataCell(Text(c.slug)),
                        DataCell(ActiveBadge(isActive: c.isActive)),
                        DataCell(Text('${c.sortOrder}')),
                        DataCell(RowActions(
                          onEdit: () => _showForm(context, ref, c),
                          onDelete: () => ref
                              .read(categoryNotifierProvider.notifier)
                              .deactivate(c.id),
                        )),
                      ],
              ),
              mobileCard: (c) => _CategoryCard(
                category: c,
                onEdit: () => _showForm(context, ref, c),
                onDelete: () => ref
                    .read(categoryNotifierProvider.notifier)
                    .deactivate(c.id),
              ),
            ),
          ),
        },
      ),
    );
  }

  void _showForm(BuildContext ctx, WidgetRef ref, CategoryEntity? existing) =>
      showDialog(
        context: ctx,
        builder: (_) =>
            _CategoryFormDialog(existing: existing, ref: ref),
      );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(
      {required this.category, required this.onEdit, required this.onDelete});
  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(category.nameEn,
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(category.slug,
          style: context.bodySmall.copyWith(color: context.mutedText)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        ActiveBadge(isActive: category.isActive),
        const SizedBox(width: 4),
        RowActions(onEdit: onEdit, onDelete: onDelete),
      ]),
    ),
  );
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({this.existing, required this.ref});
  final CategoryEntity? existing;
  final WidgetRef ref;
  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameEn = TextEditingController(text: widget.existing?.nameEn);
  late final _nameAr = TextEditingController(text: widget.existing?.nameAr);
  late final _slug   = TextEditingController(text: widget.existing?.slug);
  late final _order  = TextEditingController(
      text: '${widget.existing?.sortOrder ?? 0}');

  @override
  void dispose() {
    _nameEn.dispose(); _nameAr.dispose();
    _slug.dispose();   _order.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final notifier = widget.ref.read(categoryNotifierProvider.notifier);
    final now = DateTime.now();
    final entity = CategoryEntity(
      id: widget.existing?.id ?? '',
      nameEn: _nameEn.text.trim(),
      nameAr: _nameAr.text.trim(),
      slug:   _slug.text.trim(),
      isActive:  widget.existing?.isActive ?? true,
      sortOrder: int.tryParse(_order.text) ?? 0,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );
    widget.existing == null
        ? notifier.create(entity)
        : notifier.updatee(entity);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'New Category' : 'Edit Category'),
    content: SizedBox(
      width: context.isDesktop ? 600 : 420,
      child: SingleChildScrollView(
        child: ResponsiveForm(
          formKey: _formKey,
          fields: [
            AdminFormField(controller: _nameEn, label: 'Name (EN)',  validator: Validators.required),
            AdminFormField(controller: _nameAr, label: 'Name (AR)',  validator: Validators.required),
            AdminFormField(controller: _slug,   label: 'Slug',       validator: Validators.slug),
            AdminFormField(controller: _order,  label: 'Sort Order',
                keyboardType: TextInputType.number,
                validator: Validators.nonNegativeInt),
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
