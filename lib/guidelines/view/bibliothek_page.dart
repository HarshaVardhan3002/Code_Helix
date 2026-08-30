import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/guidelines/view/topic_page.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template bibliothek_page}
/// Browse the guideline topics.
///
/// **Info first**, the opposite of Heute — you cannot be tested on something
/// you came here to look up. Reading is unlimited here, which is exactly why
/// this is one tap away and never the landing screen.
///
/// This is the Explore grid repurposed, and the semantic change matters more
/// than the layout: it is not discovery of the unknown, it is a finite,
/// curated set of already-published topics. Get that wrong and you have built
/// a social app with quizzes in it.
/// {@endtemplate}
class BibliothekPage extends StatefulWidget {
  /// {@macro bibliothek_page}
  const BibliothekPage({super.key});

  @override
  State<BibliothekPage> createState() => _BibliothekPageState();
}

class _BibliothekPageState extends State<BibliothekPage> {
  GiRegion? _region;

  @override
  Widget build(BuildContext context) {
    return SurfaceBackground(
      child: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          final topics = _region == null
              ? state.catalog.topics
              : state.catalog.topics
                    .where((topic) => topic.region == _region)
                    .toList(growable: false);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: ShellMetrics.topInset(context)),
              ),
              const SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: _RegionFilter(
                  selected: _region,
                  regions: state.catalog.topics
                      .map((topic) => topic.region)
                      .toSet()
                      .toList(growable: false),
                  onSelected: (region) => setState(() => _region = region),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.76,
                      ),
                  itemCount: topics.length,
                  itemBuilder: (context, index) =>
                      _TopicCard(topic: topics[index]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: ShellMetrics.bottomInset(context)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bibliothek',
            style: context.headlineSmall?.copyWith(
              color: context.gi.textPrimary,
              fontWeight: AppFontWeight.semiBold,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nachschlagen statt geprüft werden. Jede Aussage mit ihrer Quelle.',
            style: context.bodyMedium?.copyWith(
              color: context.gi.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionFilter extends StatelessWidget {
  const _RegionFilter({
    required this.selected,
    required this.regions,
    required this.onSelected,
  });

  final GiRegion? selected;
  final List<GiRegion> regions;
  final ValueChanged<GiRegion?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        children: [
          _FilterChip(
            label: 'Alle',
            active: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final region in regions) ...[
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: region.label,
              active: selected == region,
              onTap: () => onSelected(region),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.gi.textPrimary.withValues(alpha: active ? 0.16 : 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(
            color: active ? context.gi.action : context.gi.hairline,
          ),
        ),
        child: Text(
          label,
          style: context.labelMedium?.copyWith(
            color: context.gi.textPrimary.withValues(alpha: active ? 1 : 0.68),
            fontWeight: active
                ? AppFontWeight.semiBold
                : AppFontWeight.regular,
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});

  final GuidelineTopic topic;

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TopicPage(topicId: topic.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.gi.fill,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(color: context.gi.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetaChip(label: topic.region.label),
            const SizedBox(height: AppSpacing.md),
            Text(
              topic.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.titleSmall?.copyWith(
                color: context.gi.textPrimary,
                height: 1.26,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Not Expanded: a Text inside a box shorter than its maxLines
            // clips at the box edge instead of ellipsising, which cuts a line
            // of German in half. Bound the lines, then push the citation down.
            Text(
              topic.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall?.copyWith(
                color: context.gi.textSecondary,
                height: 1.4,
              ),
            ),
            const Spacer(),
            const SizedBox(height: AppSpacing.sm),
            CitationBlock(citation: topic.citation, dense: true),
          ],
        ),
      ),
    );
  }
}
