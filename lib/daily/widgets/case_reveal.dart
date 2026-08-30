import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/bloc/bloc.dart';
import 'package:flutter_instagram_offline_first_clone/daily/widgets/citation_block.dart';
import 'package:flutter_instagram_offline_first_clone/daily/widgets/quiz_option_tile.dart';

/// {@template case_reveal}
/// Everything that may only be shown after the user commits.
///
/// The headline that names the diagnosis, the teaching text, the rationale for
/// every option, the takeaway, the citation and the image credit. It lives
/// below the fold, after the question, so it is structurally impossible to
/// read first.
/// {@endtemplate}
class CaseReveal extends StatelessWidget {
  /// {@macro case_reveal}
  const CaseReveal({
    required this.dailyCase,
    required this.onOpenTopic,
    this.showClosingLine = true,
    super.key,
  });

  /// The case being revealed.
  final DailyCase dailyCase;

  /// Opens the case's Bibliothek topic.
  ///
  /// The one sanctioned way out of the daily and into unlimited reading.
  final ValueChanged<String>? onOpenTopic;

  /// Whether to print the sign-off that closes the day.
  final bool showClosingLine;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaseQuizCubit, CaseQuizState>(
      builder: (context, state) {
        if (!state.isRevealed) return const SizedBox.shrink();

        final quiz = dailyCase.quiz;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xlg,
            AppSpacing.lg,
            AppSpacing.xxlg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dailyCase.unverified) ...[
                const UnverifiedChip(),
                const SizedBox(height: AppSpacing.md),
              ],
              Text(
                dailyCase.revealTitle,
                style: context.titleLarge?.copyWith(
                  color: context.gi.textPrimary,
                  height: 1.22,
                  fontWeight: AppFontWeight.semiBold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final paragraph in dailyCase.explanation.split('\n\n')) ...[
                Text(
                  paragraph,
                  style: context.bodyMedium?.copyWith(
                    color: context.gi.textPrimary,
                    height: 1.54,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              const SizedBox(height: AppSpacing.md),
              const _SectionLabel(label: 'Jede Option im Einzelnen'),
              const SizedBox(height: AppSpacing.md),
              for (final option in quiz.options) ...[
                QuizOptionTile(
                  option: option,
                  revealed: true,
                  isSelected: state.selectedId == option.id,
                  isCorrectOption: quiz.isCorrect(option.id),
                  locked: true,
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.lg),
              _Takeaway(text: quiz.takeaway),
              const SizedBox(height: AppSpacing.lg),
              CitationBlock(citation: dailyCase.citation),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Bild: ${dailyCase.imageCredit.label}',
                style: context.labelSmall?.copyWith(
                  color: context.gi.textSecondary,
                ),
              ),
              if (dailyCase.contributedBy != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Fall eingereicht von ${dailyCase.contributedBy}',
                  style: context.labelSmall?.copyWith(
                    color: context.gi.textSecondary,
                  ),
                ),
              ],
              if (dailyCase.topicId != null && onOpenTopic != null) ...[
                const SizedBox(height: AppSpacing.xlg),
                _TopicLink(
                  onTap: () => onOpenTopic!(dailyCase.topicId!),
                ),
              ],
              if (showClosingLine) ...[
                const SizedBox(height: AppSpacing.xlg),
                const _ClosingLine(),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.labelSmall?.copyWith(
        color: context.gi.textSecondary,
        letterSpacing: 1.5,
        fontSize: 9.5,
        fontWeight: AppFontWeight.semiBold,
      ),
    );
  }
}

class _Takeaway extends StatelessWidget {
  const _Takeaway({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.gi.fill,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: context.gi.hairline),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A sibling bar, not a thicker left BorderSide: Flutter refuses to
            // paint a non-uniform Border together with a borderRadius, and a
            // container that fails to paint takes its text with it.
            SizedBox(
              width: 2.5,
              child: ColoredBox(color: context.gi.action),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  text,
                  style: context.bodyMedium?.copyWith(
                    color: context.gi.textPrimary,
                    height: 1.46,
                    fontWeight: AppFontWeight.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicLink extends StatelessWidget {
  const _TopicLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(color: context.gi.hairline),
        ),
        child: Row(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 17,
              color: context.gi.textPrimary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Zum Thema in der Bibliothek',
                style: context.bodyMedium?.copyWith(
                  color: context.gi.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: context.gi.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// The sign-off that closes the day.
///
/// The point of the product is that it ends. Without a line saying so, the
/// user scrolls looking for more and finds the archive, which reads as an
/// endless feed — the exact thing this app is not.
class _ClosingLine extends StatelessWidget {
  const _ClosingLine();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: context.gi.hairline),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Das war’s für heute.',
          style: context.titleSmall?.copyWith(
            color: context.gi.textPrimary,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Morgen gibt’s einen neuen Fall.',
          style: context.bodyMedium?.copyWith(
            color: context.gi.textSecondary,
          ),
        ),
      ],
    );
  }
}
