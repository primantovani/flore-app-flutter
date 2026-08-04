import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUo_J6duRpjDjEe2pgFSbKcvRT5xHRU7U',
    appId: '1:750575976207:android:6cb3d265ae1b099967887a',
    messagingSenderId: '750575976207',
    projectId: 'flore-app-1fdc0',
    storageBucket: 'flore-app-1fdc0.firebasestorage.app',
  );
}
