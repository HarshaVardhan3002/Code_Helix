import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/widgets/widgets.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template case_page}
/// One case on its own screen.
///
/// Used by the archive, by Schwierige Fälle, and by "Teste mich dazu" in the
/// Bibliothek. Same rule as Heute: the question first, the teaching only after
/// a committed answer. An old case is still a case — the rule does not expire
/// when the day does.
///
/// The only difference from Heute is the sign-off. "Das war's für heute"
/// belongs to today and would be a lie on an archived case.
/// {@endtemplate}
class CasePage extends StatelessWidget {
  /// {@macro case_page}
  const CasePage({
    required this.dailyCase,
    this.dayLabel,
    this.onOpenTopic,
    super.key,
  });

  /// The case to show.
  final DailyCase dailyCase;

  /// Where it sits in the calendar, e.g. `Gestern`.
  final String? dayLabel;

  /// Opens the case's Bibliothek topic.
  final ValueChanged<String>? onOpenTopic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gi.base,
      body: CaseScope(
        dailyCase: dailyCase,
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Stage(dailyCase: dailyCase),
                ),
                SliverToBoxAdapter(
                  child: CaseReveal(
                    dailyCase: dailyCase,
                    onOpenTopic: onOpenTopic,
                    showClosingLine: false,
                  ),
                ),
              ],
            ),
            const StatusBarScrim(),
            _BackBar(dayLabel: dayLabel),
          ],
        ),
      ),
    );
  }
}

/// The same hero shape as Heute: a bounded frame, the panel overlapping its
/// lower edge, and the page ground continuing behind the rest of the panel.
/// See `HeutePage` for why the image is not a fill.
class _Stage extends StatelessWidget {
  const _Stage({required this.dailyCase});

  final DailyCase dailyCase;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context).height;
    final topInset = ShellMetrics.topInset(context);
    final headroom = math.max(viewport * 0.40, topInset + 150);
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
              padding: const EdgeInsets.all(AppSpacing.md),
              child: CaseQuestionPanel(dailyCase: dailyCase),
            ),
          ],
        ),
      ],
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar({required this.dayLabel});

  final String? dayLabel;

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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: context.gi.textPrimary,
                  ),
                  if (dayLabel != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      dayLabel!,
                      style: context.labelMedium?.copyWith(
                        color: context.gi.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
