import 'package:equatable/equatable.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/daily_case.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/models/guideline_citation.dart';

/// {@template library_image}
/// An image a contributor may build a case around.
///
/// Contributors pick from this library. They cannot upload.
///
/// That is a deliberate v1 boundary, not a missing feature: a physician
/// uploading their own endoscopy frame is uploading patient data, and a
/// consent pipeline is not something to improvise. Until one exists, the
/// only images in the app are ones already cleared for teaching use.
/// {@endtemplate}
class LibraryImage extends Equatable {
  /// {@macro library_image}
  const LibraryImage({
    required this.id,
    required this.asset,
    required this.label,
    required this.region,
    required this.credit,
  });

  /// Builds a [LibraryImage] from decoded JSON.
  factory LibraryImage.fromJson(Map<String, dynamic> json) => LibraryImage(
    id: json['id'] as String,
    asset: json['asset'] as String,
    label: json['label'] as String,
    region: GiRegion.parse(json['region'] as String?),
    credit: ImageCredit.fromJson(json['credit'] as Map<String, dynamic>),
  );

  /// Stable identifier.
  final String id;

  /// Path to the bundled image.
  final String asset;

  /// A neutral description, e.g. `Antrum, Übersicht`.
  ///
  /// Neutral on purpose: the picker label must not name a diagnosis, or the
  /// contributor is handed the answer to the case they are about to write.
  final String label;

  /// {@macro gi_region}
  final GiRegion region;

  /// {@macro image_credit}
  final ImageCredit credit;

  @override
  List<Object?> get props => [id, asset, label, region, credit];
}
