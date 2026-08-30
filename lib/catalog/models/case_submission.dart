import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/daily_case.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/guideline_citation.dart';

/// How serious a triage finding is.
enum TriageSeverity {
  /// Worth knowing, not worth acting on.
  info('Hinweis'),

  /// The editor should look closely at this before approving.
  warning('Prüfen'),

  /// Cannot be approved until it is resolved.
  blocker('Blocker');

  const TriageSeverity(this.label);

  /// The German label shown in the interface.
  final String label;
}

/// {@template triage_flag}
/// One thing the screening pass wants a human to look at.
/// {@endtemplate}
class TriageFlag extends Equatable {
  /// {@macro triage_flag}
  const TriageFlag({required this.severity, required this.message});

  /// {@macro triage_severity}
  final TriageSeverity severity;

  /// What the editor needs to know, in one sentence.
  final String message;

  @override
  List<Object?> get props => [severity, message];
}

/// {@template triage_report}
/// The result of screening a submission against its cited guideline.
///
/// ## What this is not
///
/// It is not an answer, and it never decides anything. It reports what the
/// submission appears to match and what a human should check. Approval is a
/// physician's act, every time — [TriageReport] has no "approved" state to
/// return.
///
/// In this build the screening is scripted and bundled with the content.
/// Nothing is generated while a user waits, so there is no model in the
/// request path and nothing to go wrong on stage.
/// {@endtemplate}
class TriageReport extends Equatable {
  /// {@macro triage_report}
  const TriageReport({
    required this.matched,
    required this.confidence,
    required this.flags,
  });

  /// The recommendation the submission appears to rest on.
  final GuidelineCitation matched;

  /// How closely it matched, between 0 and 1.
  final double confidence;

  /// What a human should look at, most serious first.
  final List<TriageFlag> flags;

  /// Whether anything blocks approval outright.
  bool get hasBlocker =>
      flags.any((flag) => flag.severity == TriageSeverity.blocker);

  @override
  List<Object?> get props => [matched, confidence, flags];
}

/// Where a submission stands.
enum SubmissionStatus {
  /// Being written. Not yet sent.
  draft('Entwurf'),

  /// Sent and screened, waiting on an editor.
  inReview('In Redaktion'),

  /// Approved by an editor and scheduled into the rotation.
  approved('Freigegeben'),

  /// Sent back by an editor.
  rejected('Abgelehnt');

  const SubmissionStatus(this.label);

  /// The German label shown in the interface.
  final String label;
}

/// {@template case_submission}
/// A case written by a society member, on its way into the rotation.
///
/// This is the engine. Two physicians reviewing is a ceiling; a society of
/// thousands writing, with review as the gate, is a supply line.
/// {@endtemplate}
class CaseSubmission extends Equatable {
  /// {@macro case_submission}
  const CaseSubmission({
    required this.id,
    required this.authorName,
    required this.submittedCase,
    required this.status,
    this.triage,
    this.editorNote,
    this.scheduledLabel,
  });

  /// Stable identifier.
  final String id;

  /// The physician who wrote it.
  final String authorName;

  /// The case itself, in the same shape it will be served in.
  final DailyCase submittedCase;

  /// {@macro submission_status}
  final SubmissionStatus status;

  /// {@macro triage_report}
  ///
  /// Null while the submission is still a draft.
  final TriageReport? triage;

  /// What the editor said when they acted on it.
  final String? editorNote;

  /// When an approved case will appear, e.g. `Morgen`.
  final String? scheduledLabel;

  /// Returns a copy with the given fields replaced.
  CaseSubmission copyWith({
    SubmissionStatus? status,
    TriageReport? triage,
    String? editorNote,
    String? scheduledLabel,
  }) => CaseSubmission(
    id: id,
    authorName: authorName,
    submittedCase: submittedCase,
    status: status ?? this.status,
    triage: triage ?? this.triage,
    editorNote: editorNote ?? this.editorNote,
    scheduledLabel: scheduledLabel ?? this.scheduledLabel,
  );

  @override
  List<Object?> get props => [
    id,
    authorName,
    submittedCase,
    status,
    triage,
    editorNote,
    scheduledLabel,
  ];
}
