import 'package:flutter/material.dart';
import 'dart:async';
import 'login_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Pulse animation for logo glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Floating animation for background elements
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    // Main animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    // Pulse animation for glow effect
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Floating animation for background elements
    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Start main animation
    _mainController.forward();

    // Navigate to login selection after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginSelectionScreen()),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0B1F), // Dark navy
              Color(0xFF1A1B3A), // Dark blue
              Color(0xFF2D1B69), // Purple
              Color(0xFF11998E), // Teal
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            ..._buildBackgroundElements(),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Enhanced animated logo
                    AnimatedBuilder(
                      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFF1F5F9),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(_pulseAnimation.value * 0.3),
                                  spreadRadius: 10,
                                  blurRadius: 30,
                                  offset: const Offset(0, 0),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer ring
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF6366F1).withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                ),
                                // Rocket icon
                                const Icon(
                                  Icons.rocket_launch_rounded,
                                  size: 90,
                                  color: Color(0xFF6366F1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 50),

                    // Animated title
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: const Text(
                            'NextStep',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 4.0,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF6366F1),
                                  offset: Offset(0, 0),
                                  blurRadius: 20,
                                ),
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Animated tagline
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.5),
                          child: Text(
                            'Your journey starts here',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.85),
                              letterSpacing: 2.0,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80),

                    // Premium loading animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.2 * _pulseAnimation.value),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4 * _pulseAnimation.value),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.9)
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundElements() {
    return List.generate(6, (index) {
      return AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          final double offset = (index * 60.0) + _floatAnimation.value;
          return Positioned(
            top: 100 + (index * 80.0) + (offset * 0.5),
            left: 50 + (index * 40.0) + (offset * 0.3),
            child: Container(
              width: 20 + (index * 5),
              height: 20 + (index * 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFF06B6D4).withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ][index % 4],
              ),
            ),
          );
        },
      );
    });
  }
}
