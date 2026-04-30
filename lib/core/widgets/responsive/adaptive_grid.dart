import 'package:flutter/material.dart';
import '../../responsive/breakpoints.dart';
import '../../responsive/responsive_helper.dart';

/// Responsive grid that adapts column count to screen width.
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = Breakpoints.gridSpacing,
    this.columnOverride,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<Widget> children;
  final double spacing;
  final int? columnOverride;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final cols = columnOverride ?? context.gridColumns;
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, i) => children[i],
    );
  }
}

/// Stat-card specific grid (uses statColumns count).
class StatGrid extends StatelessWidget {
  const StatGrid({
    super.key,
    required this.children,
    this.spacing = Breakpoints.gridSpacing,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final cols = context.statColumns;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: context.isDesktop ? 3.2 : 2.4,
      ),
      itemBuilder: (_, i) => children[i],
    );
  }
}
