import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;

  // Singleton pattern
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal() {
    _loadSavedUser();
  }

  // Sign in with Google (simplified - just simulate the process)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // For now, we'll simulate Google sign-in by opening Google's website
      // In a real implementation, you'd integrate with OAuth2 properly
      const String googleUrl = 'https://accounts.google.com/signin';

      if (await canLaunchUrl(Uri.parse(googleUrl))) {
        await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);

        // Simulate successful login for demo purposes
        // In production, you would need proper OAuth2 flow
        _isLoggedIn = true;
        _userEmail = 'user@gmail.com'; // This would come from OAuth
        _userName = 'Google User'; // This would come from OAuth

        await _saveUserData(_userEmail!, _userName!);

        return {
          'email': _userEmail,
          'name': _userName,
          'success': true,
        };
      } else {
        throw 'Could not launch Google sign-in';
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    await _clearUserData();
  }

  // Check if user is signed in
  bool get isSignedIn => _isLoggedIn;

  // Get user profile data
  Map<String, dynamic>? getUserProfile() {
    if (_isLoggedIn && _userEmail != null && _userName != null) {
      return {
        'email': _userEmail,
        'name': _userName,
        'success': true,
      };
    }
    return null;
  }

  // Save user data to shared preferences
  Future<void> _saveUserData(String email, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('google_logged_in', true);
    await prefs.setString('google_user_email', email);
    await prefs.setString('google_user_name', name);
  }

  // Clear user data from shared preferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_logged_in');
    await prefs.remove('google_user_email');
    await prefs.remove('google_user_name');
  }

  // Load user data from shared preferences
  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('google_logged_in') ?? false;
    _userEmail = prefs.getString('google_user_email');
    _userName = prefs.getString('google_user_name');
  }
}
