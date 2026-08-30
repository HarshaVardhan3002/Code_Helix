import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/progress/progress.dart';
import 'package:flutter_instagram_offline_first_clone/session/session.dart';
import 'package:flutter_instagram_offline_first_clone/settings/settings.dart';
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
      backgroundColor: context.gi.base,
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
                    const _Appearance(),
                    const SizedBox(height: AppSpacing.xxlg),
                    _SignOutButton(),
                  ],
                ),
                const StatusBarScrim(coversBackButton: true),
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
            color: context.gi.fill,
            border: Border.all(color: context.gi.hairline),
          ),
          child: Text(
            user.initials,
            style: context.titleLarge?.copyWith(
              color: context.gi.textPrimary,
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
                  color: context.gi.textPrimary,
                  fontWeight: AppFontWeight.semiBold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.affiliation,
                style: context.bodySmall?.copyWith(
                  color: context.gi.textSecondary,
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
        color: context.gi.fill,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: context.gi.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.headlineSmall?.copyWith(
              color: context.gi.textPrimary,
              fontWeight: AppFontWeight.semiBold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.labelMedium?.copyWith(
              color: context.gi.textPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            caption,
            style: context.labelSmall?.copyWith(
              color: context.gi.textSecondary,
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
            color: context.gi.textSecondary,
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
            color: context.gi.textSecondary,
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
                  color: context.gi.fill,
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  border: Border.all(
                    color: context.gi.hairline,
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
                          color: context.gi.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: context.gi.textSecondary,
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

/// The scheme picker.
///
/// Three segments rather than a switch, because the third state is the
/// default and the useful one: an endoscopy suite is a dark room and a ward
/// round is not, and the phone already knows which one the reader is standing
/// in. A two-way switch would force a choice the device can make better.
class _Appearance extends StatelessWidget {
  const _Appearance();

  @override
  Widget build(BuildContext context) {
    final gi = context.gi;
    final selected = context.watch<AppearanceCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DARSTELLUNG',
          style: context.labelSmall?.copyWith(
            color: gi.textSecondary,
            letterSpacing: 1.5,
            fontSize: 9.5,
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: gi.fill,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(color: gi.hairline),
          ),
          child: Row(
            children: [
              for (final mode in ThemeMode.values)
                Expanded(
                  child: _AppearanceOption(
                    mode: mode,
                    active: mode == selected,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({required this.mode, required this.active});

  final ThemeMode mode;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final gi = context.gi;

    return Semantics(
      button: true,
      selected: active,
      child: Tappable.faded(
        onTap: () => context.read<AppearanceCubit>().select(mode),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: active ? gi.action.withValues(alpha: 0.14) : null,
            borderRadius: BorderRadius.circular(AppSpacing.lg),
            border: Border.all(
              color: active ? gi.action : AppColors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(
                mode.icon,
                size: 19,
                color: active ? gi.action : gi.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                mode.label,
                style: context.labelMedium?.copyWith(
                  color: active ? gi.action : gi.textSecondary,
                  fontWeight: active
                      ? AppFontWeight.semiBold
                      : AppFontWeight.medium,
                ),
              ),
            ],
          ),
        ),
      ),
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
          border: Border.all(color: context.gi.hairline),
        ),
        child: Text(
          'Konto wechseln',
          style: context.titleSmall?.copyWith(
            color: context.gi.textPrimary,
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
            child: GlassSurface(
              level: GlassLevel.chip,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: context.gi.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
