import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../main.dart';
import 'login_selection_screen.dart';
import 'ai_resume_builder_page.dart';
import 'study_materials_page.dart';
import 'research_collaborations_page.dart';

class UserDashboardPage extends StatefulWidget {
  final String role;
  final String username;

  const UserDashboardPage({
    super.key,
    required this.role,
    required this.username,
  });

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  String _userName = '';
  String _userEmail = '';
  int _completedTasks = 0;
  int _totalTasks = 8;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _calculateProgress();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? widget.username;
      _userEmail = prefs.getString('user_email') ?? '${widget.username}@example.com';
    });
  }

  void _calculateProgress() {
    // Simulate progress based on user role and activities
    setState(() {
      _completedTasks = widget.role == 'student' ? 3 : 5;
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Welcome, ${_userName.split(' ')[0]}!',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon!')),
              );
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondary,
                                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              widget.role == 'student' ? Icons.school : Icons.business_center,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName,
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: widget.role == 'student'
                                        ? Colors.blue.withValues(alpha: 0.1)
                                        : Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: widget.role == 'student'
                                          ? Colors.blue
                                          : Colors.purple,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.role == 'student' ? '🎓 Student' : '🧑‍💼 Alumni',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: widget.role == 'student'
                                          ? Colors.blue
                                          : Colors.purple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.role == 'student'
                            ? 'Ready to kickstart your career journey? Let\'s get started!'
                            : 'Welcome back! Ready to mentor the next generation?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Progress Section
              Text(
                'Your Progress',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile Completion',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          '$_completedTasks/$_totalTasks',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _completedTasks / _totalTasks,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_completedTasks / _totalTasks * 100).round()}% Complete',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Career Development Section for Students
              if (widget.role == 'student') ...[
                Text(
                  'Career Development',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionCard(
                      context,
                      'Build Resume',
                      'Create a professional resume',
                      Icons.description_outlined,
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIResumeBuilderPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Study Materials',
                      'Access shared resources',
                      Icons.library_books_outlined,
                      Colors.teal,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudyMaterialsPage(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                Text(
                  'Research & Collaboration',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionCard(
                      context,
                      'Research Projects',
                      'Collaborate on research',
                      Icons.science_outlined,
                      Colors.deepPurple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResearchCollaborationsPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Get Mentored',
                      'Connect with alumni',
                      Icons.school_outlined,
                      Colors.purple,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mentorship feature coming soon!')),
                      ),
                    ),
                  ],
                ),
              ],

              // Alumni Support Section
              if (widget.role == 'alumni') ...[
                Text(
                  'Alumni Support',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionCard(
                      context,
                      'Research Collaboration',
                      'Lead research projects',
                      Icons.science_outlined,
                      Colors.deepPurple,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResearchCollaborationsPage(),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Share Opportunities',
                      'Post job openings',
                      Icons.business_outlined,
                      Colors.indigo,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Job posting feature coming soon!')),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Join Events',
                      'Network with peers',
                      Icons.event_outlined,
                      Colors.pink,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Events feature coming soon!')),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Industry Insights',
                      'Share your expertise',
                      Icons.insights_outlined,
                      Colors.amber,
                      () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Industry insights feature coming soon!')),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Recent Activity
              Text(
                'Recent Activity',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              _buildActivityItem(
                context,
                'Profile Updated',
                'Your profile information has been saved successfully.',
                '2 hours ago',
                Icons.check_circle_outline,
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                context,
                widget.role == 'student' ? 'New Job Alert' : 'Mentorship Request',
                widget.role == 'student'
                    ? 'Software Engineer position at TechCorp is now available'
                    : 'Sarah Johnson requested mentorship guidance',
                '1 day ago',
                Icons.notifications_none_outlined,
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildActivityItem(
                context,
                'Welcome to NextStep!',
                'Complete your profile to unlock more features.',
                '2 days ago',
                Icons.waving_hand_outlined,
                Colors.orange,
              ),

              const SizedBox(height: 32),

              // Motivational Quote
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.role == 'student'
                          ? '"The future belongs to those who believe in the beauty of their dreams." - Eleanor Roosevelt'
                          : '"The best way to predict the future is to create it." - Peter Drucker',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate back to login
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginSelectionScreen()),
            (route) => false,
          );
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
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
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
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
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[500]
                  : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
