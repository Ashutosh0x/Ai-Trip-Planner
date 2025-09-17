import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<void> enableBiometricLogin({required String token}) async {
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'biometrics_enabled', value: 'true');
  }

  Future<void> disableBiometricLogin() async {
    await _storage.delete(key: 'biometrics_enabled');
  }

  Future<bool> isEnabled() async {
    final String? v = await _storage.read(key: 'biometrics_enabled');
    return v == 'true';
  }

  Future<String?> authenticateAndGetToken() async {
    final bool enabled = await isEnabled();
    if (!enabled) return null;

    try {
      final bool didAuth = await _auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (!didAuth) return null;
      return await _storage.read(key: 'auth_token');
    } on PlatformException {
      return null;
    }
  }
}


