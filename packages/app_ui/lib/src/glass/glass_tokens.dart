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
///
/// ## Two schemes
///
/// Every token takes a [Brightness]. Dark glass is a smoked panel lit from
/// above; light glass is a frosted white one. They are not the same surface
/// with a different text colour — the tint inverts, the rim goes from a white
/// highlight to a grey shadow line, and the specular strength drops, because
/// a bright highlight on a white panel reads as a rendering artefact.
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
  static BorderSide sideOf(GlassLevel level, Brightness scheme) {
    final dark = scheme == Brightness.dark;
    return switch (level) {
      GlassLevel.chip => BorderSide(
        color: dark ? const Color(0x33FFFFFF) : const Color(0x1F0B1620),
        width: 0.5,
      ),
      GlassLevel.bar => BorderSide(
        color: dark ? const Color(0x2EFFFFFF) : const Color(0x1A0B1620),
        width: 0.5,
      ),
      GlassLevel.rail => BorderSide(
        color: dark ? const Color(0x3DFFFFFF) : const Color(0x240B1620),
        width: 0.75,
      ),
      GlassLevel.sheet => BorderSide(
        color: dark ? const Color(0x47FFFFFF) : const Color(0x2E0B1620),
        width: 0.75,
      ),
    };
  }

  /// The glass shape for the given [level].
  ///
  /// Always a rounded superellipse. The squircle is the shape the renderer
  /// handles best and it reads as more considered than a plain rounded rect.
  static LiquidShape shapeOf(GlassLevel level, Brightness scheme) =>
      LiquidRoundedSuperellipse(
        borderRadius: radiusOf(level),
        side: sideOf(level, scheme),
      );

  /// The renderer settings for the given [level].
  ///
  /// [dimmed] pushes the tint further from the imagery behind it. Use it when
  /// the surface sits over a frame bright enough that text on it would
  /// otherwise wash out — darker in the dark scheme, milkier in the light one.
  static LiquidGlassSettings settingsOf(
    GlassLevel level,
    Brightness scheme, {
    bool dimmed = false,
  }) => scheme == Brightness.dark
      ? _dark(level, dimmed: dimmed)
      : _light(level, dimmed: dimmed);

  static LiquidGlassSettings _dark(GlassLevel level, {required bool dimmed}) =>
      switch (level) {
        GlassLevel.chip => LiquidGlassSettings(
          thickness: 10,
          blur: 4,
          glassColor: dimmed
              ? const Color(0x3D0B0F14)
              : const Color(0x1FFFFFFF),
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
          glassColor: dimmed
              ? const Color(0x470B0F14)
              : const Color(0x1AFFFFFF),
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
          glassColor: dimmed
              ? const Color(0x520B0F14)
              : const Color(0x24FFFFFF),
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
          glassColor: dimmed
              ? const Color(0x660B0F14)
              : const Color(0x2E101720),
          lightAngle: _lightAngle,
          lightIntensity: 0.5,
          ambientStrength: 0.1,
          refractiveIndex: 1.2,
          chromaticAberration: 0.002,
          saturation: 1,
        ),
      };

  /// The light scheme.
  ///
  /// Tints are white rather than smoke and run heavier than their dark
  /// counterparts. A dark panel only needs to be a little darker than the
  /// frame to hold light text; a white panel has to actually veil the frame
  /// before near-black text on it survives a bright pink oesophagus.
  ///
  /// `lightIntensity` drops to roughly a third: the specular streak that gives
  /// a smoked panel its edge turns into a blown-out patch on a white one.
  static LiquidGlassSettings _light(GlassLevel level, {required bool dimmed}) =>
      switch (level) {
        GlassLevel.chip => LiquidGlassSettings(
          thickness: 10,
          blur: 5,
          glassColor: dimmed
              ? const Color(0x8AFFFFFF)
              : const Color(0x52FFFFFF),
          lightAngle: _lightAngle,
          lightIntensity: 0.2,
          ambientStrength: 0.14,
          refractiveIndex: 1.16,
          chromaticAberration: 0.002,
          saturation: 1,
        ),
        GlassLevel.bar => LiquidGlassSettings(
          thickness: 13,
          blur: 9,
          glassColor: dimmed
              ? const Color(0x99FFFFFF)
              : const Color(0x66FFFFFF),
          lightAngle: _lightAngle,
          lightIntensity: 0.22,
          ambientStrength: 0.16,
          refractiveIndex: 1.18,
          chromaticAberration: 0.003,
          saturation: 1,
        ),
        GlassLevel.rail => LiquidGlassSettings(
          thickness: 17,
          blur: 8,
          glassColor: dimmed
              ? const Color(0xA3FFFFFF)
              : const Color(0x70FFFFFF),
          lightAngle: _lightAngle,
          lightIntensity: 0.26,
          ambientStrength: 0.16,
          refractiveIndex: 1.24,
          chromaticAberration: 0.004,
          saturation: 1,
        ),
        GlassLevel.sheet => LiquidGlassSettings(
          thickness: 22,
          blur: 16,
          glassColor: dimmed
              ? const Color(0xC2FFFFFF)
              : const Color(0x9EF4F8FB),
          lightAngle: _lightAngle,
          lightIntensity: 0.18,
          ambientStrength: 0.18,
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
