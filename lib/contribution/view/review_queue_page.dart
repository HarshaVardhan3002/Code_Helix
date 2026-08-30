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
      backgroundColor: AppColors.black,
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
                        color: AppColors.white,
                        fontWeight: AppFontWeight.semiBold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Nichts erscheint, bevor hier freigegeben wurde.',
                      style: context.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    if (queue.isEmpty)
                      Text(
                        'Keine offenen Einreichungen.',
                        style: context.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.5),
                        ),
                      )
                    else
                      for (final submission in queue) ...[
                        _ReviewCard(submission: submission),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                  ],
                ),
                const StatusBarScrim(),
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
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
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
                  color: AppColors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            entry.quiz.question,
            style: context.titleSmall?.copyWith(
              color: AppColors.white,
              height: 1.3,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            entry.revealTitle,
            style: context.bodySmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
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
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 15,
                    color: AppColors.white.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Als Leser ansehen',
                    style: context.labelMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
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
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF1C1F25),
                        content: Text(
                          'Freigegeben. Steht jetzt als Fall des Tages in '
                          'Heute.',
                          style: TextStyle(color: AppColors.white),
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
          color: outlined
              ? AppColors.transparent
              : AppColors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(
            color: AppColors.white.withValues(alpha: outlined ? 0.25 : 0),
          ),
        ),
        child: Text(
          label,
          style: context.titleSmall?.copyWith(
            color: outlined ? AppColors.white : const Color(0xFF0B0F14),
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
            child: const GlassSurface(
              level: GlassLevel.chip,
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
