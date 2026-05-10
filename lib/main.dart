import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/voiceflowz_app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/diagnostics/app_diagnostics.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/data/local_settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final previousFlutterError = FlutterError.onError;
  FlutterError.onError = (details) {
    AppDiagnostics.recordFlutterError(details);
    if (previousFlutterError != null) {
      previousFlutterError(details);
    } else {
      FlutterError.presentError(details);
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppDiagnostics.recordUnhandledError(error, stack);
    return false;
  };
  await AppBootstrap.init();
  final initialSettings = await LocalSettingsStore().load();
  final initialThemeMode = AppThemeMode.fromThemeMode(
    initialSettings.themeMode,
  );
  runApp(
    ProviderScope(
      overrides: [
        initialAppThemeModeProvider.overrideWithValue(initialThemeMode),
      ],
      child: const VoiceFlowzApp(),
    ),
  );
}
