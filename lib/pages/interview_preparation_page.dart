import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class InterviewPreparationPage extends StatefulWidget {
  const InterviewPreparationPage({super.key});

  @override
  State<InterviewPreparationPage> createState() =>
      _InterviewPreparationPageState();
}

class _InterviewPreparationPageState extends State<InterviewPreparationPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Map<String, dynamic>> _interviewTypes = [
    {
      'title': 'Technical Interview',
      'description': 'Practice coding and technical questions',
      'icon': Icons.code,
      'color': Colors.blue,
      'questions': 25,
      'difficulty': 'Intermediate',
    },
    {
      'title': 'Behavioral Interview',
      'description': 'STAR method and soft skills practice',
      'icon': Icons.people,
      'color': Colors.green,
      'questions': 20,
      'difficulty': 'Beginner',
    },
    {
      'title': 'System Design',
      'description': 'Architecture and design patterns',
      'icon': Icons.architecture,
      'color': Colors.purple,
      'questions': 15,
      'difficulty': 'Advanced',
    },
    {
      'title': 'Company Specific',
      'description': 'Tailored questions for specific companies',
      'icon': Icons.business,
      'color': Colors.orange,
      'questions': 30,
      'difficulty': 'Intermediate',
    },
  ];

  final List<Map<String, dynamic>> _practiceSessions = [
    {
      'date': '2024-09-15',
      'type': 'Technical Interview',
      'duration': '45 min',
      'score': 85,
      'feedback': 'Great technical knowledge, work on communication',
      'company': 'Google',
    },
    {
      'date': '2024-09-12',
      'type': 'Behavioral Interview',
      'duration': '30 min',
      'score': 92,
      'feedback': 'Excellent STAR method usage',
      'company': 'Microsoft',
    },
    {
      'date': '2024-09-10',
      'type': 'System Design',
      'duration': '60 min',
      'score': 78,
      'feedback': 'Good understanding, needs more depth',
      'company': 'Amazon',
    },
  ];

  final List<Map<String, dynamic>> _upcomingInterviews = [
    {
      'company': 'Netflix',
      'position': 'Senior Flutter Developer',
      'date': '2024-09-20',
      'time': '2:00 PM',
      'type': 'Technical Round 2',
      'status': 'confirmed',
    },
    {
      'company': 'Spotify',
      'position': 'Mobile Developer',
      'date': '2024-09-22',
      'time': '10:00 AM',
      'type': 'System Design',
      'status': 'pending',
    },
  ];

  bool _isRecording = false;
  int _recordingTime = 0;
  Timer? _recordingTimer;

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
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingTime = 0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingTime++;
      });
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
    });

    // Show feedback dialog
    _showRecordingFeedback();
  }

  void _showRecordingFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Recording Complete',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text(
              'Your ${_formatDuration(_recordingTime)} recording has been saved.',
              style: GoogleFonts.inter(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'AI analysis will be available in a few minutes.',
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Interview Preparation',
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
            onPressed: () => _showInterviewAnalytics(),
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showPreparationSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Overview
            _buildStatsOverview(),

            const SizedBox(height: 24),

            // Upcoming Interviews
            _buildUpcomingInterviews(),

            const SizedBox(height: 24),

            // Mock Interview Practice
            _buildMockInterviewSection(),

            const SizedBox(height: 24),

            // Video Recording Practice
            _buildVideoRecordingSection(),

            const SizedBox(height: 24),

            // Recent Practice Sessions
            _buildRecentSessions(),

            const SizedBox(height: 24),

            // Interview Tips & Resources
            _buildInterviewTips(),

            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          heroTag: "interview_prep_fab",
          onPressed: _isRecording ? _stopRecording : _startRecording,
          backgroundColor: _isRecording
              ? Colors.red
              : Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: Icon(_isRecording ? Icons.stop : Icons.videocam),
          label: Text(_isRecording ? 'Stop Recording' : 'Start Practice'),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final avgScore = _practiceSessions.isNotEmpty
        ? _practiceSessions
                  .map((s) => s['score'] as int)
                  .reduce((a, b) => a + b) /
              _practiceSessions.length
        : 0.0;
    final totalSessions = _practiceSessions.length;
    final upcomingCount = _upcomingInterviews.length;

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
            color: Colors.blue.withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                        Colors.blue.withValues(alpha: 0.25),
                        Colors.blue.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.2),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interview Performance',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track your progress and improvement',
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
                  child: _buildStatItem(
                    'Average Score',
                    '${avgScore.toStringAsFixed(1)}%',
                    Icons.grade_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Practice Sessions',
                    totalSessions.toString(),
                    Icons.play_circle_rounded,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Upcoming',
                    upcomingCount.toString(),
                    Icons.event_rounded,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
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

  Widget _buildUpcomingInterviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Upcoming Interviews',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _viewAllUpcoming(),
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
        ..._upcomingInterviews.map(
          (interview) => _buildUpcomingInterviewCard(interview),
        ),
      ],
    );
  }

  Widget _buildUpcomingInterviewCard(Map<String, dynamic> interview) {
    Color statusColor;
    switch (interview['status']) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.06),
            spreadRadius: 1,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.25),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.business_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    interview['company'],
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    interview['position'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]!.withValues(alpha: 0.5)
                          : Colors.grey[100]!.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${interview['date']} at ${interview['time']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.15),
                        statusColor.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    interview['status'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!.withValues(alpha: 0.5)
                        : Colors.grey[200]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interview['type'],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      fontWeight: FontWeight.w600,
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

  Widget _buildMockInterviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mock Interview Practice',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: _interviewTypes.length,
          itemBuilder: (context, index) {
            return _buildInterviewTypeCard(_interviewTypes[index]);
          },
        ),
      ],
    );
  }

  Widget _buildInterviewTypeCard(Map<String, dynamic> interviewType) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: interviewType['color'].withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                interviewType['icon'],
                color: interviewType['color'],
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              interviewType['title'],
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              interviewType['description'],
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTypeMetric('${interviewType['questions']}', 'Questions'),
                const SizedBox(width: 8),
                _buildTypeMetric(interviewType['difficulty'], 'Level'),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startMockInterview(interviewType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: interviewType['color'],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Start',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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

  Widget _buildTypeMetric(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8,
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

  Widget _buildVideoRecordingSection() {
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
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Video Practice Session',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        'Record yourself answering interview questions',
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
            if (_isRecording) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fiber_manual_record,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recording: ${_formatDuration(_recordingTime)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startRecording,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
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
                      onPressed: () => _viewPreviousRecordings(),
                      icon: const Icon(Icons.play_circle),
                      label: const Text('View Recordings'),
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
            const SizedBox(height: 16),
            Text(
              'Tips: Practice in a quiet environment, maintain eye contact with the camera, and speak clearly.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]
                    : Colors.grey[400],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Practice Sessions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _viewAllSessions(),
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
        ..._practiceSessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    Color scoreColor;
    if (session['score'] >= 90) {
      scoreColor = Colors.green;
    } else if (session['score'] >= 80) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        session['type'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        '${session['company']} • ${session['date']}',
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
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${session['score']}%',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              session['feedback'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  session['duration'],
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

  Widget _buildInterviewTips() {
    final tips = [
      {
        'title': 'STAR Method',
        'description':
            'Use Situation, Task, Action, Result to structure your answers',
        'icon': Icons.lightbulb,
      },
      {
        'title': 'Body Language',
        'description': 'Maintain eye contact, smile, and use confident posture',
        'icon': Icons.accessibility,
      },
      {
        'title': 'Practice Active Listening',
        'description':
            'Listen carefully and ask clarifying questions when needed',
        'icon': Icons.hearing,
      },
      {
        'title': 'Prepare Questions',
        'description': 'Have thoughtful questions ready for your interviewer',
        'icon': Icons.question_answer,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interview Tips & Resources',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) => _buildTipCard(tip)),
      ],
    );
  }

  Widget _buildTipCard(Map<String, dynamic> tip) {
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
                tip['icon'],
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
                    tip['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip['description'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      height: 1.4,
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

  void _showInterviewAnalytics() {
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
              'Interview Analytics',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Detailed analytics and performance insights will be displayed here.',
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

  void _showPreparationSettings() {
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
              'Preparation Settings',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Interview preparation preferences and settings will be displayed here.',
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

  void _startMockInterview(Map<String, dynamic> interviewType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${interviewType['title']}...'),
        backgroundColor: interviewType['color'],
      ),
    );
  }

  void _viewAllUpcoming() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All upcoming interviews view coming soon!'),
      ),
    );
  }

  void _viewPreviousRecordings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Previous recordings view coming soon!')),
    );
  }

  void _viewAllSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All practice sessions view coming soon!')),
    );
  }
}
