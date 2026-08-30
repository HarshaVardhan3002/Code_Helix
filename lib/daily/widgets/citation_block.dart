import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';

/// {@template citation_block}
/// Where an answer comes from, rendered so a gap is visible as a gap.
///
/// An unconfirmed field prints `[offen]` rather than being quietly omitted.
/// A citation with a missing recommendation number that *looks* complete is
/// worse than one that admits what it does not know: the reader would act on
/// it either way, and only one of those is honest.
/// {@endtemplate}
class CitationBlock extends StatelessWidget {
  /// {@macro citation_block}
  const CitationBlock({required this.citation, this.dense = false, super.key});

  /// {@macro guideline_citation}
  final GuidelineCitation citation;

  /// Renders a single tight line instead of the full block.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final muted = context.gi.textSecondary;

    if (dense) {
      return Text(
        '${citation.guideline} · ${citation.registerLabel}',
        style: context.labelSmall?.copyWith(color: muted, height: 1.35),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.gi.fill,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: context.gi.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'QUELLE',
                style: context.labelSmall?.copyWith(
                  color: muted,
                  letterSpacing: 1.5,
                  fontSize: 9.5,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
              const Spacer(),
              if (!citation.isComplete) const _OpenFieldsChip(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            citation.guideline,
            style: context.bodySmall?.copyWith(
              color: context.gi.textPrimary,
              height: 1.4,
              fontWeight: AppFontWeight.medium,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${citation.registerLabel} · ${citation.versionLabel}',
            style: context.labelSmall?.copyWith(color: muted, height: 1.4),
          ),
          Text(
            citation.recommendationLabel,
            style: context.labelSmall?.copyWith(color: muted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _OpenFieldsChip extends StatelessWidget {
  const _OpenFieldsChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: context.gi.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: context.gi.warning.withValues(alpha: 0.35)),
      ),
      child: Text(
        'FELDER OFFEN',
        style: context.labelSmall?.copyWith(
          color: context.gi.warning,
          letterSpacing: 1,
          fontSize: 8.5,
          fontWeight: AppFontWeight.semiBold,
        ),
      ),
    );
  }
}

/// {@template unverified_chip}
/// Marks content no physician has cleared yet.
///
/// Visible on purpose, including to someone reading over a shoulder during the
/// demo. Nothing unreviewed may pass as cleared clinical guidance.
/// {@endtemplate}
class UnverifiedChip extends StatelessWidget {
  /// {@macro unverified_chip}
  const UnverifiedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: context.gi.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: context.gi.warning.withValues(alpha: 0.4)),
      ),
      child: Text(
        'PLATZHALTER',
        style: context.labelSmall?.copyWith(
          color: context.gi.warning,
          letterSpacing: 1.1,
          fontSize: 9.5,
          fontWeight: AppFontWeight.semiBold,
        ),
      ),
    );
  }
}

/// {@template meta_chip}
/// A small neutral label: the question type, the region, a status.
/// {@endtemplate}
class MetaChip extends StatelessWidget {
  /// {@macro meta_chip}
  const MetaChip({required this.label, this.accent, super.key});

  /// The text, rendered upper case.
  final String label;

  /// Overrides the neutral colour.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final colour = accent ?? context.gi.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: accent == null ? 0.1 : 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(
          color: colour.withValues(alpha: accent == null ? 0.16 : 0.4),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.labelSmall?.copyWith(
          color: colour.withValues(alpha: accent == null ? 0.8 : 1),
          letterSpacing: 1.1,
          fontSize: 9.5,
          fontWeight: AppFontWeight.semiBold,
        ),
      ),
    );
  }
}
