import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/contribution/view/review_queue_page.dart';
import 'package:flutter_instagram_offline_first_clone/contribution/view/submit_case_page.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/session/session.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template beitragen_page}
/// The contribution surface, gated by role.
///
/// This is the engine, not a feature. Two physicians reviewing is a ceiling; a
/// society of thousands writing, with review as the gate, is a supply line.
///
/// A reader sees why the surface is closed to them rather than an empty screen
/// — the gate is the product's credibility, so it is worth explaining.
/// {@endtemplate}
class BeitragenPage extends StatelessWidget {
  /// {@macro beitragen_page}
  const BeitragenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionCubit>().state;

    return SurfaceBackground(
      child: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          final mine = state.catalog.submissions
              .where((entry) => entry.authorName == user?.name)
              .toList(growable: false);

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              ShellMetrics.topInset(context),
              AppSpacing.lg,
              ShellMetrics.bottomInset(context),
            ),
            children: [
              Text(
                'Beitragen',
                style: context.headlineSmall?.copyWith(
                  color: context.gi.textPrimary,
                  fontWeight: AppFontWeight.semiBold,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Die Fälle kommen von den Mitgliedern. '
                'Freigegeben wird ärztlich.',
                style: context.bodyMedium?.copyWith(
                  color: context.gi.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.xlg),
              if (user == null || !user.canContribute)
                const _ReaderNotice()
              else ...[
                _ActionCard(
                  icon: Icons.edit_outlined,
                  title: 'Fall einreichen',
                  subtitle:
                      'Bild wählen, Frage und vier Optionen schreiben, '
                      'Quelle zuordnen.',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SubmitCasePage(),
                    ),
                  ),
                ),
                if (user.canEdit) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ActionCard(
                    icon: Icons.fact_check_outlined,
                    title: 'Redaktionsprüfung',
                    subtitle: state.catalog.reviewQueue.isEmpty
                        ? 'Keine offenen Einreichungen.'
                        : state.catalog.reviewQueue.length == 1
                        ? 'Eine Einreichung wartet auf Freigabe.'
                        : '${state.catalog.reviewQueue.length} Einreichungen '
                              'warten auf Freigabe.',
                    badge: state.catalog.reviewQueue.length,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ReviewQueuePage(),
                      ),
                    ),
                  ),
                ],
                if (mine.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xlg),
                  Text(
                    'MEINE EINREICHUNGEN',
                    style: context.labelSmall?.copyWith(
                      color: context.gi.textSecondary,
                      letterSpacing: 1.4,
                      fontSize: 9.5,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final submission in mine) ...[
                    _SubmissionRow(submission: submission),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ] else ...[
                  const SizedBox(height: AppSpacing.xlg),
                  const _PathNotice(),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

/// What happens to a case after it is sent.
///
/// Shown while a contributor has nothing in flight. The path is the product
/// argument — a submission is screened, then cleared by a physician, and only
/// then published — so stating it here is worth more than an empty panel.
class _PathNotice extends StatelessWidget {
  const _PathNotice();

  static const _steps = [
    ('Einreichen', 'Bild aus der Sammlung, Frage, vier Optionen, Quelle.'),
    (
      'Automatische Vorprüfung',
      'Gleicht gegen das zitierte Thema ab und markiert Lücken. '
          'Entscheidet nichts.',
    ),
    ('Ärztliche Freigabe', 'Die Redaktion gibt frei oder gibt zurück.'),
    (
      'Fall des Tages',
      'Freigegebene Fälle rücken an die Spitze der Rotation. '
          'Im Prototyp sofort, im Betrieb am nächsten Tag.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: context.gi.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEG EINER EINREICHUNG',
            style: context.labelSmall?.copyWith(
              color: context.gi.textSecondary,
              letterSpacing: 1.4,
              fontSize: 9.5,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (index, step) in _steps.indexed) ...[
            if (index > 0) const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '${index + 1}',
                    style: context.labelMedium?.copyWith(
                      color: context.gi.textSecondary,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.$1,
                        style: context.bodyMedium?.copyWith(
                          color: context.gi.textPrimary,
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.$2,
                        style: context.bodySmall?.copyWith(
                          color: context.gi.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReaderNotice extends StatelessWidget {
  const _ReaderNotice();

  @override
  Widget build(BuildContext context) {
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
          Icon(
            Icons.lock_outline_rounded,
            size: 20,
            color: context.gi.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Einreichen ist verifizierten Ärztinnen und Ärzten vorbehalten',
            style: context.titleSmall?.copyWith(
              color: context.gi.textPrimary,
              height: 1.3,
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Die Antworten dieser App gelten als Lehrinhalt. Wer sie schreibt, '
            'muss fachlich dafür einstehen können — deshalb ist das Schreiben '
            'an eine Verifizierung gebunden und die Freigabe an die '
            'Redaktion.',
            style: context.bodyMedium?.copyWith(
              color: context.gi.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.gi.fill,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(color: context.gi.hairline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 21, color: context.gi.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.titleSmall?.copyWith(
                      color: context.gi.textPrimary,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.bodySmall?.copyWith(
                      color: context.gi.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null && badge! > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              MetaChip(label: '$badge', accent: context.gi.warning),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  const _SubmissionRow({required this.submission});

  final CaseSubmission submission;

  @override
  Widget build(BuildContext context) {
    final accent = switch (submission.status) {
      SubmissionStatus.approved => context.gi.correct,
      SubmissionStatus.rejected => context.gi.warning,
      _ => context.gi.textPrimary,
    };

    return Container(
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
              Expanded(
                child: Text(
                  submission.submittedCase.quiz.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodySmall?.copyWith(
                    color: context.gi.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              MetaChip(
                label: submission.status.label,
                accent: accent == context.gi.textPrimary ? null : accent,
              ),
            ],
          ),
          if (submission.scheduledLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Freigegeben — erscheint ${submission.scheduledLabel}.',
              style: context.labelSmall?.copyWith(
                color: context.gi.correct,
                fontWeight: AppFontWeight.medium,
              ),
            ),
          ],
          if (submission.editorNote != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Redaktion: ${submission.editorNote}',
              style: context.labelSmall?.copyWith(
                color: context.gi.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
