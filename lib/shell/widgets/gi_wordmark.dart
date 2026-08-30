import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template gi_wordmark}
/// The GI Daily wordmark.
///
/// Set in Newsreader, which appears in exactly three places in the app: here,
/// on the clinical question, and on quoted guideline text. Everything else is
/// Fira Sans. A serif used sparingly reads as an editorial voice; a serif used
/// everywhere reads as a template.
///
/// `GI` is set in the action blue and `Daily` in the primary text colour, so
/// the mark carries the product's one accent without needing a logo mark
/// beside it. There is no glyph, no icon and no mascot — the brief is explicit
/// that this is for Fachärzte and must not read as childish.
/// {@endtemplate}
class GiWordmark extends StatelessWidget {
  /// {@macro gi_wordmark}
  const GiWordmark({this.size = 21, super.key});

  /// The wordmark's font size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final gi = context.gi;
    final base = GiSerif.wordmark.copyWith(fontSize: size);

    return Semantics(
      header: true,
      label: 'GI Daily',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'GI', style: base.copyWith(color: gi.action)),
              TextSpan(
                text: ' Daily',
                style: base.copyWith(color: gi.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
