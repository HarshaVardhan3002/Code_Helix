import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/daily_case.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/guideline_citation.dart';

/// {@template topic_section}
/// One readable chunk of a guideline topic.
///
/// Each carries its own [citation]. That is the point of the Bibliothek: a
/// claim you can act on is a claim you can trace back to a recommendation.
/// {@endtemplate}
class TopicSection extends Equatable {
  /// {@macro topic_section}
  const TopicSection({
    required this.heading,
    required this.body,
    required this.citation,
  });

  /// Builds a [TopicSection] from decoded JSON.
  factory TopicSection.fromJson(Map<String, dynamic> json) => TopicSection(
    heading: json['heading'] as String,
    body: json['body'] as String,
    citation: GuidelineCitation.fromJson(
      json['citation'] as Map<String, dynamic>,
    ),
  );

  /// The section heading.
  final String heading;

  /// The section text.
  final String body;

  /// {@macro guideline_citation}
  final GuidelineCitation citation;

  @override
  List<Object?> get props => [heading, body, citation];
}

/// {@template guideline_topic}
/// A readable page assembled from guideline recommendations.
///
/// The Bibliothek is **info first**: you cannot be tested on something you
/// came here to look up. Reading is unlimited here, which is exactly why it
/// is one tap away and never the landing screen.
/// {@endtemplate}
class GuidelineTopic extends Equatable {
  /// {@macro guideline_topic}
  const GuidelineTopic({
    required this.id,
    required this.title,
    required this.region,
    required this.summary,
    required this.sections,
    required this.citation,
    this.caseIds = const [],
    this.unverified = true,
  });

  /// Builds a [GuidelineTopic] from decoded JSON.
  factory GuidelineTopic.fromJson(Map<String, dynamic> json) => GuidelineTopic(
    id: json['id'] as String,
    title: json['title'] as String,
    region: GiRegion.parse(json['region'] as String?),
    summary: json['summary'] as String,
    sections: (json['sections'] as List<dynamic>)
        .map(
          (section) => TopicSection.fromJson(section as Map<String, dynamic>),
        )
        .toList(growable: false),
    citation: GuidelineCitation.fromJson(
      json['citation'] as Map<String, dynamic>,
    ),
    caseIds: (json['caseIds'] as List<dynamic>? ?? const []).cast<String>(),
    unverified: json['unverified'] as bool? ?? true,
  );

  /// Stable identifier.
  final String id;

  /// The topic name.
  final String title;

  /// {@macro gi_region}
  final GiRegion region;

  /// One line of orientation, shown on the browse grid.
  final String summary;

  /// The readable body, in order.
  final List<TopicSection> sections;

  /// The guideline this topic is drawn from.
  final GuidelineCitation citation;

  /// Cases that can be pulled by "Teste mich dazu".
  ///
  /// Pre-generated and already approved. Nothing is written on demand, so
  /// there is no model anywhere in the request path.
  final List<String> caseIds;

  /// Whether this content is still placeholder and unreviewed.
  final bool unverified;

  @override
  List<Object?> get props => [
    id,
    title,
    region,
    summary,
    sections,
    citation,
    caseIds,
    unverified,
  ];
}
