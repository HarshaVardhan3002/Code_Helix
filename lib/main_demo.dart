import 'package:flutter_instagram_offline_first_clone/catalog/catalog.dart';
import 'package:flutter_instagram_offline_first_clone/demo/demo.dart';

/// Entry point for the GI Daily prototype.
///
/// Run with `flutter run -t lib/main_demo.dart -d <android device>`.
///
/// The flavour entry points in `lib/main_{development,staging,production}.dart`
/// are untouched and still start the original Instagram app against Supabase
/// and PowerSync. This one starts the prototype with no network at all.
void main() {
  bootstrapDemo(() => const DemoApp(repository: LocalCatalogRepository()));
}
