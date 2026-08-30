import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template status_bar_scrim}
/// The fade that keeps the system clock legible over content.
///
/// The app draws edge to edge, so the status bar sits on top of whatever the
/// screen happens to be showing — a bright mucosal frame, a card, a headline.
/// Without this, the clock and the battery collide with the content and the
/// top of the screen reads as broken.
///
/// It fades toward [GiColors.mediaScrim], so it darkens in the dark scheme and
/// veils in the light one. The system icon colour flips with the theme in
/// [GiTheme.overlayFor], and the two have to agree.
/// {@endtemplate}
class StatusBarScrim extends StatelessWidget {
  /// {@macro status_bar_scrim}
  const StatusBarScrim({this.coversBackButton = false, super.key});

  /// Whether the scrim also has to cover a floating back chip.
  ///
  /// The shell's top bar is glass and spans the width, so content scrolling
  /// behind it reads as intended. A pushed page has only a small round chip,
  /// and a heading sliding under it just looks broken. Those pages set this;
  /// pages with a full-bleed frame behind the chip leave it off, because a
  /// solid band across the top of the photograph costs more than it buys.
  final bool coversBackButton;

  /// Height of the floating back chip plus the padding around it.
  static const double _backButtonRow = 38 + AppSpacing.md * 2;

  @override
  Widget build(BuildContext context) {
    final scrim = context.gi.mediaScrim;

    // The region also carries the system icon style. Every screen that draws
    // under the status bar already places this widget there, so declaring the
    // style here means a pushed route cannot forget to flip the clock from
    // white to black when the scheme changes.
    return Align(
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: GiTheme.overlayFor(Theme.of(context).brightness),
          child: Container(
            // Reaches exactly the top edge of the floating bar and is solid
            // for most of that. Content is meant to scroll *behind* the glass
            // bar; what it must not do is reappear in the gap above it, which
            // is what a scrim sized to the status bar alone allowed.
            height:
                MediaQuery.viewPaddingOf(context).top +
                AppSpacing.md +
                (coversBackButton ? _backButtonRow : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scrim, scrim, scrim.withValues(alpha: 0)],
                stops: coversBackButton
                    ? const [0, 0.78, 1]
                    : const [0, 0.66, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
