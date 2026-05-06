import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.errorContainer,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(message,
        style: context.bodyMedium.copyWith(color: context.onErrorContainer)),
  );
}
