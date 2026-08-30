import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/widgets/quiz_option_tile.dart';
import 'package:flutter_instagram_offline_first_clone/progress/progress.dart';

/// The German label for a case's position in the feed.
///
/// Derived from position rather than a stored date, so the newest case always
/// reads as today whenever the app is opened. A demo weeks after the content
/// was written must not open on "vor 19 Tagen".
String dayLabelFor(int index) => switch (index) {
  0 => 'Heute',
  1 => 'Gestern',
  _ => 'vor $index Tagen',
};

/// {@template archive_section}
/// The user's own finite, already-published archive.
///
/// It sits below today's case and nowhere else. It is not discovery and it is
/// not a feed: it is a short list of days that have already happened, and it
/// ends.
/// {@endtemplate}
class ArchiveSection extends StatelessWidget {
  /// {@macro archive_section}
  const ArchiveSection({
    required this.cases,
    required this.onOpenCase,
    this.title = 'Frühere Fälle',
    super.key,
  });

  /// The past cases, newest first.
  final List<DailyCase> cases;

  /// Opens one of them.
  final ValueChanged<DailyCase> onOpenCase;

  /// The heading above the list.
  final String title;

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) return const SizedBox.shrink();

    final progress = context.watch<ProgressCubit>().state;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xlg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: context.labelSmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.45),
              letterSpacing: 1.5,
              fontSize: 9.5,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < cases.length; index++) ...[
            _ArchiveRow(
              dailyCase: cases[index],
              // The archive starts at yesterday, so its first row is one day
              // back from today.
              dayLabel: dayLabelFor(index + 1),
              answeredOptionId: progress.answerFor(cases[index].id),
              onTap: () => onOpenCase(cases[index]),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _ArchiveRow extends StatelessWidget {
  const _ArchiveRow({
    required this.dailyCase,
    required this.dayLabel,
    required this.answeredOptionId,
    required this.onTap,
  });

  final DailyCase dailyCase;
  final String dayLabel;
  final String? answeredOptionId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final answered = answeredOptionId != null;
    final correct = answered && dailyCase.quiz.isCorrect(answeredOptionId!);

    return Tappable.faded(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            _Thumb(dailyCase: dailyCase),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayLabel,
                    style: context.labelSmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // An unanswered past case must not show its headline
                    // either — the rule does not expire when the day does.
                    answered
                        ? dailyCase.revealTitle
                        : '${dailyCase.quiz.focus.label} · '
                              '${dailyCase.region.label}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodySmall?.copyWith(
                      color: AppColors.white.withValues(
                        alpha: answered ? 0.88 : 0.7,
                      ),
                      height: 1.35,
                      fontWeight: answered
                          ? AppFontWeight.medium
                          : AppFontWeight.regular,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatusDot(answered: answered, correct: correct),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.dailyCase});

  final DailyCase dailyCase;

  @override
  Widget build(BuildContext context) {
    return ClipRSuperellipse(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Image.asset(
          dailyCase.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, _, _) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF31262A), Color(0xFF11151B)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.answered, required this.correct});

  final bool answered;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    if (!answered) {
      return Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: AppColors.white.withValues(alpha: 0.35),
      );
    }

    final accent = correct ? kVerdictCorrect : kVerdictIncorrect;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Icon(
        correct ? Icons.check_rounded : Icons.close_rounded,
        size: 16,
        color: accent,
      ),
    );
  }
}
