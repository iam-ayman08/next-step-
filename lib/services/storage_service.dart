import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../utils/config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  late encrypt.Encrypter _encrypter;
  late encrypt.IV _iv;

  factory StorageService() => _instance;

  StorageService._internal() {
    // Initialize encryption with a key from config
    final key = encrypt.Key.fromSecureRandom(32);
    // In production, use appConfig.encryptionKey
    _encrypter = encrypt.Encrypter(encrypt.AES(key));
    _iv = encrypt.IV.fromSecureRandom(16);
  }

  Future<void> initialize() async {
    // Any async initialization can be done here
    // For now, validate storage on initialization
    final isValid = await validateStorage();
    if (isValid) {
      print('❇ Storage service initialized successfully');
    } else {
      print('⚠ Storage service validation failed');
    }
  }

  // Secure Storage Methods
  Future<void> writeSecure(String key, String value) async {
    try {
      final encryptedValue = _encrypt(value);
      await _secureStorage.write(key: key, value: encryptedValue);
    } catch (e) {
      throw Exception('Failed to secure write: $e');
    }
  }

  Future<String?> readSecure(String key) async {
    try {
      final encryptedValue = await _secureStorage.read(key: key);
      if (encryptedValue == null) return null;
      return _decrypt(encryptedValue);
    } catch (e) {
      throw Exception('Failed to secure read: $e');
    }
  }

  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw Exception('Failed to secure delete: $e');
    }
  }

  Future<void> clearAllSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear secure storage: $e');
    }
  }

  // Regular Storage Methods
  Future<void> write(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      throw Exception('Failed to write: $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      throw Exception('Failed to read: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  // User Session Management
  Future<void> saveUserSession(String userId, String token, String refreshToken) async {
    try {
      await writeSecure('user_id', userId);
      await writeSecure('auth_token', token);
      await writeSecure('refresh_token', refreshToken);
      await writeSecure('session_start', DateTime.now().toIso8601String());
      await writeSecure('session_expires', DateTime.now().add(Duration(minutes: appConfig.sessionTimeout)).toIso8601String());
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  Future<Map<String, String?>> getUserSession() async {
    try {
      return {
        'user_id': await readSecure('user_id'),
        'auth_token': await readSecure('auth_token'),
        'refresh_token': await readSecure('refresh_token'),
        'session_start': await readSecure('session_start'),
        'session_expires': await readSecure('session_expires'),
      };
    } catch (e) {
      throw Exception('Failed to get session: $e');
    }
  }

  Future<void> clearUserSession() async {
    try {
      await deleteSecure('user_id');
      await deleteSecure('auth_token');
      await deleteSecure('refresh_token');
      await deleteSecure('session_start');
      await deleteSecure('session_expires');

      // Also clear user preferences
      await delete('user_preferences');
      await delete('last_login');
    } catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }

  Future<bool> isSessionValid() async {
    try {
      final sessionExpires = await readSecure('session_expires');
      if (sessionExpires == null) return false;

      final expiresAt = DateTime.parse(sessionExpires);
      return expiresAt.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final prefsJson = preferences.toString();
      await write('user_preferences', prefsJson);
    } catch (e) {
      throw Exception('Failed to update preferences: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final prefsJson = await read('user_preferences');
      if (prefsJson == null) return null;

      // Basic JSON parsing (in production might want more robust solution)
      return {'preferences': prefsJson};
    } catch (e) {
      throw Exception('Failed to get preferences: $e');
    }
  }

  // Cache Management
  Future<void> setCache(String key, String value, {int? minutes}) async {
    try {
      final cacheKey = 'cache_$key';
      final expiry = DateTime.now().add(Duration(minutes: minutes ?? appConfig.cacheDurationMinutes));
      final cacheObject = {
        'value': value,
        'expiry': expiry.toIso8601String(),
      };

      await write(cacheKey, cacheObject.toString());
    } catch (e) {
      throw Exception('Failed to set cache: $e');
    }
  }

  Future<String?> getCache(String key) async {
    try {
      final cacheKey = 'cache_$key';
      final cacheString = await read(cacheKey);
      if (cacheString == null) return null;

      // Parse cache object (basic implementation)
      // In production, consider proper JSON serialization
      final cached = {'value': cacheString, 'expiry': DateTime.now().add(Duration(days: 1)).toIso8601String()};
      final expiry = DateTime.parse(cached['expiry']!);

      if (expiry.isBefore(DateTime.now())) {
        await delete(cacheKey);
        return null;
      }

      return cached['value'];
    } catch (e) {
      throw Exception('Failed to get cache: $e');
    }
  }

  Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith('cache_'));

      for (final key in cacheKeys) {
        await getCache(key.substring(6)); // Remove 'cache_' prefix
      }
    } catch (e) {
      throw Exception('Failed to clear expired cache: $e');
    }
  }

  // Data Backup and Restore
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final session = await getUserSession();
      final preferences = await getUserPreferences();

      return {
        'session': session,
        'preferences': preferences,
        'exported_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }

  Future<void> importUserData(Map<String, dynamic> data) async {
    try {
      if (data.containsKey('session')) {
        final session = data['session'] as Map<String, String?>;
        await writeSecure('user_id', session['user_id']!);
        await writeSecure('auth_token', session['auth_token']!);
        await writeSecure('refresh_token', session['refresh_token']!);
        await writeSecure('session_start', session['session_start']!);
        await writeSecure('session_expires', session['session_expires']!);
      }

      if (data.containsKey('preferences')) {
        await updateUserPreferences(data['preferences'] as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception('Failed to import user data: $e');
    }
  }

  // Encryption helpers
  String _encrypt(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  String _decrypt(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }

  // Storage validation
  Future<bool> validateStorage() async {
    try {
      const testKey = 'storage_test';
      const testValue = 'test_value';

      await writeSecure(testKey, testValue);
      final readValue = await readSecure(testKey);
      await deleteSecure(testKey);

      return readValue == testValue;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> getStorageStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      return {
        'total_keys': keys.length,
        'cache_keys': keys.where((key) => key.startsWith('cache_')).length,
        'user_keys': keys.where((key) => key.startsWith('user_')).length,
        'other_keys': keys.where((key) => !key.startsWith('cache_') && !key.startsWith('user_')).length,
      };
    } catch (e) {
      throw Exception('Failed to get storage stats: $e');
    }
  }
}

// Global storage instance
final storageService = StorageService();
