import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/platform/android_keyboard_bridge.dart';
import '../core/platform/platform_capabilities.dart';
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
    _syncKeyboardThemeMode(value);
    Future<void>.microtask(() async {
      final localStore = ref.read(localSettingsStoreProvider);
      final activeStore = ref.read(settingsStoreProvider);
      final stores = <SettingsStore>[localStore];
      if (activeStore is! LocalSettingsStore) {
        stores.add(activeStore);
      }
      for (final store in stores) {
        try {
          await _saveThemeMode(store, value);
        } catch (_) {
          // Appearance changes apply immediately; persistence failures are
          // surfaced by the Settings sync/status work rather than blocking UI.
        }
      }
    });
  }

  Future<void> _saveThemeMode(SettingsStore store, AppThemeMode value) async {
    var settings = const UserSettingsSnapshot.defaults();
    try {
      settings = await store.load();
    } catch (_) {
      // Keep theme persistence best-effort if a store cannot hydrate first.
    }
    await store.save(settings.copyWith(themeMode: value.materialMode));
  }

  Future<void> _load() async {
    final settings = await ref.read(settingsStoreProvider).load();
    final loadedMode = AppThemeMode.fromThemeMode(settings.themeMode);
    state = loadedMode;
    _syncKeyboardThemeMode(loadedMode);
  }

  void _syncKeyboardThemeMode(AppThemeMode value) {
    if (!PlatformCapabilities.keyboardImeSupported) {
      return;
    }
    Future<void>.microtask(() async {
      try {
        await AndroidKeyboardBridge.setThemeMode(value.name);
      } catch (_) {
        // The app theme must remain usable even if the Android IME is disabled
        // or not reachable yet. Settings status refresh will surface failures.
      }
    });
  }
}

final appThemeModeProvider =
    NotifierProvider<AppThemeModeController, AppThemeMode>(
      AppThemeModeController.new,
    );

class WinFlowz extends ConsumerWidget {
  const WinFlowz({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final disableAnimations = SchedulerBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    return MaterialApp.router(
      title: 'WinFlowz',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode.materialMode,
      themeAnimationDuration: disableAnimations
          ? Duration.zero
          : AppMotion.base,
      routerConfig: router,
    );
  }
}
