// ══════════════════════════════════════════════════════════════════════════════
// firebase_options.dart — PLACEHOLDER
//
// IMPORTANT: This file contains placeholder values only.
// To generate real values:
//   1. Install FlutterFire CLI: dart pub global activate flutterfire_cli
//   2. Run: flutterfire configure
//   3. Select your Firebase project
//
// Where to place google-services.json:
//   → android/app/google-services.json
// ══════════════════════════════════════════════════════════════════════════════

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for the current platform.
/// REPLACE THIS with your actual Firebase config after running `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNcClVc2zhrjm9_4zJlwFv759D43glCTQ',
    appId: '1:167490502893:web:3d0cd71d59a1e013e2cce4',
    messagingSenderId: '167490502893',
    projectId: 'todogame-63ec9',
    authDomain: 'todogame-63ec9.firebaseapp.com',
    storageBucket: 'todogame-63ec9.firebasestorage.app',
    measurementId: 'G-HK072TLKZX',
  );

  // ── Replace ALL values below with your own from Firebase Console ────────────

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1ts3kQKKZlCOw1emymeUekm2araPL9Os',
    appId: '1:167490502893:android:65990380f79831d2e2cce4',
    messagingSenderId: '167490502893',
    projectId: 'todogame-63ec9',
    storageBucket: 'todogame-63ec9.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNcClVc2zhrjm9_4zJlwFv759D43glCTQ',
    appId: '1:167490502893:web:d0af4b129ae4cbcfe2cce4',
    messagingSenderId: '167490502893',
    projectId: 'todogame-63ec9',
    authDomain: 'todogame-63ec9.firebaseapp.com',
    storageBucket: 'todogame-63ec9.firebasestorage.app',
    measurementId: 'G-8WQCS8HHZJ',
  );

}