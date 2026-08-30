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
              : Center(child: AppCircularProgress(context.gi.action));
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
    final topInset = ShellMetrics.topInset(context);
    // Never less than this much bare image, whatever the panel does. Below
    // roughly this, the image stops reading as the subject and becomes a
    // header.
    final headroom = math.max(viewport * 0.40, topInset + 150);
    // The frame is a fixed hero, not a fill. A stack that grows with the panel
    // is 2000 px tall on a phone, and filling that from a square source makes
    // BoxFit.cover upscale it by half and crop away two thirds of its width —
    // the finding ends up outside the frame and what is left is soft. Bounding
    // the image means it is always downscaled, and always the same crop.
    final imageHeight = math.max(viewport * 0.56, topInset + 260);

    return Stack(
      children: [
        // Floor under the stack. A Stack takes its size from its
        // non-positioned children only, so without this it collapsed to the
        // height of the panel column and hard-clipped the frame partway down
        // — a straight line across the screen where the photograph stopped.
        SizedBox(height: imageHeight, width: double.infinity),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: imageHeight,
          child: CaseImage(dailyCase: dailyCase),
        ),
        // What the lower half of the panel refracts. Glass over nothing
        // renders as nothing, so the ground has to continue past the frame.
        Positioned(
          top: imageHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: ColoredBox(color: context.gi.base),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: headroom),
            Padding(
              // Not the nav inset: the last sliver already leaves that, and
              // paying it twice opened a screen-third of dead space between
              // the panel and the archive.
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.lg,
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
            color: context.gi.textPrimary,
          ),
        ),
      ),
    );
  }
}
