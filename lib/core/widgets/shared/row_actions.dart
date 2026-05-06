import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class RowActions extends StatelessWidget {
  const RowActions({super.key, required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.edit_outlined, size: 18, color: context.primary),
        tooltip: 'Edit',
        onPressed: onEdit,
      ),
      IconButton(
        icon: Icon(Icons.delete_outline, size: 18, color: context.error),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
    ],
  );
}
