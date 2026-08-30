import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/progress/bloc/progress_cubit.dart';

/// {@template progress_summary}
/// What the raw answer map means, read against the catalog.
///
/// Derived on demand rather than stored, so it cannot drift from the answers
/// it summarises.
/// {@endtemplate}
class ProgressSummary {
  /// {@macro progress_summary}
  ProgressSummary({required this.progress, required this.catalog});

  /// {@macro progress_state}
  final ProgressState progress;

  /// {@macro catalog}
  final Catalog catalog;

  /// Cases answered at all.
  Iterable<DailyCase> get answered =>
      catalog.cases.where((entry) => progress.hasAnswered(entry.id));

  /// Cases answered wrong — the Schwierige Fälle list.
  ///
  /// Auto-populated. Bookmarking is not a thing the user has to remember to
  /// do; the cases worth redoing are exactly the ones they got wrong.
  List<DailyCase> get difficult => catalog.cases
      .where(
        (entry) =>
            progress.hasAnswered(entry.id) &&
            !entry.quiz.isCorrect(progress.answerFor(entry.id)!),
      )
      .toList(growable: false);

  /// How many were answered correctly.
  int get correctCount => answered
      .where((entry) => entry.quiz.isCorrect(progress.answerFor(entry.id)!))
      .length;

  /// How many were answered at all.
  int get answeredCount => answered.length;

  /// Share answered correctly, between 0 and 1. Zero when nothing is answered.
  double get accuracy =>
      answeredCount == 0 ? 0 : correctCount / answeredCount;

  /// Consecutive days answered, counting back from today.
  ///
  /// Position in [Catalog.cases] is the calendar, so this walks from index 0
  /// until it hits a day that was skipped. A plain number — no flame, no
  /// badge, nothing that turns a study habit into a game.
  int get streak {
    var count = 0;
    for (final entry in catalog.cases) {
      if (!progress.hasAnswered(entry.id)) break;
      count++;
    }
    return count;
  }
}
