import 'package:flutter/material.dart';
import '../../responsive/responsive_helper.dart';

/// Two-column form on desktop, single-column on mobile/tablet.
class ResponsiveForm extends StatelessWidget {
  const ResponsiveForm({
    super.key,
    required this.formKey,
    required this.fields,
    this.spacing = 16,
  });

  final GlobalKey<FormState> formKey;

  /// Each item is a single field widget. Pairs are placed side-by-side on desktop.
  final List<Widget> fields;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: context.isDesktop
          ? _TwoColumnLayout(fields: fields, spacing: spacing)
          : _SingleColumnLayout(fields: fields, spacing: spacing),
    );
  }
}

class _TwoColumnLayout extends StatelessWidget {
  const _TwoColumnLayout({required this.fields, required this.spacing});
  final List<Widget> fields;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i += 2) {
      final left = fields[i];
      final right =
          (i + 1 < fields.length) ? fields[i + 1] : const SizedBox.shrink();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: spacing),
            Expanded(child: right),
          ],
        ),
      );
      if (i + 2 < fields.length) rows.add(SizedBox(height: spacing));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _SingleColumnLayout extends StatelessWidget {
  const _SingleColumnLayout({required this.fields, required this.spacing});
  final List<Widget> fields;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: fields.expand((f) => [f, SizedBox(height: spacing)]).toList()
        ..removeLast(),
    );
  }
}
