import 'package:flutter/material.dart';

/// Standard Cancel / Submit row used at the bottom of all admin dialogs.
class AdminFormActions extends StatelessWidget {
  const AdminFormActions({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    this.submitLabel = 'Save',
    this.isLoading = false,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: onCancel, child: const Text('Cancel')),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: isLoading ? null : onSubmit,
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(submitLabel),
          ),
        ],
      );
}
