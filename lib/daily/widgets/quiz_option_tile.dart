import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';

/// Muted, clinical green. A correct answer is confirmed, not celebrated.
const kVerdictCorrect = Color(0xFF56B48C);

/// Amber rather than red. Getting a case wrong is the point of the exercise;
/// an error colour would frame study as failure.
const kVerdictIncorrect = Color(0xFFD79463);

/// {@template quiz_option_tile}
/// One answer, before and after the commitment.
///
/// Before: a plain tappable row. Nothing distinguishes the correct option, and
/// nothing hints at it — no ordering tell, no length tell in the layout.
///
/// After: the correct option is marked whether or not it was chosen, a wrong
/// choice is marked amber, and the untouched options dim. Marking only what
/// the user picked would leave the other options as guesses they got away
/// with, and the rationale for every one of them is the teaching.
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
    final accent = switch ((revealed, isCorrectOption, isSelected)) {
      (true, true, _) => kVerdictCorrect,
      (true, false, true) => kVerdictIncorrect,
      _ => null,
    };
    final dimmed = revealed && accent == null;

    return Tappable.faded(
      onTap: locked ? null : onTap,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: dimmed ? 0.42 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(
              alpha: isSelected && revealed ? 0.1 : 0.05,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(
              color:
                  accent?.withValues(alpha: 0.75) ??
                  AppColors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Marker(accent: accent, isSelected: isSelected),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: context.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.92),
                        height: 1.36,
                      ),
                    ),
                    // Rationales exist for every option and appear only once
                    // the answer is committed. Showing them earlier would give
                    // the answer away outright.
                    if (revealed) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        option.rationale,
                        style: context.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                          height: 1.48,
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
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.accent, required this.isSelected});

  final Color? accent;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final icon = switch (accent) {
      kVerdictCorrect => Icons.check_rounded,
      kVerdictIncorrect => Icons.close_rounded,
      _ => null,
    };

    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent?.withValues(alpha: 0.16) ?? AppColors.transparent,
        border: Border.all(
          color:
              accent ??
              AppColors.white.withValues(alpha: isSelected ? 0.55 : 0.28),
          width: 1.2,
        ),
      ),
      child: icon == null ? null : Icon(icon, size: 13, color: accent),
    );
  }
}
