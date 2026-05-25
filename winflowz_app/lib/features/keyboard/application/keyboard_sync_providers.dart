import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/android_keyboard_bridge.dart';
import '../../auth/application/auth_session_provider.dart';
import '../../auth/application/suite_identity_provider.dart';
import '../../auth/domain/product_entitlement.dart';
import '../../auth/domain/suite_identity.dart';
import '../data/firebase_keyboard_config_store.dart';
import '../data/local_keyboard_sync_queue_store.dart';
import '../domain/keyboard_sync_store.dart';
import 'keyboard_profile_backup_service.dart';
import 'keyboard_sync_controller.dart';
import 'keyboard_sync_queue.dart';

final keyboardSyncStoreProvider = Provider<KeyboardSyncStore>(
  (ref) => FirebaseKeyboardConfigStore(),
);

final localKeyboardSyncQueueStoreProvider =
    Provider<LocalKeyboardSyncQueueStore>(
      (ref) => LocalKeyboardSyncQueueStore(),
    );

final keyboardSyncQueueProvider = Provider<KeyboardSyncQueue>((ref) {
  return DurableKeyboardSyncQueue(
    cloudStore: ref.watch(keyboardSyncStoreProvider),
    queueStore: ref.watch(localKeyboardSyncQueueStoreProvider),
  );
});

final keyboardSyncControllerProvider = Provider<KeyboardSyncController>((ref) {
  return KeyboardSyncController(
    cloudStore: ref.watch(keyboardSyncStoreProvider),
    queue: ref.watch(keyboardSyncQueueProvider),
    exportLocalProfile: AndroidKeyboardBridge.exportKeyboardSyncProfile,
    applyLocalProfile: (profile) =>
        AndroidKeyboardBridge.applyKeyboardSyncProfile(profile),
  );
});

class KeyboardSyncChangeNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void markKeyboardProfileChanged() {
    state = state + 1;
  }
}

final keyboardSyncChangeNotifierProvider =
    NotifierProvider<KeyboardSyncChangeNotifier, int>(
      KeyboardSyncChangeNotifier.new,
    );

final keyboardSyncAuthContextProvider = Provider<KeyboardSyncAuthContext>((
  ref,
) {
  final authSession = ref
      .watch(authSessionProvider)
      .maybeWhen(data: (value) => value, orElse: () => null);
  final identity = ref
      .watch(suiteIdentityProvider)
      .maybeWhen(data: (value) => value, orElse: () => null);
  return KeyboardSyncAuthContext(
    isSignedIn: authSession?.isSignedIn ?? false,
    isLocalFallback: authSession?.isLocalFallback ?? true,
    hasEntitlement:
        (identity?.statusFor(ProductId.winflowzApp) ??
            SuiteAccountStatus.unknown) ==
        SuiteAccountStatus.accessActive,
    firebaseUid: authSession?.user?.id,
    globalUserId: identity?.globalUserId,
  );
});

final keyboardProfileBackupServiceProvider =
    Provider<KeyboardProfileBackupService>((ref) {
      return KeyboardProfileBackupService(
        exportLocalProfile: AndroidKeyboardBridge.exportKeyboardSyncProfile,
        applyLocalProfile: AndroidKeyboardBridge.applyKeyboardSyncProfile,
      );
    });
