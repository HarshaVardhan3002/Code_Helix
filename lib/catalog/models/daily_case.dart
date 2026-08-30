import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/guideline_citation.dart';

/// {@template quiz_focus}
/// The three question types named in the brief.
///
/// A case asks exactly one of them. They are not difficulty tiers; they are
/// different clinical questions about the same image.
/// {@endtemplate}
enum QuizFocus {
  /// "Was ist das für eine Diagnose?"
  diagnose('Diagnose'),

  /// "Was sehen wir endoskopisch?"
  befund('Endoskopischer Befund'),

  /// "Was wäre die richtige Strategie zur Behandlung?"
  strategie('Therapiestrategie');

  const QuizFocus(this.label);

  /// The German label shown in the interface.
  final String label;

  /// Parses a [QuizFocus] from its serialised name.
  ///
  /// Falls back to [QuizFocus.diagnose] for an unknown value so that one bad
  /// content entry cannot take the daily case down mid-demo.
  static QuizFocus parse(String? value) => QuizFocus.values.firstWhere(
    (focus) => focus.name == value,
    orElse: () => QuizFocus.diagnose,
  );
}

/// {@template gi_region}
/// The anatomical region a case or topic belongs to.
///
/// Doubles as the Bibliothek's primary filter — it is how a
/// gastroenterologist actually narrows a question.
/// {@endtemplate}
enum GiRegion {
  /// Oesophagus.
  oesophagus('Ösophagus'),

  /// Stomach.
  magen('Magen'),

  /// Duodenum and small bowel.
  duodenum('Duodenum & Dünndarm'),

  /// Colon and rectum.
  kolon('Kolon & Rektum'),

  /// Liver and portal system.
  leber('Leber'),

  /// Pancreas and biliary tract.
  pankreas('Pankreas & Gallenwege');

  const GiRegion(this.label);

  /// The German label shown in the interface.
  final String label;

  /// Parses a [GiRegion] from its serialised name.
  static GiRegion parse(String? value) => GiRegion.values.firstWhere(
    (region) => region.name == value,
    orElse: () => GiRegion.kolon,
  );
}

/// {@template quiz_option}
/// One selectable answer, with the reason it is right or wrong.
/// {@endtemplate}
class QuizOption extends Equatable {
  /// {@macro quiz_option}
  const QuizOption({
    required this.id,
    required this.label,
    required this.rationale,
  });

  /// Builds a [QuizOption] from decoded JSON.
  factory QuizOption.fromJson(Map<String, dynamic> json) => QuizOption(
    id: json['id'] as String,
    label: json['label'] as String,
    rationale: json['rationale'] as String,
  );

  /// Stable identifier, used to match against the correct answer.
  final String id;

  /// The answer text as the user reads it.
  final String label;

  /// Why this option is right, or why it is wrong.
  ///
  /// Every option carries one and every one is shown on reveal. Explaining
  /// only the option the user picked leaves the other three as guesses they
  /// got away with.
  final String rationale;

  /// Serialises this option.
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'rationale': rationale,
  };

  @override
  List<Object?> get props => [id, label, rationale];
}

/// {@template case_quiz}
/// The question. Everything the user sees before they commit.
/// {@endtemplate}
class CaseQuiz extends Equatable {
  /// {@macro case_quiz}
  const CaseQuiz({
    required this.focus,
    required this.question,
    required this.options,
    required this.correctOptionId,
    required this.takeaway,
  });

  /// Builds a [CaseQuiz] from decoded JSON.
  factory CaseQuiz.fromJson(Map<String, dynamic> json) => CaseQuiz(
    focus: QuizFocus.parse(json['focus'] as String?),
    question: json['question'] as String,
    options: (json['options'] as List<dynamic>)
        .map((option) => QuizOption.fromJson(option as Map<String, dynamic>))
        .toList(growable: false),
    correctOptionId: json['correctOptionId'] as String,
    takeaway: json['takeaway'] as String,
  );

  /// {@macro quiz_focus}
  final QuizFocus focus;

  /// The question itself.
  final String question;

  /// The selectable answers, in presentation order.
  final List<QuizOption> options;

  /// The [QuizOption.id] of the correct answer.
  final String correctOptionId;

  /// The one line worth remembering tomorrow.
  final String takeaway;

  /// The correct option.
  QuizOption get correctOption =>
      options.firstWhere((option) => option.id == correctOptionId);

  /// Whether [optionId] is the correct answer.
  bool isCorrect(String optionId) => optionId == correctOptionId;

  /// Serialises this quiz.
  Map<String, dynamic> toJson() => {
    'focus': focus.name,
    'question': question,
    'options': options.map((option) => option.toJson()).toList(),
    'correctOptionId': correctOptionId,
    'takeaway': takeaway,
  };

  @override
  List<Object?> get props => [
    focus,
    question,
    options,
    correctOptionId,
    takeaway,
  ];
}

/// {@template daily_case}
/// One day's teaching case.
///
/// The atomic unit of the product: one image, one question, one answer key.
///
/// ## The split that matters
///
/// This class is deliberately divided into what may be shown **before** the
/// user commits to an answer and what may only be shown **after**.
///
/// Before: [imageAsset], [quiz], [region].
/// After: [revealTitle], [explanation], [citation], [imageCredit],
/// every [QuizOption.rationale], and [CaseQuiz.takeaway].
///
/// [revealTitle] is named the way it is so that using it on the pre-commit
/// surface looks wrong at the call site. It usually contains the diagnosis. A
/// headline over the image turns a retrieval exercise into reading
/// comprehension, and retrieval is the entire mechanism.
/// {@endtemplate}
class DailyCase extends Equatable {
  /// {@macro daily_case}
  const DailyCase({
    required this.id,
    required this.imageAsset,
    required this.imageCredit,
    required this.region,
    required this.quiz,
    required this.revealTitle,
    required this.explanation,
    required this.citation,
    this.topicId,
    this.contributedBy,
    this.unverified = true,
  });

  /// Builds a [DailyCase] from decoded JSON.
  factory DailyCase.fromJson(Map<String, dynamic> json) => DailyCase(
    id: json['id'] as String,
    imageAsset: json['imageAsset'] as String,
    imageCredit: ImageCredit.fromJson(
      json['imageCredit'] as Map<String, dynamic>,
    ),
    region: GiRegion.parse(json['region'] as String?),
    quiz: CaseQuiz.fromJson(json['quiz'] as Map<String, dynamic>),
    revealTitle: json['revealTitle'] as String,
    explanation: json['explanation'] as String,
    citation: GuidelineCitation.fromJson(
      json['citation'] as Map<String, dynamic>,
    ),
    topicId: json['topicId'] as String?,
    contributedBy: json['contributedBy'] as String?,
    unverified: json['unverified'] as bool? ?? true,
  );

  /// Stable identifier.
  final String id;

  /// Path to the bundled full-bleed image.
  ///
  /// An asset, never a URL. The app has to work with no network at all.
  final String imageAsset;

  /// Attribution for [imageAsset]. Shown on reveal only.
  final ImageCredit imageCredit;

  /// {@macro gi_region}
  final GiRegion region;

  /// {@macro case_quiz}
  final CaseQuiz quiz;

  /// The headline, shown **only after the user commits**.
  ///
  /// Usually names the diagnosis. See the class docs.
  final String revealTitle;

  /// The full teaching text, shown **only after the user commits**.
  final String explanation;

  /// {@macro guideline_citation}
  final GuidelineCitation citation;

  /// The Bibliothek topic this case belongs to, if any.
  ///
  /// Drives the "Zum Thema in der Bibliothek" link on the reveal, which is the
  /// one sanctioned way out of the daily and into unlimited reading.
  final String? topicId;

  /// The physician who submitted the case, where it came from a member.
  final String? contributedBy;

  /// Whether this content is still placeholder and unreviewed.
  ///
  /// Defaults to `true` deliberately. Nothing unreviewed may reach a user
  /// looking like cleared clinical guidance, so the interface badges it while
  /// it is.
  final bool unverified;

  @override
  List<Object?> get props => [
    id,
    imageAsset,
    imageCredit,
    region,
    quiz,
    revealTitle,
    explanation,
    citation,
    topicId,
    contributedBy,
    unverified,
  ];
}
