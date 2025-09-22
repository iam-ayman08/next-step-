import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Security service for handling sensitive data and encryption
class SecurityService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _userTokenKey = 'user_token';
  static const String _userCredentialsKey = 'user_credentials';
  static const String _biometricEnabledKey = 'biometric_enabled';

  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  late encrypt.Key _encryptionKey;
  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  // Initialize security service
  Future<void> initialize() async {
    try {
      // Get or generate encryption key
      String? keyString = await _secureStorage.read(key: _encryptionKeyKey);

      if (keyString == null) {
        // Generate a new encryption key
        final key = encrypt.Key.fromSecureRandom(32);
        keyString = base64Encode(key.bytes);
        await _secureStorage.write(key: _encryptionKeyKey, value: keyString);
      }

      _encryptionKey = encrypt.Key(base64Decode(keyString));
      _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));
      _iv = encrypt.IV.fromLength(16);

      debugPrint('Security service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize security service: $e');
      throw Exception('Security service initialization failed');
    }
  }

  // Encrypt data
  String encryptData(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      debugPrint('Failed to encrypt data: $e');
      throw Exception('Data encryption failed');
    }
  }

  // Decrypt data
  String decryptData(String encryptedData) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      return decrypted;
    } catch (e) {
      debugPrint('Failed to decrypt data: $e');
      throw Exception('Data decryption failed');
    }
  }

  // Store sensitive data securely
  Future<void> storeSecureData(String key, String data) async {
    try {
      final encryptedData = encryptData(data);
      await _secureStorage.write(key: key, value: encryptedData);
      debugPrint('Data stored securely: $key');
    } catch (e) {
      debugPrint('Failed to store secure data: $e');
      throw Exception('Secure data storage failed');
    }
  }

  // Retrieve sensitive data securely
  Future<String?> retrieveSecureData(String key) async {
    try {
      final encryptedData = await _secureStorage.read(key: key);
      if (encryptedData != null) {
        return decryptData(encryptedData);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to retrieve secure data: $e');
      return null;
    }
  }

  // Delete sensitive data
  Future<void> deleteSecureData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      debugPrint('Secure data deleted: $key');
    } catch (e) {
      debugPrint('Failed to delete secure data: $e');
    }
  }

  // Store user authentication token
  Future<void> storeAuthToken(String token) async {
    await storeSecureData(_userTokenKey, token);
  }

  // Retrieve user authentication token
  Future<String?> getAuthToken() async {
    return retrieveSecureData(_userTokenKey);
  }

  // Store user credentials
  Future<void> storeUserCredentials(String email, String password) async {
    final credentials = jsonEncode({
      'email': email,
      'password': password,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await storeSecureData(_userCredentialsKey, credentials);
  }

  // Retrieve user credentials
  Future<Map<String, dynamic>?> getUserCredentials() async {
    try {
      final credentialsString = await retrieveSecureData(_userCredentialsKey);
      if (credentialsString != null) {
        return jsonDecode(credentialsString);
      }
      return null;
    } catch (e) {
      debugPrint('Failed to retrieve user credentials: $e');
      return null;
    }
  }

  // Clear all stored data
  Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      debugPrint('All secure data cleared');
    } catch (e) {
      debugPrint('Failed to clear secure data: $e');
    }
  }

  // Hash sensitive data (for additional security)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validate password strength
  static bool isPasswordStrong(String password) {
    // At least 8 characters, contains uppercase, lowercase, number, and special character
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    return hasMinLength &&
        hasUppercase &&
        hasLowercase &&
        hasNumbers &&
        hasSpecialCharacters;
  }

  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  // Sanitize input data
  static String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input.replaceAll(RegExp(r'[<>"/\\|?*]'), '');
  }

  // Generate secure random string
  static String generateSecureToken([int length = 32]) {
    final random = encrypt.Key.fromSecureRandom(length);
    return base64Encode(
      random.bytes,
    ).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }

  // Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  // Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: enabled.toString(),
      );
      debugPrint(
        'Biometric authentication ${enabled ? 'enabled' : 'disabled'}',
      );
    } catch (e) {
      debugPrint('Failed to set biometric preference: $e');
    }
  }

  // Validate input data
  static Map<String, String?> validateUserInput({
    required String email,
    required String password,
    String? confirmPassword,
    String? name,
  }) {
    final errors = <String, String?>{};

    // Email validation
    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    // Password validation
    if (password.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (!isPasswordStrong(password)) {
      errors['password'] =
          'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
    }

    // Confirm password validation
    if (confirmPassword != null && password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    // Name validation
    if (name != null && name.isEmpty) {
      errors['name'] = 'Name is required';
    }

    return errors;
  }

  // Log security events
  void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    final logEntry = {
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      'details': details ?? {},
    };

    debugPrint('Security Event: ${jsonEncode(logEntry)}');

    // In a production app, you would send this to a security monitoring service
  }
}

// Input validation utilities
class InputValidator {
  // Validate text input
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!SecurityService.isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!SecurityService.isPasswordStrong(value)) {
      return 'Password must be at least 8 characters with uppercase, lowercase, number, and special character';
    }
    return null;
  }

  // Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    final urlRegExp = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  // Validate length
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  // Sanitize and validate combined
  static String? sanitizeAndValidate(
    String? value,
    String fieldName, {
    bool required = true,
    int? minLength,
    int? maxLength,
    bool isEmail = false,
    bool isPassword = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? '$fieldName is required' : null;
    }

    // Sanitize input
    final sanitized = SecurityService.sanitizeInput(value);

    if (isEmail) {
      return validateEmail(sanitized);
    }

    if (isPassword) {
      return validatePassword(sanitized);
    }

    if (minLength != null && sanitized.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (maxLength != null && sanitized.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }
}

// Security audit trail
class SecurityAudit {
  static final List<Map<String, dynamic>> _auditLog = [];

  static void logEvent(
    String event,
    String userId, {
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
  }) {
    final auditEntry = {
      'event': event,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
      'details': details ?? {},
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };

    _auditLog.add(auditEntry);

    // Keep only last 1000 entries
    if (_auditLog.length > 1000) {
      _auditLog.removeAt(0);
    }

    debugPrint('Security Audit: $event by $userId');
  }

  static List<Map<String, dynamic>> getAuditLog({
    String? userId,
    String? event,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _auditLog.where((entry) {
      if (userId != null && entry['userId'] != userId) return false;
      if (event != null && entry['event'] != event) return false;

      final entryDate = DateTime.parse(entry['timestamp']);
      if (startDate != null && entryDate.isBefore(startDate)) return false;
      if (endDate != null && entryDate.isAfter(endDate)) return false;

      return true;
    }).toList();
  }

  static void clearAuditLog() {
    _auditLog.clear();
    debugPrint('Security audit log cleared');
  }
}
