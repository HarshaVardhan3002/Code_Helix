part of 'catalog_cubit.dart';

/// Loading state of the catalog.
enum CatalogStatus {
  /// Nothing requested yet.
  initial,

  /// Content is being read from the bundle.
  loading,

  /// The catalog is available.
  ready,

  /// The bundled content could not be read.
  failure,
}

/// {@template catalog_state}
/// The catalog, plus whether a submission is currently being screened.
/// {@endtemplate}
class CatalogState extends Equatable {
  /// {@macro catalog_state}
  const CatalogState({
    required this.status,
    required this.catalog,
    this.screening = false,
    this.lastApprovedId,
  });

  /// The state before anything has been requested.
  const CatalogState.initial()
    : this(status: CatalogStatus.initial, catalog: const Catalog.empty());

  /// {@macro catalog_status}
  final CatalogStatus status;

  /// {@macro catalog}
  final Catalog catalog;

  /// Whether a submission is in the screening pass right now.
  final bool screening;

  /// The case id most recently approved into the rotation.
  ///
  /// Lets Heute point at what just changed, which is the payoff of the whole
  /// contribution loop.
  final String? lastApprovedId;

  /// Returns a copy with the given fields replaced.
  CatalogState copyWith({
    CatalogStatus? status,
    Catalog? catalog,
    bool? screening,
    String? lastApprovedId,
  }) => CatalogState(
    status: status ?? this.status,
    catalog: catalog ?? this.catalog,
    screening: screening ?? this.screening,
    lastApprovedId: lastApprovedId ?? this.lastApprovedId,
  );

  @override
  List<Object?> get props => [status, catalog, screening, lastApprovedId];
}
