import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

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
      TextButton(
        onPressed: onCancel,
        child: Text('Cancel',
            style: context.labelLarge.copyWith(color: context.mutedText)),
      ),
      const SizedBox(width: 12),
      FilledButton(
        onPressed: isLoading ? null : onSubmit,
        child: isLoading
            ? SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: context.onPrimary))
            : Text(submitLabel),
      ),
    ],
  );
}
