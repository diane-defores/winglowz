import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/application/settings_store_provider.dart';
import '../features/settings/data/local_settings_store.dart';
import '../features/settings/domain/settings_store.dart';

final initialAppThemeModeProvider = Provider<AppThemeMode>(
  (ref) => AppThemeMode.system,
);

class AppThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    final initialMode = ref.watch(initialAppThemeModeProvider);
    ref.listen<SettingsStore>(settingsStoreProvider, (_, _) {
      Future<void>.microtask(_load);
    });
    Future<void>.microtask(_load);
    return initialMode;
  }

  void setMode(AppThemeMode value) {
    state = value;
    Future<void>.microtask(() async {
      try {
        final settings = UserSettingsSnapshot.defaults().copyWith(
          themeMode: value.materialMode,
        );
        final localStore = ref.read(localSettingsStoreProvider);
        final activeStore = ref.read(settingsStoreProvider);
        await localStore.save(settings);
        if (activeStore is! LocalSettingsStore) {
          await activeStore.save(settings);
        }
      } catch (_) {
        // Appearance changes apply immediately; persistence failures are
        // surfaced by the Settings sync/status work rather than blocking UI.
      }
    });
  }

  Future<void> _load() async {
    final settings = await ref.read(settingsStoreProvider).load();
    state = AppThemeMode.fromThemeMode(settings.themeMode);
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeModeController, AppThemeMode>(
      AppThemeModeController.new,
    );

class VoiceFlowzApp extends ConsumerWidget {
  const VoiceFlowzApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    return MaterialApp.router(
      title: 'VoiceFlowz',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode.materialMode,
      routerConfig: router,
    );
  }
}
