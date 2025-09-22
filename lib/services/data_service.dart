import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  static const String _opportunitiesKey = 'opportunities';
  static const String _networkingDataKey = 'networkingData';
  static const String _userProfileKey = 'userProfile';
  static const String _appSettingsKey = 'appSettings';

  // Generic data operations
  Future<T?> getData<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        final jsonData = json.decode(jsonString);
        return fromJson(jsonData);
      }
    } catch (e) {
      print('Error loading data for key $key: $e');
    }
    return null;
  }

  Future<void> saveData<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(toJson(data));
      await prefs.setString(key, jsonString);
    } catch (e) {
      print('Error saving data for key $key: $e');
      rethrow;
    }
  }

  Future<void> deleteData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      print('Error deleting data for key $key: $e');
    }
  }

  // Specific data operations for opportunities
  Future<List<Map<String, dynamic>>> getOpportunities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_opportunitiesKey);
      if (jsonString != null) {
        final jsonData = json.decode(jsonString) as List<dynamic>;
        return jsonData.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error loading opportunities: $e');
    }
    return [];
  }

  Future<void> saveOpportunities(
    List<Map<String, dynamic>> opportunities,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(opportunities);
      await prefs.setString(_opportunitiesKey, jsonString);
    } catch (e) {
      print('Error saving opportunities: $e');
      rethrow;
    }
  }

  // Specific data operations for networking
  Future<Map<String, dynamic>?> getNetworkingData() async {
    return getData<Map<String, dynamic>>(
      _networkingDataKey,
      (json) => json,
    );
  }

  Future<void> saveNetworkingData(Map<String, dynamic> networkingData) async {
    await saveData<Map<String, dynamic>>(
      _networkingDataKey,
      networkingData,
      (data) => data,
    );
  }

  // Specific data operations for user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    return getData<Map<String, dynamic>>(
      _userProfileKey,
      (json) => json,
    );
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await saveData<Map<String, dynamic>>(
      _userProfileKey,
      profile,
      (data) => data,
    );
  }

  // Specific data operations for app settings
  Future<Map<String, dynamic>?> getAppSettings() async {
    return getData<Map<String, dynamic>>(
      _appSettingsKey,
      (json) => json,
    );
  }

  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await saveData<Map<String, dynamic>>(
      _appSettingsKey,
      settings,
      (data) => data,
    );
  }

  // Clear all data (for logout or reset)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Check if data exists
  Future<bool> hasData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  // Get storage info
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final data = <String, dynamic>{};

      for (final key in keys) {
        final value = prefs.get(key);
        if (value != null) {
          data[key] = value.toString().length; // Approximate size in characters
        }
      }

      return {
        'totalKeys': keys.length,
        'keys': keys.toList(),
        'approximateSize': data.values.fold<int>(
          0,
          (sum, size) => sum + (size as int),
        ),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
