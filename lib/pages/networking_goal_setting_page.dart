import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NetworkingGoalSettingPage extends StatefulWidget {
  const NetworkingGoalSettingPage({super.key});

  @override
  State<NetworkingGoalSettingPage> createState() =>
      _NetworkingGoalSettingPageState();
}

class _NetworkingGoalSettingPageState extends State<NetworkingGoalSettingPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Map<String, dynamic>> _networkingGoals = [
    {
      'id': '1',
      'title': 'Connect with 5 Tech Leaders',
      'description': 'Reach out to senior engineers and tech executives',
      'category': 'Connections',
      'target': 5,
      'current': 3,
      'deadline': '2024-10-15',
      'status': 'In Progress',
      'priority': 'High',
      'color': Colors.blue,
      'milestones': [
        {
          'title': 'Research target alumni',
          'completed': true,
          'date': '2024-09-10',
        },
        {
          'title': 'Send 3 connection requests',
          'completed': true,
          'date': '2024-09-12',
        },
        {'title': 'Schedule 2 coffee chats', 'completed': false, 'date': null},
        {'title': 'Get 1 referral', 'completed': false, 'date': null},
        {'title': 'Complete 5 connections', 'completed': false, 'date': null},
      ],
    },
    {
      'id': '2',
      'title': 'Attend 3 Networking Events',
      'description': 'Participate in virtual and in-person networking events',
      'category': 'Events',
      'target': 3,
      'current': 1,
      'deadline': '2024-11-30',
      'status': 'In Progress',
      'priority': 'Medium',
      'color': Colors.green,
      'milestones': [
        {
          'title': 'Register for Tech Summit',
          'completed': true,
          'date': '2024-09-08',
        },
        {'title': 'Attend Startup Mixer', 'completed': false, 'date': null},
        {
          'title': 'Participate in Alumni Meetup',
          'completed': false,
          'date': null,
        },
      ],
    },
    {
      'id': '3',
      'title': 'Get 2 Professional Referrals',
      'description': 'Request and receive referrals from alumni network',
      'category': 'Referrals',
      'target': 2,
      'current': 0,
      'deadline': '2024-12-31',
      'status': 'Not Started',
      'priority': 'High',
      'color': Colors.purple,
      'milestones': [
        {
          'title': 'Identify potential referrers',
          'completed': false,
          'date': null,
        },
        {'title': 'Send referral requests', 'completed': false, 'date': null},
        {'title': 'Receive 2 referrals', 'completed': false, 'date': null},
      ],
    },
    {
      'id': '4',
      'title': 'Build Personal Brand Online',
      'description': 'Enhance LinkedIn profile and online presence',
      'category': 'Personal Branding',
      'target': 100,
      'current': 75,
      'deadline': '2024-10-30',
      'status': 'In Progress',
      'priority': 'Medium',
      'color': Colors.orange,
      'milestones': [
        {
          'title': 'Update LinkedIn profile',
          'completed': true,
          'date': '2024-08-15',
        },
        {
          'title': 'Add professional photo',
          'completed': true,
          'date': '2024-08-16',
        },
        {'title': 'Write 3 posts this month', 'completed': false, 'date': null},
        {'title': 'Reach 100 connections', 'completed': false, 'date': null},
      ],
    },
  ];

  final List<Map<String, dynamic>> _goalTemplates = [
    {
      'title': 'Connection Builder',
      'description': 'Focus on expanding your professional network',
      'goals': [
        'Connect with 10 alumni',
        'Attend 2 networking events',
        'Send 5 personalized messages',
      ],
      'duration': '3 months',
      'difficulty': 'Beginner',
    },
    {
      'title': 'Mentorship Seeker',
      'description': 'Find mentors and build guidance relationships',
      'goals': [
        'Identify 3 potential mentors',
        'Schedule 2 mentorship calls',
        'Get 1 ongoing mentorship',
      ],
      'duration': '2 months',
      'difficulty': 'Intermediate',
    },
    {
      'title': 'Career Accelerator',
      'description': 'Fast-track career growth through networking',
      'goals': [
        'Get 3 referrals',
        'Attend 5 industry events',
        'Connect with 20 professionals',
      ],
      'duration': '6 months',
      'difficulty': 'Advanced',
    },
    {
      'title': 'Industry Expert',
      'description': 'Become recognized in your field',
      'goals': [
        'Publish 2 articles',
        'Speak at 1 event',
        'Join 3 professional groups',
      ],
      'duration': '4 months',
      'difficulty': 'Advanced',
    },
  ];

  final List<Map<String, dynamic>> _weeklyActivities = [
    {
      'day': 'Monday',
      'activity': 'Send 2 connection requests',
      'completed': true,
    },
    {
      'day': 'Tuesday',
      'activity': 'Comment on 3 LinkedIn posts',
      'completed': false,
    },
    {
      'day': 'Wednesday',
      'activity': 'Attend networking webinar',
      'completed': false,
    },
    {
      'day': 'Thursday',
      'activity': 'Follow up with 1 connection',
      'completed': true,
    },
    {
      'day': 'Friday',
      'activity': 'Review weekly networking progress',
      'completed': false,
    },
    {
      'day': 'Saturday',
      'activity': 'Personal branding activity',
      'completed': false,
    },
    {
      'day': 'Sunday',
      'activity': 'Plan next week\'s networking goals',
      'completed': false,
    },
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Connections',
    'Events',
    'Referrals',
    'Personal Branding',
  ];

  int _currentTabIndex = 0;
  final List<String> _tabs = ['Goals', 'Templates', 'Weekly Plan'];

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
          'Networking Goals',
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
            onPressed: () => _showGoalAnalytics(),
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showGoalSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTabIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _currentTabIndex == index
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _tabs[index],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _currentTabIndex == index
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Tab Content
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          heroTag: "networking_goals_fab",
          onPressed: () => _createNewGoal(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Goal'),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildGoalsTab();
      case 1:
        return _buildTemplatesTab();
      case 2:
        return _buildWeeklyPlanTab();
      default:
        return _buildGoalsTab();
    }
  }

  Widget _buildGoalsTab() {
    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Goals list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _networkingGoals.length,
            itemBuilder: (context, index) {
              return _buildGoalCard(_networkingGoals[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final progress = goal['target'] > 0
        ? (goal['current'] / goal['target'])
        : 0.0;
    final isCompleted = goal['current'] >= goal['target'];
    final isOverdue = DateTime.now().isAfter(DateTime.parse(goal['deadline']));

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
            color: goal['color'].withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: goal['color'].withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        goal['color'].withValues(alpha: 0.25),
                        goal['color'].withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: goal['color'].withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: goal['color'].withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: goal['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'],
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.15),
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          goal['category'],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
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
                        _getPriorityColor(
                          goal['priority'],
                        ).withValues(alpha: 0.15),
                        _getPriorityColor(
                          goal['priority'],
                        ).withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getPriorityColor(
                        goal['priority'],
                      ).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    goal['priority'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _getPriorityColor(goal['priority']),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              goal['description'],
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[200]
                    : Colors.grey[700],
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 20),

            // Progress
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${goal['current']}/${goal['target']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        goal['color'].withValues(alpha: 0.15),
                                        goal['color'].withValues(alpha: 0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: goal['color'].withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${(progress * 100).round()}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: goal['color'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                goal['color'],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted
                                ? [
                                    Colors.green.withValues(alpha: 0.15),
                                    Colors.green.withValues(alpha: 0.08),
                                  ]
                                : isOverdue
                                ? [
                                    Colors.red.withValues(alpha: 0.15),
                                    Colors.red.withValues(alpha: 0.08),
                                  ]
                                : [
                                    Colors.blue.withValues(alpha: 0.15),
                                    Colors.blue.withValues(alpha: 0.08),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                (isCompleted
                                        ? Colors.green
                                        : isOverdue
                                        ? Colors.red
                                        : Colors.blue)
                                    .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isCompleted
                              ? 'Completed'
                              : isOverdue
                              ? 'Overdue'
                              : 'In Progress',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? Colors.green
                                : isOverdue
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Deadline
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!.withValues(alpha: 0.5)
                    : Colors.grey[200]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Deadline: ${goal['deadline']}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () => _viewGoalDetails(goal),
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: Text(
                        'View Details',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          goal['color'],
                          goal['color'].withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: goal['color'].withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _updateGoalProgress(goal),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text(
                        'Update Progress',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildTemplatesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _goalTemplates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(_goalTemplates[index]);
      },
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    Color difficultyColor;
    switch (template['difficulty']) {
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
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template['title'],
                    style: GoogleFonts.inter(
                      fontSize: 18,
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
                    color: difficultyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    template['difficulty'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: difficultyColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              template['description'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  template['duration'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Goals:',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 8),

            ...List.generate(
              (template['goals'] as List<String>).length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        template['goals'][index],
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _useTemplate(template),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Use This Template',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPlanTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Weekly overview
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Week\'s Plan',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildWeeklyStat(
                        'Completed',
                        _weeklyActivities
                            .where((a) => a['completed'] == true)
                            .length
                            .toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWeeklyStat(
                        'Remaining',
                        _weeklyActivities
                            .where((a) => a['completed'] == false)
                            .length
                            .toString(),
                        Icons.schedule,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildWeeklyStat(
                        'Total',
                        _weeklyActivities.length.toString(),
                        Icons.list,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Daily activities
        Text(
          'Daily Activities',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),

        const SizedBox(height: 16),

        ..._weeklyActivities.map((activity) => _buildActivityCard(activity)),
      ],
    );
  }

  Widget _buildWeeklyStat(
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

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    final isCompleted = activity['completed'] as bool;

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
                color: isCompleted
                    ? Colors.green.withValues(alpha: 0.1)
                    : Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['day'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['activity'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompleted)
              IconButton(
                onPressed: () => _markActivityComplete(activity),
                icon: const Icon(Icons.check, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showGoalAnalytics() {
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
              'Goal Analytics',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed goal analytics and progress insights will be displayed here.',
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

  void _showGoalSettings() {
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
              'Goal Settings',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Goal preferences and notification settings will be displayed here.',
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

  void _createNewGoal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create new goal feature coming soon!')),
    );
  }

  void _viewGoalDetails(Map<String, dynamic> goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing ${goal['title']} details...')),
    );
  }

  void _updateGoalProgress(Map<String, dynamic> goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating progress for ${goal['title']}...')),
    );
  }

  void _useTemplate(Map<String, dynamic> template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Using ${template['title']} template...')),
    );
  }

  void _markActivityComplete(Map<String, dynamic> activity) {
    setState(() {
      activity['completed'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity['activity']} marked as complete!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
