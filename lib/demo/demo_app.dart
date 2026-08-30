import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/progress/progress.dart';
import 'package:flutter_instagram_offline_first_clone/session/session.dart';
import 'package:flutter_instagram_offline_first_clone/shell/shell.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// {@template demo_app}
/// The prototype shell.
///
/// Provides one repository and three cubits, and shows either the account list
/// or the three surfaces. No router, no network client, and nothing that can
/// fail on bad wifi.
///
/// The original Instagram modules — feed, reels, chats, search, stories,
/// timeline, profile, comments, auth — are untouched on disk and still
/// compile. They are unplugged by not being wired into this shell rather than
/// by being deleted or broken.
/// {@endtemplate}
class DemoApp extends StatelessWidget {
  /// {@macro demo_app}
  const DemoApp({required this.repository, super.key});

  /// Source of the catalog.
  final CatalogRepository repository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<CatalogRepository>.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => CatalogCubit(repository: repository)..load(),
            lazy: false,
          ),
          BlocProvider(create: (_) => SessionCubit()),
          BlocProvider(create: (_) => ProgressCubit()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GI Daily',
          // Dark only. The product is an image-first reader that lives on top
          // of endoscopy frames; light chrome would fight every image in it.
          theme: const AppDarkTheme().theme,
          locale: const Locale('de'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('de'), Locale('en')],
          home: const _Root(),
        ),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionUser?>(
      builder: (context, user) =>
          user == null ? const SignInPage() : const ShellPage(),
    );
  }
}
