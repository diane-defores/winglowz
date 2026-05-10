import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/voiceflowz_app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/data/local_settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
