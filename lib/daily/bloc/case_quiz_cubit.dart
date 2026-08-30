import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';

part 'case_quiz_state.dart';

/// {@template case_quiz_cubit}
/// Drives one case from untouched to answered.
///
/// The evaluation beat is theatre. The verdict and every rationale were
/// bundled with the case; the pause exists so the answer reads as considered
/// rather than as a lookup. Nothing is generated and nothing is fetched.
///
/// A case that was already answered on a previous run starts revealed, with no
/// pause and no animation — the pause is for the moment of commitment, and
/// replaying it on every visit would be a lie.
/// {@endtemplate}
class CaseQuizCubit extends Cubit<CaseQuizState> {
  /// {@macro case_quiz_cubit}
  CaseQuizCubit({
    required CaseQuiz quiz,
    String? committedOptionId,
    this.onCommitted,
  }) : _quiz = quiz,
       super(
         committedOptionId == null
             ? const CaseQuizState.idle()
             : CaseQuizState(
                 phase: CaseQuizPhase.revealed,
                 selectedId: committedOptionId,
                 correct: quiz.isCorrect(committedOptionId),
               ),
       );

  /// Long enough to read as deliberation, short enough that a busy clinician
  /// does not feel stalled — and short enough to survive a live demo.
  static const Duration _evaluation = Duration(milliseconds: 900);

  final CaseQuiz _quiz;

  /// Called once, when an answer is first committed.
  ///
  /// This is where the answer is persisted. It fires before the reveal, so a
  /// user who closes the app mid-reveal still comes back to an answered case.
  final void Function(String optionId)? onCommitted;

  /// Commits [optionId] as the answer.
  ///
  /// Ignored once an answer is in. One considered attempt is what makes the
  /// verdict mean anything; a retry loop turns it into guessing.
  Future<void> answer(String optionId) async {
    if (state.phase != CaseQuizPhase.idle) return;

    onCommitted?.call(optionId);
    emit(CaseQuizState(phase: CaseQuizPhase.evaluating, selectedId: optionId));

    await Future<void>.delayed(_evaluation);
    if (isClosed) return;

    emit(
      CaseQuizState(
        phase: CaseQuizPhase.revealed,
        selectedId: optionId,
        correct: _quiz.isCorrect(optionId),
      ),
    );
  }
}
