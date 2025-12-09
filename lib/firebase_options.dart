// File generated using FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFCoOBam7NvR68hnaC2EbRSQkR7ceMHAQ',
    appId: '1:190233405672:android:e4423cc62c8e46f066c15d',
    messagingSenderId: '190233405672',
    projectId: 'flirtscan-2025-ee6d7',
    storageBucket: 'flirtscan-2025-ee6d7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDXZsoN7iZljmB7pwd6XfkIhq-YBcX4u-c',
    appId: '1:190233405672:ios:9f84e77bdbf5569e66c15d',
    messagingSenderId: '190233405672',
    projectId: 'flirtscan-2025-ee6d7',
    storageBucket: 'flirtscan-2025-ee6d7.firebasestorage.app',
    iosBundleId: 'com.kenhuang.flirtscan',
  );
}

