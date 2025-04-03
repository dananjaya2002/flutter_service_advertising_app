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
    apiKey: 'AIzaSyAekMi4dWOAKX2wjef_7HFFEmtcxijLDKA',
    appId: '1:719863271390:web:2f7af6824bce1f1746174f',
    messagingSenderId: '719863271390',
    projectId: 'madv4-52dff',
    authDomain: 'madv4-52dff.firebaseapp.com',
    storageBucket: 'madv4-52dff.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDPhy3yqylfT2Zf_nk5a90yErq1vvkGRpU',
    appId: '1:719863271390:android:a0ae10ece5618bd646174f',
    messagingSenderId: '719863271390',
    projectId: 'madv4-52dff',
    storageBucket: 'madv4-52dff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxpmnYwcmbr0lpweyz7va4_bCX9zNcebM',
    appId: '1:719863271390:ios:3753e064fa138ca946174f',
    messagingSenderId: '719863271390',
    projectId: 'madv4-52dff',
    storageBucket: 'madv4-52dff.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCxpmnYwcmbr0lpweyz7va4_bCX9zNcebM',
    appId: '1:719863271390:ios:3753e064fa138ca946174f',
    messagingSenderId: '719863271390',
    projectId: 'madv4-52dff',
    storageBucket: 'madv4-52dff.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAekMi4dWOAKX2wjef_7HFFEmtcxijLDKA',
    appId: '1:719863271390:web:7ec770bf5acab5ab46174f',
    messagingSenderId: '719863271390',
    projectId: 'madv4-52dff',
    authDomain: 'madv4-52dff.firebaseapp.com',
    storageBucket: 'madv4-52dff.firebasestorage.app',
  );
}
