import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';
import 'status_badge.dart';

/// Convenience wrapper — maps a boolean to a StatusBadge.
class ActiveBadge extends StatelessWidget {
  const ActiveBadge({super.key, required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) =>
      StatusBadge(isActive ? 'active' : 'inactive');
}
