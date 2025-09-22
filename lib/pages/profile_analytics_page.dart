import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAnalyticsPage extends StatefulWidget {
  const ProfileAnalyticsPage({super.key});

  @override
  State<ProfileAnalyticsPage> createState() => _ProfileAnalyticsPageState();
}

class _ProfileAnalyticsPageState extends State<ProfileAnalyticsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final ProfileStats _stats = ProfileStats();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorCard(Map<String, dynamic> visitor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Text(
                visitor['name'][0].toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visitor['name'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    visitor['role'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    visitor['company'],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.blue[400]),
                const SizedBox(height: 4),
                Text(
                  '2h ago',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[500]
                        : Colors.grey[400],
                  ),
                ),
              ],
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
        title: Text(
          'Profile Analytics',
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
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Filters', style: GoogleFonts.inter()),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        title: Text('This week', style: GoogleFonts.inter()),
                        value: true,
                        onChanged: (value) {},
                      ),
                      CheckboxListTile(
                        title: Text('This month', style: GoogleFonts.inter()),
                        value: false,
                        onChanged: (value) {},
                      ),
                      CheckboxListTile(
                        title: Text('All time', style: GoogleFonts.inter()),
                        value: false,
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Apply', style: GoogleFonts.inter()),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            ScaleTransition(
              scale: _scaleAnimation,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
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
                    child: const Icon(
                      Icons.insights,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Profile Insights',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          'Track engagement and reach',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Stats Grid
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Overview',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  context,
                  'Profile Views',
                  _stats.profileViews.toString(),
                  Icons.visibility,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Total Likes',
                  _stats.totalLikes.toString(),
                  Icons.thumb_up,
                  Colors.pink,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Recent Visitors
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Who Viewed Your Profile',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),

            const SizedBox(height: 16),

            ..._stats.visitorHistory.map(
              (visitor) => Column(
                children: [
                  _buildVisitorCard(visitor),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Improve your profile visibility',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep your profile updated and engaging to get more views and connections.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
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
