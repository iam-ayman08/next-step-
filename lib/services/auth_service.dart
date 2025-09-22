import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'database_service.dart';
import 'dart:convert'; // For JSON handling

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _userEmailKey = 'user_email';
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'user_id';
  static const String _lastLoginKey = 'last_login';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static Future<void> initialize() async {
    // Any async initialization can be done here
    print('Auth service initialized successfully');
  }

  // Stream to notify authentication state changes
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get authStateStream => _authStateController.stream;

  AuthState _currentAuthState = AuthState.unauthenticated;
  AuthState get currentAuthState => _currentAuthState;

  void _updateAuthState(AuthState state) {
    _currentAuthState = state;
    _authStateController.add(state);
  }

  // Username/Password Authentication Methods
  Future<AuthResult> signInWithCredentials(String username, String password) async {
    try {
      _updateAuthState(AuthState.authenticating);

      // Call login API
      final response = await _apiService.login(username, password);

      if (response['access_token'] != null) {
        final token = response['access_token'];
        final userData = response['user'];

        // Store tokens securely
        await _secureStorage.write(key: _accessTokenKey, value: token);
        await _secureStorage.write(key: _userEmailKey, value: userData['email']);
        await _secureStorage.write(key: _usernameKey, value: userData['username']);
        await _secureStorage.write(key: _userIdKey, value: userData['id']);

        // Create UserModel from backend response
        final user = UserModel.fromJson({
          'uid': userData['id'],
          'email': userData['email'],
          'fullName': userData['name'],
          'username': userData['username'],
          'role': userData['role'] ?? 'student',
          'provider': 'credentials',
          'isVerified': true,
        });

        // Store user data in SQLite
        await _dbService.insertOrUpdateUser(user);
        await _dbService.updateLastLogin(userData['email']);

        _updateAuthState(AuthState.authenticated);
        return AuthResult.success(user);
      } else {
        _updateAuthState(AuthState.unauthenticated);
        return AuthResult.failure('Login failed: Invalid response from server');
      }

    } catch (e) {
      print('Login error: $e');
      _updateAuthState(AuthState.unauthenticated);

      String errorMessage = 'Login failed';
      final errorString = e.toString();

      if (errorString.contains('Invalid username or password')) {
        errorMessage = 'Invalid username or password. Please check your credentials and try again.';
      } else if (errorString.contains('Network error')) {
        errorMessage = 'Network error occurred. Please check your internet connection and try again.';
      } else if (errorString.contains('Account is disabled')) {
        errorMessage = 'Your account has been disabled. Please contact support.';
      } else {
        errorMessage = 'An unexpected error occurred during login. Please try again or contact support if the problem persists.';
      }

      return AuthResult.failure(errorMessage);
    }
  }

  Future<AuthResult> registerWithCredentials(String username, String email, String password, String name, String role) async {
    try {
      _updateAuthState(AuthState.authenticating);

      // Call register API
      final response = await _apiService.register(username, email, password, name, role);

      if (response['access_token'] != null) {
        final token = response['access_token'];
        final userData = response['user'];

        // Store tokens securely
        await _secureStorage.write(key: _accessTokenKey, value: token);
        await _secureStorage.write(key: _userEmailKey, value: userData['email']);
        await _secureStorage.write(key: _usernameKey, value: userData['username']);
        await _secureStorage.write(key: _userIdKey, value: userData['id']);

        // Create UserModel from backend response
        final user = UserModel.fromJson({
          'uid': userData['id'],
          'email': userData['email'],
          'fullName': userData['name'],
          'username': userData['username'],
          'role': userData['role'] ?? 'student',
          'provider': 'credentials',
          'isVerified': true,
        });

        // Store user data in SQLite
        await _dbService.insertOrUpdateUser(user);
        await _dbService.updateLastLogin(userData['email']);

        _updateAuthState(AuthState.authenticated);
        return AuthResult.success(user);
      } else {
        _updateAuthState(AuthState.unauthenticated);
        return AuthResult.failure('Registration failed: Invalid response from server');
      }

    } catch (e) {
      print('Registration error: $e');
      _updateAuthState(AuthState.unauthenticated);

      String errorMessage = 'Registration failed';
      final errorString = e.toString();

      if (errorString.contains('Username already exists')) {
        errorMessage = 'Username already exists. Please choose a different username.';
      } else if (errorString.contains('Email already exists')) {
        errorMessage = 'Email already exists. Please use a different email address.';
      } else if (errorString.contains('Network error')) {
        errorMessage = 'Network error occurred. Please check your internet connection and try again.';
      } else {
        errorMessage = 'An unexpected error occurred during registration. Please try again or contact support if the problem persists.';
      }

      return AuthResult.failure(errorMessage);
    }
  }

  // Auto-Reauthentication Methods
  Future<bool> tryAutoReauthentication() async {
    try {
      // Check if we have stored access token
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken == null) {
        return false;
      }

      // Verify token with backend
      final response = await _apiService.verifyToken();
      if (response['valid'] == true) {
        final userData = response['user'];

        // Update secure storage if needed
        await _secureStorage.write(key: _userEmailKey, value: userData['email']);
        await _secureStorage.write(key: _usernameKey, value: userData['username']);
        await _secureStorage.write(key: _userIdKey, value: userData['id']);

        // Update database
        await _dbService.updateLastLogin(userData['email']);

        _updateAuthState(AuthState.authenticated);
        return true;
      } else {
        return false;
      }

    } catch (e) {
      print('Auto-reauthentication failed: $e');
      return false;
    }
  }

  Future<UserModel?> getLastLoggedInUser() async {
    try {
      final lastUser = await _dbService.getLastLoggedInUser();
      return lastUser;
    } catch (e) {
      print('Error getting last logged in user: $e');
      return null;
    }
  }

  // Logout Methods
  Future<void> logout() async {
    try {
      // Clear secure storage
      await _secureStorage.deleteAll();

      // Clear database login info if needed
      // (You might want to keep user data but clear session info)

      _updateAuthState(AuthState.unauthenticated);

    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Token Management Methods
  Future<String?> getStoredAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getStoredUserEmail() async {
    return await _secureStorage.read(key: _userEmailKey);
  }

  Future<String?> getStoredUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  Future<String?> getStoredUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  Future<Map<String, String?>> getStoredAuthData() async {
    final accessToken = await getStoredAccessToken();
    final userEmail = await getStoredUserEmail();
    final username = await getStoredUsername();
    final userId = await getStoredUserId();

    return {
      'accessToken': accessToken,
      'userEmail': userEmail,
      'username': username,
      'userId': userId,
    };
  }

  // Utility Methods
  Future<bool> isUserAuthenticated() async {
    final accessToken = await getStoredAccessToken();
    return accessToken != null;
  }

  Future<void> clearAuthData() async {
    await _secureStorage.deleteAll();
    _updateAuthState(AuthState.unauthenticated);
  }

  void dispose() {
    _authStateController.close();
  }
}

// Auth Result class for better error handling
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({required this.success, this.user, this.errorMessage});

  factory AuthResult.success(UserModel user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(success: false, errorMessage: errorMessage);
  }
}

// Auth State enum
enum AuthState {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}
