import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'splash_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/auth_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/file_upload_widget.dart';
import '../services/biometric_service.dart';

// Custom gradient background widget
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: child,
    );
  }
}

// Enhanced form field with better styling
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.inter(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            size: 20,
          ),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]?.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

// Enhanced button with loading state
class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isPrimary;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.transparent : Theme.of(context).colorScheme.surface,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final UserType userType;
  const LoginPage({super.key, required this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  String role = "student";
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final extraController = TextEditingController();
  final extra2Controller = TextEditingController();

  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late AnimationController _formAnimationController;
  late Animation<Offset> _formSlideAnimation;
  late AnimationController _passwordStrengthController;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _showPasswordStrength = false;
  double _passwordStrength = 0.0;
  String _passwordStrengthText = "";
  Color _passwordStrengthColor = Colors.red;

  // Password strength criteria
  final List<String> _strengthCriteria = [
    "At least 8 characters",
    "Contains uppercase letter",
    "Contains lowercase letter",
    "Contains number",
    "Contains special character",
  ];

  @override
  void initState() {
    super.initState();
    role = widget.userType == UserType.student ? "student" : "alumni";

    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeIn),
    );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formAnimationController,
            curve: Curves.easeOut,
          ),
        );

    _startAnimations();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Start form animations and ensure they complete
    _formAnimationController.forward();

    // Add animation listener to ensure completion
    Completer<void> completer = Completer<void>();
    void listener() {
      if (_formAnimationController.isCompleted && !completer.isCompleted) {
        completer.complete();
        _formAnimationController.removeListener(listener);
      }
    }
    _formAnimationController.addListener(listener);

    // Wait for animation to complete or timeout after 2 seconds
    await completer.future.timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        _formAnimationController.removeListener(listener);
        return null;
      },
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Use our new API service for authentication
        final apiService = ApiService();

        // Call login API through our service
        final loginData = await apiService.login(
          emailController.text.trim(),
          passController.text.trim(),
        );

        if (loginData['access_token'] != null) {
          // Login successful
          final token = loginData['access_token'];

          // Save token and role using our service
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("auth_token", token);
          await prefs.setString("role", role);

          // Get user profile to verify login
          try {
            final user = await apiService.getCurrentUser();

            // Navigate to main page with user data
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MainPage(role: role),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
              ),
            );
          } catch (e) {
            // If getting user profile fails, still proceed with login
            print('Warning: Could not fetch user profile: $e');
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MainPage(role: role),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
              ),
            );
          }
        } else {
          // Login failed - no token returned
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Login failed: Invalid credentials"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
        }
      } catch (e) {
        // Network error or other exception
        String errorMessage = 'Login failed';

        if (e.toString().contains('Network error')) {
          errorMessage = 'Network error: Please check your connection';
        } else if (e.toString().contains('Invalid credentials')) {
          errorMessage = 'Invalid email or password';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timeout: Please try again';
        } else {
          errorMessage = 'Login failed: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveRole(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("role", role);
  }

  void _calculatePasswordStrength(String password) {
    int score = 0;

    // Length check
    if (password.length >= 8) score += 20;
    if (password.length >= 12) score += 10;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score += 20;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 20;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 15;

    setState(() {
      _passwordStrength = score / 100.0;

      if (score < 40) {
        _passwordStrengthText = "Weak";
        _passwordStrengthColor = Colors.red;
      } else if (score < 70) {
        _passwordStrengthText = "Medium";
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrengthText = "Strong";
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  bool _checkPasswordCriteria(String password, String criteria) {
    switch (criteria) {
      case "At least 8 characters":
        return password.length >= 8;
      case "Contains uppercase letter":
        return RegExp(r'[A-Z]').hasMatch(password);
      case "Contains lowercase letter":
        return RegExp(r'[a-z]').hasMatch(password);
      case "Contains number":
        return RegExp(r'[0-9]').hasMatch(password);
      case "Contains special character":
        return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      default:
        return false;
    }
  }

  void _showRegistrationDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    String registerRole = "student";
    final registerFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Create Account"),
              content: SingleChildScrollView(
                child: Form(
                  key: registerFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter a username";
                          }
                          if (val.length < 3) {
                            return "Username must be at least 3 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!val.contains("@")) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter your full name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter a password";
                          }
                          if (val.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                        ),
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(8),
                          isSelected: [registerRole == "student", registerRole == "alumni"],
                          onPressed: (index) {
                            setState(() {
                              registerRole = index == 0 ? "student" : "alumni";
                            });
                          },
                          fillColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                          selectedColor: Theme.of(context).colorScheme.secondary,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Text("Student"),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Text("Alumni"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (registerFormKey.currentState!.validate()) {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: LoadingWidget(
                            message: 'Creating account...',
                            loadingType: LoadingType.dots,
                            size: 40,
                          ),
                        ),
                      );

                      try {
                        // Use our API service for registration
                        final apiService = ApiService();

                        // Call registration API through our service
                        final registerData = await apiService.register(
                          usernameController.text.trim(),
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          nameController.text.trim(),
                          registerRole,
                        );

                        // Close loading dialog
                        Navigator.of(context).pop();

                        if (registerData['access_token'] != null) {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Account created successfully! Please login."),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          );

                          // Close registration dialog
                          Navigator.of(context).pop();
                        } else {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Registration failed: Please try again"),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        // Close loading dialog
                        Navigator.of(context).pop();

                        // Show error message
                        String errorMessage = 'Registration failed';

                        if (e.toString().contains('Network error')) {
                          errorMessage = 'Network error: Please check your connection';
                        } else if (e.toString().contains('already exists')) {
                          errorMessage = 'Username or email already exists';
                        } else if (e.toString().contains('timeout')) {
                          errorMessage = 'Connection timeout: Please try again';
                        } else {
                          errorMessage = 'Registration failed: ${e.toString()}';
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: const Text("Register"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.userType == UserType.student;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isStudent
                ? [
                    const Color(0xFF1E3A8A), // Student blue
                    const Color(0xFF1E40AF),
                    const Color(0xFF3B82F6),
                  ]
                : [
                    const Color(0xFF059669), // Alumni green
                    const Color(0xFF047857),
                    const Color(0xFF10B981),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // User-specific Logo Section
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isStudent
                                ? [
                                    const Color(0xFF3B82F6),
                                    const Color(0xFF1D4ED8),
                                  ]
                                : [
                                    const Color(0xFF10B981),
                                    const Color(0xFF059669),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isStudent
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF10B981)).withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              isStudent ? Icons.school : Icons.business_center,
                              color: isStudent
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF059669),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User-specific Welcome Text
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          isStudent ? "Welcome Student!" : "Welcome Alumni!",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isStudent
                              ? "Launch your career journey with us"
                              : "Advance your professional network",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // User-specific Form Card
                  SlideTransition(
                    position: _formSlideAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.95),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isStudent ? "Student Login" : "Alumni Login",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isStudent
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isStudent
                                ? "Enter your student credentials"
                                : "Enter your alumni credentials",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Form Fields
                          CustomTextField(
                            controller: emailController,
                            label: "Email Address",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return "Please enter your email";
                              }
                              if (!val.contains("@")) return "Please enter a valid email";
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Enhanced Password Field with visibility toggle
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: passController,
                              obscureText: _obscurePassword,
                              onChanged: (value) {
                                setState(() {
                                  _showPasswordStrength = value.isNotEmpty;
                                  _calculatePasswordStrength(value);
                                });
                              },
                              style: GoogleFonts.inter(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: GoogleFonts.inter(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[900]?.withOpacity(0.8)
                                    : Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please enter your password";
                                }
                                if (val.length < 8) {
                                  return "Password must be at least 8 characters";
                                }
                                return null;
                              },
                            ),
                          ),

                          // Password Strength Indicator
                          if (_showPasswordStrength) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey[50],
                                border: Border.all(
                                  color: _passwordStrengthColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _passwordStrength >= 0.8
                                            ? Icons.check_circle
                                            : _passwordStrength >= 0.6
                                                ? Icons.warning
                                                : Icons.error,
                                        color: _passwordStrengthColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Password Strength: $_passwordStrengthText",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _passwordStrengthColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: _passwordStrength,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                                  ),
                                  const SizedBox(height: 8),
                                  ..._strengthCriteria.map((criteria) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _checkPasswordCriteria(passController.text, criteria)
                                              ? Icons.check
                                              : Icons.close,
                                          size: 12,
                                          color: _checkPasswordCriteria(passController.text, criteria)
                                              ? Colors.green
                                              : Colors.grey[400],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          criteria,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: _checkPasswordCriteria(passController.text, criteria)
                                                ? Colors.green
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Role-specific fields
                          if (isStudent) ...[
                            CustomTextField(
                              controller: extraController,
                              label: "Roll Number",
                              icon: Icons.badge_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please enter your roll number";
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            CustomTextField(
                              controller: extraController,
                              label: "Graduation Year",
                              icon: Icons.school_outlined,
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please enter graduation year";
                                }
                                int? year = int.tryParse(val);
                                int current = DateTime.now().year;
                                if (year == null || year < 1950 || year > current) {
                                  return "Please enter a valid year";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: extra2Controller,
                              label: "Company",
                              icon: Icons.business_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return "Please enter your company";
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Login Button
                          CustomButton(
                            onPressed: _isLoading ? null : _login,
                            text: "Sign In",
                            isLoading: _isLoading,
                            icon: Icons.login,
                          ),

                          const SizedBox(height: 20),

                          // Action Buttons Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Forgot password feature coming soon!")),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: GoogleFonts.inter(
                                    color: isStudent
                                        ? const Color(0xFF1E3A8A)
                                        : const Color(0xFF059669),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          MainPage(role: isStudent ? "student" : "alumni"),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        var offsetAnimation = animation.drive(tween);
                                        return SlideTransition(position: offsetAnimation, child: child);
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  "Skip for now",
                                  style: GoogleFonts.inter(
                                    color: isStudent
                                        ? const Color(0xFF1E3A8A)
                                        : const Color(0xFF059669),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // New User Section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: isStudent
                                    ? [
                                        const Color(0xFF1E3A8A).withOpacity(0.1),
                                        const Color(0xFF3B82F6).withOpacity(0.05),
                                      ]
                                    : [
                                        const Color(0xFF059669).withOpacity(0.1),
                                        const Color(0xFF10B981).withOpacity(0.05),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: isStudent
                                    ? const Color(0xFF1E3A8A).withOpacity(0.3)
                                    : const Color(0xFF059669).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_add,
                                      color: isStudent
                                          ? const Color(0xFF1E3A8A)
                                          : const Color(0xFF059669),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "New User?",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isStudent
                                            ? const Color(0xFF1E3A8A)
                                            : const Color(0xFF059669),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isStudent
                                      ? "Join our student community and start building your future!"
                                      : "Join our alumni network and expand your professional connections!",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                CustomButton(
                                  onPressed: _showRegistrationDialog,
                                  text: "Create Account",
                                  isPrimary: false,
                                  icon: Icons.person_add,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
