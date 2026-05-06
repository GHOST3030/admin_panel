import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ── Design tokens — ONE place only ─────────────────────────
  static const Color _seedPrimary = Color(0xFF1A1A2E);
  static const Color _seedAccent  = Color(0xFF4361EE);
  static const Color _seedError   = Color(0xFFE63946);
  static const Color _seedSuccess = Color(0xFF2DC653);
  static const Color _seedWarning = Color(0xFFF4A261);

  /// Sidebar background exposed so the shell can reference it
  /// without hardcoding a colour literal outside this file.
  static const Color sidebarBackground = _seedPrimary;

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: _seedAccent,
      primary: _seedPrimary,
      secondary: _seedAccent,
      error: _seedError,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: base.surfaceContainerLowest,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: base.surface,
        foregroundColor: base.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: base.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: base.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: base.outlineVariant.withOpacity(0.6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: base.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: base.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: base.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: base.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: base.error, width: 2),
        ),
        labelStyle: TextStyle(color: base.onSurface.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base.secondary,
          foregroundColor: base.onSecondary,
          minimumSize: const Size(120, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: base.secondary,
          foregroundColor: base.onSecondary,
          minimumSize: const Size(120, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: base.secondary,
          side: BorderSide(color: base.secondary),
          minimumSize: const Size(100, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor:
            WidgetStatePropertyAll(base.surfaceContainerLow),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 60,
        columnSpacing: 24,
        horizontalMargin: 20,
        headingTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: base.onSurface.withOpacity(0.6),
          letterSpacing: 0.4,
        ),
        dataTextStyle: GoogleFonts.inter(fontSize: 13),
      ),
      dividerTheme: DividerThemeData(
        color: base.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      extensions: const [_AppSemanticColors(_seedSuccess, _seedWarning)],
    );
  }

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: _seedAccent,
      primary: _seedAccent,
      error: _seedError,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: base.surfaceContainerLowest,
      textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme),
      extensions: const [_AppSemanticColors(_seedSuccess, _seedWarning)],
    );
  }
}

// ── Theme extension for semantic colours ─────────────────────
@immutable
class _AppSemanticColors extends ThemeExtension<_AppSemanticColors> {
  const _AppSemanticColors(this.success, this.warning);
  final Color success;
  final Color warning;

  @override
  _AppSemanticColors copyWith({Color? success, Color? warning}) =>
      _AppSemanticColors(success ?? this.success, warning ?? this.warning);

  @override
  _AppSemanticColors lerp(_AppSemanticColors? other, double t) {
    if (other == null) return this;
    return _AppSemanticColors(
      Color.lerp(success, other.success, t)!,
      Color.lerp(warning, other.warning, t)!,
    );
  }
}

/// Read semantic colours from the theme safely.
extension AppSemanticColorsX on ThemeData {
  _AppSemanticColors get semantic =>
      extension<_AppSemanticColors>()!;
}
