import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      print('Biometric availability check failed: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Failed to get available biometrics: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate({
    String reason = 'Authenticate to access your account',
    bool biometricOnly = false,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          sensitiveTransaction: true,
        ),
      );

      if (didAuthenticate) {
        // Store successful authentication timestamp
        await _secureStorage.write(
          key: 'last_biometric_auth',
          value: DateTime.now().toIso8601String(),
        );
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Biometric authentication failed: $e');
      return false;
    }
  }

  // Check if user has authenticated recently (within last 5 minutes)
  Future<bool> hasRecentAuthentication() async {
    try {
      final String? lastAuth = await _secureStorage.read(key: 'last_biometric_auth');

      if (lastAuth == null) return false;

      final DateTime lastAuthTime = DateTime.parse(lastAuth);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(lastAuthTime);

      // Consider valid for 5 minutes
      return difference.inMinutes < 5;
    } catch (e) {
      print('Failed to check recent authentication: $e');
      return false;
    }
  }

  // Authenticate with fallback to PIN/pattern if biometrics fail
  Future<bool> authenticateWithFallback({
    String reason = 'Authenticate to access your account',
    bool allowFallback = true,
  }) async {
    try {
      // First try biometrics
      final bool biometricSuccess = await authenticate(reason: reason);

      if (biometricSuccess) {
        return true;
      }

      // If biometrics failed and fallback is allowed, try device credentials
      if (allowFallback) {
        return await authenticate(
          reason: '$reason (Fallback to device credentials)',
          biometricOnly: false,
        );
      }

      return false;
    } catch (e) {
      print('Authentication with fallback failed: $e');
      return false;
    }
  }

  // Store biometric preference
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: 'biometric_enabled',
        value: enabled.toString(),
      );
    } catch (e) {
      print('Failed to store biometric preference: $e');
    }
  }

  // Get biometric preference
  Future<bool> isBiometricEnabled() async {
    try {
      final String? enabled = await _secureStorage.read(key: 'biometric_enabled');
      return enabled == 'true';
    } catch (e) {
      print('Failed to get biometric preference: $e');
      return false;
    }
  }

  // Clear all biometric data
  Future<void> clearBiometricData() async {
    try {
      await _secureStorage.delete(key: 'last_biometric_auth');
      await _secureStorage.delete(key: 'biometric_enabled');
    } catch (e) {
      print('Failed to clear biometric data: $e');
    }
  }

  // Get biometric type display name
  String getBiometricTypeDisplayName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      default:
        return 'Biometric';
    }
  }

  // Check if biometric setup is complete
  Future<bool> isBiometricSetupComplete() async {
    final bool available = await isBiometricAvailable();
    final bool enabled = await isBiometricEnabled();
    return available && enabled;
  }

  // Setup biometric authentication
  Future<bool> setupBiometricAuthentication() async {
    try {
      final bool available = await isBiometricAvailable();

      if (!available) {
        throw Exception('Biometric authentication is not available on this device');
      }

      // Test authentication
      final bool testAuth = await authenticate(
        reason: 'Set up biometric authentication',
      );

      if (testAuth) {
        await setBiometricEnabled(true);
        return true;
      } else {
        throw Exception('Biometric authentication test failed');
      }
    } catch (e) {
      print('Biometric setup failed: $e');
      await setBiometricEnabled(false);
      return false;
    }
  }

  // Disable biometric authentication
  Future<void> disableBiometricAuthentication() async {
    await setBiometricEnabled(false);
    await clearBiometricData();
  }

  // Get authentication status
  Future<BiometricStatus> getBiometricStatus() async {
    final bool available = await isBiometricAvailable();
    final bool enabled = await isBiometricEnabled();
    final bool recentAuth = await hasRecentAuthentication();

    if (!available) {
      return BiometricStatus.notAvailable;
    } else if (!enabled) {
      return BiometricStatus.disabled;
    } else if (recentAuth) {
      return BiometricStatus.authenticated;
    } else {
      return BiometricStatus.available;
    }
  }
}

enum BiometricStatus {
  notAvailable,
  disabled,
  available,
  authenticated,
}
