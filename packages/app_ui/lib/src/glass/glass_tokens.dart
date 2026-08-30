import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// {@template glass_level}
/// The role a glass surface plays in the interface.
///
/// Every glass surface in the app must pick one of these instead of inventing
/// its own [LiquidGlassSettings]. Roles are ordered from the lightest, most
/// transparent surface to the heaviest one.
/// {@endtemplate}
enum GlassLevel {
  /// A small floating pill: a quiz option, a tag, a badge.
  ///
  /// Sits directly on the imagery and must never fight it for attention.
  chip,

  /// The floating top bar that carries the app identity.
  ///
  /// Thin and highly transparent so the image reads from edge to edge behind
  /// it.
  bar,

  /// The action rail overlaid on the image: like, save, share.
  ///
  /// Slightly thicker than [bar] so the icons stay readable over bright
  /// mucosa.
  rail,

  /// The draggable bottom sheet that carries the case text and the quiz.
  ///
  /// The heaviest surface in the app. It has to hold several paragraphs of
  /// body copy at Facharzt level, so legibility outranks transparency here.
  sheet,
}

/// {@template app_glass}
/// Glass design tokens for the app.
///
/// This is the single source of truth for every liquid glass surface. Widgets
/// select a [GlassLevel] and receive the matching [LiquidGlassSettings], corner
/// radius and rim [BorderSide]. Nothing outside this file should construct
/// [LiquidGlassSettings] by hand.
///
/// ## Why these numbers
///
/// The imagery underneath is endoscopy. Colour fidelity is clinical
/// information, not decoration: mucosal hue is how a finding is read. So the
/// tokens deliberately stay far below the package defaults on the two settings
/// that distort colour.
///
/// * `saturation` is kept at or near `1.0`. The package default of `1.5`
///   pushes mucosa toward a false erythematous red.
/// * `chromaticAberration` is kept very low. The package default of `0.01`
///   fringes fine vascular pattern, which is exactly the detail a
///   gastroenterologist is looking at.
///
/// Refraction, thickness and specular light carry the premium feel instead.
/// Those bend geometry, not colour.
/// {@endtemplate}
abstract final class AppGlass {
  /// Corner radius for a glass surface at the given [level].
  ///
  /// Radii climb with the surface's weight so that stacked surfaces read as a
  /// hierarchy rather than as repeats of one shape.
  static double radiusOf(GlassLevel level) => switch (level) {
    GlassLevel.chip => 18,
    GlassLevel.bar => 24,
    GlassLevel.rail => 30,
    GlassLevel.sheet => 34,
  };

  /// The hairline rim drawn around a glass surface at the given [level].
  ///
  /// A real glass edge catches light. Without this rim the surface reads as a
  /// blurred hole rather than as a solid object sitting above the image.
  static BorderSide sideOf(GlassLevel level) => switch (level) {
    GlassLevel.chip => const BorderSide(
      color: Color(0x33FFFFFF),
      width: 0.5,
    ),
    GlassLevel.bar => const BorderSide(
      color: Color(0x2EFFFFFF),
      width: 0.5,
    ),
    GlassLevel.rail => const BorderSide(
      color: Color(0x3DFFFFFF),
      width: 0.75,
    ),
    GlassLevel.sheet => const BorderSide(
      color: Color(0x47FFFFFF),
      width: 0.75,
    ),
  };

  /// The glass shape for the given [level].
  ///
  /// Always a rounded superellipse. The squircle is the shape the renderer
  /// handles best and it reads as more considered than a plain rounded rect.
  static LiquidShape shapeOf(GlassLevel level) => LiquidRoundedSuperellipse(
    borderRadius: radiusOf(level),
    side: sideOf(level),
  );

  /// The renderer settings for the given [level].
  ///
  /// [dimmed] darkens the tint. Use it when the surface sits over a bright
  /// frame and light text on it would otherwise wash out.
  static LiquidGlassSettings settingsOf(
    GlassLevel level, {
    bool dimmed = false,
  }) => switch (level) {
    GlassLevel.chip => LiquidGlassSettings(
      thickness: 10,
      blur: 4,
      glassColor: dimmed ? const Color(0x3D0B0F14) : const Color(0x1FFFFFFF),
      lightAngle: _lightAngle,
      lightIntensity: 0.55,
      ambientStrength: 0.06,
      refractiveIndex: 1.16,
      chromaticAberration: 0.002,
      saturation: 1,
    ),
    GlassLevel.bar => LiquidGlassSettings(
      thickness: 13,
      blur: 7,
      glassColor: dimmed ? const Color(0x470B0F14) : const Color(0x1AFFFFFF),
      lightAngle: _lightAngle,
      lightIntensity: 0.6,
      ambientStrength: 0.08,
      refractiveIndex: 1.18,
      chromaticAberration: 0.003,
      saturation: 1.05,
    ),
    GlassLevel.rail => LiquidGlassSettings(
      thickness: 17,
      blur: 6,
      glassColor: dimmed ? const Color(0x520B0F14) : const Color(0x24FFFFFF),
      lightAngle: _lightAngle,
      lightIntensity: 0.7,
      ambientStrength: 0.08,
      refractiveIndex: 1.24,
      chromaticAberration: 0.004,
      saturation: 1.05,
    ),
    GlassLevel.sheet => LiquidGlassSettings(
      thickness: 22,
      blur: 13,
      glassColor: dimmed ? const Color(0x660B0F14) : const Color(0x2E101720),
      lightAngle: _lightAngle,
      lightIntensity: 0.5,
      ambientStrength: 0.1,
      refractiveIndex: 1.2,
      chromaticAberration: 0.002,
      saturation: 1,
    ),
  };

  /// The direction the specular highlight comes from, in radians.
  ///
  /// Fixed for the whole app. Light arriving from a single consistent angle is
  /// what makes a set of separate surfaces read as one physical scene.
  static const double _lightAngle = -0.35 * math.pi;
}
