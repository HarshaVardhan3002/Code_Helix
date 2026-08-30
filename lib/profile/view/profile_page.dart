import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/progress/progress.dart';
import 'package:flutter_instagram_offline_first_clone/session/session.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';

/// {@template profile_page}
/// Minimal and private.
///
/// Not a public identity page: there is no follower count, no avatar as
/// identity, no way for anyone else to look at it. What it holds is what the
/// user alone needs — how consistent they have been, how accurate, what they
/// got wrong, and what they have submitted.
///
/// The streak is a plain number. No flame, no badge, no confetti. The brief
/// ruled out childishness in writing, and a streak that shouts is exactly the
/// mechanic it was ruling out.
/// {@endtemplate}
class ProfilePage extends StatelessWidget {
  /// {@macro profile_page}
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SurfaceBackground(
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (context, catalogState) {
            final progress = context.watch<ProgressCubit>().state;
            final summary = ProgressSummary(
              progress: progress,
              catalog: catalogState.catalog,
            );
            final submissions = catalogState.catalog.submissions
                .where((entry) => entry.authorName == user?.name)
                .length;

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
                    if (user != null) _Identity(user: user),
                    const SizedBox(height: AppSpacing.xlg),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            value: '${summary.streak}',
                            label: summary.streak == 1 ? 'Tag' : 'Tage',
                            caption: 'in Folge',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _Stat(
                            value: summary.answeredCount == 0
                                ? '—'
                                : '${(summary.accuracy * 100).round()} %',
                            label: 'richtig',
                            caption:
                                '${summary.correctCount} von '
                                '${summary.answeredCount}',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _Stat(
                            value: '$submissions',
                            label: submissions == 1
                                ? 'Einreichung'
                                : 'Einreichungen',
                            caption: 'von dir',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxlg),
                    _DifficultCases(cases: summary.difficult),
                    const SizedBox(height: AppSpacing.xxlg),
                    _SignOutButton(),
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

class _Identity extends StatelessWidget {
  const _Identity({required this.user});

  final SessionUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withValues(alpha: 0.09),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            user.initials,
            style: context.titleLarge?.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: context.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: AppFontWeight.semiBold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.affiliation,
                style: context.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              RoleChip(role: user.role),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.caption,
  });

  final String value;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.headlineSmall?.copyWith(
              color: AppColors.white,
              fontWeight: AppFontWeight.semiBold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.labelMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            caption,
            style: context.labelSmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// {@template difficult_cases}
/// The cases answered wrong, to redo.
///
/// The bookmark feature repurposed, and auto-populated: the cases worth going
/// back to are exactly the ones that were missed, and nobody has to remember
/// to tag them.
/// {@endtemplate}
class _DifficultCases extends StatelessWidget {
  const _DifficultCases({required this.cases});

  final List<DailyCase> cases;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SCHWIERIGE FÄLLE',
          style: context.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.45),
            letterSpacing: 1.5,
            fontSize: 9.5,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          cases.isEmpty
              ? 'Noch nichts danebengegangen.'
              : 'Falsch beantwortet — hier liegt der Lerngewinn.',
          style: context.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.5),
          ),
        ),
        if (cases.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          for (final entry in cases) ...[
            Tappable.faded(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CasePage(dailyCase: entry),
                ),
              ),
              borderRadius: BorderRadius.circular(AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.revealTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.88),
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.white.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () {
        context.read<SessionCubit>().signOut();
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          'Konto wechseln',
          style: context.titleSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.9),
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
