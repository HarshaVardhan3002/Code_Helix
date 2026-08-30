import 'package:equatable/equatable.dart';

/// {@template guideline_citation}
/// Where an answer comes from.
///
/// Every revealed answer in the app carries one. It is not decoration: the
/// product's entire claim is that the answer key is the society's own
/// guideline, and a claim without a traceable source is just an opinion in a
/// nicer font.
///
/// [register], [version] and [recommendation] are nullable on purpose. A field
/// that is not yet confirmed renders as a visible placeholder rather than
/// being filled with something plausible. A citation that looks real and is
/// not is worse than no citation at all — a reader can act on it, and in this
/// domain acting on a wrong recommendation causes harm.
/// {@endtemplate}
class GuidelineCitation extends Equatable {
  /// {@macro guideline_citation}
  const GuidelineCitation({
    required this.guideline,
    this.register,
    this.version,
    this.recommendation,
  });

  /// Builds a [GuidelineCitation] from decoded JSON.
  factory GuidelineCitation.fromJson(Map<String, dynamic> json) =>
      GuidelineCitation(
        guideline: json['guideline'] as String,
        register: json['register'] as String?,
        version: json['version'] as String?,
        recommendation: json['recommendation'] as String?,
      );

  /// The guideline's name, e.g. `S3-Leitlinie Kolorektales Karzinom`.
  final String guideline;

  /// The AWMF register number, e.g. `021-007OL`.
  ///
  /// Null where it has not been confirmed.
  final String? register;

  /// The guideline version or year.
  final String? version;

  /// The recommendation number the answer rests on.
  final String? recommendation;

  /// Whether every field is filled.
  ///
  /// Drives the placeholder badge in the citation block.
  bool get isComplete =>
      register != null && version != null && recommendation != null;

  /// The register line, with an explicit marker where the number is missing.
  String get registerLabel =>
      register == null ? 'AWMF-Register [offen]' : 'AWMF $register';

  /// The version line, with an explicit marker where it is missing.
  String get versionLabel => version == null ? 'Version [offen]' : version!;

  /// The recommendation line, with an explicit marker where it is missing.
  String get recommendationLabel => recommendation == null
      ? 'Empfehlung [offen]'
      : 'Empfehlung $recommendation';

  @override
  List<Object?> get props => [guideline, register, version, recommendation];
}

/// {@template image_credit}
/// Attribution for a case image.
///
/// Shown on reveal, never before — the source can give the answer away.
/// {@endtemplate}
class ImageCredit extends Equatable {
  /// {@macro image_credit}
  const ImageCredit({required this.source, this.licence});

  /// Builds an [ImageCredit] from decoded JSON.
  factory ImageCredit.fromJson(Map<String, dynamic> json) => ImageCredit(
    source: json['source'] as String,
    licence: json['licence'] as String?,
  );

  /// Who the image belongs to.
  final String source;

  /// The licence it is used under, where one applies.
  final String? licence;

  /// The single line rendered under a revealed case.
  String get label => licence == null ? source : '$source · $licence';

  @override
  List<Object?> get props => [source, licence];
}
