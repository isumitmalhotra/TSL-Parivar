import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Authentication service using Firebase Auth
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ============== Phone Authentication ==============

  /// Send OTP to phone number
  static Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerify,
    int? resendToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android
          onAutoVerify(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Phone verification failed: ${e.message}');
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ OTP sent to $phoneNumber');
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏰ Auto retrieval timeout');
        },
      );
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      onError(e.toString());
    }
  }

  /// Verify OTP and sign in
  static Future<UserCredential?> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('✅ User signed in: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ OTP verification failed: ${e.message}');
      rethrow;
    }
  }

  /// Sign in with credential (for auto-verification)
  static Future<UserCredential?> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('❌ Sign in with credential failed: $e');
      rethrow;
    }
  }

  // ============== Email/Password Authentication ==============

  /// Sign up with email and password
  static Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User created: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign up failed: ${e.message}');
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User signed in: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign in failed: ${e.message}');
      rethrow;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password reset failed: ${e.message}');
      rethrow;
    }
  }

  // ============== Sign Out ==============

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }

  // ============== User Profile ==============

  /// Update user display name
  static Future<void> updateDisplayName(String name) async {
    try {
      await currentUser?.updateDisplayName(name);
      debugPrint('✅ Display name updated to $name');
    } catch (e) {
      debugPrint('❌ Update display name failed: $e');
      rethrow;
    }
  }

  /// Update user photo URL
  static Future<void> updatePhotoURL(String url) async {
    try {
      await currentUser?.updatePhotoURL(url);
      debugPrint('✅ Photo URL updated');
    } catch (e) {
      debugPrint('❌ Update photo URL failed: $e');
      rethrow;
    }
  }

  /// Delete user account
  static Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
      debugPrint('✅ User account deleted');
    } catch (e) {
      debugPrint('❌ Delete account failed: $e');
      rethrow;
    }
  }
}
