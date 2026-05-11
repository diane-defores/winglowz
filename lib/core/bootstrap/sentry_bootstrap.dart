import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app_build_info.dart';
import '../diagnostics/app_diagnostics.dart';

class SentryBootstrap {
  SentryBootstrap._();

  static const dsnEnvironmentName = 'SENTRY_DSN';
  static const environmentEnvironmentName = 'SENTRY_ENVIRONMENT';

  static const _dsn = String.fromEnvironment(dsnEnvironmentName);
  static const _environment = String.fromEnvironment(
    environmentEnvironmentName,
  );

  static bool _initialized = false;
  static String? _initError;

  static bool get isConfigured => _dsn.trim().isNotEmpty;
  static bool get isInitialized => _initialized;
  static String? get initError => _initError;

  static String get environment {
    final value = _environment.trim();
    if (value.isNotEmpty) {
      return value;
    }
    if (kReleaseMode) {
      return 'production';
    }
    if (kProfileMode) {
      return 'profile';
    }
    return 'debug';
  }

  static String? get release {
    if (AppBuildInfo.sha == 'local') {
      return null;
    }
    return 'voiceflowz@${AppBuildInfo.shortSha}';
  }

  static String? get dist {
    if (AppBuildInfo.runId == 'local') {
      return null;
    }
    return AppBuildInfo.runId;
  }

  static Future<void> init({required AppRunner appRunner}) async {
    if (!isConfigured) {
      AppDiagnostics.record('sentry_init', 'disabled: missing SENTRY_DSN');
      await appRunner();
      return;
    }

    var appRunnerCalled = false;
    try {
      await SentryFlutter.init(
        _configureOptions,
        appRunner: () async {
          appRunnerCalled = true;
          _initialized = true;
          _initError = null;
          _installDiagnosticBreadcrumbs();
          await _configureScope();
          await appRunner();
        },
      );
    } catch (error) {
      _initialized = false;
      _initError = 'Sentry initialization failed: $error';
      AppDiagnostics.record('sentry_init_error', error);
      if (!appRunnerCalled) {
        await appRunner();
      } else {
        rethrow;
      }
    }
  }

  static Future<void> _configureOptions(SentryFlutterOptions options) async {
    options.dsn = _dsn.trim();
    options.environment = environment;
    options.release = release;
    options.dist = dist;
    options.sendDefaultPii = false;
    options.attachScreenshot = false;
    options.enableAutoSessionTracking = true;
    options.tracesSampleRate = null;
    options.beforeBreadcrumb = (breadcrumb, hint) {
      final message = breadcrumb?.message;
      if (message == null) {
        return breadcrumb;
      }
      breadcrumb?.message = _sanitize(message);
      return breadcrumb;
    };
  }

  static Future<void> _configureScope() async {
    await Sentry.configureScope((scope) async {
      await scope.setTag('app', 'voiceflowz');
      await scope.setTag('backend_contract', 'backend-agnostic');
      await scope.setTag('build_sha', AppBuildInfo.shortSha);
      await scope.setTag('build_ref', AppBuildInfo.refName);
      await scope.setTag('build_run_id', AppBuildInfo.runId);
      await scope.setTag('sentry_environment', environment);
    });
  }

  static void _installDiagnosticBreadcrumbs() {
    AppDiagnostics.breadcrumbRecorder = (category, message) {
      if (category == 'flutter_first_frame_assertion') {
        return;
      }
      Sentry.addBreadcrumb(
        Breadcrumb(
          category: 'voiceflowz.$category',
          message: _sanitize(message),
          level: category.endsWith('_error') || category == 'flutter_error'
              ? SentryLevel.error
              : SentryLevel.info,
        ),
      );
    };
  }

  static String _sanitize(Object? value) {
    var text = value?.toString() ?? 'none';
    final redactionPatterns = [
      RegExp(r'AIza[0-9A-Za-z_-]{20,}'),
      RegExp(r'sb_[0-9A-Za-z_-]{12,}'),
      RegExp(r'eyJ[0-9A-Za-z_.-]{20,}'),
      RegExp(r'sk-[0-9A-Za-z_-]{12,}'),
      RegExp(
        r'(api[_-]?key|anon[_-]?key|publishable[_-]?key|token|secret|password)\s*[:=]\s*[^,\s;]+',
        caseSensitive: false,
      ),
    ];
    for (final pattern in redactionPatterns) {
      text = text.replaceAll(pattern, '<redacted>');
    }
    return text.replaceAll('\n', ' | ');
  }
}
