import 'package:equatable/equatable.dart';

/// {@template user_role}
/// What a person is allowed to do.
///
/// Three roles, because the product is a supply line: someone reads, someone
/// writes, someone approves. Nothing here is a permission system — it gates
/// which surface Beitragen shows and nothing else.
/// {@endtemplate}
enum UserRole {
  /// Reads the daily case and the Bibliothek.
  reader('Leser:in'),

  /// A verified physician who may submit cases.
  contributor('Autor:in'),

  /// A physician editor who approves or returns submissions.
  editor('Redaktion');

  const UserRole(this.label);

  /// The German label shown in the interface.
  final String label;
}

/// {@template session_user}
/// Who is currently using the app.
/// {@endtemplate}
class SessionUser extends Equatable {
  /// {@macro session_user}
  const SessionUser({
    required this.id,
    required this.name,
    required this.affiliation,
    required this.role,
  });

  /// Stable identifier.
  final String id;

  /// Display name.
  final String name;

  /// Where they work, shown under the name.
  final String affiliation;

  /// {@macro user_role}
  final UserRole role;

  /// Whether this account may submit cases.
  bool get canContribute =>
      role == UserRole.contributor || role == UserRole.editor;

  /// Whether this account may approve submissions.
  bool get canEdit => role == UserRole.editor;

  /// Initial of the surname, for the profile chip.
  String get initials {
    final words = name
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 1 && !word.endsWith('.'))
        .toList();
    if (words.isEmpty) return '?';
    return words.last.substring(0, 1).toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, affiliation, role];
}

/// The three accounts seeded for the demo.
///
/// Fictional, and labelled as such in the interface. They exist so the
/// contribution loop — submit, screen, approve, appear — can be walked live in
/// ninety seconds without a backend, a signup flow or a password anywhere.
abstract final class DemoAccounts {
  /// Reads the daily case. Sees Beitragen as a locked surface.
  static const SessionUser reader = SessionUser(
    id: 'demo-reader',
    name: 'Dr. Weber',
    affiliation: 'Assistenzärztin, Innere Medizin',
    role: UserRole.reader,
  );

  /// Writes and submits cases.
  static const SessionUser contributor = SessionUser(
    id: 'demo-contributor',
    name: 'Dr. Schneider',
    affiliation: 'Fachärztin für Gastroenterologie',
    role: UserRole.contributor,
  );

  /// Approves or returns submissions.
  static const SessionUser editor = SessionUser(
    id: 'demo-editor',
    name: 'Dr. Braun',
    affiliation: 'Oberarzt, Redaktion',
    role: UserRole.editor,
  );

  /// All three, in the order the login screen lists them.
  static const List<SessionUser> all = [reader, contributor, editor];
}
