import 'package:flutter/material.dart';
import '../../responsive/responsive_helper.dart';

/// Applies horizontal padding based on screen size.
/// Always use this instead of hardcoded Padding widgets.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.vertical = 24,
  });

  final Widget child;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.hPadding,
        vertical: vertical,
      ),
      child: child,
    );
  }
}
