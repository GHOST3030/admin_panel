import 'package:flutter/material.dart';
import '../../responsive/responsive_helper.dart';
import '../../responsive/screen_type.dart';

/// Rebuilds only when [ScreenType] changes, not on every pixel.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return switch (context.screenType) {
      ScreenType.mobile  => mobile(context),
      ScreenType.tablet  => (tablet ?? desktop)(context),
      ScreenType.desktop => desktop(context),
    };
  }
}
