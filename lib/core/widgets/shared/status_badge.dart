import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

/// Pill-shaped status badge driven entirely by [BuildContext] theme.
/// Zero hardcoded colours — all derived via [statusColors].
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (:bg, :fg) = context.statusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: context.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
