import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/contribution/contribution.dart';
import 'package:flutter_instagram_offline_first_clone/daily/daily.dart';
import 'package:flutter_instagram_offline_first_clone/guidelines/guidelines.dart';
import 'package:flutter_instagram_offline_first_clone/profile/profile.dart';
import 'package:flutter_instagram_offline_first_clone/session/session.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell_metrics.dart';
import 'package:flutter_instagram_offline_first_clone/shell/widgets/widgets.dart';

/// The three surfaces.
enum ShellTab {
  /// The daily case.
  heute('Heute', Icons.today_outlined, Icons.today_rounded),

  /// Guideline topics.
  bibliothek('Bibliothek', Icons.menu_book_outlined, Icons.menu_book_rounded),

  /// Case submission and review.
  beitragen('Beitragen', Icons.edit_note_outlined, Icons.edit_note_rounded);

  const ShellTab(this.label, this.icon, this.activeIcon);

  /// The German label.
  final String label;

  /// Icon when inactive.
  final IconData icon;

  /// Icon when active.
  final IconData activeIcon;
}

/// {@template shell_page}
/// The app frame: three surfaces, a floating glass bar at each end.
///
/// Heute is the landing surface and stays the landing surface. Bibliothek is
/// one tap away — reachable, never in the way. Anything that lets a user read
/// their way to today's answer before committing has to be at least one
/// deliberate act away, and a tab is exactly that.
/// {@endtemplate}
class ShellPage extends StatefulWidget {
  /// {@macro shell_page}
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  ShellTab _tab = ShellTab.heute;

  void _openBibliothek(String topicId) {
    setState(() => _tab = ShellTab.bibliothek);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TopicPage(topicId: topicId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppColors.transparent,
        systemNavigationBarColor: AppColors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            IndexedStack(
              index: _tab.index,
              children: [
                HeutePage(onOpenTopic: _openBibliothek),
                const BibliothekPage(),
                const BeitragenPage(),
              ],
            ),
            const StatusBarScrim(),
            const _ShellTopBar(),
            _ShellNavBar(
              current: _tab,
              onSelected: (tab) => setState(() => _tab = tab),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellTopBar extends StatelessWidget {
  const _ShellTopBar();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionCubit>().state;

    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: GlassSurface(
            level: GlassLevel.bar,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: SizedBox(
              height: ShellMetrics.topBarHeight - AppSpacing.lg,
              child: Row(
                children: [
                  const AppLogo(width: 88, height: 24, color: AppColors.white),
                  const Spacer(),
                  if (user != null) _ProfileButton(user: user),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.user});

  final SessionUser user;

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
      ),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.22)),
        ),
        child: Text(
          user.initials,
          style: context.labelMedium?.copyWith(
            color: AppColors.white.withValues(alpha: 0.9),
            fontWeight: AppFontWeight.semiBold,
          ),
        ),
      ),
    );
  }
}

class _ShellNavBar extends StatelessWidget {
  const _ShellNavBar({required this.current, required this.onSelected});

  final ShellTab current;
  final ValueChanged<ShellTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: GlassSurface(
            level: GlassLevel.rail,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: SizedBox(
              height: ShellMetrics.navHeight - AppSpacing.sm,
              child: Row(
                children: [
                  for (final tab in ShellTab.values)
                    Expanded(
                      child: _NavItem(
                        tab: tab,
                        active: tab == current,
                        onTap: () => onSelected(tab),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final ShellTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colour = AppColors.white.withValues(alpha: active ? 1 : 0.55);

    return Tappable.faded(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? tab.activeIcon : tab.icon, size: 21, color: colour),
          const SizedBox(height: 3),
          Text(
            tab.label,
            style: context.labelSmall?.copyWith(
              color: colour,
              fontSize: 10,
              letterSpacing: 0.2,
              fontWeight: active
                  ? AppFontWeight.semiBold
                  : AppFontWeight.regular,
            ),
          ),
        ],
      ),
    );
  }
}
