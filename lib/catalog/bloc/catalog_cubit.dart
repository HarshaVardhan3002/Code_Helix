import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/data/catalog_repository.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/data/triage_service.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/models.dart';

part 'catalog_state.dart';

/// {@template catalog_cubit}
/// Holds the catalog and the submissions moving through it.
///
/// Provided once above the shell, because the contribution loop crosses every
/// surface: a case submitted in Beitragen is approved in Beitragen's editor
/// queue and then has to appear in Heute. Keeping one owner of that state is
/// what makes the loop demonstrable in ninety seconds instead of a story
/// about what would happen.
///
/// Mutations are in memory only. Nothing is written back to the bundle, so a
/// restart returns to the seeded state — which is exactly the behaviour you
/// want between demo runs.
/// {@endtemplate}
class CatalogCubit extends Cubit<CatalogState> {
  /// {@macro catalog_cubit}
  CatalogCubit({
    required CatalogRepository repository,
    TriageService triage = const TriageService(),
  }) : _repository = repository,
       _triage = triage,
       super(const CatalogState.initial());

  final CatalogRepository _repository;
  final TriageService _triage;

  /// Loads the seeded catalog.
  Future<void> load() async {
    emit(state.copyWith(status: CatalogStatus.loading));
    try {
      final catalog = await _repository.load();
      emit(state.copyWith(status: CatalogStatus.ready, catalog: catalog));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: CatalogStatus.failure));
    }
  }

  /// Screens [submitted] and puts it in front of an editor.
  ///
  /// Returns the submission so the contributor can be shown its report
  /// straight away.
  Future<CaseSubmission> submit({
    required DailyCase submitted,
    required String authorName,
  }) async {
    final pending = CaseSubmission(
      id: 'submission-${DateTime.now().microsecondsSinceEpoch}',
      authorName: authorName,
      submittedCase: submitted,
      status: SubmissionStatus.draft,
    );

    emit(state.copyWith(screening: true));

    final report = await _triage.screen(
      submitted: submitted,
      topic: submitted.topicId == null
          ? null
          : state.catalog.topicById(submitted.topicId!),
    );

    final screened = pending.copyWith(
      status: SubmissionStatus.inReview,
      triage: report,
    );

    emit(
      state.copyWith(
        screening: false,
        catalog: state.catalog.copyWith(
          submissions: [screened, ...state.catalog.submissions],
        ),
      ),
    );

    return screened;
  }

  /// Approves [submissionId] and schedules it as tomorrow's case.
  ///
  /// The approved case is inserted at the head of the rotation. In a build
  /// with no clock, position zero is what a reader sees, so an approved case
  /// takes that place immediately rather than waiting for a date to turn over.
  ///
  /// The product rule is one new case per day; the prototype cannot show that
  /// without waiting a day, so it publishes at once. Every string around the
  /// approval says so — nothing promises "morgen" and then shows it now.
  void approve(String submissionId, {String? note}) {
    final submission = _find(submissionId);
    if (submission == null) return;

    final approved = submission.copyWith(
      status: SubmissionStatus.approved,
      editorNote: note,
      scheduledLabel: 'als nächster Fall des Tages',
    );

    emit(
      state.copyWith(
        catalog: state.catalog.copyWith(
          cases: [
            approved.submittedCase.copyWithUnverified(unverified: false),
            ...state.catalog.cases,
          ],
          submissions: _replace(approved),
        ),
        lastApprovedId: approved.submittedCase.id,
      ),
    );
  }

  /// Sends [submissionId] back to its author.
  void reject(String submissionId, {String? note}) {
    final submission = _find(submissionId);
    if (submission == null) return;

    emit(
      state.copyWith(
        catalog: state.catalog.copyWith(
          submissions: _replace(
            submission.copyWith(
              status: SubmissionStatus.rejected,
              editorNote: note,
            ),
          ),
        ),
      ),
    );
  }

  CaseSubmission? _find(String id) {
    for (final submission in state.catalog.submissions) {
      if (submission.id == id) return submission;
    }
    return null;
  }

  List<CaseSubmission> _replace(CaseSubmission updated) => [
    for (final submission in state.catalog.submissions)
      if (submission.id == updated.id) updated else submission,
  ];
}

/// Lets an approved case shed its unreviewed badge.
extension on DailyCase {
  DailyCase copyWithUnverified({required bool unverified}) => DailyCase(
    id: id,
    imageAsset: imageAsset,
    imageCredit: imageCredit,
    region: region,
    quiz: quiz,
    revealTitle: revealTitle,
    explanation: explanation,
    citation: citation,
    topicId: topicId,
    contributedBy: contributedBy,
    unverified: unverified,
  );
}
