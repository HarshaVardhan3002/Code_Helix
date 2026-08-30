import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_instagram_offline_first_clone/catalog/models/models.dart';

/// {@template catalog}
/// Everything the app serves, loaded once.
/// {@endtemplate}
class Catalog extends Equatable {
  /// {@macro catalog}
  const Catalog({
    required this.cases,
    required this.topics,
    required this.images,
    required this.submissions,
  });

  /// An empty catalog.
  const Catalog.empty()
    : this(
        cases: const [],
        topics: const [],
        images: const [],
        submissions: const [],
      );

  /// Published cases, today's first.
  ///
  /// Order *is* the calendar: index 0 is today, 1 is yesterday, and so on.
  /// Deriving the day from position rather than from a stored date means the
  /// newest case reads as "Heute" whenever the app is opened — a demo weeks
  /// after the content was written must not open on "vor 19 Tagen".
  final List<DailyCase> cases;

  /// Bibliothek topics.
  final List<GuidelineTopic> topics;

  /// Images a contributor may build a case around.
  final List<LibraryImage> images;

  /// Submissions in flight, newest first.
  final List<CaseSubmission> submissions;

  /// The case for today, if there is one.
  DailyCase? get today => cases.isEmpty ? null : cases.first;

  /// Everything published before today.
  List<DailyCase> get archive =>
      cases.length <= 1 ? const [] : cases.sublist(1);

  /// The case with [id], or null.
  DailyCase? caseById(String id) {
    for (final entry in cases) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  /// The topic with [id], or null.
  GuidelineTopic? topicById(String id) {
    for (final topic in topics) {
      if (topic.id == id) return topic;
    }
    return null;
  }

  /// Submissions waiting on an editor.
  List<CaseSubmission> get reviewQueue => submissions
      .where((submission) => submission.status == SubmissionStatus.inReview)
      .toList(growable: false);

  /// Returns a copy with the given fields replaced.
  Catalog copyWith({
    List<DailyCase>? cases,
    List<GuidelineTopic>? topics,
    List<LibraryImage>? images,
    List<CaseSubmission>? submissions,
  }) => Catalog(
    cases: cases ?? this.cases,
    topics: topics ?? this.topics,
    images: images ?? this.images,
    submissions: submissions ?? this.submissions,
  );

  @override
  List<Object?> get props => [cases, topics, images, submissions];
}

/// {@template catalog_repository}
/// Source of everything the app serves.
///
/// Deliberately narrow. The seam is small enough that a real backend can be
/// dropped in behind it without touching a single widget.
/// {@endtemplate}
// A deliberate seam, not an accident.
// ignore: one_member_abstracts
abstract interface class CatalogRepository {
  /// Loads the catalog.
  Future<Catalog> load();
}

/// {@template local_catalog_repository}
/// Reads the catalog from bundled JSON assets.
///
/// This is the make-do backend. The venue's wifi is unreliable and the
/// prototype has to survive having no network at all, so the content ships
/// inside the APK. Nothing here touches Supabase, PowerSync or Firebase.
/// {@endtemplate}
class LocalCatalogRepository implements CatalogRepository {
  /// {@macro local_catalog_repository}
  const LocalCatalogRepository();

  @override
  Future<Catalog> load() async {
    final cases = await _decode('assets/daily/cases.json', 'cases');
    final topics = await _decode('assets/daily/topics.json', 'topics');
    final images = await _decode('assets/daily/images.json', 'images');

    return Catalog(
      cases: cases.map(DailyCase.fromJson).toList(growable: false),
      topics: topics.map(GuidelineTopic.fromJson).toList(growable: false),
      images: images.map(LibraryImage.fromJson).toList(growable: false),
      submissions: const [],
    );
  }

  Future<List<Map<String, dynamic>>> _decode(String asset, String key) async {
    final raw = await rootBundle.loadString(asset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded[key] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
