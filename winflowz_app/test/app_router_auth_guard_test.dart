import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:winflowz_app/core/router/app_router.dart';
import 'package:winflowz_app/core/sync/sync_status.dart';
import 'package:winflowz_app/features/auth/application/auth_session_provider.dart';
import 'package:winflowz_app/features/auth/domain/auth_session_store.dart';

const _productRoutes = {
  '/home': 'Accueil',
  '/voice': 'Capture automatique',
  '/clipboard': 'Nouvel élément clipboard',
  '/snippets': 'Nouveau snippet (raccourci texte)',
  '/dictionary': 'Nouveau terme',
  '/settings': 'Réglages',
};

const _signedOut = AuthSessionSnapshot(
  user: null,
  syncStatus: SyncStatus.unavailable(),
);

const _signedIn = AuthSessionSnapshot(
  user: AuthUserSnapshot(
    id: 'user-1',
    provider: AuthProviderKind.emailPassword,
  ),
  syncStatus: SyncStatus(health: SyncHealth.synced),
);

Widget _routerWidget(
  AuthSessionSnapshot session,
  void Function(GoRouter) bind,
) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith((ref) => Stream.value(session)),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouterProvider);
        bind(router);
        return MaterialApp.router(routerConfig: router);
      },
    ),
  );
}

Future<void> _pumpRouter(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('signed-out direct product routes redirect to auth gate', (
    tester,
  ) async {
    for (final route in _productRoutes.keys) {
      late GoRouter router;
      await tester.pumpWidget(
        _routerWidget(_signedOut, (value) => router = value),
      );
      await _pumpRouter(tester);
      router.go(route);
      await _pumpRouter(tester);

      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(find.text('Connexion'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('local mode can open product routes', (tester) async {
    for (final entry in _productRoutes.entries) {
      late GoRouter router;
      await tester.pumpWidget(
        _routerWidget(const AuthSessionSnapshot.localFallback(), (value) {
          router = value;
        }),
      );
      await _pumpRouter(tester);
      router.go(entry.key);
      await _pumpRouter(tester);

      expect(router.routeInformationProvider.value.uri.path, entry.key);
      expect(find.textContaining(entry.value), findsAtLeastNWidgets(1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('signed-in session can open product routes', (tester) async {
    for (final entry in _productRoutes.entries) {
      late GoRouter router;
      await tester.pumpWidget(
        _routerWidget(_signedIn, (value) => router = value),
      );
      await _pumpRouter(tester);
      router.go(entry.key);
      await _pumpRouter(tester);

      expect(router.routeInformationProvider.value.uri.path, entry.key);
      expect(find.textContaining(entry.value), findsAtLeastNWidgets(1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });
}
