import 'package:flutter/widgets.dart';

/// {@template surface_background}
/// The ground the glass bars sit on where there is no image behind them.
///
/// Liquid glass renders by distorting the pixels underneath it, so over a flat
/// fill it comes out as almost nothing — the bar loses its edges and its
/// specular highlight. Bibliothek, Beitragen and Profil have no full-bleed
/// photograph, so they supply this gradient instead. It is not decoration; it
/// is what the surfaces above it refract.
/// {@endtemplate}
class SurfaceBackground extends StatelessWidget {
  /// {@macro surface_background}
  const SurfaceBackground({required this.child, super.key});

  /// The surface's own content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.6, -0.85),
              radius: 1.45,
              colors: [Color(0xFF2E2429), Color(0xFF12161D), Color(0xFF07090C)],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
