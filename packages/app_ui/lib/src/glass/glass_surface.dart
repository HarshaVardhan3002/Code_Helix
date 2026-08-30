import 'package:app_ui/src/glass/glass_tokens.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// {@template glass_layer}
/// A container that renders every [GlassSurface.inLayer] beneath it.
///
/// Prefer one [GlassLayer] per cluster of surfaces that share a [GlassLevel].
/// The renderer allocates a texture covering the layer's entire area, so a
/// layer must be wrapped as tightly around its surfaces as possible. Never
/// stretch one layer across the whole screen to serve a few sparse shapes.
/// {@endtemplate}
class GlassLayer extends StatelessWidget {
  /// {@macro glass_layer}
  const GlassLayer({
    required this.child,
    this.level = GlassLevel.sheet,
    this.dimmed = false,
    this.fake = false,
    super.key,
  });

  /// The subtree containing the [GlassSurface.inLayer] shapes to render.
  final Widget child;

  /// {@macro glass_level}
  final GlassLevel level;

  /// Whether to darken the tint for legibility over a bright frame.
  final bool dimmed;

  /// Whether to render the cheap approximation instead of the real shader.
  ///
  /// Set this to `true` for the duration of a drag or transition. Glass is
  /// almost free while it holds still and expensive on every frame it moves,
  /// so moving surfaces should fall back and then settle back into the real
  /// effect at rest.
  final bool fake;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: AppGlass.settingsOf(
        level,
        Theme.of(context).brightness,
        dimmed: dimmed,
      ),
      fake: fake,
      child: child,
    );
  }
}

/// {@template glass_surface}
/// A single liquid glass surface.
///
/// This is the only glass primitive in the app. Every frosted, blurred or
/// refractive surface must go through it so that thickness, tint, corner
/// radius, rim light and light angle stay consistent. Do not reach for
/// `BackdropFilter`, `ImageFilter.blur` or a bare `LiquidGlass` at a call
/// site.
///
/// The effect works by distorting the pixels behind the surface, so it only
/// renders as glass when something is actually painted underneath it. Place it
/// in a [Stack] above real content; over a flat background it will look like
/// nothing at all.
///
/// The default constructor is self-contained and creates its own layer, which
/// is the right choice for one isolated surface. When several surfaces share a
/// [GlassLevel], wrap them in a single [GlassLayer] and build them with
/// [GlassSurface.inLayer] instead — one shared layer is markedly cheaper than
/// several individual ones.
/// {@endtemplate}
class GlassSurface extends StatelessWidget {
  /// {@macro glass_surface}
  const GlassSurface({
    required this.child,
    this.level = GlassLevel.sheet,
    this.shape,
    this.padding = EdgeInsets.zero,
    this.dimmed = false,
    this.fake = false,
    this.glassContainsChild = false,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  }) : _inLayer = false;

  /// Creates a surface that draws into an ancestor [GlassLayer].
  ///
  /// The layer owns the settings, so [dimmed] and [fake] are set on the
  /// [GlassLayer] rather than here.
  const GlassSurface.inLayer({
    required this.child,
    this.level = GlassLevel.sheet,
    this.shape,
    this.padding = EdgeInsets.zero,
    this.glassContainsChild = false,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  }) : _inLayer = true,
       dimmed = false,
       fake = false;

  /// The content carried by the surface.
  final Widget child;

  /// {@macro glass_level}
  ///
  /// Selects thickness, blur, tint, corner radius and rim from [AppGlass].
  final GlassLevel level;

  /// Overrides the shape derived from [level].
  ///
  /// Only pass this when a surface genuinely needs a different geometry, such
  /// as a circular action button. Leave it null everywhere else so the corner
  /// language stays uniform.
  final LiquidShape? shape;

  /// Inset applied to [child] inside the surface.
  final EdgeInsetsGeometry padding;

  /// Whether to darken the tint for legibility over a bright frame.
  final bool dimmed;

  /// Whether to render the cheap approximation instead of the real shader.
  ///
  /// See [GlassLayer.fake].
  final bool fake;

  /// Whether [child] is rendered inside the glass rather than on top of it.
  ///
  /// Keep this `false` for anything the user has to read. Text placed inside
  /// the glass is refracted along with the background and stops being legible.
  final bool glassContainsChild;

  /// How the surface clips [child].
  final Clip clipBehavior;

  /// Whether this surface draws into an ancestor [GlassLayer].
  final bool _inLayer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).brightness;
    final effectiveShape = shape ?? AppGlass.shapeOf(level, scheme);
    final content = padding == EdgeInsets.zero
        ? child
        : Padding(padding: padding, child: child);

    if (_inLayer) {
      return LiquidGlass(
        shape: effectiveShape,
        glassContainsChild: glassContainsChild,
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    return LiquidGlass.withOwnLayer(
      shape: effectiveShape,
      settings: AppGlass.settingsOf(level, scheme, dimmed: dimmed),
      fake: fake,
      glassContainsChild: glassContainsChild,
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}
