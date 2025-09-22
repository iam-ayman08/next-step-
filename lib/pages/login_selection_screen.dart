import 'package:flutter/material.dart';
import 'student_login_screen.dart';
import 'alumni_login_screen.dart';
import 'institution_login_screen.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                const Text(
                  'Welcome to NextStep',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose your login type to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Student Login Card
                _buildLoginCard(
                  context,
                  title: 'Student Login',
                  subtitle: 'Access student portal',
                  icon: Icons.school_rounded,
                  gradient: const [
                    Color(0xFF6366F1), // Indigo
                    Color(0xFF8B5CF6), // Purple
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentLoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Alumni Login Card
                _buildLoginCard(
                  context,
                  title: 'Alumni Login',
                  subtitle: 'Access alumni network',
                  icon: Icons.business_center_rounded,
                  gradient: const [
                    Color(0xFF11998E), // Teal
                    Color(0xFF06B6D4), // Cyan
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlumniLoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Institution Login Card
                _buildLoginCard(
                  context,
                  title: 'Institution Login',
                  subtitle: 'Access institution portal',
                  icon: Icons.school_rounded,
                  gradient: const [
                    Color.fromARGB(255, 65, 21, 169), // Purple
                    Color.fromARGB(255, 106, 34, 174), // Violet
                  ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstitutionLoginScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Footer text
                Text(
                  'Join our community of learners and leaders',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 25,
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
