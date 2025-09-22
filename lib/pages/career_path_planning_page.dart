import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CareerPathPlanningPage extends StatefulWidget {
  const CareerPathPlanningPage({super.key});

  @override
  State<CareerPathPlanningPage> createState() => _CareerPathPlanningPageState();
}

class _CareerPathPlanningPageState extends State<CareerPathPlanningPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Map<String, dynamic>> _careerPaths = [
    {
      'title': 'Software Engineering',
      'description': 'Traditional software development career path',
      'currentPosition': 'Junior Developer',
      'targetPosition': 'Senior Engineer',
      'timeline': '3-5 years',
      'salaryRange': '\$80K - \$150K',
      'demand': 'High',
      'growth': 0.85,
      'color': Colors.blue,
      'milestones': [
        {
          'title': 'Complete CS Fundamentals',
          'completed': true,
          'date': '2023-06-15',
        },
        {'title': 'Get First Job', 'completed': true, 'date': '2023-09-01'},
        {
          'title': 'Learn Advanced Frameworks',
          'completed': false,
          'date': null,
        },
        {'title': 'Lead a Project', 'completed': false, 'date': null},
        {'title': 'Get Senior Role', 'completed': false, 'date': null},
      ],
    },
    {
      'title': 'Product Management',
      'description': 'Strategic product leadership and development',
      'currentPosition': 'Associate PM',
      'targetPosition': 'Senior Product Manager',
      'timeline': '4-6 years',
      'salaryRange': '\$90K - \$180K',
      'demand': 'Very High',
      'growth': 0.92,
      'color': Colors.purple,
      'milestones': [
        {
          'title': 'Product Fundamentals Course',
          'completed': true,
          'date': '2023-08-20',
        },
        {'title': 'First PM Role', 'completed': true, 'date': '2024-01-15'},
        {'title': 'MBA Degree', 'completed': false, 'date': null},
        {'title': 'Launch Major Product', 'completed': false, 'date': null},
        {'title': 'Senior PM Position', 'completed': false, 'date': null},
      ],
    },
    {
      'title': 'Data Science',
      'description': 'AI and machine learning specialization',
      'currentPosition': 'Data Analyst',
      'targetPosition': 'Senior Data Scientist',
      'timeline': '3-4 years',
      'salaryRange': '\$85K - \$160K',
      'demand': 'High',
      'growth': 0.78,
      'color': Colors.green,
      'milestones': [
        {
          'title': 'Statistics & Math Foundation',
          'completed': true,
          'date': '2023-05-10',
        },
        {
          'title': 'Python & ML Skills',
          'completed': true,
          'date': '2023-11-30',
        },
        {'title': 'First Data Role', 'completed': true, 'date': '2024-03-01'},
        {'title': 'Advanced ML Techniques', 'completed': false, 'date': null},
        {'title': 'Lead Data Projects', 'completed': false, 'date': null},
      ],
    },
  ];

  final List<Map<String, dynamic>> _industryTrends = [
    {
      'industry': 'Artificial Intelligence',
      'growth': '+45%',
      'demand': 'Very High',
      'avgSalary': '\$130K',
      'topSkills': ['Machine Learning', 'Python', 'Deep Learning'],
      'trend': 'up',
      'color': Colors.blue,
    },
    {
      'industry': 'Cloud Computing',
      'growth': '+32%',
      'demand': 'High',
      'avgSalary': '\$125K',
      'topSkills': ['AWS', 'Docker', 'Kubernetes'],
      'trend': 'up',
      'color': Colors.orange,
    },
    {
      'industry': 'Cybersecurity',
      'growth': '+28%',
      'demand': 'Very High',
      'avgSalary': '\$120K',
      'topSkills': ['Network Security', 'Ethical Hacking', 'Compliance'],
      'trend': 'up',
      'color': Colors.red,
    },
    {
      'industry': 'Blockchain',
      'growth': '+15%',
      'demand': 'Medium',
      'avgSalary': '\$110K',
      'topSkills': ['Smart Contracts', 'Cryptography', 'Web3'],
      'trend': 'stable',
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _salaryData = [
    {'role': 'Junior Developer', 'salary': 75000, 'experience': '0-2 years'},
    {'role': 'Mid Developer', 'salary': 95000, 'experience': '2-4 years'},
    {'role': 'Senior Developer', 'salary': 130000, 'experience': '4-6 years'},
    {'role': 'Tech Lead', 'salary': 160000, 'experience': '6-8 years'},
    {'role': 'Engineering Manager', 'salary': 190000, 'experience': '8+ years'},
  ];

  String _selectedIndustry = 'All';
  final List<String> _industries = [
    'All',
    'Technology',
    'Finance',
    'Healthcare',
    'Education',
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
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Career Path Planning',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => _openAICareerCounselor(),
            tooltip: 'AI Career Counselor',
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showCareerAnalytics(),
            tooltip: 'Career Analytics',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Career Overview
            _buildCareerOverview(),

            const SizedBox(height: 24),

            // Career Paths
            _buildCareerPaths(),

            const SizedBox(height: 24),

            // Industry Trends
            _buildIndustryTrends(),

            const SizedBox(height: 24),

            // Salary Comparison
            _buildSalaryComparison(),

            const SizedBox(height: 24),

            // Career Milestones
            _buildCareerMilestones(),

            const SizedBox(height: 24),

            // Career Recommendations
            _buildCareerRecommendations(),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          heroTag: "career_planning_fab",
          onPressed: () => _createCareerPlan(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Create Plan'),
        ),
      ),
    );
  }

  Widget _buildCareerOverview() {
    final completedMilestones = _careerPaths
        .expand((path) => path['milestones'] as List)
        .where((milestone) => milestone['completed'] == true)
        .length;
    final totalMilestones = _careerPaths
        .expand((path) => path['milestones'] as List)
        .length;
    final completionRate = totalMilestones > 0
        ? (completedMilestones / totalMilestones)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]!.withValues(alpha: 0.9)
                : Colors.white,
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withValues(alpha: 0.7)
                : Colors.grey[50]!.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.058,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.25),
                        Colors.green.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Career Progress Overview',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your journey towards career goals',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildProgressMetric(
                    'Milestones Completed',
                    '$completedMilestones/$totalMilestones',
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressMetric(
                    'Overall Progress',
                    '${(completionRate * 100).round()}%',
                    Icons.trending_up_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressMetric(
                    'Active Paths',
                    _careerPaths.length.toString(),
                    Icons.route_rounded,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.grey[100]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: completionRate,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(completionRate * 100).round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCareerPaths() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Career Paths',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _viewAllPaths(),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._careerPaths.map((path) => _buildCareerPathCard(path)),
      ],
    );
  }

  Widget _buildCareerPathCard(Map<String, dynamic> path) {
    final completedMilestones = (path['milestones'] as List)
        .where((milestone) => milestone['completed'] == true)
        .length;
    final totalMilestones = (path['milestones'] as List).length;
    final progress = totalMilestones > 0
        ? completedMilestones / totalMilestones
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]!.withValues(alpha: 0.9)
                : Colors.white,
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withValues(alpha: 0.7)
                : Colors.grey[50]!.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (path['color'] as Color).withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: (path['color'] as Color).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.058,
          vertical: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (path['color'] as Color).withValues(alpha: 0.25),
                        (path['color'] as Color).withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (path['color'] as Color).withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (path['color'] as Color).withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.work_rounded,
                    color: path['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path['title'],
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        path['description'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.grey[100]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPathInfo('Current', path['currentPosition']),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[500],
                    ),
                  ),
                  Expanded(
                    child: _buildPathInfo('Target', path['targetPosition']),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPathInfo('Timeline', path['timeline'])),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPathInfo('Salary Range', path['salaryRange']),
                ),
                const SizedBox(width: 8),
                Expanded(child: _buildPathInfo('Demand', path['demand'])),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!.withValues(alpha: 0.3)
                    : Colors.grey[50]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            path['color'] as Color,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: path['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedMilestones of $totalMilestones milestones completed',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    path['color'] as Color,
                    (path['color'] as Color).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (path['color'] as Color).withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _viewPathDetails(path),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'View Details',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathInfo(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
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

  Widget _buildIndustryTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Industry Trends & Insights',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            DropdownButton<String>(
              value: _selectedIndustry,
              items: _industries.map((industry) {
                return DropdownMenuItem(value: industry, child: Text(industry));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIndustry = value!;
                });
              },
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: (constraints.maxWidth < 600)
                  ? 320
                  : 260, // Increased height for better content fit
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _industryTrends.length,
                itemBuilder: (context, index) {
                  return _buildTrendCard(_industryTrends[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrendCard(Map<String, dynamic> trend) {
    IconData trendIcon;
    Color trendColor;

    switch (trend['trend']) {
      case 'up':
        trendIcon = Icons.trending_up;
        trendColor = Colors.green;
        break;
      case 'down':
        trendIcon = Icons.trending_down;
        trendColor = Colors.red;
        break;
      default:
        trendIcon = Icons.trending_flat;
        trendColor = Colors.grey;
    }

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row - Always visible
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: trend['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.business,
                          color: trend['color'],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          trend['industry'],
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(trendIcon, size: 14, color: trendColor),
                            const SizedBox(width: 4),
                            Text(
                              trend['growth'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: trendColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrendMetric(
                          'Demand',
                          trend['demand'],
                          trend['color'],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTrendMetric(
                          'Avg Salary',
                          trend['avgSalary'],
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Skills Section - Make this scrollable if needed
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Skills:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight:
                              constraints.maxHeight *
                              0.4, // Limit skills height
                        ),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: (trend['topSkills'] as List<String>).map((
                              skill,
                            ) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  skill,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrendMetric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryComparison() {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Salary Comparison Tool',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        'Compare salaries across roles and experience levels',
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
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _salaryData.length,
                itemBuilder: (context, index) {
                  return _buildSalaryCard(_salaryData[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _compareSalaries(),
                    icon: const Icon(Icons.compare),
                    label: const Text('Compare Roles'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewSalaryInsights(),
                    icon: const Icon(Icons.insights),
                    label: const Text('Salary Insights'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _buildSalaryCard(Map<String, dynamic> salary) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            salary['role'],
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${(salary['salary'] / 1000).round()}K',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            salary['experience'],
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerMilestones() {
    final allMilestones = _careerPaths
        .expand((path) => path['milestones'] as List)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career Milestones',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...allMilestones
            .take(5)
            .map((milestone) => _buildMilestoneCard(milestone)),
        if (allMilestones.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: TextButton(
                onPressed: () => _viewAllMilestones(),
                child: Text(
                  'View All Milestones',
                  style: GoogleFonts.inter(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMilestoneCard(Map<String, dynamic> milestone) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: milestone['completed']
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
              child: Icon(
                milestone['completed']
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: milestone['completed'] ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      decoration: milestone['completed']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (milestone['date'] != null)
                    Text(
                      'Completed: ${milestone['date']}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildCareerRecommendations() {
    final recommendations = [
      {
        'title': 'Consider Upskilling in AI/ML',
        'reason': 'High growth industry with excellent salary potential',
        'action': 'Explore AI courses',
        'priority': 'High',
      },
      {
        'title': 'Network in Tech Leadership',
        'reason': 'Limited connections in senior tech roles',
        'action': 'Join leadership communities',
        'priority': 'Medium',
      },
      {
        'title': 'Update Your Portfolio',
        'reason': 'Showcase recent projects and achievements',
        'action': 'Add recent work',
        'priority': 'High',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Career Recommendations',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...recommendations.map((rec) => _buildRecommendationCard(rec)),
      ],
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> rec) {
    Color priorityColor;
    switch (rec['priority']) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    rec['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rec['priority'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              rec['reason'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _takeRecommendationAction(rec),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      rec['action'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _dismissRecommendation(rec),
                  icon: const Icon(Icons.close, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAICareerCounselor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Career Counselor opening...')),
    );
  }

  void _showCareerAnalytics() {
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
              'Career Analytics',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed career analytics and insights will be displayed here.',
              style: GoogleFonts.inter(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createCareerPlan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create career plan feature coming soon!')),
    );
  }

  void _viewAllPaths() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All career paths view coming soon!')),
    );
  }

  void _viewPathDetails(Map<String, dynamic> path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${path['title']} details...')),
    );
  }

  void _compareSalaries() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salary comparison tool opening...')),
    );
  }

  void _viewSalaryInsights() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salary insights view coming soon!')),
    );
  }

  void _viewAllMilestones() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All milestones view coming soon!')),
    );
  }

  void _takeRecommendationAction(Map<String, dynamic> rec) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Taking action: ${rec['action']}')));
  }

  void _dismissRecommendation(Map<String, dynamic> rec) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Dismissed: ${rec['title']}')));
  }
}
