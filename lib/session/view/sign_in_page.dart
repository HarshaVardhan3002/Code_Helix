import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/session/bloc/session_cubit.dart';
import 'package:flutter_instagram_offline_first_clone/session/models/session_user.dart';
import 'package:flutter_instagram_offline_first_clone/shell/widgets/widgets.dart';

/// {@template sign_in_page}
/// The account list.
///
/// Three seeded accounts, one tap each. No password field, no validation, no
/// reset flow — none of that appears in a ten-minute demo, and building it
/// would buy nothing.
///
/// What it does buy: the role switch becomes a visible, deliberate act on
/// stage. The jury sees a physician sign in, submit a case, and an editor sign
/// in and approve it, rather than a debug toggle flipping somewhere.
/// {@endtemplate}
class SignInPage extends StatelessWidget {
  /// {@macro sign_in_page}
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gi.base,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Glass takes its appearance from what is behind it, so a flat
          // background would render the cards as nothing at all. This is the
          // same gradient the other surfaces refract, and it has to follow the
          // scheme: light glass over a hardcoded dark ground puts near-black
          // type on a near-black page.
          const SurfaceBackground(child: SizedBox.expand()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  const Center(child: GiWordmark(size: 36)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Täglich ein Fall aus den Leitlinien.',
                    textAlign: TextAlign.center,
                    style: context.bodyMedium?.copyWith(
                      color: context.gi.textSecondary,
                    ),
                  ),
                  const Spacer(flex: 3),
                  Text(
                    'DEMO-ZUGÄNGE',
                    style: context.labelSmall?.copyWith(
                      color: context.gi.textSecondary,
                      letterSpacing: 1.6,
                      fontSize: 10,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final account in DemoAccounts.all) ...[
                    _AccountCard(account: account),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  const Spacer(flex: 2),
                  Text(
                    'Prototyp. Fiktive Konten, keine Passwörter. '
                    'Es werden keine Daten an einen Server gesendet.',
                    textAlign: TextAlign.center,
                    style: context.labelSmall?.copyWith(
                      color: context.gi.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final SessionUser account;

  @override
  Widget build(BuildContext context) {
    return Tappable.scaled(
      onTap: () => context.read<SessionCubit>().signIn(account),
      child: GlassSurface(
        level: GlassLevel.rail,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _Initial(letter: account.initials),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: context.titleSmall?.copyWith(
                      color: context.gi.textPrimary,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.affiliation,
                    style: context.labelSmall?.copyWith(
                      color: context.gi.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            RoleChip(role: account.role),
          ],
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.gi.fill,
        border: Border.all(color: context.gi.hairline),
      ),
      child: Text(
        letter,
        style: context.titleSmall?.copyWith(
          color: context.gi.textPrimary,
          fontWeight: AppFontWeight.semiBold,
        ),
      ),
    );
  }
}

/// {@template role_chip}
/// The small label naming a role.
/// {@endtemplate}
class RoleChip extends StatelessWidget {
  /// {@macro role_chip}
  const RoleChip({required this.role, super.key});

  /// {@macro user_role}
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: context.gi.fill,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: context.gi.hairline),
      ),
      child: Text(
        role.label.toUpperCase(),
        style: context.labelSmall?.copyWith(
          color: context.gi.textPrimary,
          letterSpacing: 1,
          fontSize: 9.5,
          fontWeight: AppFontWeight.semiBold,
        ),
      ),
    );
  }
}
