import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/bootstrap/firebase_bootstrap.dart';
import '../../auth/application/auth_session_provider.dart';
import '../../auth/application/suite_identity_provider.dart';
import '../../auth/domain/product_entitlement.dart';
import '../data/firebase_snippet_store.dart';
import '../data/in_memory_snippet_store.dart';
import '../domain/snippet_store.dart';

final localSnippetStoreProvider = Provider<InMemorySnippetStore>(
  (ref) => InMemorySnippetStore(),
);

final snippetStoreProvider = Provider<SnippetStore>((ref) {
  final session = ref.watch(
    authSessionProvider.select(
      (value) =>
          value.maybeWhen(data: (session) => session, orElse: () => null),
    ),
  );
  final hasRemoteSession =
      session != null && session.isSignedIn && !session.isLocalFallback;
  final hasWinFlowzAppAccess = ref
      .watch(suiteIdentityProvider)
      .maybeWhen(
        data: (identity) => identity.hasAccessTo(ProductId.winflowzApp),
        orElse: () => false,
      );

  if (FirebaseBootstrap.isConfigured &&
      hasRemoteSession &&
      hasWinFlowzAppAccess &&
      firebase_auth.FirebaseAuth.instance.currentUser != null) {
    return FirebaseSnippetStore();
  }

  return ref.watch(localSnippetStoreProvider);
});
