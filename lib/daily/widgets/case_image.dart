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
/// frame the question panel loses its edges and white type stops reading. The
/// scrim guarantees legibility across arbitrary imagery instead of hoping
/// every frame happens to be dark enough.
class _LegibilityScrim extends StatelessWidget {
  const _LegibilityScrim();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.24, 0.5, 1],
            colors: [
              Color(0x8005070A),
              Color(0x1A05070A),
              Color(0x5905070A),
              Color(0xD105070A),
            ],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}

/// Stand-in shown until real endoscopy imagery is bundled.
///
/// Deliberately abstract. It must not read as a photograph of a real
/// examination — a plausible-looking fake endoscopic frame under a real
/// register number is exactly the failure mode the citation rules exist to
/// prevent. So: tissue-adjacent tones, no structures, and a marker that says
/// the image is missing.
///
/// It is not a flat grey box either, because the glass panel above takes its
/// colour and refraction from what is behind it. Over black, the glass renders
/// as nothing and the whole surface reads as a plain dark card.
///
/// Names the anatomical region and nothing else. The earlier version listed
/// the case's clinical tags here, which handed over the diagnosis before the
/// question had been asked.
class _MissingImage extends StatelessWidget {
  const _MissingImage({required this.region});

  final GiRegion region;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.35, -0.55),
              radius: 1.25,
              colors: [Color(0xFF7A3F42), Color(0xFF3B2226), Color(0xFF16171C)],
              stops: [0, 0.5, 1],
            ),
          ),
        ),
        // A second, offset lobe. One gradient reads as a vignette; two read as
        // a lit cavity, which is what gives the glass above something with
        // direction to bend.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.75, -0.1),
              radius: 0.85,
              colors: [Color(0x66C97A62), Color(0x00C97A62)],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.1, 0.35),
              radius: 1.1,
              colors: [Color(0x0005070A), Color(0xB305070A)],
              stops: [0.45, 1],
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
                color: AppColors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'BILD FOLGT',
                style: context.labelSmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.55),
                  letterSpacing: 2,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                region.label,
                style: context.labelMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.45),
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
