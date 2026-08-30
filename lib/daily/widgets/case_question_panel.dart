import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/bloc/bloc.dart';
import 'package:flutter_instagram_offline_first_clone/daily/widgets/citation_block.dart';
import 'package:flutter_instagram_offline_first_clone/daily/widgets/quiz_option_tile.dart';

/// {@template case_question_panel}
/// The glass panel over the image, carrying the question.
///
/// This is the only thing on the first screen besides the image, and it holds
/// the whole rule the product rests on: **quiz before information**. There is
/// no headline, no summary, no tag and no caption anywhere above the fold. You
/// cannot read your way to the answer.
///
/// Once an answer is committed the panel collapses to the verdict and points
/// down. The teaching lives below, where it cannot be reached first.
/// {@endtemplate}
class CaseQuestionPanel extends StatelessWidget {
  /// {@macro case_question_panel}
  const CaseQuestionPanel({required this.dailyCase, super.key});

  /// The case being asked.
  final DailyCase dailyCase;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaseQuizCubit, CaseQuizState>(
      builder: (context, state) {
        return GlassSurface(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: state.isRevealed
                ? _Answered(correct: state.correct)
                : _Asking(dailyCase: dailyCase, state: state),
          ),
        );
      },
    );
  }
}

class _Asking extends StatelessWidget {
  const _Asking({required this.dailyCase, required this.state});

  final DailyCase dailyCase;
  final CaseQuizState state;

  @override
  Widget build(BuildContext context) {
    final quiz = dailyCase.quiz;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MetaChip(label: quiz.focus.label),
            const SizedBox(width: AppSpacing.sm),
            MetaChip(label: dailyCase.region.label),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Newsreader, not the UI sans. The question is the one line on this
        // screen the reader has to weigh, and the serif marks it as the
        // subject of the screen rather than a caption on the image.
        Text(
          quiz.question,
          style: GiSerif.question.copyWith(color: context.gi.textPrimary),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final option in quiz.options) ...[
          QuizOptionTile(
            option: option,
            revealed: false,
            isSelected: state.selectedId == option.id,
            isCorrectOption: quiz.isCorrect(option.id),
            locked: state.isLocked,
            onTap: () => context.read<CaseQuizCubit>().answer(option.id),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (state.phase == CaseQuizPhase.evaluating) ...[
          const SizedBox(height: AppSpacing.xs),
          const _Evaluating(),
        ],
      ],
    );
  }
}

/// The deliberation beat.
///
/// Nothing is computed here — the verdict shipped with the case. The pause
/// exists so the answer arrives as a considered read rather than as a lookup.
class _Evaluating extends StatelessWidget {
  const _Evaluating();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 13,
          height: 13,
          child: CircularProgressIndicator(
            strokeWidth: 1.4,
            color: context.gi.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          'Antwort wird geprüft',
          style: context.bodySmall?.copyWith(
            color: context.gi.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Answered extends StatelessWidget {
  const _Answered({required this.correct});

  final bool correct;

  @override
  Widget build(BuildContext context) {
    final accent = correct ? context.gi.correct : context.gi.incorrect;

    return Row(
      children: [
        Icon(
          correct ? Icons.check_rounded : Icons.close_rounded,
          size: 18,
          color: accent,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          correct ? 'Richtig' : 'Nicht ganz',
          style: context.titleSmall?.copyWith(
            color: accent,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const Spacer(),
        Text(
          'Auflösung unten',
          style: context.labelSmall?.copyWith(
            color: context.gi.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: context.gi.textSecondary,
        ),
      ],
    );
  }
}
