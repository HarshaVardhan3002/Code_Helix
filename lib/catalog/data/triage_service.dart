import 'package:flutter_instagram_offline_first_clone/catalog/models/models.dart';

/// {@template triage_service}
/// Screens a submission before it reaches an editor.
///
/// ## What it actually does
///
/// It is rule-based and deterministic. It checks the submission's own
/// structure — is exactly one option correct, does every option carry a
/// rationale, is the citation complete — and scores how much vocabulary the
/// case shares with the guideline topic the author cited. Nothing is
/// generated, nothing is fetched, and the same input always produces the same
/// report.
///
/// That is a deliberate choice, not a shortcut. A model in the request path is
/// a thing that can be slow, wrong or offline while a jury watches. The
/// roadmap is a model that reads the guideline text itself; the interface,
/// the report shape and the editor's gate are already built for it and do not
/// change when it arrives.
///
/// ## What it must never do
///
/// Decide. [TriageReport] has no approved state to return. Screening narrows
/// what a physician has to look at; it never replaces the looking.
/// {@endtemplate}
class TriageService {
  /// {@macro triage_service}
  const TriageService();

  /// How long the screening pass appears to take.
  ///
  /// Long enough to read as work, short enough to survive a live demo.
  static const Duration _duration = Duration(milliseconds: 1400);

  /// Screens [submitted] against [topic] and reports what a human should check.
  Future<TriageReport> screen({
    required DailyCase submitted,
    GuidelineTopic? topic,
  }) async {
    await Future<void>.delayed(_duration);

    final flags = <TriageFlag>[
      ..._structuralFlags(submitted),
      ..._citationFlags(submitted.citation),
    ]..sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return TriageReport(
      matched: submitted.citation,
      confidence: _overlap(submitted, topic),
      flags: List<TriageFlag>.unmodifiable(flags),
    );
  }

  List<TriageFlag> _structuralFlags(DailyCase submitted) {
    final flags = <TriageFlag>[];
    final quiz = submitted.quiz;

    final labels = quiz.options.map((option) => option.label.trim()).toList();
    if (labels.toSet().length != labels.length) {
      flags.add(
        const TriageFlag(
          severity: TriageSeverity.blocker,
          message: 'Zwei Antwortoptionen sind identisch.',
        ),
      );
    }

    if (!quiz.options.any((option) => option.id == quiz.correctOptionId)) {
      flags.add(
        const TriageFlag(
          severity: TriageSeverity.blocker,
          message: 'Keine der Optionen ist als richtig markiert.',
        ),
      );
    }

    for (final option in quiz.options) {
      if (option.rationale.trim().length < 40) {
        flags.add(
          TriageFlag(
            severity: TriageSeverity.warning,
            message:
                'Die Begründung zu "${_short(option.label)}" ist sehr kurz. '
                'Jede Option wird nach der Antwort angezeigt.',
          ),
        );
      }
    }

    if (submitted.explanation.trim().length < 120) {
      flags.add(
        const TriageFlag(
          severity: TriageSeverity.warning,
          message: 'Der Falltext ist kurz für Facharztniveau.',
        ),
      );
    }

    if (quiz.takeaway.trim().isEmpty) {
      flags.add(
        const TriageFlag(
          severity: TriageSeverity.warning,
          message: 'Es fehlt die Merksatz-Zeile.',
        ),
      );
    }

    return flags;
  }

  List<TriageFlag> _citationFlags(GuidelineCitation citation) {
    final flags = <TriageFlag>[];

    if (citation.recommendation == null) {
      flags.add(
        const TriageFlag(
          severity: TriageSeverity.warning,
          message:
              'Die Empfehlungsnummer fehlt. Ohne sie ist die Antwort nicht '
              'nachvollziehbar.',
        ),
      );
    }
    if (citation.register == null) {
      flags.add(
        const TriageFlag(
          severity: TriageSeverity.info,
          message: 'AWMF-Registernummer nicht hinterlegt.',
        ),
      );
    }

    return flags;
  }

  /// Vocabulary overlap between the submission and the cited topic.
  ///
  /// A blunt retrieval score, not a judgement: it says how much of the
  /// guideline topic's language the case actually uses. Low overlap means the
  /// case may be citing a recommendation it does not really rest on, which is
  /// precisely the thing worth putting in front of an editor.
  double _overlap(DailyCase submitted, GuidelineTopic? topic) {
    if (topic == null) return 0;

    final topicTerms = _terms(
      topic.sections.map((section) => section.body).join(' '),
    );
    if (topicTerms.isEmpty) return 0;

    final caseTerms = _terms(
      '${submitted.explanation} ${submitted.quiz.question} '
      '${submitted.quiz.options.map((option) => option.rationale).join(' ')}',
    );
    if (caseTerms.isEmpty) return 0;

    final shared = caseTerms.intersection(topicTerms).length;
    return (shared / caseTerms.length).clamp(0.0, 1.0);
  }

  Set<String> _terms(String text) => text
      .toLowerCase()
      .split(RegExp('[^a-zA-ZäöüÄÖÜß]+'))
      .where((word) => word.length > 5)
      .toSet();

  String _short(String label) =>
      label.length <= 32 ? label : '${label.substring(0, 32)}…';
}
