import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static GoogleSignIn? _googleSignIn;
  
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Please call FirebaseService.initialize() first.');
    }
    return _auth!;
  }
  
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Please call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }
  
  static GoogleSignIn get googleSignIn {
    if (_googleSignIn == null) {
      _googleSignIn = GoogleSignIn();
    }
    return _googleSignIn!;
  }

  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        print('✅ Firebase already initialized');
        return;
      }

      // Check if we have real API keys (not placeholder values)
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.apiKey.contains('YOUR_') || options.projectId.contains('your-project-id-here')) {
        print('⚠️  Firebase not configured - using placeholder keys');
        print('📝 Please follow FIREBASE_SETUP.md to configure Firebase');
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Initialize services after Firebase is initialized
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _googleSignIn = GoogleSignIn();
      
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      print('⚠️  App will continue without Firebase features');
    }
  }

  /// Check if Firebase is properly configured
  static bool get isFirebaseConfigured {
    try {
      // Check if Firebase is initialized and we have real API keys
      if (_auth == null || _firestore == null) {
        return false;
      }
      
      final options = DefaultFirebaseOptions.currentPlatform;
      return !options.apiKey.contains('YOUR_') && 
             !options.projectId.contains('your-project-id-here');
    } catch (e) {
      return false;
    }
  }

  /// Get current user
  static User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is signed in
  static bool get isSignedIn {
    try {
      return currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      if (_auth != null) {
        await _auth!.signOut();
      }
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges {
    try {
      return _auth?.authStateChanges() ?? Stream.value(null);
    } catch (e) {
      return Stream.value(null);
    }
  }
}
