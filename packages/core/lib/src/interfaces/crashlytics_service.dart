abstract class ICrashlyticsService {
  Future<void> initialize();

  Future<void> log(String message);

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? information,
    bool fatal = false,
  });

  Future<void> setCustomKey(String key, dynamic value);

  Future<void> setUserIdentifier(String identifier);

  Future<void> setCrashlyticsCollectionEnabled(bool enabled);

  Future<void> crash();
}
