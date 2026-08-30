import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template topic_page}
/// A readable page assembled from guideline recommendations.
///
/// Every section carries its own citation, because a claim you can act on is a
/// claim you can trace. Quotes stay short — the copyright in the guideline
/// text sits with the AWMF author collective, and this app is a pointer to it,
/// not a replacement for it.
///
/// "Teste mich dazu" sits at the bottom, after the reading. Here the order is
/// the opposite of Heute's on purpose: you came to look something up, so being
/// quizzed before you were allowed to read would be obstruction, not
/// retrieval practice.
/// {@endtemplate}
class TopicPage extends StatelessWidget {
  /// {@macro topic_page}
  const TopicPage({required this.topicId, super.key});

  /// The topic to show.
  final String topicId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SurfaceBackground(
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, state) {
            final topic = state.catalog.topicById(topicId);
            if (topic == null) {
              return const Center(
                child: Text(
                  'Thema nicht gefunden.',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            }

            final cases = topic.caseIds
                .map(state.catalog.caseById)
                .whereType<DailyCase>()
                .toList(growable: false);

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
                    Row(
                      children: [
                        MetaChip(label: topic.region.label),
                        if (topic.unverified) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const UnverifiedChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      topic.title,
                      style: context.headlineSmall?.copyWith(
                        color: AppColors.white,
                        height: 1.2,
                        fontWeight: AppFontWeight.semiBold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      topic.summary,
                      style: context.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.62),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xlg),
                    for (final section in topic.sections) ...[
                      _Section(section: section),
                      const SizedBox(height: AppSpacing.xlg),
                    ],
                    if (cases.isNotEmpty) _TestMe(cases: cases),
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

class _Section extends StatelessWidget {
  const _Section({required this.section});

  final TopicSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: context.titleSmall?.copyWith(
            color: AppColors.white,
            height: 1.3,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          section.body,
          style: context.bodyMedium?.copyWith(
            color: AppColors.white.withValues(alpha: 0.86),
            height: 1.54,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CitationBlock(citation: section.citation),
      ],
    );
  }
}

/// The way from reading into retrieval.
///
/// Pulls cases that were written and approved for this topic. Nothing is
/// generated on demand — there is no model in the request path, so this cannot
/// be slow, wrong or offline while a jury watches.
class _TestMe extends StatelessWidget {
  const _TestMe({required this.cases});

  final List<DailyCase> cases;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: AppColors.white.withValues(alpha: 0.1)),
        const SizedBox(height: AppSpacing.xlg),
        Text(
          'Teste mich dazu',
          style: context.titleSmall?.copyWith(
            color: AppColors.white,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${cases.length} ${cases.length == 1 ? 'Fall' : 'Fälle'} '
          'zu diesem Thema.',
          style: context.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final entry in cases) ...[
          Tappable.faded(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CasePage(dailyCase: entry),
              ),
            ),
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.lg),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      // The question, never the headline. Listing the answer
                      // here would defeat the exercise before it starts.
                      entry.quiz.question,
                      style: context.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.88),
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.white.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
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
