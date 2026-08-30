import 'package:bloc/bloc.dart';
import 'package:flutter_instagram_offline_first_clone/session/models/session_user.dart';

/// {@template session_cubit}
/// Who is signed in.
///
/// Held in memory only, so every launch starts at the sign-in screen. That is
/// deliberate for a demo: the run always begins from the same known state, and
/// the role switch stays a visible, deliberate act rather than something that
/// silently persisted from the last rehearsal.
/// {@endtemplate}
class SessionCubit extends Cubit<SessionUser?> {
  /// {@macro session_cubit}
  SessionCubit() : super(null);

  /// Signs [user] in.
  void signIn(SessionUser user) => emit(user);

  /// Signs out and returns to the account list.
  void signOut() => emit(null);
}
