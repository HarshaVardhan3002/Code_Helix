import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';

/// {@template triage_report_card}
/// What the screening pass found.
///
/// Deliberately worded as screening, never as a verdict: it reports what the
/// submission appears to match and what a human should check. The card has no
/// approve button and no "looks good" state, because the decision is not the
/// machine's to make.
/// {@endtemplate}
class TriageReportCard extends StatelessWidget {
  /// {@macro triage_report_card}
  const TriageReportCard({required this.report, super.key});

  /// {@macro triage_report}
  final TriageReport report;

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
          Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 15,
                color: context.gi.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'AUTOMATISCHE VORPRÜFUNG',
                style: context.labelSmall?.copyWith(
                  color: context.gi.textSecondary,
                  letterSpacing: 1.4,
                  fontSize: 9.5,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Zugeordnete Quelle',
            style: context.labelSmall?.copyWith(
              color: context.gi.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          CitationBlock(citation: report.matched),
          const SizedBox(height: AppSpacing.lg),
          _Confidence(value: report.confidence),
          const SizedBox(height: AppSpacing.lg),
          Text(
            report.flags.isEmpty
                ? 'Keine Auffälligkeiten.'
                : 'Zur Prüfung (${report.flags.length})',
            style: context.labelSmall?.copyWith(
              color: context.gi.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final flag in report.flags) ...[
            _Flag(flag: flag),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Die Vorprüfung entscheidet nichts. Freigegeben wird '
            'ausschließlich durch die ärztliche Redaktion.',
            style: context.labelSmall?.copyWith(
              color: context.gi.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Confidence extends StatelessWidget {
  const _Confidence({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Begriffliche Übereinstimmung mit dem Thema',
                style: context.labelSmall?.copyWith(
                  color: context.gi.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${(value * 100).round()} %',
              style: context.labelMedium?.copyWith(
                color: context.gi.textPrimary,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: context.gi.hairline,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.gi.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.flag});

  final TriageFlag flag;

  @override
  Widget build(BuildContext context) {
    final accent = switch (flag.severity) {
      TriageSeverity.blocker => context.gi.incorrect,
      TriageSeverity.warning => context.gi.warning,
      TriageSeverity.info => context.gi.textPrimary,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            flag.message,
            style: context.bodySmall?.copyWith(
              color: context.gi.textPrimary,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        MetaChip(label: flag.severity.label, accent: accent),
      ],
    );
  }
}
