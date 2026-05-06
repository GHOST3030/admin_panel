import 'package:flutter/material.dart';
import '../../responsive/responsive_helper.dart';
import '../../theme/app_text_styles.dart';

class AdaptiveTable<T> extends StatelessWidget {
  const AdaptiveTable({
    super.key,
    required this.columns,
    required this.items,
    required this.desktopRow,
    required this.mobileCard,
    this.tabletColumns,
  });
  final List<String> columns;
  final List<String>? tabletColumns;
  final List<T> items;
  final DataRow Function(T item, bool isTablet) desktopRow;
  final Widget Function(T item) mobileCard;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
              context.surfaceContainerLow),
          columns: usedLabels
              .map((l) => DataColumn(
                    label: Text(l,
                        style: context.labelSmall.copyWith(
                            color: context.mutedText,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4)),
                  ))
              .toList(),
          rows: items.map((item) => desktopRow(item, isTablet)).toList(),
        ),
      ),
    );
  }
}
