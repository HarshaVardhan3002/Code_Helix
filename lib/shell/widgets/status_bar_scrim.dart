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
  const StatusBarScrim({super.key});

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
            height: MediaQuery.viewPaddingOf(context).top + AppSpacing.sm,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scrim, scrim.withValues(alpha: 0)],
                stops: const [0.55, 1],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
