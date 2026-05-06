import 'package:flutter/material.dart';

extension AppTextStyles on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors  => Theme.of(this).colorScheme;

  // ── Typography shortcuts ────────────────────────────────────
  TextStyle get displayLarge   => textTheme.displayLarge!;
  TextStyle get displayMedium  => textTheme.displayMedium!;
  TextStyle get headlineLarge  => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall  => textTheme.headlineSmall!;
  TextStyle get titleLarge     => textTheme.titleLarge!;
  TextStyle get titleMedium    => textTheme.titleMedium!;
  TextStyle get titleSmall     => textTheme.titleSmall!;
  TextStyle get bodyLarge      => textTheme.bodyLarge!;
  TextStyle get bodyMedium     => textTheme.bodyMedium!;
  TextStyle get bodySmall      => textTheme.bodySmall!;
  TextStyle get labelLarge     => textTheme.labelLarge!;
  TextStyle get labelMedium    => textTheme.labelMedium!;
  TextStyle get labelSmall     => textTheme.labelSmall!;

  // ── Semantic colour shortcuts ───────────────────────────────
  Color get primary            => colors.primary;
  Color get onPrimary          => colors.onPrimary;
  Color get secondary          => colors.secondary;
  Color get onSecondary        => colors.onSecondary;
  Color get surface            => colors.surface;
  Color get onSurface          => colors.onSurface;
  Color get surfaceContainer   => colors.surfaceContainer;
  Color get outline            => colors.outline;
  Color get outlineVariant     => colors.outlineVariant;
  Color get error              => colors.error;
  Color get onError            => colors.onError;
  Color get errorContainer     => colors.errorContainer;
  Color get onErrorContainer   => colors.onErrorContainer;
  Color get primaryContainer   => colors.primaryContainer;
  Color get onPrimaryContainer => colors.onPrimaryContainer;
  Color get surfaceContainerLow      => colors.surfaceContainerLow;
  Color get surfaceContainerLowest   => colors.surfaceContainerLowest;
  Color get surfaceContainerHighest  => colors.surfaceContainerHighest;

  // ── Status semantic colours (resolved from theme seeds) ─────
  Color get successColor  => Color.lerp(colors.primary, const Color(0xFF2DC653), 0.8)!;
  Color get warningColor  => Color.lerp(colors.secondary, const Color(0xFFF4A261), 0.8)!;
  Color get mutedText     => colors.onSurface.withOpacity(0.5);
  Color get subtleText    => colors.onSurface.withOpacity(0.7);
  Color get dividerColor  => colors.outlineVariant;
  Color get cardBorder    => colors.outlineVariant.withOpacity(0.6);

  // ── Status badge helpers ────────────────────────────────────
  ({Color bg, Color fg}) statusColors(String status) => switch (status) {
    'delivered'  => (bg: successColor.withValues(alpha: .15),  fg: successColor),
    'processing' => (bg: warningColor.withOpacity(0.15),  fg: warningColor),
    'shipped'    => (bg: colors.primary.withOpacity(0.12), fg: colors.primary),
    'cancelled'  => (bg: colors.error.withOpacity(0.12),  fg: colors.error),
    'active'     => (bg: successColor.withOpacity(0.12),  fg: successColor),
    'inactive'   => (bg: colors.error.withOpacity(0.12),  fg: colors.error),
    _            => (bg: colors.surfaceContainer,         fg: mutedText),
  };
}
