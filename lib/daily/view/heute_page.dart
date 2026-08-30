import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/view/case_page.dart';
import 'package:flutter_instagram_offline_first_clone/daily/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell_metrics.dart';

/// {@template heute_page}
/// The landing surface. One case, today's, and nothing above it.
///
/// ## The two rules this screen exists to enforce
///
/// **Quiz first.** The first screenful is the image and the question. No
/// headline, no summary, no tag, no caption. The teaching is below the fold
/// and gated on a committed answer, so it cannot be read first.
///
/// **One per day.** There is no pager and no swipe to the next case. Tomorrow
/// is unreachable; the archive below is finite and already published. An
/// endless feed would kill the product, which is why the earlier build's
/// case-to-case pager was removed rather than adapted.
/// {@endtemplate}
class HeutePage extends StatelessWidget {
  /// {@macro heute_page}
  const HeutePage({required this.onOpenTopic, super.key});

  /// Opens a Bibliothek topic from the reveal.
  final ValueChanged<String> onOpenTopic;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        final today = state.catalog.today;

        if (state.status == CatalogStatus.failure) {
          return const _Message('Die Fälle konnten nicht geladen werden.');
        }
        if (today == null) {
          return state.status == CatalogStatus.ready
              ? const _Message('Für heute ist kein Fall veröffentlicht.')
              : const Center(child: AppCircularProgress(AppColors.white));
        }

        return CaseScope(
          dailyCase: today,
          builder: (context) => _TodayView(
            dailyCase: today,
            archive: state.catalog.archive,
            onOpenTopic: onOpenTopic,
          ),
        );
      },
    );
  }
}

class _TodayView extends StatelessWidget {
  const _TodayView({
    required this.dailyCase,
    required this.archive,
    required this.onOpenTopic,
  });

  final DailyCase dailyCase;
  final List<DailyCase> archive;
  final ValueChanged<String> onOpenTopic;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Stage(dailyCase: dailyCase)),
        SliverToBoxAdapter(
          child: CaseReveal(
            dailyCase: dailyCase,
            onOpenTopic: onOpenTopic,
          ),
        ),
        SliverToBoxAdapter(
          child: ArchiveSection(
            cases: archive,
            onOpenCase: (entry) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CasePage(
                  dailyCase: entry,
                  dayLabel: dayLabelFor(archive.indexOf(entry) + 1),
                  onOpenTopic: onOpenTopic,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: ShellMetrics.bottomInset(context)),
        ),
      ],
    );
  }
}

/// The first screenful: the image, and the question over it.
///
/// The image fills the whole stage; a spacer above the panel decides how much
/// of it stays uncovered. The stack sizes itself to the panel, so a case with
/// four long options grows the stage instead of pushing its own question off
/// the top of the screen — which is exactly what a fixed viewport-height stage
/// did.
class _Stage extends StatelessWidget {
  const _Stage({required this.dailyCase});

  final DailyCase dailyCase;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context).height;
    // Never less than this much image, whatever the panel does. Below roughly
    // this, the image stops reading as the subject and becomes a header.
    final imageHeadroom = math.max(
      viewport * 0.42,
      ShellMetrics.topInset(context) + 150,
    );

    return Stack(
      children: [
        Positioned.fill(child: CaseImage(dailyCase: dailyCase)),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: imageHeadroom),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                ShellMetrics.bottomInset(context),
              ),
              child: CaseQuestionPanel(dailyCase: dailyCase),
            ),
          ],
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxlg),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.bodyMedium?.copyWith(
            color: AppColors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
