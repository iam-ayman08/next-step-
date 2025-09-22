import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillAssessmentPage extends StatefulWidget {
  const SkillAssessmentPage({super.key});

  @override
  State<SkillAssessmentPage> createState() => _SkillAssessmentPageState();
}

class _SkillAssessmentPageState extends State<SkillAssessmentPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;

  final List<Map<String, dynamic>> _skills = [
    {
      'name': 'Flutter',
      'currentLevel': 7,
      'targetLevel': 9,
      'category': 'Mobile Development',
    },
    {
      'name': 'Dart',
      'currentLevel': 8,
      'targetLevel': 9,
      'category': 'Programming',
    },
    {
      'name': 'Firebase',
      'currentLevel': 6,
      'targetLevel': 8,
      'category': 'Backend',
    },
    {
      'name': 'UI/UX Design',
      'currentLevel': 5,
      'targetLevel': 8,
      'category': 'Design',
    },
    {
      'name': 'Python',
      'currentLevel': 4,
      'targetLevel': 7,
      'category': 'Programming',
    },
    {
      'name': 'Machine Learning',
      'currentLevel': 3,
      'targetLevel': 6,
      'category': 'AI/ML',
    },
    {
      'name': 'Project Management',
      'currentLevel': 6,
      'targetLevel': 8,
      'category': 'Management',
    },
    {
      'name': 'Agile/Scrum',
      'currentLevel': 7,
      'targetLevel': 8,
      'category': 'Methodology',
    },
  ];

  final List<Map<String, dynamic>> _learningPaths = [
    {
      'title': 'Mobile App Development Mastery',
      'description': 'Complete path to become a Flutter expert',
      'duration': '12 weeks',
      'difficulty': 'Intermediate',
      'courses': 8,
      'certifications': 2,
      'progress': 0.6,
      'skills': ['Flutter', 'Dart', 'Firebase', 'UI/UX'],
      'color': Colors.blue,
    },
    {
      'title': 'Data Science Fundamentals',
      'description': 'Learn Python, statistics, and machine learning basics',
      'duration': '16 weeks',
      'difficulty': 'Beginner',
      'courses': 12,
      'certifications': 3,
      'progress': 0.3,
      'skills': ['Python', 'Statistics', 'Machine Learning'],
      'color': Colors.green,
    },
    {
      'title': 'Full Stack Development',
      'description': 'Master both frontend and backend development',
      'duration': '20 weeks',
      'difficulty': 'Advanced',
      'courses': 15,
      'certifications': 4,
      'progress': 0.2,
      'skills': ['React', 'Node.js', 'Database', 'API Design'],
      'color': Colors.purple,
    },
  ];

  final List<Map<String, dynamic>> _certifications = [
    {
      'name': 'Google Flutter Developer Certificate',
      'issuer': 'Google',
      'status': 'In Progress',
      'progress': 0.7,
      'deadline': '2024-12-31',
      'skills': ['Flutter', 'Dart', 'Mobile Development'],
    },
    {
      'name': 'AWS Certified Developer',
      'issuer': 'Amazon Web Services',
      'status': 'Not Started',
      'progress': 0.0,
      'deadline': '2025-03-15',
      'skills': ['Cloud Computing', 'AWS', 'DevOps'],
    },
    {
      'name': 'Scrum Master Certification',
      'issuer': 'Scrum Alliance',
      'status': 'Completed',
      'progress': 1.0,
      'deadline': '2024-06-15',
      'skills': ['Agile', 'Scrum', 'Project Management'],
    },
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

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOut),
    );

    _fabAnimationController.forward();
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Skill Assessment',
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
            icon: const Icon(Icons.analytics),
            onPressed: () => _showSkillAnalytics(),
            tooltip: 'Skill Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showAssessmentSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skill Gap Analysis Overview
            _buildSkillGapOverview(),

            const SizedBox(height: 24),

            // Current Skills Assessment
            _buildSkillsAssessment(),

            const SizedBox(height: 24),

            // Learning Paths
            _buildLearningPaths(),

            const SizedBox(height: 24),

            // Certifications Tracking
            _buildCertificationsSection(),

            const SizedBox(height: 24),

            // Skill Recommendations
            _buildSkillRecommendations(),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          heroTag: "skill_assessment_fab",
          onPressed: () => _startNewAssessment(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.assessment),
          label: const Text('New Assessment'),
        ),
      ),
    );
  }

  Widget _buildSkillGapOverview() {
    final totalSkills = _skills.length;
    final skillsNeedingImprovement = _skills
        .where((skill) => skill['currentLevel'] < skill['targetLevel'])
        .length;
    final averageGap =
        _skills
            .map((skill) => skill['targetLevel'] - skill['currentLevel'])
            .reduce((a, b) => a + b) /
        totalSkills;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange[400]!.withValues(alpha: 0.2),
                        Colors.orange[600]!.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: Colors.orange[600],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skill Gap Analysis',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI-powered assessment of your skill levels',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          height: 1.4,
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
                  child: _buildGapMetric(
                    'Skills to Improve',
                    skillsNeedingImprovement.toString(),
                    Icons.trending_up_rounded,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGapMetric(
                    'Average Gap',
                    averageGap.toStringAsFixed(1),
                    Icons.show_chart_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGapMetric(
                    'Completion',
                    '${((totalSkills - skillsNeedingImprovement) / totalSkills * 100).round()}%',
                    Icons.check_circle_rounded,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGapMetric(
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

  Widget _buildSkillsAssessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Assessment',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ..._skills.map((skill) => _buildSkillItem(skill)),
      ],
    );
  }

  Widget _buildSkillItem(Map<String, dynamic> skill) {
    final gap = skill['targetLevel'] - skill['currentLevel'];
    final progress = skill['currentLevel'] / 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withValues(alpha: 0.8)
                : Colors.white,
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]!.withValues(alpha: 0.6)
                : Colors.grey[50]!.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gap > 0 ? Colors.orange : Colors.green).withValues(
              alpha: 0.1,
            ),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: (gap > 0 ? Colors.orange : Colors.green).withValues(
            alpha: 0.2,
          ),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (gap > 0 ? Colors.orange : Colors.green).withValues(
                          alpha: 0.2,
                        ),
                        (gap > 0 ? Colors.orange : Colors.green).withValues(
                          alpha: 0.1,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    gap > 0 ? Icons.trending_up : Icons.check_circle,
                    color: gap > 0 ? Colors.orange : Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill['name'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        skill['category'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (gap > 0 ? Colors.orange : Colors.green).withValues(
                          alpha: 0.15,
                        ),
                        (gap > 0 ? Colors.orange : Colors.green).withValues(
                          alpha: 0.05,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (gap > 0 ? Colors.orange : Colors.green)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    gap > 0 ? 'Gap: $gap' : 'On Track',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: gap > 0 ? Colors.orange[700] : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Level',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${skill['currentLevel']}/10',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[600]
                      : Colors.grey[300],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Level',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${skill['targetLevel']}/10',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]
                    : Colors.grey[200],
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        gap > 0 ? Colors.orange[400]! : Colors.green[400]!,
                        gap > 0 ? Colors.orange[600]! : Colors.green[600]!,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (gap > 0 ? Colors.orange : Colors.green)
                            .withValues(alpha: 0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}% Proficiency',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: gap > 0 ? Colors.orange[600] : Colors.green[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningPaths() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recommended Learning Paths',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _viewAllLearningPaths(),
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
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _learningPaths.length,
            itemBuilder: (context, index) {
              return _buildLearningPathCard(_learningPaths[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLearningPathCard(Map<String, dynamic> path) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            path['color'].withValues(alpha: 0.1),
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: path['color'].withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: path['color'].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          path['color'].withValues(alpha: 0.2),
                          path['color'].withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: path['color'].withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      color: path['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(
                        path['difficulty'],
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      path['difficulty'],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getDifficultyColor(path['difficulty']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                path['title'],
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  letterSpacing: -0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                path['description'],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[600],
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildPathMetric(
                    path['courses'].toString(),
                    'Courses',
                    path['color'],
                  ),
                  const SizedBox(width: 16),
                  _buildPathMetric(
                    path['certifications'].toString(),
                    'Certs',
                    path['color'],
                  ),
                  const SizedBox(width: 16),
                  _buildPathMetric(path['duration'], 'Duration', path['color']),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[200],
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: path['progress'],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          path['color'].withValues(alpha: 0.8),
                          path['color'],
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: path['color'].withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(path['progress'] * 100).round()}% Complete',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    path['progress'] > 0.8
                        ? Icons.celebration
                        : Icons.access_time,
                    size: 16,
                    color: path['color'],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      path['color'],
                      path['color'].withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: path['color'].withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _startLearningPath(path),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        path['progress'] > 0
                            ? Icons.play_arrow
                            : Icons.rocket_launch,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        path['progress'] > 0
                            ? 'Continue Learning'
                            : 'Start Learning',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathMetric(String value, String label, [Color? color]) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Certifications',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _viewAllCertifications(),
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
        ..._certifications.map((cert) => _buildCertificationItem(cert)),
      ],
    );
  }

  Widget _buildCertificationItem(Map<String, dynamic> cert) {
    Color statusColor;
    IconData statusIcon;

    switch (cert['status']) {
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_top;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.schedule;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert['name'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        'by ${cert['issuer']}',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        cert['status'],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (cert['status'] == 'In Progress') ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: cert['progress'],
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]
                    : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${(cert['progress'] * 100).round()}% Complete',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Deadline: ${cert['deadline']}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillRecommendations() {
    final recommendedSkills = [
      {
        'name': 'React Native',
        'reason': 'High demand in mobile development',
        'difficulty': 'Intermediate',
      },
      {
        'name': 'Docker',
        'reason': 'Essential for modern deployment',
        'difficulty': 'Advanced',
      },
      {
        'name': 'TypeScript',
        'reason': 'Improves code quality and maintainability',
        'difficulty': 'Intermediate',
      },
      {
        'name': 'GraphQL',
        'reason': 'Modern API development',
        'difficulty': 'Intermediate',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Skills to Learn',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...recommendedSkills.map((skill) => _buildRecommendationItem(skill)),
      ],
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> skill) {
    Color difficultyColor;
    switch (skill['difficulty']) {
      case 'Beginner':
        difficultyColor = Colors.green;
        break;
      case 'Intermediate':
        difficultyColor = Colors.orange;
        break;
      case 'Advanced':
        difficultyColor = Colors.red;
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                Icons.lightbulb,
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
                    skill['name'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    skill['reason'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                skill['difficulty'],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: difficultyColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkillAnalytics() {
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
              'Skill Analytics',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Analytics content would go here
            Text(
              'Detailed skill analytics and insights will be displayed here.',
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

  void _showAssessmentSettings() {
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
              'Assessment Settings',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Settings content would go here
            Text(
              'Assessment preferences and settings will be displayed here.',
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

  void _startNewAssessment() {
    // Navigate to assessment creation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('New skill assessment feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _viewAllLearningPaths() {
    // Navigate to all learning paths
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All learning paths view coming soon!')),
    );
  }

  void _startLearningPath(Map<String, dynamic> path) {
    // Navigate to learning path detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${path['title']}...'),
        backgroundColor: path['color'],
      ),
    );
  }

  void _viewAllCertifications() {
    // Navigate to all certifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All certifications view coming soon!')),
    );
  }
}
