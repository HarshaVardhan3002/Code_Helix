import 'package:flutter/material.dart';

/// {@template gi_text_styles}
/// The two typefaces GI Daily runs on.
///
/// **Fira Sans** carries the interface: every label, control, answer option,
/// piece of metadata and paragraph of body copy. It is a humanist sans with a
/// large x-height and unambiguous letterforms, which is what long German
/// compounds at 13 px on a phone need.
///
/// **Newsreader** carries exactly three things, and nothing else:
///
/// 1. the GI Daily wordmark,
/// 2. the clinical question,
/// 3. quoted guideline text.
///
/// The restriction is the point. A serif appearing anywhere else turns into
/// decoration; used only for the question and the quotation, it marks the two
/// moments where the reader is looking at the society's words rather than at
/// the app's. Do not reach for [GiSerif] for a headline, a card title or a
/// section label.
///
/// Newsreader ships from Google Fonts only as a variable font. The four faces
/// bundled here are static instances cut from it, with `opsz` pinned to the
/// size each face is actually used at.
/// {@endtemplate}
abstract final class GiType {
  static const _package = 'app_ui';

  /// The interface family.
  static const sans = 'FiraSans';

  /// The editorial family. See [GiSerif].
  static const serif = 'Newsreader';

  static const TextStyle _sans = TextStyle(
    package: _package,
    fontFamily: sans,
    decoration: TextDecoration.none,
    textBaseline: TextBaseline.alphabetic,
  );

  /// The app's [TextTheme].
  ///
  /// Sizes are tuned for a phone held at reading distance with German medical
  /// vocabulary in them: slightly tighter than Material's defaults at the
  /// display end, slightly looser in body line height.
  ///
  /// [color] is applied to every slot, so the same scale serves both schemes.
  static TextTheme textTheme(Color color) {
    TextStyle s(double size, double height, FontWeight weight, [double? ls]) =>
        _sans.copyWith(
          fontSize: size,
          height: height,
          fontWeight: weight,
          letterSpacing: ls,
          color: color,
        );

    return TextTheme(
      displayLarge: s(40, 1.1, FontWeight.w600, -0.8),
      displayMedium: s(34, 1.14, FontWeight.w600, -0.6),
      displaySmall: s(29, 1.18, FontWeight.w600, -0.4),
      headlineLarge: s(27, 1.2, FontWeight.w600, -0.3),
      headlineMedium: s(24, 1.22, FontWeight.w600, -0.2),
      headlineSmall: s(21, 1.26, FontWeight.w600, -0.1),
      titleLarge: s(23, 1.24, FontWeight.w600, -0.2),
      titleMedium: s(18, 1.32, FontWeight.w600),
      titleSmall: s(15.5, 1.36, FontWeight.w600, 0.05),
      bodyLarge: s(16, 1.52, FontWeight.w400),
      bodyMedium: s(14.5, 1.56, FontWeight.w400),
      bodySmall: s(13, 1.48, FontWeight.w400, 0.05),
      labelLarge: s(14.5, 1.2, FontWeight.w500, 0.1),
      labelMedium: s(12.5, 1.25, FontWeight.w500, 0.2),
      labelSmall: s(11, 1.3, FontWeight.w500, 0.3),
    );
  }
}

/// {@macro gi_text_styles}
abstract final class GiSerif {
  static const TextStyle _base = TextStyle(
    package: 'app_ui',
    fontFamily: GiType.serif,
    decoration: TextDecoration.none,
    textBaseline: TextBaseline.alphabetic,
  );

  /// The GI Daily wordmark in the top bar.
  static const TextStyle wordmark = TextStyle(
    package: 'app_ui',
    fontFamily: GiType.serif,
    fontSize: 21,
    height: 1.1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// The clinical question, asked over the frame.
  ///
  /// The one line on the first screen the reader has to weigh. Set larger and
  /// looser than any sans title in the app so it reads as the subject of the
  /// screen rather than as a caption on the image.
  static const TextStyle question = TextStyle(
    package: 'app_ui',
    fontFamily: GiType.serif,
    fontSize: 22,
    height: 1.34,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  /// Quoted guideline text.
  ///
  /// Used only for words that belong to the guideline itself. App prose about
  /// a guideline stays in Fira Sans.
  static TextStyle quotation = _base.copyWith(
    fontSize: 16.5,
    height: 1.62,
    fontWeight: FontWeight.w400,
  );
}
