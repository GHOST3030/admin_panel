import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendPositive,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendPositive;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: context.bodySmall.copyWith(
                      color: context.mutedText, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(value,
                  style: context.titleLarge
                      .copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
              if (trend != null) ...[
                const SizedBox(height: 2),
                Row(children: [
                  Icon(
                    trendPositive == true
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 12,
                    color: trendPositive == true
                        ? context.successColor
                        : context.error,
                  ),
                  const SizedBox(width: 3),
                  Text(trend!,
                      style: context.labelSmall.copyWith(
                          color: trendPositive == true
                              ? context.successColor
                              : context.error)),
                ]),
              ],
            ],
          ),
        ),
      ]),
    ),
  );
}
