import 'package:flutter/material.dart';
import 'breakpoints.dart';
import 'screen_type.dart';

abstract final class ResponsiveHelper {
  static ScreenType screenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.mobile)  return ScreenType.mobile;
    if (width < Breakpoints.tablet)  return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context)  => screenType(context) == ScreenType.mobile;
  static bool isTablet(BuildContext context)   => screenType(context) == ScreenType.tablet;
  static bool isDesktop(BuildContext context)  => screenType(context) == ScreenType.desktop;

  /// True when sidebar should always be visible.
  static bool hasPersistentSidebar(BuildContext context) =>
      isDesktop(context);

  /// True when sidebar should be collapsible (icon-only).
  static bool hasCollapsibleSidebar(BuildContext context) =>
      isTablet(context);

  /// True when layout should use a Drawer.
  static bool usesDrawer(BuildContext context) =>
      isMobile(context);

  static double horizontalPadding(BuildContext context) =>
      isMobile(context)
          ? Breakpoints.contentPaddingHSm
          : Breakpoints.contentPaddingH;

  static int gridColumnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.mobile)  return 1;
    if (width < Breakpoints.tablet)  return 2;
    if (width < 1400)                return 3;
    return 4;
  }

  static int statCardColumnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.mobile)  return 1;
    if (width < Breakpoints.tablet)  return 2;
    return 4;
  }

  /// Returns value based on current screen type.
  static T when<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    return switch (screenType(context)) {
      ScreenType.mobile  => mobile,
      ScreenType.tablet  => tablet,
      ScreenType.desktop => desktop,
    };
  }

  static T maybeWhen<T>(
    BuildContext context, {
    T? mobile,
    T? tablet,
    T? desktop,
    required T orElse,
  }) {
    return switch (screenType(context)) {
      ScreenType.mobile  => mobile  ?? orElse,
      ScreenType.tablet  => tablet  ?? orElse,
      ScreenType.desktop => desktop ?? orElse,
    };
  }
}

extension ResponsiveContext on BuildContext {
  ScreenType get screenType     => ResponsiveHelper.screenType(this);
  bool get isMobile             => ResponsiveHelper.isMobile(this);
  bool get isTablet             => ResponsiveHelper.isTablet(this);
  bool get isDesktop            => ResponsiveHelper.isDesktop(this);
  bool get hasPersistentSidebar => ResponsiveHelper.hasPersistentSidebar(this);
  bool get hasCollapsibleSidebar=> ResponsiveHelper.hasCollapsibleSidebar(this);
  bool get usesDrawer           => ResponsiveHelper.usesDrawer(this);
  double get hPadding           => ResponsiveHelper.horizontalPadding(this);
  int get gridColumns           => ResponsiveHelper.gridColumnCount(this);
  int get statColumns           => ResponsiveHelper.statCardColumnCount(this);

  T responsiveWhen<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) => ResponsiveHelper.when(this, mobile: mobile, tablet: tablet, desktop: desktop);
}
