import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Wrapper around local_auth so UI code stays simple and testable.
class BiometricService {
  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Biometric check failed (device support): $e');
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Biometric check failed (canCheckBiometrics): $e');
      return false;
    }
  }

  Future<bool> hasEnrolledBiometrics() async {
    try {
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (e) {
      debugPrint('Biometric check failed (available biometrics): $e');
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
      return false;
    }
  }
}

