import 'package:flutter/foundation.dart';

import 'package:core/core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService implements ICrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  CrashlyticsService({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> initialize() async {
    FlutterError.onError = _crashlytics.recordFlutterFatalError;
  }

  @override
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? information,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      information: information?.entries
          .map((e) => '${e.key}: ${e.value}')
          .toList() ?? [],
      fatal: fatal,
    );
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    await _crashlytics.setUserIdentifier(identifier);
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> crash() async {
    _crashlytics.crash();
  }
}
