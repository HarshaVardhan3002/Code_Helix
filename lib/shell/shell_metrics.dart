import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';

/// Layout constants shared between the shell and the surfaces inside it.
///
/// The shell's bars float over the content as glass rather than reserving a
/// band of their own — that is the whole point of an image-first app. The cost
/// is that every scrolling surface has to inset itself by hand, so those
/// numbers live in one place instead of being guessed at each call site.
abstract final class ShellMetrics {
  /// Height of the floating bottom navigation bar.
  static const double navHeight = 62;

  /// Height of the floating top bar.
  static const double topBarHeight = 52;

  /// Space a scrolling surface must leave at the bottom to clear the nav.
  static double bottomInset(BuildContext context) =>
      navHeight + AppSpacing.lg + MediaQuery.paddingOf(context).bottom;

  /// Space a scrolling surface must leave at the top to clear the top bar.
  static double topInset(BuildContext context) =>
      topBarHeight + AppSpacing.md + MediaQuery.paddingOf(context).top;
}
