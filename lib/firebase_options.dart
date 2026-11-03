import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for KITLUY POS
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
        return macos;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-ArLoNr94Nx8i58OKmYZl-Osembeie7w',
    appId: '1:106262239338:web:feef94e878682c1aae1213',
    messagingSenderId: '106262239338',
    projectId: 'kitluy-pos',
    authDomain: 'kitluy-pos.firebaseapp.com',
    storageBucket: 'kitluy-pos.firebasestorage.app',
    measurementId: 'G-77RQ995R7E',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-ArLoNr94Nx8i58OKmYZl-Osembeie7w',
    appId: '1:106262239338:web:feef94e878682c1aae1213',
    messagingSenderId: '106262239338',
    projectId: 'kitluy-pos',
    authDomain: 'kitluy-pos.firebaseapp.com',
    storageBucket: 'kitluy-pos.firebasestorage.app',
    measurementId: 'G-77RQ995R7E',
  );
}
