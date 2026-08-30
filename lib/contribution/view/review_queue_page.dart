import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/contribution/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template review_queue_page}
/// The editor's queue.
///
/// The gate the whole product rests on: nothing unreviewed reaches a user.
/// The screening report is here to narrow what has to be looked at, not to
/// replace the looking — approval is a physician's act, every time.
/// {@endtemplate}
class ReviewQueuePage extends StatelessWidget {
  /// {@macro review_queue_page}
  const ReviewQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gi.base,
      body: SurfaceBackground(
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            final queue = state.catalog.reviewQueue;

            return Stack(
              fit: StackFit.expand,
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    ShellMetrics.topInset(context),
                    AppSpacing.lg,
                    AppSpacing.xxlg,
                  ),
                  children: [
                    Text(
                      'Redaktionsprüfung',
                      style: context.headlineSmall?.copyWith(
                        color: context.gi.textPrimary,
                        fontWeight: AppFontWeight.semiBold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Nichts erscheint, bevor hier freigegeben wurde.',
                      style: context.bodyMedium?.copyWith(
                        color: context.gi.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    if (queue.isEmpty)
                      Text(
                        'Keine offenen Einreichungen.',
                        style: context.bodyMedium?.copyWith(
                          color: context.gi.textSecondary,
                        ),
                      )
                    else
                      for (final submission in queue) ...[
                        _ReviewCard(submission: submission),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                  ],
                ),
                const StatusBarScrim(coversBackButton: true),
                const _BackButton(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.submission});

  final CaseSubmission submission;

  @override
  Widget build(BuildContext context) {
    final entry = submission.submittedCase;
    final report = submission.triage;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.gi.fill,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: context.gi.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wrap, not Row: two German region labels plus an author name do
          // not fit one line on a phone, and a Row overflows rather than
          // breaking.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MetaChip(label: entry.quiz.focus.label),
              MetaChip(label: entry.region.label),
              Text(
                submission.authorName,
                style: context.labelSmall?.copyWith(
                  color: context.gi.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            entry.quiz.question,
            style: context.titleSmall?.copyWith(
              color: context.gi.textPrimary,
              height: 1.3,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            entry.revealTitle,
            style: context.bodySmall?.copyWith(
              color: context.gi.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (report != null) TriageReportCard(report: report),
          const SizedBox(height: AppSpacing.lg),
          Tappable.faded(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CasePage(dailyCase: entry),
              ),
            ),
            borderRadius: BorderRadius.circular(AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(
                  color: context.gi.hairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 15,
                    color: context.gi.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Als Leser ansehen',
                    style: context.labelMedium?.copyWith(
                      color: context.gi.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _DecisionButton(
                  label: 'Zurückgeben',
                  outlined: true,
                  onTap: () => context.read<CatalogCubit>().reject(
                    submission.id,
                    note: 'Bitte Empfehlungsnummer ergänzen.',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DecisionButton(
                  label: 'Freigeben',
                  outlined: false,
                  onTap: () {
                    context.read<CatalogCubit>().approve(submission.id);
                    // The card disappears from the queue on approval. Without
                    // a line saying where it went, the editor is left looking
                    // at an empty page wondering whether it worked.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Freigegeben. Steht jetzt als Fall des Tages in '
                          'Heute.',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.outlined,
    required this.onTap,
  });

  final String label;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? AppColors.transparent : context.gi.action,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(
            color: outlined ? context.gi.hairline : AppColors.transparent,
          ),
        ),
        child: Text(
          label,
          style: context.titleSmall?.copyWith(
            color: outlined
                ? context.gi.textPrimary
                : Theme.of(context).colorScheme.onPrimary,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Tappable.scaled(
            onTap: Navigator.of(context).pop,
            child: GlassSurface(
              level: GlassLevel.chip,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: context.gi.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
