import 'package:flutter/material.dart';

/// {@template gi_colors}
/// The GI Daily colour palette, as a [ThemeExtension].
///
/// Every colour the product surfaces use comes from here. Nothing in the
/// prototype may write a hex literal at a call site or reach for
/// `AppColors.white.withValues(...)` — that pattern is what made the first
/// build dark-only, because a hardcoded white cannot become a near-black when
/// the scheme flips.
///
/// ## The two families
///
/// Tokens split by what sits *behind* them, not by where they are used.
///
/// * The **surface** tokens ([base] … [warning]) describe chrome painted on
///   the app's own background. They invert between schemes.
/// * The **media** tokens ([onMediaPrimary] … [mediaScrim]) describe anything
///   painted over an endoscopy frame. They also flip, because in light mode
///   the frame is veiled with a white scrim rather than a black one — a
///   half-light mode that keeps a black scrim under white glass reads as a
///   bug, not as a theme.
///
/// Read it with [GiColorsX.gi] on [BuildContext].
/// {@endtemplate}
@immutable
class GiColors extends ThemeExtension<GiColors> {
  /// {@macro gi_colors}
  const GiColors({
    required this.base,
    required this.raised,
    required this.textPrimary,
    required this.textSecondary,
    required this.action,
    required this.correct,
    required this.incorrect,
    required this.warning,
    required this.hairline,
    required this.fill,
    required this.fillStrong,
    required this.onMediaPrimary,
    required this.onMediaSecondary,
    required this.onMediaHairline,
    required this.mediaScrim,
  });

  /// The dark scheme. Cool glacier-blue near-black.
  static const dark = GiColors(
    base: Color(0xFF000000),
    raised: Color(0xFF080F14),
    textPrimary: Color(0xFFE4EBF2),
    textSecondary: Color(0xFF9BAAB6),
    action: Color(0xFF3FA9F5),
    correct: Color(0xFF30D158),
    incorrect: Color(0xFFFF453A),
    warning: Color(0xFFFF9F0A),
    hairline: Color(0x24E4EBF2),
    fill: Color(0x0FE4EBF2),
    fillStrong: Color(0x1FE4EBF2),
    onMediaPrimary: Color(0xFFFFFFFF),
    onMediaSecondary: Color(0xC7FFFFFF),
    onMediaHairline: Color(0x3DFFFFFF),
    mediaScrim: Color(0xFF000000),
  );

  /// The light scheme. Cool glacier-blue near-white.
  static const light = GiColors(
    base: Color(0xFFFFFFFF),
    raised: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0B1620),
    textSecondary: Color(0xFF485A69),
    action: Color(0xFF0B6BB5),
    correct: Color(0xFF2E7D4F),
    incorrect: Color(0xFFC0392B),
    warning: Color(0xFFB26A00),
    hairline: Color(0x2E0B1620),
    fill: Color(0x0A0B1620),
    fillStrong: Color(0x140B1620),
    onMediaPrimary: Color(0xFF0B1620),
    onMediaSecondary: Color(0xC70B1620),
    onMediaHairline: Color(0x3D0B1620),
    mediaScrim: Color(0xFFFFFFFF),
  );

  /// The page background.
  final Color base;

  /// A panel, card or sheet lifted off [base].
  final Color raised;

  /// Body copy, headlines, anything that must be read.
  final Color textPrimary;

  /// Metadata, captions, labels, disabled states.
  final Color textSecondary;

  /// The one interactive accent. Links, selection, primary buttons.
  final Color action;

  /// A correct answer.
  final Color correct;

  /// A wrong answer.
  final Color incorrect;

  /// Something the reader must notice before acting — an unreviewed case, a
  /// triage finding, a missing citation field.
  final Color warning;

  /// The hairline that separates two surfaces of the same colour.
  final Color hairline;

  /// A barely-there wash used to group content inside a panel.
  final Color fill;

  /// The same wash, one step more present. Selected rows, filled chips.
  final Color fillStrong;

  /// Text painted over an endoscopy frame.
  final Color onMediaPrimary;

  /// Metadata painted over an endoscopy frame.
  final Color onMediaSecondary;

  /// A rim drawn over an endoscopy frame.
  final Color onMediaHairline;

  /// The colour the legibility gradient over a frame fades toward.
  ///
  /// Black in the dark scheme, white in the light one. The frame itself is
  /// never recoloured — clinical hue is information — it is only veiled.
  final Color mediaScrim;

  @override
  GiColors copyWith({
    Color? base,
    Color? raised,
    Color? textPrimary,
    Color? textSecondary,
    Color? action,
    Color? correct,
    Color? incorrect,
    Color? warning,
    Color? hairline,
    Color? fill,
    Color? fillStrong,
    Color? onMediaPrimary,
    Color? onMediaSecondary,
    Color? onMediaHairline,
    Color? mediaScrim,
  }) => GiColors(
    base: base ?? this.base,
    raised: raised ?? this.raised,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    action: action ?? this.action,
    correct: correct ?? this.correct,
    incorrect: incorrect ?? this.incorrect,
    warning: warning ?? this.warning,
    hairline: hairline ?? this.hairline,
    fill: fill ?? this.fill,
    fillStrong: fillStrong ?? this.fillStrong,
    onMediaPrimary: onMediaPrimary ?? this.onMediaPrimary,
    onMediaSecondary: onMediaSecondary ?? this.onMediaSecondary,
    onMediaHairline: onMediaHairline ?? this.onMediaHairline,
    mediaScrim: mediaScrim ?? this.mediaScrim,
  );

  @override
  GiColors lerp(covariant GiColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return GiColors(
      base: c(base, other.base),
      raised: c(raised, other.raised),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      action: c(action, other.action),
      correct: c(correct, other.correct),
      incorrect: c(incorrect, other.incorrect),
      warning: c(warning, other.warning),
      hairline: c(hairline, other.hairline),
      fill: c(fill, other.fill),
      fillStrong: c(fillStrong, other.fillStrong),
      onMediaPrimary: c(onMediaPrimary, other.onMediaPrimary),
      onMediaSecondary: c(onMediaSecondary, other.onMediaSecondary),
      onMediaHairline: c(onMediaHairline, other.onMediaHairline),
      mediaScrim: c(mediaScrim, other.mediaScrim),
    );
  }
}

/// Reads the [GiColors] for the current theme.
extension GiColorsX on BuildContext {
  /// {@macro gi_colors}
  ///
  /// Falls back to [GiColors.dark] rather than throwing, so a widget rendered
  /// under a bare `MaterialApp` in a test still paints.
  GiColors get gi => Theme.of(this).extension<GiColors>() ?? GiColors.dark;
}
