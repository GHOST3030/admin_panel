import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title,
          style: context.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      if (action != null) action!,
    ],
  );
}
