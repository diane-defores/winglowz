import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/bootstrap/firebase_bootstrap.dart';
import '../data/firebase_auth_session_store.dart';
import '../data/local_auth_session_store.dart';
import '../domain/auth_session_store.dart';

final localAuthSessionStoreProvider = Provider<LocalAuthSessionStore>(
  (ref) => const LocalAuthSessionStore(),
);

class LocalAuthModeController extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() {
    state = true;
  }

  void disable() {
    state = false;
  }
}

final localAuthModeProvider = NotifierProvider<LocalAuthModeController, bool>(
  LocalAuthModeController.new,
);

final signupWelcomePendingProvider = StateProvider<bool>((ref) => false);

final authSessionStoreProvider = Provider<AuthSessionStore>((ref) {
  if (ref.watch(localAuthModeProvider)) {
    return ref.watch(localAuthSessionStoreProvider);
  }
  if (FirebaseBootstrap.isConfigured) {
    return FirebaseAuthSessionStore();
  }
  return ref.watch(localAuthSessionStoreProvider);
});

final authSessionProvider = StreamProvider<AuthSessionSnapshot>((ref) {
  final store = ref.watch(authSessionStoreProvider);
  return store.watchSession();
});
