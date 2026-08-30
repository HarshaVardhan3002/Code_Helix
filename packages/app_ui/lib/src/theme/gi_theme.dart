import 'package:app_ui/src/spacing/app_spacing.dart';
import 'package:app_ui/src/theme/gi_colors.dart';
import 'package:app_ui/src/typography/gi_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template gi_theme}
/// The GI Daily [ThemeData], in both schemes.
///
/// Deliberately built by hand rather than through `FlexThemeData`, which the
/// unplugged Instagram screens still use. Those screens are a different
/// product with a different palette; sharing a theme factory with them is how
/// a stray purple gradient ends up in a clinical reader.
///
/// The whole scheme is derived from one [GiColors] instance, which is attached
/// as a [ThemeExtension] so call sites read semantic tokens
/// (`context.gi.textSecondary`) instead of Material's approximations
/// (`onSurfaceVariant`).
/// {@endtemplate}
abstract final class GiTheme {
  /// {@macro gi_theme}
  static ThemeData get dark => _build(Brightness.dark, GiColors.dark);

  /// {@macro gi_theme}
  static ThemeData get light => _build(Brightness.light, GiColors.light);

  /// The status- and navigation-bar style that matches [scheme].
  ///
  /// Both bars are transparent: the app draws to the edges and lays its own
  /// scrim under the clock. Only the icon brightness has to flip.
  static SystemUiOverlayStyle overlayFor(Brightness scheme) {
    final iconsAreLight = scheme == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: const Color(0x00000000),
      statusBarBrightness: iconsAreLight ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: iconsAreLight
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarColor: const Color(0x00000000),
      systemNavigationBarIconBrightness: iconsAreLight
          ? Brightness.light
          : Brightness.dark,
    );
  }

  static ThemeData _build(Brightness brightness, GiColors c) {
    final text = GiType.textTheme(c.textPrimary);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [c],
      scaffoldBackgroundColor: c.base,
      canvasColor: c.base,
      splashColor: c.fill,
      highlightColor: c.fill,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.action,
        onPrimary: isDark ? const Color(0xFF04121C) : const Color(0xFFFFFFFF),
        secondary: c.action,
        onSecondary: isDark ? const Color(0xFF04121C) : const Color(0xFFFFFFFF),
        error: c.incorrect,
        onError: isDark ? const Color(0xFF1B0503) : const Color(0xFFFFFFFF),
        surface: c.base,
        onSurface: c.textPrimary,
        surfaceContainerHighest: c.raised,
        onSurfaceVariant: c.textSecondary,
        outline: c.hairline,
        outlineVariant: c.hairline,
      ),
      textTheme: text,
      primaryTextTheme: text,
      iconTheme: IconThemeData(color: c.textPrimary),
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: c.base,
        surfaceTintColor: c.base,
        foregroundColor: c.textPrimary,
        systemOverlayStyle: overlayFor(brightness),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.raised,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.textPrimary),
        actionTextColor: c.action,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          side: BorderSide(color: c.hairline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.raised,
        surfaceTintColor: c.raised,
        modalBackgroundColor: c.raised,
        showDragHandle: true,
        dragHandleColor: c.hairline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.fill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: c.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: c.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: c.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: c.action, width: 1.5),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.action),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.action,
        selectionColor: c.action.withValues(alpha: 0.3),
        selectionHandleColor: c.action,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
