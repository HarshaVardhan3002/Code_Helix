import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// {@template appearance_cubit}
/// Which scheme the app paints in.
///
/// Three states, not two. [ThemeMode.system] is the default and it matters
/// clinically: an endoscopy suite is a dark room and a ward round is not, and
/// the phone already knows which one the reader is standing in.
///
/// Hydrated, so a deliberate override survives a restart. Without that, a
/// reader who forced light mode would find the app dark again the next
/// morning and reasonably conclude the switch does not work.
/// {@endtemplate}
class AppearanceCubit extends HydratedCubit<ThemeMode> {
  /// {@macro appearance_cubit}
  AppearanceCubit() : super(ThemeMode.system);

  /// Selects [mode].
  void select(ThemeMode mode) => emit(mode);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final name = json['mode'] as String?;
    return ThemeMode.values.where((m) => m.name == name).firstOrNull;
  }

  @override
  Map<String, dynamic> toJson(ThemeMode state) => {'mode': state.name};
}

/// The German label for a [ThemeMode], as shown in Profil.
extension ThemeModeLabel on ThemeMode {
  /// The label shown on the appearance control.
  String get label => switch (this) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Hell',
    ThemeMode.dark => 'Dunkel',
  };

  /// The icon shown on the appearance control.
  IconData get icon => switch (this) {
    ThemeMode.system => Icons.brightness_auto_rounded,
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.dark => Icons.dark_mode_rounded,
  };
}
