import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService extends ChangeNotifier {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;

  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricEnabled = false;

  bool get isBiometricEnabled => _isBiometricEnabled;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    notifyListeners();
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final available = await _localAuth.canCheckBiometrics;
      final biometricTypes = await _localAuth.getAvailableBiometrics();

      // Check if fingerprint is available
      return available && biometricTypes.contains(BiometricType.fingerprint);
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!_isBiometricEnabled) {
      return false;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated;
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
      return false;
    }
  }

  Future<void> enableBiometrics() async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        throw Exception('Biometric authentication not available');
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Enable fingerprint authentication',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        _isBiometricEnabled = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fingerprint_enabled', true);
        notifyListeners();
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      debugPrint('Failed to enable biometrics: $e');
      rethrow;
    }
  }

  Future<void> disableBiometrics() async {
    _isBiometricEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fingerprint_enabled', false);
    notifyListeners();
  }
}
