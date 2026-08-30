import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template status_bar_scrim}
/// Fades scrolling content out under the system status bar.
///
/// Every surface here draws edge to edge and floats its own bar — the shell's
/// glass top bar, a pushed page's back button. Content therefore scrolls up
/// past those bars and collides with the clock and the battery icon. On the
/// daily case the image scrim covered this; on a flat surface there is nothing
/// behind the system row but text.
///
/// Deliberately only as tall as the status bar itself: any taller and it reads
/// as a header band, which would break the full-bleed premise.
/// {@endtemplate}
class StatusBarScrim extends StatelessWidget {
  /// {@macro status_bar_scrim}
  const StatusBarScrim({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: IgnorePointer(
        child: Container(
          height: MediaQuery.viewPaddingOf(context).top + AppSpacing.sm,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF05070A), Color(0x0005070A)],
              stops: [0.55, 1],
            ),
          ),
        ),
      ),
    );
  }
}
