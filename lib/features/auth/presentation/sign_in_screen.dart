import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../core/bootstrap/sentry_bootstrap.dart';
import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/theme/app_theme.dart';
import '../application/auth_session_provider.dart';
import '../domain/auth_failure.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _errorDetail;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool signup}) async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _error = null;
      _errorDetail = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _error = 'Corrige les champs indiqués avant de continuer.';
      });
      return;
    }

    final store = ref.read(authSessionStoreProvider);

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      if (signup) {
        await store.createAccountWithEmailPassword(
          email: email,
          password: password,
        );
      } else {
        await store.signInWithEmailPassword(email: email, password: password);
      }
    } on AuthFailure catch (error, stackTrace) {
      await _presentAuthFailure(error, stackTrace);
    } on UnsupportedError catch (error, stackTrace) {
      await _presentAuthFailure(AuthFailure.unsupported(error), stackTrace);
    } catch (error, stackTrace) {
      await _presentAuthFailure(AuthFailure.unexpected(error), stackTrace);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _continueLocally() async {
    setState(() {
      _busy = true;
      _error = null;
      _errorDetail = null;
    });
    try {
      ref.read(localAuthModeProvider.notifier).enable();
      final store = ref.read(localAuthSessionStoreProvider);
      await store.signInAnonymously();
    } on AuthFailure catch (error, stackTrace) {
      await _presentAuthFailure(error, stackTrace);
    } on UnsupportedError catch (error, stackTrace) {
      await _presentAuthFailure(AuthFailure.unsupported(error), stackTrace);
    } catch (error, stackTrace) {
      await _presentAuthFailure(
        const AuthFailure(
          kind: AuthFailureKind.unexpected,
          userMessage: 'Mode local indisponible pour le moment.',
          category: 'auth_local_unexpected',
          code: 'local-unexpected',
        ),
        stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final store = ref.read(authSessionStoreProvider);
    setState(() {
      _busy = true;
      _error = null;
      _errorDetail = null;
    });
    try {
      await store.signInWithGoogle();
    } on AuthFailure catch (error, stackTrace) {
      await _presentAuthFailure(error, stackTrace);
    } on UnsupportedError catch (error, stackTrace) {
      await _presentAuthFailure(AuthFailure.unsupported(error), stackTrace);
    } catch (error, stackTrace) {
      await _presentAuthFailure(
        AuthFailure(
          kind: AuthFailureKind.unexpected,
          userMessage:
              'Connexion Google impossible pour le moment. Réessaie plus tard.',
          category: 'auth_google_unexpected',
          code: 'google-unexpected',
          supportDetail: error,
        ),
        stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _setError(String message, {String? detail}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _error = message;
      _errorDetail = detail;
    });
  }

  Future<void> _presentAuthFailure(
    AuthFailure failure,
    StackTrace stackTrace,
  ) async {
    final detail = failure.safeSupportDetail;
    AppDiagnostics.record(failure.category, detail);
    if (SentryBootstrap.isInitialized && failure.reportToSentry) {
      await Sentry.captureException(failure, stackTrace: stackTrace);
    }
    _setError(
      failure.userMessage,
      detail: failure.reportToSentry ? detail : null,
    );
  }

  Future<void> _copyErrorDetail() async {
    final detail = _errorDetail;
    if (detail == null || detail.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: detail));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Détail technique copié.')));
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Renseigne ton email.';
    }
    final hasBasicEmailShape = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
    if (!hasBasicEmailShape) {
      return 'Entre un email valide, par exemple nom@domaine.com.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Renseigne ton mot de passe.';
    }
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('WinFlowz')),
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.shell(colorScheme.brightness),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: AppInsets.screen,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  child: Padding(
                    padding: AppInsets.card,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autovalidateMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connexion',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          AppGaps.x1,
                          Text(
                            'Accède à ton espace de dictée, clipboard et snippets.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          AppGaps.x5,
                          TextFormField(
                            controller: _emailController,
                            enabled: !_busy,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            validator: _validateEmail,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          AppGaps.x3,
                          TextFormField(
                            controller: _passwordController,
                            enabled: !_busy,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: _validatePassword,
                            onFieldSubmitted: (_) {
                              if (!_busy) {
                                _submit(signup: false);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Mot de passe',
                            ),
                          ),
                          AppGaps.x4,
                          if (_error != null)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.md,
                                ),
                                border: Border.all(
                                  color: colorScheme.error.withValues(
                                    alpha: 0.24,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: AppInsets.compactCard,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _error!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onErrorContainer,
                                          ),
                                    ),
                                    if (_errorDetail != null) ...[
                                      AppGaps.x2,
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton.icon(
                                          onPressed: _copyErrorDetail,
                                          icon: const Icon(Icons.copy_outlined),
                                          label: const Text('Copier le détail'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          AppGaps.x2,
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _submit(signup: false),
                                  child: const Text('Se connecter'),
                                ),
                              ),
                              AppGaps.horizontalX3,
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _submit(signup: true),
                                  child: const Text('Créer un compte'),
                                ),
                              ),
                            ],
                          ),
                          AppGaps.x3,
                          OutlinedButton(
                            onPressed: _busy ? null : _continueLocally,
                            child: const Text('Continuer en local'),
                          ),
                          AppGaps.x2,
                          OutlinedButton.icon(
                            onPressed: _busy ? null : _signInWithGoogle,
                            icon: const Icon(Icons.login_outlined),
                            label: const Text('Continuer avec Google'),
                          ),
                          if (_busy)
                            const Padding(
                              padding: AppInsets.progress,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
