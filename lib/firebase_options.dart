// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAmQ_pDRkVKdrdXmbDfzWOJM22W6vBBsMA',
    appId: '1:263392941004:web:1e720249e06316c1914369',
    messagingSenderId: '263392941004',
    projectId: 'classbook-3492f',
    authDomain: 'classbook-3492f.firebaseapp.com',
    storageBucket: 'classbook-3492f.firebasestorage.app',
    measurementId: 'G-7GWMF9HWJ1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCw-Pj4BhvZD2Yc8zGn1bWEkh_WadQEIiE',
    appId: '1:263392941004:android:c6f162f99f46323c914369',
    messagingSenderId: '263392941004',
    projectId: 'classbook-3492f',
    storageBucket: 'classbook-3492f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJakfFtLrScHVmFtn9fMiUSPGnO30KaAE',
    appId: '1:263392941004:ios:018c125e4c96df3a914369',
    messagingSenderId: '263392941004',
    projectId: 'classbook-3492f',
    storageBucket: 'classbook-3492f.firebasestorage.app',
    iosBundleId: 'com.example.classbook',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDJakfFtLrScHVmFtn9fMiUSPGnO30KaAE',
    appId: '1:263392941004:ios:018c125e4c96df3a914369',
    messagingSenderId: '263392941004',
    projectId: 'classbook-3492f',
    storageBucket: 'classbook-3492f.firebasestorage.app',
    iosBundleId: 'com.example.classbook',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAmQ_pDRkVKdrdXmbDfzWOJM22W6vBBsMA',
    appId: '1:263392941004:web:17e82f36c05b7a7e914369',
    messagingSenderId: '263392941004',
    projectId: 'classbook-3492f',
    authDomain: 'classbook-3492f.firebaseapp.com',
    storageBucket: 'classbook-3492f.firebasestorage.app',
    measurementId: 'G-VZ6EZ1GSVK',
  );
}
