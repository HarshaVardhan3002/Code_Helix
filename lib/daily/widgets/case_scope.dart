import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/daily/bloc/bloc.dart';
import 'package:flutter_instagram_offline_first_clone/progress/progress.dart';

/// {@template case_scope}
/// Provides the quiz state for one case, wired to persisted progress.
///
/// Seeds the cubit from what the user already committed, so a case answered
/// yesterday opens revealed instead of asking again, and writes the answer
/// back the moment it is committed.
///
/// Keyed by case id, so moving between cases never carries one case's answer
/// into another.
/// {@endtemplate}
class CaseScope extends StatelessWidget {
  /// {@macro case_scope}
  const CaseScope({
    required this.dailyCase,
    required this.builder,
    super.key,
  });

  /// The case to scope.
  final DailyCase dailyCase;

  /// Builds the subtree that reads the quiz state.
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CaseQuizCubit>(
      key: ValueKey(dailyCase.id),
      create: (_) {
        // read, not watch: the cubit is seeded once at creation. Watching
        // would rebuild and recreate it the instant an answer is recorded,
        // throwing away the evaluation beat that was mid-flight.
        final progress = context.read<ProgressCubit>();
        return CaseQuizCubit(
          quiz: dailyCase.quiz,
          committedOptionId: progress.state.answerFor(dailyCase.id),
          onCommitted: (optionId) => progress.record(
            caseId: dailyCase.id,
            optionId: optionId,
          ),
        );
      },
      child: Builder(builder: builder),
    );
  }
}
