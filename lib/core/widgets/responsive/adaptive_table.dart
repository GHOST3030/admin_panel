import 'package:flutter/material.dart';
import '../../responsive/responsive_helper.dart';

/// Renders a DataTable on desktop/tablet, a Card list on mobile.
class AdaptiveTable<T> extends StatelessWidget {
  const AdaptiveTable({
    super.key,
    required this.columns,
    required this.items,
    required this.desktopRow,
    required this.mobileCard,
    this.tabletColumns,
  });

  /// Column labels for desktop.
  final List<String> columns;

  /// Column labels for tablet (subset). Falls back to [columns].
  final List<String>? tabletColumns;

  final List<T> items;

  /// Builds a [DataRow] for desktop/tablet view.
  final DataRow Function(T item, bool isTablet) desktopRow;

  /// Builds a [Card] widget for mobile view.
  final Widget Function(T item) mobileCard;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => mobileCard(items[i]),
      );
    }

    final isTablet   = context.isTablet;
    final usedLabels = (isTablet && tabletColumns != null)
        ? tabletColumns!
        : columns;

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          columns: usedLabels
              .map((l) => DataColumn(label: Text(l)))
              .toList(),
          rows: items.map((item) => desktopRow(item, isTablet)).toList(),
        ),
      ),
    );
  }
}
