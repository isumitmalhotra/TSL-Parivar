import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/shared_models.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/messaging_service.dart';

/// Authentication state enum
enum AuthState {
  initial,
  unauthenticated,
  authenticating,
  otpSent,
  verifyingOtp,
  authenticated,
  error,
}

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  AuthState _authState = AuthState.initial;
  UserRole? _userRole;
  String? _userId;
  String? _phoneNumber;
  String? _errorMessage;
  bool _hasSeenOnboarding = false;
  bool _isInitialized = false;
  final BiometricService _biometricService = BiometricService();

  // Firebase Auth specific
  String? _verificationId;
  int? _resendToken;
  String? _otpFlowId;
  DateTime? _nextOtpAllowedAt;

  // Getters
  AuthState get authState => _authState;
  UserRole? get userRole => _userRole;
  String? get userId => _userId;
  String? get phoneNumber => _phoneNumber;
  String? get errorMessage => _errorMessage;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isLoading =>
      _authState == AuthState.authenticating ||
      _authState == AuthState.verifyingOtp;
  int get otpCooldownSecondsRemaining {
    final next = _nextOtpAllowedAt;
    if (next == null) return 0;
    final diff = next.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return diff.inSeconds + 1;
  }

  bool get isOtpCooldownActive => otpCooldownSecondsRemaining > 0;

  /// Initialize the auth provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      _hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
      
      // Check Firebase Auth state first
      final firebaseUser = AuthService.currentUser;
      
      if (firebaseUser != null) {
        // User is logged in via Firebase
        _userId = firebaseUser.uid;
        _phoneNumber = firebaseUser.phoneNumber;
        
        // Get role from SharedPreferences (set during registration)
        final roleKey = prefs.getString(_userRoleKey);
        if (roleKey != null) {
          _userRole = UserRoleExtension.fromKey(roleKey);
          _authState = AuthState.authenticated;
        } else {
          // Attempt to recover role from Firestore for existing users.
          final roleFromFirestore = await _loadRoleFromFirestore(firebaseUser.uid);
          if (roleFromFirestore != null) {
            _userRole = roleFromFirestore;
            await prefs.setString(_userRoleKey, roleFromFirestore.key);
          }
          _authState = AuthState.authenticated;
        }

        final biometricEnabled = _isBiometricEnabledForUser(
          prefs,
          firebaseUser.uid,
        );
        if (biometricEnabled) {
          final unlocked = await _biometricService.authenticate();
          if (!unlocked) {
            await AuthService.signOut();
            _authState = AuthState.unauthenticated;
            _userRole = null;
            _userId = null;
            _phoneNumber = null;
            await prefs.remove(_isLoggedInKey);
            await prefs.remove(_userRoleKey);
            await prefs.remove(_userIdKey);
            await prefs.remove(_phoneNumberKey);
          }
        }
      } else {
        // Firebase user is source of truth. Clear stale local auth cache.
        _authState = AuthState.unauthenticated;
        _userRole = null;
        _userId = null;
        _phoneNumber = null;
        await prefs.remove(_isLoggedInKey);
        await prefs.remove(_userRoleKey);
        await prefs.remove(_userIdKey);
        await prefs.remove(_phoneNumberKey);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Auth initialization error: $e');
      _authState = AuthState.error;
      _errorMessage = 'Failed to initialize authentication';
      _isInitialized = true;
      notifyListeners();
    }
  }

  bool _isBiometricEnabledForUser(SharedPreferences prefs, String uid) {
    final raw = prefs.getString('app_settings_v1_$uid');
    if (raw == null || raw.isEmpty) {
      return false;
    }
    final parts = raw.split('|');
    if (parts.length != 6) {
      return false;
    }
    return parts[5] == '1';
  }

  /// Mark onboarding as seen
  Future<void> markOnboardingSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenOnboardingKey, true);
      _hasSeenOnboarding = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking onboarding seen: $e');
    }
  }

  /// Select user role
  void selectRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }

  /// Send OTP to phone number using Firebase Auth
  Future<bool> sendOtp(String phoneNumber) async {
    if (isOtpCooldownActive) {
      _authState = AuthState.error;
      _errorMessage = 'Please wait $otpCooldownSecondsRemaining seconds before retrying OTP.';
      notifyListeners();
      return false;
    }

    _otpFlowId = 'otp_${DateTime.now().millisecondsSinceEpoch}';
    _authState = AuthState.authenticating;
    _errorMessage = null;
    _phoneNumber = phoneNumber;
    notifyListeners();

    try {
      // Normalize to E.164-like format for Firebase Phone Auth.
      final digitsOnly = phoneNumber.replaceAll(RegExp('[^0-9+]'), '');
      final formattedPhone = digitsOnly.startsWith('+')
          ? digitsOnly
          : '+91$digitsOnly';

      final completer = Completer<bool>();
      
      await AuthService.sendOTP(
        phoneNumber: formattedPhone,
        resendToken: _resendToken,
        onCodeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _nextOtpAllowedAt = null;
          _authState = AuthState.otpSent;
          debugPrint('🧪[OTP:${_otpFlowId}] codeSent phone=$formattedPhone');
          notifyListeners();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onError: (String error) {
          _authState = AuthState.error;
          _errorMessage = _getReadableErrorMessage(error);
          _applyCooldownForError(error);
          debugPrint('❌ OTP send error: $error');
          notifyListeners();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        onAutoVerify: (PhoneAuthCredential credential) async {
          // Auto-verification on Android (when SMS is auto-detected)
          debugPrint('🧪[OTP:${_otpFlowId}] autoVerify triggered');
          await _signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
      );

      return completer.future.timeout(
        const Duration(seconds: 35),
        onTimeout: () {
          _authState = AuthState.error;
          _errorMessage =
              'OTP was not sent. Please retry in 30 seconds or check Firebase phone auth settings.';
          _setOtpCooldown(const Duration(seconds: 30));
          notifyListeners();
          return false;
        },
      );
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'Failed to send OTP. Please try again.';
      debugPrint('❌[OTP:${_otpFlowId}] sendOtp exception: $e');
      notifyListeners();
      return false;
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getReadableErrorMessage(String error) {
    if (error.contains('invalid-phone-number')) {
      return 'Invalid phone number. Please check and try again.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (error.contains('quota-exceeded')) {
      return 'SMS quota exceeded. Please try again later.';
    } else if (error.contains('captcha-check-failed')) {
      return 'Human verification failed. Please retry and complete the browser check.';
    } else if (error.contains('missing-client-identifier')) {
      return 'App verification failed. Install from Play Internal/Production build and try again.';
    } else if (error.contains('invalid-app-credential') || error.contains('app-not-authorized')) {
      return 'This app build is not authorized for OTP yet. Please update the app and try again.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('invalid-verification-code')) {
      return 'Invalid OTP. Please check and try again.';
    } else if (error.contains('session-expired')) {
      return 'OTP expired. Please request a new one.';
    }
    return error;
  }

  void _setOtpCooldown(Duration duration) {
    _nextOtpAllowedAt = DateTime.now().add(duration);
  }

  void _applyCooldownForError(String error) {
    if (error.contains('too-many-requests') || error.contains('quota-exceeded')) {
      _setOtpCooldown(const Duration(minutes: 2));
      return;
    }
    if (error.contains('missing-client-identifier') ||
        error.contains('invalid-app-credential') ||
        error.contains('captcha-check-failed')) {
      _setOtpCooldown(const Duration(seconds: 45));
      return;
    }
    _setOtpCooldown(const Duration(seconds: 20));
  }

  /// Verify OTP using Firebase Auth
  Future<bool> verifyOtp(String otp) async {
    _authState = AuthState.verifyingOtp;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🧪[OTP:${_otpFlowId}] verifyOtp started');
      if (_verificationId == null) {
        _authState = AuthState.error;
        _errorMessage = 'Session expired. Please request a new OTP.';
        notifyListeners();
        return false;
      }

      final userCredential = await AuthService.verifyOTP(
        verificationId: _verificationId!,
        otp: otp,
      );

      if (userCredential?.user != null) {
        _userId = userCredential!.user!.uid;
        _phoneNumber = userCredential.user!.phoneNumber;

        // Save user to Firestore if new user
        await _createOrUpdateUserInFirestore(userCredential.user!);

        // Save to SharedPreferences
        await _saveAuthState();

        // Save FCM token for push notifications
        await MessagingService.saveTokenForUser(_userId!);

        _authState = AuthState.authenticated;
        _nextOtpAllowedAt = null;
        debugPrint('✅[OTP:${_otpFlowId}] verified uid=$_userId');
        notifyListeners();
        return true;
      } else {
        _authState = AuthState.otpSent;
        _errorMessage = 'Verification failed. Please try again.';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _authState = AuthState.otpSent;
      _errorMessage = _getReadableErrorMessage(e.code);
      debugPrint('❌[OTP:${_otpFlowId}] FirebaseAuth ${e.code} - ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'Failed to verify OTP. Please try again.';
      debugPrint('❌[OTP:${_otpFlowId}] verifyOtp exception: $e');
      notifyListeners();
      return false;
    }
  }

  /// Sign in with auto-verified credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    _authState = AuthState.verifyingOtp;
    notifyListeners();

    try {
      final userCredential = await AuthService.signInWithCredential(credential);
      
      if (userCredential?.user != null) {
        _userId = userCredential!.user!.uid;
        _phoneNumber = userCredential.user!.phoneNumber;

        // Save user to Firestore
        await _createOrUpdateUserInFirestore(userCredential.user!);

        // Save to SharedPreferences
        await _saveAuthState();

        _authState = AuthState.authenticated;
        debugPrint('✅[OTP:${_otpFlowId}] auto-verified uid=$_userId');
        notifyListeners();
      }
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = 'Auto-verification failed. Please enter OTP manually.';
      debugPrint('❌[OTP:${_otpFlowId}] auto sign-in error: $e');
      notifyListeners();
    }
  }

  /// Create or update user document in Firestore
  Future<void> _createOrUpdateUserInFirestore(User user) async {
    try {
      final userDoc = await FirestoreService.getDocument(
        collection: FirestoreService.usersCollection,
        documentId: user.uid,
      );

      if (!userDoc.exists) {
        // New user - create document
        await FirestoreService.createDocument(
          collection: FirestoreService.usersCollection,
          documentId: user.uid,
          data: {
            'phone': user.phoneNumber,
            'role': _userRole?.key,
            'createdAt': DateTime.now().toIso8601String(),
            'isActive': true,
          },
        );
        debugPrint('✅ New user created in Firestore');
      } else {
        final existingData = userDoc.data() ?? const <String, dynamic>{};
        final existingRole = existingData['role'] as String?;

        // Existing user - update last login
        await FirestoreService.updateDocument(
          collection: FirestoreService.usersCollection,
          documentId: user.uid,
          data: {
            'lastLoginAt': DateTime.now().toIso8601String(),
            if (existingRole == null && _userRole != null) 'role': _userRole!.key,
          },
        );

        if (_userRole == null && existingRole != null) {
          _userRole = UserRoleExtension.fromKey(existingRole);
        }
        debugPrint('✅ User last login updated in Firestore');
      }
    } catch (e) {
      debugPrint('⚠️ Firestore user update error (non-fatal): $e');
      // Don't fail auth if Firestore update fails
    }
  }

  Future<UserRole?> _loadRoleFromFirestore(String uid) async {
    try {
      final userDoc = await FirestoreService.getDocument(
        collection: FirestoreService.usersCollection,
        documentId: uid,
      );
      final data = userDoc.data();
      final roleKey = data?['role'] as String?;
      if (roleKey == null || roleKey.isEmpty) {
        return null;
      }
      return UserRoleExtension.fromKey(roleKey);
    } catch (e) {
      debugPrint('⚠️ Unable to load role from Firestore: $e');
      return null;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (_phoneNumber == null) return false;
    return sendOtp(_phoneNumber!);
  }

  /// Save auth state to SharedPreferences
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      if (_userRole != null) {
        await prefs.setString(_userRoleKey, _userRole!.key);
      }
      if (_userId != null) {
        await prefs.setString(_userIdKey, _userId!);
      }
      if (_phoneNumber != null) {
        await prefs.setString(_phoneNumberKey, _phoneNumber!);
      }
    } catch (e) {
      debugPrint('Error saving auth state: $e');
    }
  }

  /// Logout - sign out from Firebase and clear local state
  Future<void> logout() async {
    try {
      debugPrint('🧪[AUTH] logout started uid=$_userId');
      // Sign out from Firebase
      await AuthService.signOut();
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_phoneNumberKey);

      // Reset local state
      _authState = AuthState.unauthenticated;
      _userRole = null;
      _userId = null;
      _phoneNumber = null;
      _errorMessage = null;
      _verificationId = null;
      _resendToken = null;
      
      debugPrint('✅[AUTH] logout completed');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset to role selection (for changing role)
  void resetToRoleSelection() {
    _authState = AuthState.unauthenticated;
    _userRole = null;
    notifyListeners();
  }
}
