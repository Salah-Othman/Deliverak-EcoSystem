import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import 'env.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: Env.firebaseApiKey,
    appId: Env.firebaseAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.projectId,
    storageBucket: Env.firebaseStorageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: Env.firebaseApiKey,
    appId: Env.firebaseAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.projectId,
    storageBucket: Env.firebaseStorageBucket,
    iosBundleId: 'com.deliverak.customer',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: Env.firebaseApiKey,
    appId: Env.firebaseAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.projectId,
    storageBucket: Env.firebaseStorageBucket,
    authDomain: '${Env.projectId}.firebaseapp.com',
  );
}
