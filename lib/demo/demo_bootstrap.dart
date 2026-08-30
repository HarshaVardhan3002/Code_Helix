import 'dart:async';
import 'dart:developer';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

/// Logs bloc errors during the prototype run.
class DemoBlocObserver extends BlocObserver {
  /// {@macro demo_bloc_observer}
  const DemoBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

/// Starts the prototype.
///
/// The counterpart to `bootstrap` in `lib/bootstrap.dart`, with everything
/// that needs a network removed. The original still initialises Firebase and
/// PowerSync before `runApp` and is left exactly as it was; this one touches
/// neither, along with Supabase and Firebase Messaging.
///
/// That is what makes the prototype survive the venue: it has no startup path
/// that can fail on bad wifi, because it never reaches for the network at all.
/// The case content ships inside the build as an asset.
Future<void> bootstrapDemo(FutureOr<Widget> Function() builder) async {
  Bloc.observer = const DemoBlocObserver();

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        log(
          details.exceptionAsString(),
          stackTrace: details.stack,
        );
      };

      // Local storage only, so answered cases survive a restart. Nothing
      // here reaches the network; HydratedStorage writes to the device.
      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
      );

      SystemUiOverlayTheme.setPortraitOrientation();

      // Edge to edge, because the image is the interface. Any reserved system
      // band would break the full-bleed premise the whole layout rests on.
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      runApp(await builder());
    },
    (error, stack) => log(error.toString(), stackTrace: stack),
  );
}
