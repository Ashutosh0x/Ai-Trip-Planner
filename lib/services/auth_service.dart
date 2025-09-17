import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseService.auth;
  static final GoogleSignIn _googleSignIn = FirebaseService.googleSignIn;
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Check for default test credentials
      if (email == 'ashutosh@gmail.com' && password == 'password@123') {
        // For testing, we'll simulate a successful login by returning null
        // The login screen will handle this case specially
        return null;
      }

      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  static Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);

      // Persist/refresh profile
      final User? user = result.user;
      if (user != null) {
        final String? displayName = user.displayName ?? googleUser.displayName;
        // Prefer Google profile photo if available; request a larger size
        String? photoUrl = user.photoURL ?? googleUser.photoUrl;
        if (photoUrl != null && !photoUrl.contains('=s')) {
          photoUrl = '$photoUrl?sz=256';
        }
        final String providerId = 'google.com';
        await saveUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          fullName: displayName ?? '',
          profileImageUrl: photoUrl,
          providerId: providerId,
          providerLabel: 'Google',
        );
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on PlatformException catch (e) {
      // Common cause: ApiException 10 (DEVELOPER_ERROR) when SHA-1/SHA-256 are missing
      final message = e.message ?? '';
      if (e.code == 'sign_in_failed' && message.contains('ApiException: 10')) {
        throw Exception(
          'Google Sign-In is not fully configured for Android (ApiException 10). '
          'Add your debug/release SHA-1 and SHA-256 fingerprints to Firebase → Project settings → Android app `com.example.ai_trip_planner`, then download & replace `android/app/google-services.json`, clean and rebuild.',
        );
      }
      throw Exception('Google sign in failed: ${e.message ?? e.code}');
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Sign in with Microsoft (OAuth)
  static Future<UserCredential?> signInWithMicrosoft() async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      final provider = OAuthProvider('microsoft.com');
      provider.addScope('openid');
      provider.addScope('email');
      provider.addScope('profile');
      // Optional: choose tenant behavior; default is 'common'
      provider.setCustomParameters({'prompt': 'consent'});

      final UserCredential result = await _auth.signInWithProvider(provider);
      // Persist/refresh profile
      final User? user = result.user;
      if (user != null) {
        final String? displayName = user.displayName;
        final String? photoUrl = user.photoURL;
        await saveUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          fullName: displayName ?? '',
          profileImageUrl: photoUrl,
          providerId: 'microsoft.com',
          providerLabel: 'Microsoft',
        );
      }
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Microsoft sign in failed: $e');
    }
  }

  /// Sign in with Twitter (OAuth)
  static Future<UserCredential?> signInWithTwitter() async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      final provider = OAuthProvider('twitter.com');
      final UserCredential result = await _auth.signInWithProvider(provider);
      // Persist/refresh profile
      final User? user = result.user;
      if (user != null) {
        final String? displayName = user.displayName;
        final String? photoUrl = user.photoURL;
        await saveUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          fullName: displayName ?? '',
          profileImageUrl: photoUrl,
          providerId: 'twitter.com',
          providerLabel: 'Twitter',
        );
      }
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Twitter sign in failed: $e');
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Save user profile to Firestore
  static Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String fullName,
    String? profileImageUrl,
    String? country,
    String? dreamTrip,
    String? providerId,
    String? providerLabel,
    Map<String, dynamic>? onboardingPreferences,
  }) async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'fullName': fullName,
        'profileImageUrl': profileImageUrl,
        'country': country,
        'dreamTrip': dreamTrip,
        'providerId': providerId,
        'provider': providerLabel,
        'onboardingPreferences': onboardingPreferences,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile fields
  static Future<void> updateUserProfile({
    required String uid,
    String? fullName,
    String? country,
    String? dreamTrip,
    String? profileImageUrl,
    Map<String, dynamic>? onboardingPreferences,
  }) async {
    try {
      if (!FirebaseService.isFirebaseConfigured) {
        throw Exception('Firebase not configured. Please follow FIREBASE_SETUP.md to configure Firebase.');
      }

      final Map<String, dynamic> updates = {
        if (fullName != null) 'fullName': fullName,
        if (country != null) 'country': country,
        if (dreamTrip != null) 'dreamTrip': dreamTrip,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (onboardingPreferences != null) 'onboardingPreferences': onboardingPreferences,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(updates, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

