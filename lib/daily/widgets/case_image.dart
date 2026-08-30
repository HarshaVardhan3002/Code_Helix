import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';

/// {@template case_image}
/// The full-bleed image a case is built on.
///
/// Fills its slot edge to edge and never animates. That second part is a
/// rendering constraint, not a stylistic one: the glass surfaces above are
/// nearly free while the pixels behind them hold still, and cost a full
/// re-render on every frame those pixels move.
///
/// Nothing drawn here may name a finding. Not the placeholder, not a caption,
/// not a tag. The user is about to be asked what this is.
/// {@endtemplate}
class CaseImage extends StatelessWidget {
  /// {@macro case_image}
  const CaseImage({required this.dailyCase, this.scrim = true, super.key});

  /// The case whose image is shown.
  final DailyCase dailyCase;

  /// Whether to lay the legibility gradient over the image.
  final bool scrim;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            dailyCase.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, _, _) => _MissingImage(
              region: dailyCase.region,
            ),
          ),
          if (scrim) const _LegibilityScrim(),
        ],
      ),
    );
  }
}

/// The gradient that buys back contrast for the overlaid surfaces.
///
/// Glass takes its colour from what is behind it, so over a bright, washed-out
/// frame the question panel loses its edges and its type stops reading. The
/// scrim guarantees legibility across arbitrary imagery instead of hoping
/// every frame happens to be dark enough.
///
/// It fades toward [GiColors.mediaScrim] and so inverts with the scheme: the
/// frame is veiled black under dark glass, white under light glass. The frame
/// itself is never recoloured or desaturated - mucosal hue is the finding.
///
/// The light scheme needs a heavier veil than the dark one. A dark panel over
/// a dark-scrimmed frame only has to be slightly darker than what surrounds
/// it; near-black text on a white panel over a bright pink oesophagus needs
/// the frame genuinely knocked back first.
class _LegibilityScrim extends StatelessWidget {
  const _LegibilityScrim();

  @override
  Widget build(BuildContext context) {
    final scrim = context.gi.mediaScrim;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // The last stop is fully opaque on purpose. The frame is a bounded hero
    // with the page ground directly under its bottom edge, and anything short
    // of opaque leaves a hard horizontal seam across the screen where the
    // photograph stops.
    final steps = dark
        ? const [0.50, 0.10, 0.35, 1.0]
        : const [0.55, 0.12, 0.34, 1.0];

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.24, 0.5, 1],
            colors: [
              for (final a in steps) scrim.withValues(alpha: a),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Stand-in shown where a case has no licensed frame yet.
///
/// Deliberately abstract. It must not read as a photograph of a real
/// examination - a plausible-looking fake endoscopic frame under a real
/// register number is exactly the failure mode the citation rules exist to
/// prevent. So: no structures, no tissue colour, and a marker that says the
/// image is missing.
///
/// It is not a flat fill either, because the glass panel above takes its
/// colour and refraction from what is behind it. Over one flat tone the glass
/// renders as nothing and the whole surface reads as a plain card.
///
/// Names the anatomical region and nothing else. An earlier version listed the
/// case's clinical tags here, which handed over the diagnosis before the
/// question had been asked.
class _MissingImage extends StatelessWidget {
  const _MissingImage({required this.region});

  final GiRegion region;

  @override
  Widget build(BuildContext context) {
    final gi = context.gi;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.55),
              radius: 1.25,
              colors: dark
                  ? const [
                      Color(0xFF23414F),
                      Color(0xFF12222C),
                      Color(0xFF060B0F),
                    ]
                  : const [
                      Color(0xFFFFFFFF),
                      Color(0xFFDCE7EF),
                      Color(0xFFB9CBD8),
                    ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
        // A second, offset lobe. One gradient reads as a vignette; two read as
        // a lit cavity, which is what gives the glass above something with
        // direction to bend.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.75, -0.1),
              radius: 0.85,
              colors: [
                gi.action.withValues(alpha: dark ? 0.22 : 0.14),
                gi.action.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        // Sits high, not centred: the stage grows downward under the question
        // panel, so a centred marker ends up behind it.
        Align(
          alignment: const Alignment(0, -0.45),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_outlined,
                size: AppSpacing.xxlg,
                color: gi.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'BILD FOLGT',
                style: context.labelSmall?.copyWith(
                  color: gi.textSecondary,
                  letterSpacing: 2,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                region.label,
                style: context.labelMedium?.copyWith(
                  color: gi.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
