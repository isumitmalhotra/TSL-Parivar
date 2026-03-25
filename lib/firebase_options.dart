// File generated for Firebase configuration
// This file contains platform-specific Firebase options

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android configuration from google-services.json (com.tslsteel.parivar)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzrYIFGM1COZfcHNLWQcRduypC50HNWkM',
    appId: '1:868208183306:android:6c4e7a33bc761d917737f3',
    messagingSenderId: '868208183306',
    projectId: 'tsl-parivar',
    storageBucket: 'tsl-parivar.firebasestorage.app',
  );

  // iOS configuration from GoogleService-Info.plist (com.tslsteel.parivar)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBkLrX708PF89TONRID6emWaI76HMJwXfE',
    appId: '1:868208183306:ios:acbf4a9978d91a977737f3',
    messagingSenderId: '868208183306',
    projectId: 'tsl-parivar',
    storageBucket: 'tsl-parivar.firebasestorage.app',
    iosBundleId: 'com.tslsteel.parivar',
  );
}
