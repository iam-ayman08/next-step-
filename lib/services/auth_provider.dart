import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String _userRole = '';

  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;

  final AuthService _authService = AuthService();

  void login(String username, String password) async {
    // Use real username/password authentication
    try {
      final result = await _authService.signInWithCredentials(username, password);
      if (result.success && result.user != null) {
        _isAuthenticated = true;
        _userRole = result.user!.role;
        notifyListeners();
      }
    } catch (e) {
      _isAuthenticated = false;
      _userRole = '';
      notifyListeners();
    }
  }

  void register(String username, String email, String password, String name, String role) async {
    // Use real registration
    try {
      final result = await _authService.registerWithCredentials(username, email, password, name, role);
      if (result.success && result.user != null) {
        _isAuthenticated = true;
        _userRole = result.user!.role;
        notifyListeners();
      }
    } catch (e) {
      _isAuthenticated = false;
      _userRole = '';
      notifyListeners();
    }
  }

  void logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _userRole = '';
    notifyListeners();
  }
}
