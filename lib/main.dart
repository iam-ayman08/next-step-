import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

// Import created services
import 'services/logging_service.dart';
import 'utils/config.dart';
import 'services/performance_service.dart';
import 'services/storage_service.dart';
import 'utils/app_state.dart';
import 'widgets/enhanced_error_boundary.dart';
import 'services/messaging_service.dart';

// Import extracted pages
import 'pages/splash_screen.dart';
import 'pages/login_selection_screen.dart';
import 'pages/profile_page.dart';
import 'pages/user_dashboard_page.dart';
import 'pages/research_collaborations_page.dart';
import 'pages/conversations_page.dart';
import 'pages/industry_trends_page.dart';

// Existing pages
import 'pages/ai_resume_builder_page.dart';
import 'pages/opportunities_page.dart';
import 'pages/networking_page.dart';
import 'pages/feedback_page.dart';
import 'pages/mentorship_page.dart';
import 'pages/profile_analytics_page.dart';
import 'pages/achievements_page.dart';
import 'pages/meetings_page.dart';
import 'pages/study_groups_page.dart';
import 'pages/skill_assessment_page.dart';
import 'pages/interview_preparation_page.dart';
import 'pages/career_path_planning_page.dart';
import 'pages/forum_page.dart';
import 'pages/terms_and_conditions_page.dart';
import 'pages/study_materials_page.dart';

// Extracted components
import 'pages/notification_page.dart';
import 'pages/search_page.dart';
import 'pages/ai_chat_page.dart';
import 'widgets/error_boundary.dart';
import 'widgets/advanced_ui_components.dart';
import 'utils/performance_monitor.dart';
import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Initialize services in proper order
  try {
    // Start with logging service - this is critical for error reporting
    await logger.initialize();

    // Initialize app configuration
    await appConfig.initialize();

    // Initialize performance monitoring
    await performanceMonitor.initialize();

    // Initialize storage service
    await storageService.initialize();

    // Initialize other services
    await AIService.initialize();
    await DatabaseService.initialize();

    logInfo('Application services initialized successfully', tag: 'AppInit');

  } catch (error, stackTrace) {
    // If initialization fails, log error and try to start with minimal services
    debugPrint('Failed to initialize services: $error');
    debugPrint('Stack trace: $stackTrace');

    // Initialize minimal logger if it failed
    try {
      await logger.initialize();
    } catch (_) {}

    logFatal('Failed to initialize app services', error: error, stackTrace: stackTrace, tag: 'AppInit');
  }

  runApp(const NextStepApp());
}

class NextStepApp extends StatelessWidget {
  const NextStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MessagingService>(
          create: (_) => MessagingService(),
        ),
      ],
      child: MaterialApp(
        title: 'Next Step',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF0D1B2A),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          textTheme: GoogleFonts.interTextTheme().copyWith(
            bodyLarge: GoogleFonts.inter(
              color: const Color(0xFF0D1B2A),
              fontSize: 16,
            ),
            bodyMedium: GoogleFonts.inter(
              color: const Color(0xFF0D1B2A),
              fontSize: 14,
            ),
            bodySmall: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 12,
            ),
            headlineLarge: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            headlineMedium: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            headlineSmall: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
            titleLarge: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            titleMedium: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            titleSmall: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
            primary: const Color(0xFF2196F3),
            secondary: const Color(0xFF06B6D4),
            tertiary: const Color(0xFF8B5CF6),
            surface: Colors.white,
            error: const Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF0D1B2A),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0D1B2A),
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0D1B2A),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2196F3),
            unselectedItemColor: const Color(0xFF64748B),
            selectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            elevation: 12,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            labelStyle: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 14,
            ),
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFF1F5F9),
            selectedColor: const Color(0xFF2196F3).withValues(alpha: 0.1),
            checkmarkColor: const Color(0xFF2196F3),
            labelStyle: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            secondaryLabelStyle: GoogleFonts.inter(
              color: const Color(0xFF2196F3),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide.none,
          ),
        ),
        home: const FPSMonitor(
          showOverlay: false, // Set to true for debugging FPS
          child: ErrorBoundary(child: SplashScreen()),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _progressAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _scale;
  late Animation<double> _progressValue;
  late Animation<double> _textOpacity;

  String _currentMessage = "Initializing NextStep...";
  String _tagline = "";
  final String _fullTagline = "Unlock Alumni Power 🚀";
  double _progress = 0.0;
  bool _isTypingComplete = false;

  // Service initialization states
  final List<String> _initMessages = [
    "Connecting to services...",
    "Loading user preferences...",
    "Preparing your experience...",
    "Almost ready...",
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Single scale animation for logo
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Progress animation
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Text animation
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeIn),
    );
  }

  Future<void> _startAnimationSequence() async {
    // Start simplified animations
    _scaleAnimationController.forward();

    // Start progress and typing sequence
    _startProgressAnimation();
    await _startTypingAnimation();

    // Service initialization simulation
    await _simulateServiceInitialization();

    // Final transition
    await Future.delayed(const Duration(milliseconds: 500));
    _navigateToLogin();
  }

  void _startProgressAnimation() {
    _progressAnimationController.forward().then((_) {
      setState(() {
        _progress = 1.0;
      });
    });
  }

  Future<void> _startTypingAnimation() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Use Timer instead of setState to avoid build phase issues
    int charIndex = 0;
    Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (charIndex < _fullTagline.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _tagline = _fullTagline.substring(
              0,
              (charIndex + 1).clamp(0, _fullTagline.length),
            );
          });
        });
        charIndex++;
      } else {
        timer.cancel();
        if (!mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _isTypingComplete = true;
          });
          _textAnimationController.forward();
        });
      }
    });
  }

  Future<void> _simulateServiceInitialization() async {
    for (int i = 0; i < _initMessages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _currentMessage = _initMessages[i];
      });
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      // Check for accessibility - respect reduced motion preferences
      final MediaQueryData mediaQuery = MediaQuery.of(context);
      final bool reduceMotion = mediaQuery.accessibleNavigation;

      if (reduceMotion) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginSelectionScreen()));
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginSelectionScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _progressAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF111827)
          : const Color(0xFF0D1B2A),
      body: Semantics(
        label: "NextStep app is loading, $_progress% complete",
        hint: "Loading time remaining: ${_getTimeRemaining()} seconds",
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF111827)
                      : const Color(0xFF0D1B2A),
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1F2937)
                      : const Color(0xFF1A2332),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with simplified animation
                AnimatedBuilder(
                  animation: _scaleAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scale.value,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2196F3),
                              const Color(0xFF1976D2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2196F3,
                              ).withValues(alpha: 0.4),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: const Color(
                                0xFF2196F3,
                              ).withValues(alpha: 0.2),
                              spreadRadius: 8,
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                child: const Icon(
                                  Icons.group,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'NextStep',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Tagline with cursor effect
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _tagline,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: const Color(
                                0xFF2196F3,
                              ).withValues(alpha: 0.6),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // Typing cursor animation
                      _isTypingComplete
                          ? const SizedBox.shrink()
                          : Container(
                              height: 28,
                              width: 3,
                              margin: const EdgeInsets.only(left: 4),
                              color: const Color(
                                0xFF2196F3,
                              ).withValues(alpha: 0.8),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Context-aware loading message
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textOpacity,
                      child: Text(
                        _currentMessage,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Enhanced progress indicator
                SizedBox(
                  width: 280,
                  child: AnimatedBuilder(
                    animation: _progressAnimationController,
                    builder: (context, child) {
                      return Container(
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white24,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _progressValue.value,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2196F3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),

                // Social proof (optional)
                AnimatedBuilder(
                  animation: _textAnimationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textOpacity,
                      child: Text(
                        "Join 10,000+ professionals in their career journey",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white60,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeRemaining() {
    // Estimate remaining time based on progress
    final remainingPercent = 1.0 - _progress;
    final estimatedSeconds = (remainingPercent * 12).round();
    return estimatedSeconds.toString();
  }
}



class ProfilePage extends StatefulWidget {
  final String role;

  const ProfilePage({super.key, required this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  bool _isEditing = false;
  bool _isLoading = false;

  // Profile data
  String _name = "";
  String _email = "";
  String _bio = "";
  String _location = "";
  String _phone = "";
  String _linkedin = "";
  String _website = "";
  List<String> _skills = [];
  String _currentPosition = "";
  String _company = "";
  String _education = "";
  String _graduationYear = "";
  String _rollNumber = "";
  List<String> _achievements = [];
  List<String> _interests = [];

  // Profile image data
  String _profileImagePath = "";
  bool _isImageLoading = false;

  // Image picker functionality
  final ImagePicker _imagePicker = ImagePicker();

  // Gamification data
  int _totalPoints = 0;
  String _currentLevel = "Beginner";
  List<String> _earnedBadges = [];
  double _completionProgress = 0.0;
  final Map<String, int> _skillEndorsements = {};

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _currentPositionController =
      TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _graduationYearController =
      TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();

  late AnimationController _editAnimationController;

  @override
  void initState() {
    super.initState();
    _loadProfileData();

    _editAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _skillsController.dispose();
    _currentPositionController.dispose();
    _companyController.dispose();
    _educationController.dispose();
    _graduationYearController.dispose();
    _rollNumberController.dispose();
    _achievementsController.dispose();
    _interestsController.dispose();
    _editAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _name =
          prefs.getString('profile_name') ??
          (widget.role == "student" ? "John Doe" : "Jane Smith");
      _email =
          prefs.getString('profile_email') ??
          (widget.role == "student"
              ? "john.doe@student.com"
              : "jane.smith@alumni.com");
      _bio =
          prefs.getString('profile_bio') ??
          "Passionate about technology and innovation. Always eager to learn and grow.";
      _location = prefs.getString('profile_location') ?? "New York, USA";
      _phone = prefs.getString('profile_phone') ?? "+1 (555) 123-4567";
      _linkedin =
          prefs.getString('profile_linkedin') ??
          "linkedin.com/in/${_name.toLowerCase().replaceAll(' ', '')}";
      _website =
          prefs.getString('profile_website') ??
          "www.${_name.toLowerCase().replaceAll(' ', '')}.com";
      _skills =
          prefs.getStringList('profile_skills') ??
          ["Flutter", "Dart", "Firebase", "UI/UX Design"];
      _currentPosition =
          prefs.getString('profile_position') ??
          (widget.role == "student"
              ? "Computer Science Student"
              : "Software Engineer");
      _company =
          prefs.getString('profile_company') ??
          (widget.role == "student" ? "University" : "Tech Corp");
      _education =
          prefs.getString('profile_education') ??
          "Bachelor of Computer Science";
      _graduationYear =
          prefs.getString('profile_graduation_year') ??
          (widget.role == "student" ? "2025" : "2020");
      _rollNumber =
          prefs.getString('profile_roll_number') ??
          (widget.role == "student" ? "CS2021001" : "");
      _achievements =
          prefs.getStringList('profile_achievements') ??
          ["Dean's List", "Hackathon Winner", "Open Source Contributor"];
      _interests =
          prefs.getStringList('profile_interests') ??
          ["Machine Learning", "Mobile Development", "Entrepreneurship"];
    });

    _updateControllers();
    _calculateProfileCompletion();
    _initializeGamificationData();
  }

  void _calculateProfileCompletion() {
    int completedFields = 0;
    int totalFields =
        9; // name, email, bio, location, phone, linkedin, website, skills, position

    if (_name.isNotEmpty && _name != "John Doe" && _name != "Jane Smith") {
      completedFields++;
    }
    if (_email.isNotEmpty && !_email.contains("test.com")) completedFields++;
    if (_bio.isNotEmpty &&
        _bio !=
            "Passionate about technology and innovation. Always eager to learn and grow.") {
      completedFields++;
    }
    if (_location.isNotEmpty && _location != "New York, USA") completedFields++;
    if (_phone.isNotEmpty && _phone != "+1 (555) 123-4567") completedFields++;
    if (_linkedin.isNotEmpty && !_linkedin.contains("linkedin.com/in/")) {
      completedFields++;
    }
    if (_website.isNotEmpty &&
        !_website.contains("www.") &&
        !_website.contains(".com")) {
      completedFields++;
    }
    if (_skills.isNotEmpty && !_skills.contains("Flutter")) completedFields++;
    if (_currentPosition.isNotEmpty &&
        !_currentPosition.contains("Student") &&
        !_currentPosition.contains("Software Engineer")) {
      completedFields++;
    }

    setState(() {
      _completionProgress = completedFields / totalFields;
    });
  }

  void _initializeGamificationData() {
    // Calculate level based on completion
    int level = 1;
    if (_completionProgress >= 0.8) {
      level = 3;
    } else if (_completionProgress >= 0.6) {
      level = 2;
    }

    // Calculate points based on completion and activities
    int points =
        (_completionProgress * 100).round() +
        (_skills.length * 5) +
        (_achievements.length * 10);

    // Initialize badges based on progress
    List<String> badges = [];
    if (_completionProgress >= 0.3) badges.add("First Steps");
    if (_completionProgress >= 0.7) badges.add("Profile Master");
    if (_skills.length >= 3) badges.add("Network Builder");
    if (_achievements.length >= 2) badges.add("Opportunity Seeker");
    if (_currentPosition.isNotEmpty) badges.add("Forum Contributor");

    setState(() {
      _currentLevel = level == 1
          ? "Beginner"
          : level == 2
          ? "Intermediate"
          : "Advanced";
      _totalPoints = points;
      _earnedBadges = badges;
    });
  }

  void _updateControllers() {
    _nameController.text = _name;
    _emailController.text = _email;
    _bioController.text = _bio;
    _locationController.text = _location;
    _phoneController.text = _phone;
    _linkedinController.text = _linkedin;
    _websiteController.text = _website;
    _skillsController.text = _skills.join(', ');
    _currentPositionController.text = _currentPosition;
    _companyController.text = _company;
    _educationController.text = _education;
    _graduationYearController.text = _graduationYear;
    _rollNumberController.text = _rollNumber;
    _achievementsController.text = _achievements.join(', ');
    _interestsController.text = _interests.join(', ');
  }

  Future<void> _pickImage() async {
    setState(() {
      _isImageLoading = true;
    });

    try {
      // Show image source selection dialog
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final pickedFile = await _imagePicker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (pickedFile != null) {
                        await _processImage(pickedFile.path);
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Camera',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      final pickedFile = await _imagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (pickedFile != null) {
                        await _processImage(pickedFile.path);
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gallery',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isImageLoading = false;
      });
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      // Save image path to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', imagePath);

      setState(() {
        _profileImagePath = imagePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile image updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _saveProfileData() async {
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_name', _nameController.text);
    await prefs.setString('profile_email', _emailController.text);
    await prefs.setString('profile_bio', _bioController.text);
    await prefs.setString('profile_location', _locationController.text);
    await prefs.setString('profile_phone', _phoneController.text);
    await prefs.setString('profile_linkedin', _linkedinController.text);
    await prefs.setString('profile_website', _websiteController.text);
    await prefs.setStringList(
      'profile_skills',
      _skillsController.text.split(',').map((s) => s.trim()).toList(),
    );
    await prefs.setString('profile_position', _currentPositionController.text);
    await prefs.setString('profile_company', _companyController.text);
    await prefs.setString('profile_education', _educationController.text);
    await prefs.setString(
      'profile_graduation_year',
      _graduationYearController.text,
    );
    await prefs.setString('profile_roll_number', _rollNumberController.text);
    await prefs.setStringList(
      'profile_achievements',
      _achievementsController.text.split(',').map((s) => s.trim()).toList(),
    );
    await prefs.setStringList(
      'profile_interests',
      _interestsController.text.split(',').map((s) => s.trim()).toList(),
    );

    await _loadProfileData();

    setState(() {
      _isEditing = false;
      _isLoading = false;
    });

    _editAnimationController.reverse();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Profile updated successfully!"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelEditing() {
    _updateControllers();
    setState(() => _isEditing = false);
    _editAnimationController.reverse();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                subtitle: const Text('Toggle between light and dark mode'),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (bool value) {
                    // Theme toggle disabled - light theme only
                    Navigator.of(context).pop();
                  },
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Profile' : 'Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () {
                setState(() => _isEditing = true);
                _editAnimationController.forward();
              },
            )
          else
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: _cancelEditing,
                ),
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: _isLoading ? null : _saveProfileData,
                ),
              ],
            ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _profileImagePath.isNotEmpty
                      ? ClipOval(
                          child: Image.file(
                            File(_profileImagePath),
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Image(
                            image: AssetImage('nextstep_logo.png'),
                            width: 90,
                            height: 90,
                          ),
                        ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 3,
                          ),
                        ),
                        child: _isImageLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onSecondary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).colorScheme.onSecondary,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Name
            _isEditing
                ? TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  )
                : Text(
                    _name,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
            const SizedBox(height: 8),
            // Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 1,
                ),
              ),
              child: Text(
                widget.role == "student" ? "🎓 Student" : "🧑‍💼 Alumni",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bio
            _isEditing
                ? TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: "Tell us about yourself...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  )
                : Text(
                    _bio,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 24),

            // Profile Completion Progress and Gamification
            if (!_isEditing) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with level and points
                      Row(
                        children: [
                          Text(
                            'Profile Level: $_currentLevel',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stars,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_totalPoints pts',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress bar
                      LinearProgressIndicator(
                        value: _completionProgress,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_completionProgress * 100).round()}% Complete',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),

                      // Earned badges
                      if (_earnedBadges.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Earned Badges',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _earnedBadges
                              .map(
                                (badge) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getBadgeColor(
                                      badge,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _getBadgeColor(badge),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getBadgeIcon(badge),
                                        size: 16,
                                        color: _getBadgeColor(badge),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        badge,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _getBadgeColor(badge),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Profile Details
            Card(
              elevation: 8,
              shadowColor: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Basic Information
                    _buildProfileSection(context, "Basic Information", [
                      _buildProfileItem(
                        context,
                        Icons.email,
                        "Email",
                        _email,
                        controller: _emailController,
                        isEditing: _isEditing,
                      ),
                      _buildProfileItem(
                        context,
                        Icons.location_on,
                        "Location",
                        _location,
                        controller: _locationController,
                        isEditing: _isEditing,
                      ),
                      _buildProfileItem(
                        context,
                        Icons.phone,
                        "Phone",
                        _phone,
                        controller: _phoneController,
                        isEditing: _isEditing,
                      ),
                    ]),
                    const Divider(height: 32),

                    // Professional Information
                    _buildProfileSection(context, "Professional", [
                      _buildProfileItem(
                        context,
                        Icons.business_center,
                        "Current Position",
                        _currentPosition,
                        controller: _currentPositionController,
                        isEditing: _isEditing,
                      ),
                      _buildProfileItem(
                        context,
                        Icons.business,
                        "Company",
                        _company,
                        controller: _companyController,
                        isEditing: _isEditing,
                      ),
                      _buildProfileItem(
                        context,
                        Icons.link,
                        "LinkedIn",
                        _linkedin,
                        controller: _linkedinController,
                        isEditing: _isEditing,
                      ),
                      _buildProfileItem(
                        context,
                        Icons.language,
                        "Website",
                        _website,
                        controller: _websiteController,
                        isEditing: _isEditing,
                      ),
                    ]),
                    const Divider(height: 32),

                    // Education
                    _buildProfileSection(context, "Education", [
                      _buildProfileItem(
                        context,
                        Icons.school,
                        "Education",
                        _education,
                        controller: _educationController,
                        isEditing: _isEditing,
                      ),
                      if (widget.role == "student")
                        _buildProfileItem(
                          context,
                          Icons.badge,
                          "Roll Number",
                          _rollNumber,
                          controller: _rollNumberController,
                          isEditing: _isEditing,
                        ),
                      _buildProfileItem(
                        context,
                        Icons.calendar_today,
                        "Graduation Year",
                        _graduationYear,
                        controller: _graduationYearController,
                        isEditing: _isEditing,
                      ),
                    ]),
                    const Divider(height: 32),

                    // Skills
                    _buildProfileSection(context, "Skills", [
                      if (_isEditing)
                        _buildProfileItem(
                          context,
                          Icons.code,
                          "Skills",
                          _skills.join(', '),
                          controller: _skillsController,
                          isEditing: _isEditing,
                          maxLines: 2,
                        )
                      else
                        _buildSkillsSection(context),
                    ]),
                    const Divider(height: 32),

                    // Achievements
                    _buildProfileSection(context, "Achievements", [
                      _buildProfileItem(
                        context,
                        Icons.emoji_events,
                        "Achievements",
                        _achievements.join(', '),
                        controller: _achievementsController,
                        isEditing: _isEditing,
                        maxLines: 3,
                      ),
                    ]),
                    const Divider(height: 32),

                    // Interests
                    _buildProfileSection(context, "Interests", [
                      _buildProfileItem(
                        context,
                        Icons.favorite,
                        "Interests",
                        _interests.join(', '),
                        controller: _interestsController,
                        isEditing: _isEditing,
                        maxLines: 2,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _cancelEditing,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveProfileData,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    TextEditingController? controller,
    bool isEditing = false,
    int maxLines = 1,
  }) {
    if (isEditing && controller != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[50],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (_completionProgress >= 0.8) return Colors.green;
    if (_completionProgress >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'first steps':
        return Colors.blue;
      case 'profile master':
        return Colors.purple;
      case 'network builder':
        return Colors.green;
      case 'opportunity seeker':
        return Colors.orange;
      case 'forum contributor':
        return Colors.teal;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge.toLowerCase()) {
      case 'first steps':
        return Icons.start;
      case 'profile master':
        return Icons.verified;
      case 'network builder':
        return Icons.people;
      case 'opportunity seeker':
        return Icons.business;
      case 'forum contributor':
        return Icons.forum;
      default:
        return Icons.emoji_events;
    }
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills
              .map(
                (skill) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.thumb_up,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        '${_skillEndorsements[skill] ?? 0}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  final List<String> _allItems = [
    "Software Engineer Internship",
    "Marketing Manager Position",
    "Data Analyst Job",
    "UX Designer Role",
    "Product Manager Opportunity",
    "John Doe - Alumni",
    "Jane Smith - Student",
    "Tech Conference 2024",
    "Career Development Workshop",
    "Networking Event",
  ];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final results = _allItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() => _searchResults = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: "Search opportunities, people, events...",
            hintStyle: GoogleFonts.inter(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.clear,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchResults = []);
            },
          ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Search for opportunities,\npeople, and events",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : _searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No results found",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      result.contains("Alumni") || result.contains("Student")
                          ? Icons.person
                          : result.contains("Event") ||
                                result.contains("Conference")
                          ? Icons.event
                          : Icons.business,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(
                      result,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onTap: () {
                      // Handle item tap
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Selected: $result"),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'message': 'Hello! I\'m your AI assistant. How can I help you today?',
      'timestamp': DateTime.now(),
      'isTyping': false,
      'suggestions': [
        'Tell me about job opportunities',
        'Help with resume',
        'Career advice',
      ],
    },
  ];

  bool _isTyping = false;
  bool _isAiTyping = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _messageAnimationController;
  late Animation<double> _messageAnimation;

  final List<String> _quickSuggestions = [
    'Help me improve my resume',
    'Find job opportunities',
    'Career advice',
    'Interview preparation',
    'Networking tips',
    'Skill development',
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _messageAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _fabAnimationController.forward();
    _messageAnimationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickMessage]) async {
    final message = quickMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    // Get API key from AIService constant
    final String apiKey = AIService.openaiApiKey;
    if (apiKey.isEmpty || apiKey == 'your-openai-api-key-here') {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'message':
              'To enable AI chat features, please set your OpenAI API key in the AIService configuration. Contact your administrator or developer for setup assistance.',
          'timestamp': DateTime.now(),
          'isTyping': false,
          'suggestions': ['Learn more about AI setup'],
        });
      });
      return;
    }

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': message,
        'timestamp': DateTime.now(),
        'isTyping': false,
      });
      _isTyping = false;
      _isAiTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Use real AI service
      final aiService = AIService(apiKey);
      final aiResponse = await aiService.generateResponse(
        message,
        maxTokens: 500,
      );

      setState(() {
        _isAiTyping = false;
        _messages.add({
          'sender': 'ai',
          'message': aiResponse,
          'timestamp': DateTime.now(),
          'isTyping': false,
          'suggestions': _getContextualSuggestions(message),
        });
      });
    } catch (e) {
      // Fallback to simulated response if AI fails
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isAiTyping = false;
        _messages.add({
          'sender': 'ai',
          'message': _generateAIResponse(message),
          'timestamp': DateTime.now(),
          'isTyping': false,
          'suggestions': _getContextualSuggestions(message),
        });
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI service failed, using fallback: $e'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    _scrollToBottom();
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('resume') || message.contains('cv')) {
      return 'I can help you improve your resume! The AI Resume Builder in this app can analyze your experience and create a professional resume. Would you like me to guide you through the process?';
    } else if (message.contains('job') || message.contains('opportunity')) {
      return 'Great! I can help you find job opportunities. Check out the Opportunities page where you can search for jobs, apply directly, and even get AI-powered recommendations based on your profile.';
    } else if (message.contains('network') || message.contains('connect')) {
      return 'Networking is key to career success! The Networking page lets you connect with alumni, send messages, and request referrals. You can filter by industry, location, and graduation year.';
    } else if (message.contains('interview')) {
      return 'Interview preparation is crucial! I recommend practicing common questions, researching the company, and preparing stories about your experience. Would you like specific tips for your field?';
    } else if (message.contains('skill') || message.contains('learn')) {
      return 'Continuous learning is essential! Consider online courses, certifications, or hands-on projects. What skills are you interested in developing?';
    } else {
      return 'That\'s an interesting question! I\'m here to help with career advice, resume building, job searching, networking, and professional development. What specific area would you like to focus on?';
    }
  }

  List<String> _getContextualSuggestions(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('resume')) {
      return [
        'Upload my resume for review',
        'Resume formatting tips',
        'Tailor resume for specific job',
      ];
    } else if (message.contains('job')) {
      return [
        'Search for remote jobs',
        'Entry-level opportunities',
        'Jobs in my field',
      ];
    } else if (message.contains('network')) {
      return [
        'Find alumni in my industry',
        'Mentorship opportunities',
        'Professional groups',
      ];
    } else {
      return [
        'Career path guidance',
        'Salary negotiation tips',
        'Work-life balance advice',
      ];
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickSuggestions
                  .map(
                    (suggestion) => ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        Navigator.pop(context);
                        _sendMessage(suggestion);
                      },
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      labelStyle: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  ),
                ),
                Text(
                  _isAiTyping ? 'Typing...' : 'Online',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _isAiTyping ? Colors.green : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showQuickActions,
            tooltip: 'Quick Actions',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]!.withValues(alpha: 0.3)
                        : Colors.grey[50]!.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isAiTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isAiTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }

                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';

                  return AnimatedBuilder(
                    animation: _messageAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _messageAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: isUser
                                ? const Offset(1, 0)
                                : const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(_messageAnimation),
                          child: _buildMessageBubble(message, isUser),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Quick Suggestions (show only for last AI message)
          if (_messages.isNotEmpty &&
              _messages.last['sender'] == 'ai' &&
              _messages.last['suggestions'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!
                        : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (_messages.last['suggestions'] as List<String>).map(
                    (suggestion) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            suggestion,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          onPressed: () => _sendMessage(suggestion),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.1),
                          labelStyle: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            // Voice input functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice input coming soon!'),
                              ),
                            );
                          },
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (value) {
                        setState(() {
                          _isTyping = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ScaleTransition(
                  scale: _fabAnimation,
                  child: FloatingActionButton(
                    heroTag: "chat_send",
                    onPressed: _isTyping ? () => _sendMessage() : null,
                    backgroundColor: _isTyping
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    elevation: _isTyping ? 6 : 0,
                    child: Icon(_isTyping ? Icons.send : Icons.send_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message']!,
                    style: GoogleFonts.inter(
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  if (!isUser && message['suggestions'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Quick suggestions:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (message['suggestions'] as List<String>)
                                .map((suggestion) {
                                  return InkWell(
                                    onTap: () => _sendMessage(suggestion),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        suggestion,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTimestamp(message['timestamp']),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: const Radius.circular(4),
            bottomRight: const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Text(
              'AI is thinking',
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _messageAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        transform: Matrix4.translationValues(
                          0,
                          -4 *
                              (index == 0
                                  ? _messageAnimation.value
                                  : index == 1
                                  ? (_messageAnimation.value - 0.3).clamp(0, 1)
                                  : (_messageAnimation.value - 0.6).clamp(
                                      0,
                                      1,
                                    )),
                          0,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'About NextStep',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Image(
                        image: AssetImage('nextstep_logo.png'),
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NextStep',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Gateway to Alumni Success',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Mission Section
            _buildSectionCard(
              context,
              'Our Mission',
              Icons.flag,
              Colors.blue,
              'To bridge the gap between students and alumni by creating a comprehensive platform for career development, mentorship, and professional networking.',
            ),

            const SizedBox(height: 20),

            // What We Offer Section
            _buildSectionCard(
              context,
              'What We Offer',
              Icons.business_center,
              Colors.green,
              '• AI-powered resume building and optimization\n• Job opportunity discovery and application tracking\n• Mentorship matching with industry professionals\n• Study materials and resource sharing\n• Professional networking and collaboration tools\n• Career guidance and skill assessment',
            ),

            const SizedBox(height: 20),

            // Features Overview
            Text(
              'Key Features',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),

            // Features Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureCard(
                  context,
                  Icons.smart_toy,
                  'AI Assistant',
                  'Get instant help with resumes, interviews, and career advice',
                  Colors.indigo,
                ),
                _buildFeatureCard(
                  context,
                  Icons.people,
                  'Mentorship',
                  'Connect with alumni mentors in your field of interest',
                  Colors.purple,
                ),
                _buildFeatureCard(
                  context,
                  Icons.business,
                  'Job Board',
                  'Discover and apply to exclusive alumni job opportunities',
                  Colors.orange,
                ),
                _buildFeatureCard(
                  context,
                  Icons.library_books,
                  'Study Materials',
                  'Access and share high-quality educational resources',
                  Colors.teal,
                ),
                _buildFeatureCard(
                  context,
                  Icons.analytics,
                  'Analytics',
                  'Track your profile views, connections, and application progress',
                  Colors.blue,
                ),
                _buildFeatureCard(
                  context,
                  Icons.group,
                  'Networking',
                  'Build meaningful professional relationships with alumni',
                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Statistics Section
            Text(
              'Platform Statistics',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    '10,000+',
                    'Active Users',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '5,000+',
                    'Alumni Mentors',
                    Icons.school,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    '15,000+',
                    'Job Opportunities',
                    Icons.business,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '50,000+',
                    'Study Materials',
                    Icons.library_books,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Contact Information
            _buildSectionCard(
              context,
              'Contact Us',
              Icons.contact_mail,
              Colors.teal,
              '📧 Email: support@nextstep.com\n📱 Phone: +1 (555) 123-4567\n🌐 Website: www.nextstep.com\n📍 Address: 123 Career Street, Success City, SC 12345',
            ),

            const SizedBox(height: 20),

            // Social Links
            _buildSectionCard(
              context,
              'Follow Us',
              Icons.share,
              Colors.pink,
              '🔗 LinkedIn: @NextStep\n🐦 Twitter: @NextStepApp\n📘 Facebook: @NextStep\n📷 Instagram: @NextStepOfficial',
            ),

            const SizedBox(height: 32),

            // Team Section
            Text(
              'Our Team',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),

            _buildTeamMemberCard(
              context,
              'Dr. Sarah Johnson',
              'Founder & CEO',
              'Former Google Engineering Director with 15+ years in tech leadership',
              Icons.person,
              Colors.blue,
            ),
            const SizedBox(height: 12),

            _buildTeamMemberCard(
              context,
              'Michael Chen',
              'CTO',
              'Ex-Microsoft Principal Engineer specializing in mobile and AI technologies',
              Icons.person,
              Colors.green,
            ),
            const SizedBox(height: 12),

            _buildTeamMemberCard(
              context,
              'Emily Rodriguez',
              'Head of Product',
              'Former Product Manager at Amazon with expertise in user experience design',
              Icons.person,
              Colors.purple,
            ),

            const SizedBox(height: 32),

            // Legal Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legal Information',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© 2024 NextStep. All rights reserved.\n\nThis application is designed to facilitate career development and alumni networking. By using this app, you agree to our Terms of Service and Privacy Policy.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String content,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String number,
    String label,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              number,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(
    BuildContext context,
    String name,
    String role,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    role,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStats {
  int totalLikes = 0;
  int profileViews = 42;
  List<Map<String, dynamic>> visitorHistory = [
    {
      'name': 'Sarah Johnson',
      'role': 'Senior Developer',
      'visitedAt': '2024-09-16 14:30:00',
      'company': 'Google',
    },
    {
      'name': 'Michael Chen',
      'role': 'Product Manager',
      'visitedAt': '2024-09-16 12:15:00',
      'company': 'Microsoft',
    },
    {
      'name': 'Emily Rodriguez',
      'role': 'Data Scientist',
      'visitedAt': '2024-09-15 09:45:00',
      'company': 'Amazon',
    },
    {
      'name': 'David Kim',
      'role': 'Marketing Director',
      'visitedAt': '2024-09-15 16:20:00',
      'company': 'Nike',
    },
    {
      'name': 'Lisa Thompson',
      'role': 'Healthcare Admin',
      'visitedAt': '2024-09-14 11:10:00',
      'company': 'Mayo Clinic',
    },
  ];
}

class UserAchievements {
  List<Map<String, dynamic>> unlockedBadges = [
    {
      'name': 'First Steps',
      'description': 'Completed your profile',
      'icon': Icons.start,
      'color': Colors.blue,
      'unlockedAt': '2024-09-10',
    },
    {
      'name': 'Network Builder',
      'description': 'Connected with 5+ people',
      'icon': Icons.people,
      'color': Colors.green,
      'unlockedAt': '2024-09-12',
    },
    {
      'name': 'Mentor Seeker',
      'description': 'Requested mentorship',
      'icon': Icons.school,
      'color': Colors.purple,
      'unlockedAt': '2024-09-14',
    },
  ];

  List<Map<String, dynamic>> availableBadges = [
    {
      'name': 'Super Connector',
      'description': 'Connect with 20+ alumni',
      'icon': Icons.connect_without_contact,
      'color': Colors.orange,
      'progress': 0.7,
    },
    {
      'name': 'Profile Master',
      'description': 'Complete profile to 100%',
      'icon': Icons.verified,
      'color': Colors.teal,
      'progress': 0.85,
    },
    {
      'name': 'Opportunity Hunter',
      'description': 'Apply to 5 opportunities',
      'icon': Icons.business,
      'color': Colors.red,
      'progress': 0.4,
    },
    {
      'name': 'Mentor Guru',
      'description': 'Guide 10 mentees',
      'icon': Icons.star,
      'color': Colors.amber,
      'progress': 0.2,
    },
  ];

  List<Map<String, dynamic>> unlockableFeatures = [
    {
      'name': 'Premium Mentorship',
      'description': 'Access to premium mentors',
      'requiredPoints': 100,
      'points': 75,
      'locked': true,
    },
    {
      'name': 'Advanced Analytics',
      'description': 'Detailed profile insights',
      'requiredPoints': 150,
      'points': 120,
      'locked': true,
    },
    {
      'name': 'Priority Support',
      'description': '24/7 priority assistance',
      'requiredPoints': 200,
      'points': 180,
      'locked': true,
    },
    {
      'name': 'Exclusive Events',
      'description': 'Invite-only networking events',
      'requiredPoints': 250,
      'points': 230,
      'locked': true,
    },
  ];
}

class MainPage extends StatefulWidget {
  final String role;
  const MainPage({super.key, required this.role});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int currentIndex = 0;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.role == "student" ? 0 : 1;
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPage()),
    );
  }

  void _showDashboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.dashboard, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Dashboard Overview', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDashboardItem(
                context,
                'Profile Completion',
                '85%',
                Icons.person,
                Colors.blue,
                0.85,
              ),
              const SizedBox(height: 16),
              _buildDashboardItem(
                context,
                'Active Connections',
                '12',
                Icons.people,
                Colors.green,
                0.6,
              ),
              const SizedBox(height: 16),
              _buildDashboardItem(
                context,
                'Applications Sent',
                '8',
                Icons.business,
                Colors.orange,
                0.4,
              ),
              const SizedBox(height: 16),
              _buildDashboardItem(
                context,
                'Skills Endorsed',
                '15',
                Icons.thumb_up,
                Colors.purple,
                0.75,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileAnalyticsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: const Text('View Details'),
            ),
          ],
        );
      },
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.analytics, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Analytics Summary', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profile Views', style: GoogleFonts.inter(fontSize: 14)),
                        Text('42', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Connection Requests', style: GoogleFonts.inter(fontSize: 14)),
                        Text('5', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Job Applications', style: GoogleFonts.inter(fontSize: 14)),
                        Text('8', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This week: +15% increase in profile views',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileAnalyticsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: const Text('View Full Analytics'),
            ),
          ],
        );
      },
    );
  }

  void _showQuickActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Text('Quick Actions', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.description, color: Theme.of(context).colorScheme.secondary),
                title: Text('Update Resume', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AIResumeBuilderPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.people, color: Theme.of(context).colorScheme.secondary),
                title: Text('Find Mentors', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MentorshipPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.business, color: Theme.of(context).colorScheme.secondary),
                title: Text('Browse Jobs', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => currentIndex = 1);
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Theme.of(context).colorScheme.secondary),
                title: Text('AI Assistant', style: GoogleFonts.inter()),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AIChatPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.school, color: Colors.purple),
                title: Text('Scholarships', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Browse & apply for scholarships', style: GoogleFonts.inter(fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showScholarshipsDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.lightbulb, color: Colors.amber),
                title: Text('Project Aid & Support', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Get help with your projects', style: GoogleFonts.inter(fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showProjectAidDialog(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
          ],
        );
      },
    );
  }

  void _showScholarshipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.school, color: Colors.purple),
              const SizedBox(width: 8),
              Text('Scholarships', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scholarship Categories
                Text(
                  'Scholarship Categories',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildScholarshipCategory(
                  context,
                  '🎓 Merit-Based Scholarships',
                  'Academic excellence awards',
                  Icons.star,
                  Colors.amber,
                ),
                const SizedBox(height: 8),
                _buildScholarshipCategory(
                  context,
                  '💰 Need-Based Scholarships',
                  'Financial assistance awards',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildScholarshipCategory(
                  context,
                  '🔬 Research Grants',
                  'Research project funding',
                  Icons.science,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildScholarshipCategory(
                  context,
                  '🏆 Achievement Awards',
                  'Special recognition awards',
                  Icons.emoji_events,
                  Colors.purple,
                ),

                const SizedBox(height: 20),

                // Available Scholarships
                Text(
                  'Available Scholarships',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildScholarshipCard(
                  context,
                  'Tech Excellence Scholarship',
                  '₹50,000',
                  'For Computer Science students with GPA > 8.5',
                  'Deadline: Dec 31, 2024',
                  'Alumni: Sarah Johnson (Google)',
                  'Merit-Based',
                ),
                const SizedBox(height: 12),
                _buildScholarshipCard(
                  context,
                  'Innovation Grant',
                  '₹25,000',
                  'For students working on innovative projects',
                  'Deadline: Jan 15, 2025',
                  'Alumni: Michael Chen (Microsoft)',
                  'Research',
                ),
                const SizedBox(height: 12),
                _buildScholarshipCard(
                  context,
                  'Women in Tech Scholarship',
                  '₹30,000',
                  'For female students in STEM fields',
                  'Deadline: Feb 28, 2025',
                  'Alumni: Emily Rodriguez (Amazon)',
                  'Achievement',
                ),
                const SizedBox(height: 12),
                _buildScholarshipCard(
                  context,
                  'Financial Aid Grant',
                  '₹15,000',
                  'For students with demonstrated financial need',
                  'Deadline: Rolling',
                  'Alumni: David Kim (Finance)',
                  'Need-Based',
                ),

                const SizedBox(height: 20),

                // Application Process
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📋 Application Process',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.purple),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Review eligibility criteria\n2. Prepare required documents\n3. Submit online application\n4. Interview with alumni committee\n5. Receive decision within 2 weeks',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Success Stories
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎉 Success Stories',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"The Tech Excellence Scholarship helped me pursue my masters. Now I\'m working at Google!" - Priya Sharma, Alumni',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Alumni Testimonials
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👥 Alumni Testimonials',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"Giving back through scholarships is my way of supporting the next generation of innovators." - Sarah Johnson, Google',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
            ElevatedButton.icon(
              onPressed: () => _showScholarshipApplicationForm(context),
              icon: Icon(Icons.add),
              label: Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProjectAidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber),
              const SizedBox(width: 8),
              Text('Project Aid & Support', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get Help with Your Projects',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _buildProjectCard(
                  context,
                  'Mobile App Development',
                  'Need help with Flutter app development',
                  '₹5,000 funded',
                  'Mentor: David Kim (Senior Developer)',
                ),
                const SizedBox(height: 12),
                _buildProjectCard(
                  context,
                  'AI Research Project',
                  'Machine learning model for healthcare',
                  '₹10,000 funded',
                  'Mentor: Lisa Thompson (Data Scientist)',
                ),
                const SizedBox(height: 12),
                _buildProjectCard(
                  context,
                  'Startup Business Plan',
                  'E-commerce platform for local artisans',
                  '₹8,000 funded',
                  'Mentor: John Smith (Entrepreneur)',
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚀 Alumni Support Types',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.amber[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Financial Support: Direct funding for projects\n• Mentorship: One-on-one guidance\n• Technical Help: Code reviews, debugging\n• Resources: Tools, software, cloud credits\n• Networking: Introductions to industry contacts',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            ),
            ElevatedButton.icon(
              onPressed: () => _showProjectSubmissionForm(context),
              icon: Icon(Icons.add),
              label: Text('Submit Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showScholarshipApplicationForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _gpaController = TextEditingController();
    final _essayController = TextEditingController();
    final _achievementsController = TextEditingController();
    String _selectedScholarship = 'Tech Excellence Scholarship';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.school, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text('Scholarship Application', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scholarship Selection
                      DropdownButtonFormField<String>(
                        value: _selectedScholarship,
                        decoration: InputDecoration(
                          labelText: 'Select Scholarship',
                          prefixIcon: Icon(Icons.school, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          'Tech Excellence Scholarship',
                          'Innovation Grant',
                          'Women in Tech Scholarship',
                          'Financial Aid Grant',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedScholarship = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a scholarship' : null,
                      ),
                      const SizedBox(height: 16),

                      // Personal Information
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
                      ),
                      const SizedBox(height: 16),

                      // Academic Information
                      TextFormField(
                        controller: _gpaController,
                        decoration: InputDecoration(
                          labelText: 'Current GPA / CGPA',
                          prefixIcon: Icon(Icons.grade, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter your GPA' : null,
                      ),
                      const SizedBox(height: 16),

                      // Essay
                      TextFormField(
                        controller: _essayController,
                        decoration: InputDecoration(
                          labelText: 'Why do you deserve this scholarship? (200-500 words)',
                          prefixIcon: Icon(Icons.description, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 6,
                        maxLength: 500,
                        validator: (value) => value!.isEmpty ? 'Please write your essay' : null,
                      ),
                      const SizedBox(height: 16),

                      // Achievements
                      TextFormField(
                        controller: _achievementsController,
                        decoration: InputDecoration(
                          labelText: 'Key Achievements (Optional)',
                          prefixIcon: Icon(Icons.emoji_events, color: Colors.purple),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Scholarship application submitted successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.send),
                  label: Text('Submit Application'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showProjectSubmissionForm(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _projectTitleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _budgetController = TextEditingController();
    final _timelineController = TextEditingController();
    final _teamController = TextEditingController();
    final _goalsController = TextEditingController();
    String _projectCategory = 'Technology';
    String _fundingType = 'Financial Support';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber[700]),
                  const SizedBox(width: 8),
                  Text('Submit Project', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Project Category
                      DropdownButtonFormField<String>(
                        value: _projectCategory,
                        decoration: InputDecoration(
                          labelText: 'Project Category',
                          prefixIcon: Icon(Icons.category, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          'Technology',
                          'Research',
                          'Social Impact',
                          'Healthcare',
                          'Education',
                          'Environment',
                          'Business',
                          'Arts & Culture',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _projectCategory = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 16),

                      // Project Title
                      TextFormField(
                        controller: _projectTitleController,
                        decoration: InputDecoration(
                          labelText: 'Project Title',
                          prefixIcon: Icon(Icons.title, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter project title' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Project Description',
                          prefixIcon: Icon(Icons.description, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        maxLength: 300,
                        validator: (value) => value!.isEmpty ? 'Please describe your project' : null,
                      ),
                      const SizedBox(height: 16),

                      // Funding Type
                      DropdownButtonFormField<String>(
                        value: _fundingType,
                        decoration: InputDecoration(
                          labelText: 'Type of Support Needed',
                          prefixIcon: Icon(Icons.support, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          'Financial Support',
                          'Mentorship',
                          'Technical Help',
                          'Resources',
                          'Networking',
                          'All of the above',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _fundingType = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select support type' : null,
                      ),
                      const SizedBox(height: 16),

                      // Budget
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget Required (₹)',
                          prefixIcon: Icon(Icons.account_balance_wallet, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter budget' : null,
                      ),
                      const SizedBox(height: 16),

                      // Timeline
                      TextFormField(
                        controller: _timelineController,
                        decoration: InputDecoration(
                          labelText: 'Project Timeline',
                          prefixIcon: Icon(Icons.timeline, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter timeline' : null,
                      ),
                      const SizedBox(height: 16),

                      // Team Information
                      TextFormField(
                        controller: _teamController,
                        decoration: InputDecoration(
                          labelText: 'Team Members (Optional)',
                          prefixIcon: Icon(Icons.group, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Goals
                      TextFormField(
                        controller: _goalsController,
                        decoration: InputDecoration(
                          labelText: 'Expected Outcomes',
                          prefixIcon: Icon(Icons.flag, color: Colors.amber[700]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 200,
                        validator: (value) => value!.isEmpty ? 'Please describe expected outcomes' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Project submitted successfully! Alumni will review your proposal.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.send),
                  label: Text('Submit Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScholarshipCategory(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipCard(
    BuildContext context,
    String title,
    String amount,
    String description,
    String deadline,
    String alumni,
    String category,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  amount,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                deadline,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                alumni,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    String title,
    String description,
    String funding,
    String mentor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  funding,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                mentor,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String subtitle,
    String time,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[500]
                  : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalActionIcon(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]!.withValues(alpha: 0.5)
                  : Colors.grey[50]!.withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Hero Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.3),
                            spreadRadius: 3,
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Image(
                          image: AssetImage('nextstep_logo.png'),
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        "Welcome to NextStep",
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your gateway to alumni connections and opportunities",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Quick Actions Grid
              Text(
                "Quick Actions",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _buildQuickActionCard(
                    context,
                    "AI Resume Builder",
                    "Create professional resumes",
                    Icons.description,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIResumeBuilderPage(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    "Skill Assessment",
                    "Evaluate your skills",
                    Icons.assessment,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SkillAssessmentPage(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    "Interview Prep",
                    "Practice interviews",
                    Icons.question_answer,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InterviewPreparationPage(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    "Career Planning",
                    "Plan your career path",
                    Icons.timeline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CareerPathPlanningPage(),
                      ),
                    ),
                  ),
                  _buildQuickActionCard(
                    context,
                    "Find Opportunities",
                    "Discover jobs and internships",
                    Icons.business,
                    () => setState(() => currentIndex = 1),
                  ),
                  _buildQuickActionCard(
                    context,
                    "Network",
                    "Connect with alumni",
                    Icons.people,
                    () => setState(() => currentIndex = 3),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Recent Activity
              Text(
                "Recent Activity",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 20),

              _buildActivityItem(
                context,
                "New job opportunity posted",
                "Software Engineer at TechCorp",
                "2 hours ago",
                Icons.business,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                context,
                "Alumni connection request",
                "Sarah Johnson wants to connect",
                "5 hours ago",
                Icons.people,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                context,
                "Resume updated successfully",
                "Your profile is now 85% complete",
                "1 day ago",
                Icons.description,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      const OpportunitiesPage(),
      const ForumPage(),
      const NetworkingPage(),
      ProfilePage(role: widget.role),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Container(
          alignment: Alignment.center,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                const Color(0xFF2196F3), // Blue
                const Color(0xFF4CAF50), // Green
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "Next Step",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // This will be overridden by the gradient
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.apps,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Navigation Menu',
          ),
        ),
        actions:
            currentIndex ==
                4 // Profile page
            ? [
                IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsPage()),
                    );
                  },
                  tooltip: 'About Us',
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: () {
                    // Settings dialog will be shown from ProfilePage
                  },
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: _openSearch,
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: _openNotifications,
                ),
                IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsPage()),
                    );
                  },
                  tooltip: 'About Us',
                ),
              ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Image(
                        image: AssetImage('nextstep_logo.png'),
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.role == "student" ? "John Doe" : "Jane Smith",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    widget.role == "student" ? "🎓 Student" : "🧑‍💼 Alumni",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home,
                color: currentIndex == 0
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Home',
                style: GoogleFonts.inter(
                  color: currentIndex == 0
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: currentIndex == 0
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() => currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.smart_toy,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'AI Resume Builder',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AIResumeBuilderPage(),
                  ),
                );
              },
            ),


            // Phase 1: Core Career Development Features
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Career Development',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.assessment,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Skill Assessment',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SkillAssessmentPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.question_answer,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Interview Preparation',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InterviewPreparationPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.timeline,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Career Path Planning',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CareerPathPlanningPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.trending_up,
                color: Colors.blue[700],
              ),
              title: Text(
                'Industry Trends',
                style: GoogleFonts.inter(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Stay updated with industry insights',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IndustryTrendsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.chat,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Chat with AI',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIChatPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.handshake,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Mentorship Matching',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MentorshipPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.groups,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Study Groups',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudyGroupsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.video_call,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Meetings & Schedules',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeetingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.library_books,
                color: Colors.indigo,
              ),
              title: Text(
                'Study Materials',
                style: GoogleFonts.inter(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Access & share study resources',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudyMaterialsPage()),
                );
              },
            ),

            // New Alumni Support Features
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.support,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Alumni Support',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.school,
                color: Colors.purple,
              ),
              title: Text(
                'Scholarships',
                style: GoogleFonts.inter(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Browse & apply for scholarships',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showScholarshipsDialog(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.lightbulb,
                color: Colors.amber[700],
              ),
              title: Text(
                'Project Aid & Support',
                style: GoogleFonts.inter(
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Get help with your projects',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showProjectAidDialog(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.science,
                color: Colors.teal,
              ),
              title: Text(
                'Research Collaborations',
                style: GoogleFonts.inter(
                  color: Colors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Collaborate on research projects',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResearchCollaborationsPage()),
                );
              },
            ),

            // New Analytics and Engagement Features
            ListTile(
              leading: Icon(
                Icons.analytics,
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.8),
              ),
              title: Text(
                'Profile Analytics',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'View likes, visits & insights',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileAnalyticsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.emoji_events, color: Colors.amber[600]),
              title: Text(
                'Achievements',
                style: GoogleFonts.inter(
                  color: Colors.amber[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Badges & unlocks',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsPage()),
                );
              },
            ),

            const Divider(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.amber[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Engagement Stats',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.thumb_up,
                                color: Colors.pink[400],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '0',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink[500],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Likes',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: Colors.blue[400],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '42',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[500],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Views',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber[500],
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '3',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Badges',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(
                Icons.feedback,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Feedback',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedbackPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.description,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Terms & Conditions',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsAndConditionsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'About Us',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUsPage()),
                );
              },
            ),

            const Divider(),
            ListTile(
              leading: Icon(
                Icons.brightness_6,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Toggle Theme',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: null, // Theme toggle disabled - light theme only
                activeThumbColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          pages[currentIndex],

          // Left Side Vertical Action Icons
          Positioned(
            left: 16,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dashboard Analytics Icon
                _buildVerticalActionIcon(
                  context,
                  Icons.dashboard,
                  'Dashboard',
                  Colors.blue,
                  () => _showDashboardDialog(context),
                ),
                const SizedBox(height: 12),

                // Analytics Icon
                _buildVerticalActionIcon(
                  context,
                  Icons.analytics,
                  'Analytics',
                  Colors.green,
                  () => _showAnalyticsDialog(context),
                ),
                const SizedBox(height: 12),

                // Quick Actions Icon
                _buildVerticalActionIcon(
                  context,
                  Icons.flash_on,
                  'Quick Actions',
                  Colors.orange,
                  () => _showQuickActionsDialog(context),
                ),
                const SizedBox(height: 12),



                // AI Assistant Icon
                _buildVerticalActionIcon(
                  context,
                  Icons.smart_toy,
                  'AI Assistant',
                  Colors.indigo,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AIChatPage()),
                  ),
                ),
              ],
            ),
          ),


        ],
      ),

      bottomNavigationBar: AdvancedBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: "Opportunities",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Forum"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Network"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
