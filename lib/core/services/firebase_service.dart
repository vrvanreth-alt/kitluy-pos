import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;

  static FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firestore = FirebaseFirestore.instance;
      _firestore!.settings = const Settings(persistenceEnabled: true);
      _isInitialized = true;
      debugPrint('✅ Firebase & Cloud Firestore initialized successfully!');
    } catch (e) {
      debugPrint('⚠️ Firebase initialization error: $e');
    }
  }
}
