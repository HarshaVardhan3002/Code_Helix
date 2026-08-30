import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// {@template progress_state}
/// Which cases have been answered, and with what.
///
/// One map is the whole model. Accuracy, the streak and the Schwierige Fälle
/// list are all derived from it against the catalog, so there is no second
/// copy of the truth to fall out of sync.
/// {@endtemplate}
class ProgressState extends Equatable {
  /// {@macro progress_state}
  const ProgressState({this.answers = const {}});

  /// Restores state written by [toJson].
  factory ProgressState.fromJson(Map<String, dynamic> json) => ProgressState(
    answers: (json['answers'] as Map<String, dynamic>? ?? const {}).map(
      (caseId, optionId) => MapEntry(caseId, optionId as String),
    ),
  );

  /// Case id to the option id the user committed to.
  final Map<String, String> answers;

  /// Whether [caseId] has been answered.
  bool hasAnswered(String caseId) => answers.containsKey(caseId);

  /// The option committed to for [caseId], if any.
  String? answerFor(String caseId) => answers[caseId];

  /// Serialises this state.
  Map<String, dynamic> toJson() => {'answers': answers};

  @override
  List<Object?> get props => [answers];
}

/// {@template progress_cubit}
/// Remembers what the user has already answered.
///
/// Persisted, because the product's promise is one case per day: reopening the
/// app must not hand you the same question again as if you had never seen it.
/// Storage is local — `HydratedStorage` writes to the device and nothing
/// leaves it.
///
/// There is no unanswer. A committed answer is the point of the exercise; a
/// retry button would turn one considered attempt into guessing until it goes
/// green.
/// {@endtemplate}
class ProgressCubit extends HydratedCubit<ProgressState> {
  /// {@macro progress_cubit}
  ProgressCubit() : super(const ProgressState());

  /// Records that [caseId] was answered with [optionId].
  ///
  /// Ignored if the case already has an answer.
  void record({required String caseId, required String optionId}) {
    if (state.hasAnswered(caseId)) return;
    emit(ProgressState(answers: {...state.answers, caseId: optionId}));
  }

  /// Clears everything. Used between demo runs.
  void reset() => emit(const ProgressState());

  @override
  ProgressState fromJson(Map<String, dynamic> json) =>
      ProgressState.fromJson(json);

  @override
  Map<String, dynamic> toJson(ProgressState state) => state.toJson();
}
