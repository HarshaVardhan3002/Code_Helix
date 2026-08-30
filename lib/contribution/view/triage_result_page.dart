import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/contribution/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template triage_result_page}
/// What the author sees straight after submitting.
///
/// The screening report, and a status that says plainly what happens next:
/// nothing, until a physician editor acts. The page has no approve button.
/// {@endtemplate}
class TriageResultPage extends StatelessWidget {
  /// {@macro triage_result_page}
  const TriageResultPage({required this.submission, super.key});

  /// The submission that was just screened.
  final CaseSubmission submission;

  @override
  Widget build(BuildContext context) {
    final report = submission.triage;

    return Scaffold(
      backgroundColor: context.gi.base,
      body: SurfaceBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            ShellMetrics.topInset(context),
            AppSpacing.lg,
            AppSpacing.xxlg,
          ),
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 34,
              color: context.gi.correct,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Eingereicht',
              style: context.headlineSmall?.copyWith(
                color: context.gi.textPrimary,
                fontWeight: AppFontWeight.semiBold,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Der Fall liegt jetzt bei der Redaktion. '
              'Bis zur Freigabe sieht ihn kein Leser.',
              style: context.bodyMedium?.copyWith(
                color: context.gi.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.xlg),
            _StatusRow(status: submission.status),
            const SizedBox(height: AppSpacing.xlg),
            if (report != null) TriageReportCard(report: report),
            const SizedBox(height: AppSpacing.xxlg),
            Tappable.scaled(
              onTap: Navigator.of(context).pop,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  border: Border.all(
                    color: context.gi.hairline,
                  ),
                ),
                child: Text(
                  'Fertig',
                  style: context.titleSmall?.copyWith(
                    color: context.gi.textPrimary,
                    fontWeight: AppFontWeight.semiBold,
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

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.status});

  final SubmissionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.gi.fill,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: context.gi.hairline),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 17,
            color: context.gi.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Status: ${status.label}',
            style: context.bodyMedium?.copyWith(
              color: context.gi.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
