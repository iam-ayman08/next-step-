import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.system;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;

  // Custom colors for light theme
  static const Color _lightPrimary = Color(0xFF1E3A8A); // Blue
  static const Color _lightSecondary = Color(0xFF059669); // Green
  static const Color _lightTertiary = Color(0xFF7C3AED); // Purple

  // Custom colors for dark theme
  static const Color _darkPrimary = Color(0xFF3B82F6); // Light blue
  static const Color _darkSecondary = Color(0xFF10B981); // Light green
  static const Color _darkTertiary = Color(0xFF8B5CF6); // Light purple

  Future<void> initialize() async {
    await _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode') ?? 'system';

    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        _isDarkMode = false;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        _isDarkMode = true;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        _isDarkMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
        break;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    switch (mode) {
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
      case ThemeMode.system:
        _isDarkMode = WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
        break;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  // Get theme data for light mode
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightPrimary,
        brightness: Brightness.light,
        primary: _lightPrimary,
        secondary: _lightSecondary,
        tertiary: _lightTertiary,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: _lightPrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.black54,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lightSecondary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: Colors.grey.shade600,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _lightPrimary,
        linearTrackColor: Colors.grey.shade200,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _lightPrimary;
          }
          return Colors.grey.shade300;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _lightPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(color: Colors.grey.shade400),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _lightPrimary;
          }
          return Colors.grey.shade400;
        }),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: _lightPrimary,
        inactiveTrackColor: Colors.grey.shade300,
        thumbColor: _lightPrimary,
        overlayColor: _lightPrimary.withValues(alpha: 0.2),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: _lightPrimary,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: _lightPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey.shade800,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Get theme data for dark mode
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkPrimary,
        brightness: Brightness.dark,
        primary: _darkPrimary,
        secondary: _darkSecondary,
        tertiary: _darkTertiary,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.grey.shade800,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: _darkPrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white60,
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Colors.white70,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkSecondary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.grey.shade900,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: Colors.grey.shade500,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _darkPrimary,
        linearTrackColor: Colors.grey.shade700,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return Colors.grey.shade600;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _darkPrimary;
          }
          return Colors.grey.shade700;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _darkPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(color: Colors.grey.shade600),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _darkPrimary;
          }
          return Colors.grey.shade600;
        }),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: _darkPrimary,
        inactiveTrackColor: Colors.grey.shade700,
        thumbColor: _darkPrimary,
        overlayColor: _darkPrimary.withValues(alpha: 0.2),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        labelColor: _darkPrimary,
        unselectedLabelColor: Colors.grey.shade500,
        indicatorColor: _darkPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.grey.shade800,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey.shade200,
        contentTextStyle: const TextStyle(color: Colors.black87),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Get current theme data
  ThemeData get currentTheme {
    switch (_themeMode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return WidgetsBinding.instance.window.platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;
    }
  }

  // Get theme icon
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.dark_mode;
      case ThemeMode.dark:
        return Icons.light_mode;
      case ThemeMode.system:
        return WidgetsBinding.instance.window.platformBrightness == Brightness.dark
            ? Icons.light_mode
            : Icons.dark_mode;
    }
  }

  // Get theme tooltip
  String get themeTooltip {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Switch to dark mode';
      case ThemeMode.dark:
        return 'Switch to light mode';
      case ThemeMode.system:
        return 'Switch to ${_isDarkMode ? 'light' : 'dark'} mode';
    }
  }
}
