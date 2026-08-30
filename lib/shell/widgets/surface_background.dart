import 'package:flutter/material.dart';

/// {@template surface_background}
/// The ground the glass bars sit on where there is no image behind them.
///
/// Liquid glass renders by distorting the pixels underneath it, so over a flat
/// fill it comes out as almost nothing — the bar loses its edges and its
/// specular highlight. Bibliothek, Beitragen and Profil have no full-bleed
/// photograph, so they supply this gradient instead. It is not decoration; it
/// is what the surfaces above it refract.
///
/// The gradient is a single cool wash from the top left, one step lighter than
/// the page it sits behind. It must never become a feature: any colour with a
/// hue of its own would read as a second accent and would sit under every
/// screen in the app at once.
/// {@endtemplate}
class SurfaceBackground extends StatelessWidget {
  /// {@macro surface_background}
  const SurfaceBackground({required this.child, super.key});

  /// The surface's own content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.6, -0.85),
              radius: 1.45,
              colors: dark
                  ? const [
                      Color(0xFF15242E),
                      Color(0xFF080F14),
                      Color(0xFF000000),
                    ]
                  : const [
                      Color(0xFFFFFFFF),
                      Color(0xFFF1F5F9),
                      Color(0xFFDFE8EF),
                    ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
