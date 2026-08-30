import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';

/// How an option reads once the answer is in.
enum QuizVerdict {
  /// The correct option, whether or not it was the one chosen.
  correct,

  /// The option that was chosen and was wrong.
  incorrect;

  /// The palette colour for this verdict.
  Color color(BuildContext context) => switch (this) {
    QuizVerdict.correct => context.gi.correct,
    QuizVerdict.incorrect => context.gi.incorrect,
  };

  /// The glyph drawn in the marker.
  IconData get icon => switch (this) {
    QuizVerdict.correct => Icons.check_rounded,
    QuizVerdict.incorrect => Icons.close_rounded,
  };
}

/// {@template quiz_option_tile}
/// One answer, before and after the commitment.
///
/// Before: a plain tappable row. Nothing distinguishes the correct option, and
/// nothing hints at it — no ordering tell, no length tell in the layout.
///
/// After: the correct option is marked whether or not it was chosen, a wrong
/// choice is marked, and the untouched options dim. Marking only what the user
/// picked would leave the other options as guesses they got away with, and the
/// rationale for every one of them is the teaching.
///
/// The wrong answer is marked in the palette's incorrect red, but only on the
/// marker and the rim — never as a fill behind the text, and never with a
/// second signal like a shake or a sound. It states a fact; it does not scold.
/// {@endtemplate}
class QuizOptionTile extends StatelessWidget {
  /// {@macro quiz_option_tile}
  const QuizOptionTile({
    required this.option,
    required this.revealed,
    required this.isSelected,
    required this.isCorrectOption,
    required this.locked,
    required this.onTap,
    super.key,
  });

  /// {@macro quiz_option}
  final QuizOption option;

  /// Whether the verdict is in.
  final bool revealed;

  /// Whether this is the option the user committed to.
  final bool isSelected;

  /// Whether this is the correct option.
  ///
  /// Must not change how the tile looks until [revealed].
  final bool isCorrectOption;

  /// Whether taps are ignored.
  final bool locked;

  /// Called when the option is chosen.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gi = context.gi;
    final verdict = switch ((revealed, isCorrectOption, isSelected)) {
      (true, true, _) => QuizVerdict.correct,
      (true, false, true) => QuizVerdict.incorrect,
      _ => null,
    };
    final accent = verdict?.color(context);
    final dimmed = revealed && verdict == null;

    return Semantics(
      button: !locked,
      selected: isSelected,
      child: Tappable.faded(
        onTap: locked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: dimmed ? 0.5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: accent == null
                  ? gi.fill
                  : accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(
                color: accent?.withValues(alpha: 0.75) ?? gi.hairline,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Marker(verdict: verdict, isSelected: isSelected),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: context.bodyMedium?.copyWith(
                          color: gi.textPrimary,
                          height: 1.36,
                        ),
                      ),
                      // Rationales exist for every option and appear only once
                      // the answer is committed. Showing them earlier would
                      // give the answer away outright.
                      if (revealed) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          option.rationale,
                          style: context.bodySmall?.copyWith(
                            color: gi.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.verdict, required this.isSelected});

  final QuizVerdict? verdict;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final gi = context.gi;
    final accent = verdict?.color(context);

    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent?.withValues(alpha: 0.16) ?? AppColors.transparent,
        border: Border.all(
          color: accent ?? (isSelected ? gi.action : gi.textSecondary),
          width: 1.2,
        ),
      ),
      child: verdict == null
          ? null
          : Icon(verdict!.icon, size: 13, color: accent),
    );
  }
}
