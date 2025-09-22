import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  // User authentication state
  String? _currentUserRole;
  String? _currentUserEmail;
  bool _isLoggedIn = false;

  // App settings
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _language = 'en';

  // Loading states
  final Map<String, bool> _loadingStates = {};
  final Map<String, String?> _errorStates = {};

  // Cached data
  final Map<String, dynamic> _cachedData = {};

  // Getters
  String? get currentUserRole => _currentUserRole;
  String? get currentUserEmail => _currentUserEmail;
  bool get isLoggedIn => _isLoggedIn;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;

  bool isLoading(String key) => _loadingStates[key] ?? false;
  String? getError(String key) => _errorStates[key];
  dynamic getCachedData(String key) => _cachedData[key];

  // Authentication methods
  Future<void> login(String email, String role) async {
    setLoading('auth', true);
    clearError('auth');

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      _currentUserEmail = email;
      _currentUserRole = role;
      _isLoggedIn = true;

      // Save to persistent storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);
      await prefs.setString('user_email', email);
      await prefs.setBool('is_logged_in', true);

      notifyListeners();
    } catch (e) {
      setError('auth', e.toString());
    } finally {
      setLoading('auth', false);
    }
  }

  Future<void> logout() async {
    setLoading('auth', true);

    try {
      // Clear all user data
      _currentUserRole = null;
      _currentUserEmail = null;
      _isLoggedIn = false;

      // Clear persistent storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_role');
      await prefs.remove('user_email');
      await prefs.remove('is_logged_in');

      // Clear cached data
      _cachedData.clear();
      _loadingStates.clear();
      _errorStates.clear();

      notifyListeners();
    } finally {
      setLoading('auth', false);
    }
  }

  Future<void> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserRole = prefs.getString('user_role');
      _currentUserEmail = prefs.getString('user_email');
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      // Load app settings
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'en';

      notifyListeners();
    } catch (e) {
      print('Error loading user session: $e');
    }
  }

  // Settings methods
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);

    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', enabled);

    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);

    notifyListeners();
  }

  // Loading and error state management
  void setLoading(String key, bool loading) {
    _loadingStates[key] = loading;
    notifyListeners();
  }

  void setError(String key, String? error) {
    if (error != null) {
      _errorStates[key] = error;
    } else {
      _errorStates.remove(key);
    }
    notifyListeners();
  }

  void clearError(String key) {
    _errorStates.remove(key);
    notifyListeners();
  }

  void clearAllErrors() {
    _errorStates.clear();
    notifyListeners();
  }

  // Cache management
  void setCachedData(String key, dynamic data) {
    _cachedData[key] = data;
    notifyListeners();
  }

  void removeCachedData(String key) {
    _cachedData.remove(key);
    notifyListeners();
  }

  void clearCache() {
    _cachedData.clear();
    notifyListeners();
  }

  // Bulk operations
  void updateMultipleStates(Map<String, dynamic> updates) {
    updates.forEach((key, value) {
      switch (key) {
        case 'loading':
          if (value is Map<String, bool>) {
            _loadingStates.addAll(value);
          }
          break;
        case 'errors':
          if (value is Map<String, String?>) {
            _errorStates.addAll(value);
          }
          break;
        case 'cache':
          if (value is Map<String, dynamic>) {
            _cachedData.addAll(value);
          }
          break;
      }
    });
    notifyListeners();
  }

  // Performance monitoring
  Map<String, dynamic> getStateStats() {
    return {
      'loadingStates': _loadingStates.length,
      'errorStates': _errorStates.length,
      'cachedData': _cachedData.length,
      'isLoggedIn': _isLoggedIn,
      'userRole': _currentUserRole,
    };
  }

  // Reset all state (for testing or app reset)
  void reset() {
    _currentUserRole = null;
    _currentUserEmail = null;
    _isLoggedIn = false;
    _isDarkMode = false;
    _notificationsEnabled = true;
    _language = 'en';
    _loadingStates.clear();
    _errorStates.clear();
    _cachedData.clear();

    notifyListeners();
  }
}
