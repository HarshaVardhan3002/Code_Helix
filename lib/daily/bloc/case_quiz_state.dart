part of 'case_quiz_cubit.dart';

/// Where a case's question currently stands.
enum CaseQuizPhase {
  /// Nothing committed yet.
  idle,

  /// An answer is in and the verdict is being prepared.
  evaluating,

  /// The verdict and every rationale are available.
  revealed,
}

/// {@template case_quiz_state}
/// The answer the user committed to and what came of it.
/// {@endtemplate}
class CaseQuizState extends Equatable {
  /// {@macro case_quiz_state}
  const CaseQuizState({
    required this.phase,
    this.selectedId,
    this.correct = false,
  });

  /// The untouched state.
  const CaseQuizState.idle() : this(phase: CaseQuizPhase.idle);

  /// {@macro case_quiz_phase}
  final CaseQuizPhase phase;

  /// The [QuizOption.id] the user committed to, if any.
  final String? selectedId;

  /// Whether that option was correct.
  ///
  /// Only meaningful once [phase] is [CaseQuizPhase.revealed].
  final bool correct;

  /// Whether the answer and its explanations may be shown.
  ///
  /// Everything that could give the answer away is gated on this.
  bool get isRevealed => phase == CaseQuizPhase.revealed;

  /// Whether the options should stop accepting taps.
  bool get isLocked => phase != CaseQuizPhase.idle;

  @override
  List<Object?> get props => [phase, selectedId, correct];
}
