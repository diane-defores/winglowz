import 'package:flutter/foundation.dart';

class AppDiagnosticEvent {
  const AppDiagnosticEvent({
    required this.timestampUtc,
    required this.category,
    required this.message,
  });

  final DateTime timestampUtc;
  final String category;
  final String message;

  @override
  String toString() {
    return '${timestampUtc.toIso8601String()} [$category] $message';
  }
}

class AppDiagnostics {
  AppDiagnostics._();

  static const _maxEvents = 40;
  static final List<AppDiagnosticEvent> _events = <AppDiagnosticEvent>[];

  static List<AppDiagnosticEvent> get recentEvents =>
      List<AppDiagnosticEvent>.unmodifiable(_events);

  static void record(String category, Object? message) {
    final event = AppDiagnosticEvent(
      timestampUtc: DateTime.now().toUtc(),
      category: category,
      message: _singleLine(message),
    );
    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }
  }

  static void recordFlutterError(FlutterErrorDetails details) {
    record(
      'flutter_error',
      '${details.exceptionAsString()} | library=${details.library ?? 'unknown'}',
    );
  }

  static void recordUnhandledError(Object error, StackTrace stackTrace) {
    record('unhandled_error', error);
  }

  static String _singleLine(Object? value) {
    final text = value?.toString() ?? 'none';
    return text.replaceAll('\n', ' | ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
