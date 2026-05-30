import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../features/auth/application/auth_session_provider.dart';
import '../../features/auth/presentation/auth_gate_screen.dart';
import '../../features/keyboard/presentation/keyboard_theme_studio_screen.dart';
import '../../features/shell/presentation/app_shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authSessionProvider);
  return GoRouter(
    observers: [SentryNavigatorObserver(enableAutoTransactions: false)],
    redirect: (context, state) {
      final path = state.uri.path;
      final authPath = path == '/' || path.isEmpty;
      final hasAccess = authState.maybeWhen(
        data: (session) => session.isSignedIn || session.isLocalFallback,
        orElse: () => false,
      );
      if (!authPath && !hasAccess) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'auth_gate',
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const AppShellScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/voice',
        name: 'voice',
        builder: (context, state) => const AppShellScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/clipboard',
        name: 'clipboard',
        builder: (context, state) => const AppShellScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => AppShellScreen(
          initialIndex: 5,
          initialOnboardingStep: state.uri.queryParameters['onboarding'],
        ),
      ),
      GoRoute(
        path: '/keyboard/theme',
        name: 'keyboard_theme_studio',
        builder: (context, state) => const KeyboardThemeStudioScreen(),
      ),
      GoRoute(
        path: '/snippets',
        name: 'snippets',
        builder: (context, state) => const AppShellScreen(initialIndex: 3),
      ),
      GoRoute(
        path: '/dictionary',
        name: 'dictionary',
        builder: (context, state) => const AppShellScreen(initialIndex: 4),
      ),
    ],
  );
});
