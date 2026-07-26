class Env {
  Env._();

  static const String projectId = String.fromEnvironment(
    'PROJECT_ID',
    defaultValue: 'deliverak-prod',
  );

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'YOUR_FIREBASE_API_KEY',
  );

  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: 'YOUR_FIREBASE_APP_ID',
  );

  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: 'YOUR_FIREBASE_MESSAGING_SENDER_ID',
  );

  static const String firebaseStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'deliverak-prod.appspot.com',
  );
}
