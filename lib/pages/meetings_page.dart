import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class MeetingRequest {
  final String id;
  final String requesterName;
  final String requesterRole;
  final String title;
  final String description;
  final DateTime requestedTime;
  String status; // 'pending', 'accepted', 'rejected'
  final int duration; // in minutes

  MeetingRequest({
    required this.id,
    required this.requesterName,
    required this.requesterRole,
    required this.title,
    required this.description,
    required this.requestedTime,
    this.status = 'pending',
    this.duration = 30,
  });
}

class MeetingRoom {
  final String id;
  final String title;
  final List<String> participants;
  final DateTime scheduledTime;
  final int duration; // minutes
  final List<MeetingMessage> messages;
  bool isActive;
  bool hasAudio;
  bool hasScreenShare;
  DateTime? startedAt;

  MeetingRoom({
    required this.id,
    required this.title,
    required this.participants,
    required this.scheduledTime,
    required this.duration,
    this.messages = const [],
    this.isActive = false,
    this.hasAudio = false,
    this.hasScreenShare = false,
    this.startedAt,
  });
}

class MeetingMessage {
  final String senderName;
  final String message;
  final DateTime timestamp;

  MeetingMessage({
    required this.senderName,
    required this.message,
    required this.timestamp,
  });
}

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<MeetingRequest> _meetingRequests = [
    MeetingRequest(
      id: '1',
      requesterName: 'Sarah Johnson',
      requesterRole: 'Alumni',
      title: 'Career Guidance Session',
      description:
          'I would like to discuss my career options in software development.',
      requestedTime: DateTime.now().add(const Duration(hours: 2)),
      duration: 45,
    ),
    MeetingRequest(
      id: '2',
      requesterName: 'Mike Chen',
      requesterRole: 'Student',
      title: 'Resume Review',
      description:
          'Can you please review my resume for the internship application?',
      requestedTime: DateTime.now().add(const Duration(days: 1)),
      duration: 30,
    ),
  ];

  final List<MeetingRoom> _scheduledMeetings = [
    MeetingRoom(
      id: 'meeting_1',
      title: 'Test Meeting: Career Discussion',
      participants: ['John Doe', 'Sarah Johnson'],
      scheduledTime: DateTime.now().add(const Duration(minutes: 15)),
      duration: 30,
      messages: [
        MeetingMessage(
          senderName: 'Sarah Johnson',
          message: 'Looking forward to our meeting!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
    ),
  ];

  final List<MeetingRoom> _meetingHistory = [
    MeetingRoom(
      id: 'history_1',
      title: 'Previous Career Session',
      participants: ['John Doe', 'Sarah Johnson'],
      scheduledTime: DateTime.now().subtract(const Duration(days: 2)),
      duration: 60,
      isActive: false,
      messages: [],
    ),
  ];

  Timer? _meetingTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _meetingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Meetings & Schedules',
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
            icon: Icon(
              Icons.add,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _showRequestMeetingDialog,
            tooltip: 'Request Meeting',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Requests',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                  if (_meetingRequests
                      .where((r) => r.status == 'pending')
                      .isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_meetingRequests.where((r) => r.status == 'pending').length}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Tab(
              child: Text(
                'Scheduled',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const Tab(
              child: Text(
                'History',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildScheduledTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRequestMeetingDialog,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        tooltip: 'Request New Meeting',
        child: const Icon(Icons.video_call),
      ),
    );
  }

  Widget _buildRequestsTab() {
    final pendingRequests = _meetingRequests
        .where((r) => r.status == 'pending')
        .toList();

    if (pendingRequests.isEmpty) {
      return _buildEmptyState(
        'No meeting requests',
        'Requests from others will appear here for you to accept or decline.',
        Icons.schedule,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
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
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.08),
                spreadRadius: 2,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
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
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
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
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.4),
                          width: 2.5,
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
                      child: Center(
                        child: Text(
                          request.requesterName
                              .split(' ')
                              .map((n) => n[0])
                              .join(''),
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.title,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
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
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.15),
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.08),
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
                              '${request.requesterName} (${request.requesterRole})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.secondary,
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
                  request.description,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[200]
                        : Colors.grey[700],
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!.withValues(alpha: 0.5)
                        : Colors.grey[100]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${request.duration} minutes • ${_formatTime(request.requestedTime)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptMeetingRequest(request.id),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Accept'),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectMeetingRequest(request.id),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Decline'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none,
                            foregroundColor: Colors.red[600],
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
      },
    );
  }

  Widget _buildScheduledTab() {
    if (_scheduledMeetings.isEmpty) {
      return _buildEmptyState(
        'No scheduled meetings',
        'Accepted meeting requests will appear here.',
        Icons.video_call,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scheduledMeetings.length,
      itemBuilder: (context, index) {
        final meeting = _scheduledMeetings[index];
        final isSoon =
            meeting.scheduledTime.difference(DateTime.now()).inMinutes <= 30;

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
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.08),
                spreadRadius: 2,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
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
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.4),
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
                        Icons.video_call_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.title,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
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
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.15),
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.08),
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
                              'With: ${meeting.participants.join(", ")}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orange, Colors.orangeAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          'Starting Soon',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]!.withValues(alpha: 0.5)
                        : Colors.grey[100]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${meeting.duration} minutes • ${_formatTime(meeting.scheduledTime)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.secondary,
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _joinMeeting(meeting),
                          icon: const Icon(Icons.video_call_rounded, size: 18),
                          label: const Text('Join Meeting'),
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
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => _showMeetingDetails(meeting),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                        ),
                        tooltip: 'Meeting Details',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_meetingHistory.isEmpty) {
      return _buildEmptyState(
        'No meeting history',
        'Completed meetings will appear here.',
        Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meetingHistory.length,
      itemBuilder: (context, index) {
        final meeting = _meetingHistory[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.history, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meeting.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Text(
                            'Completed • ${_formatDate(meeting.scheduledTime)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Duration: ${meeting.duration} minutes',
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
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]
                    : Colors.grey[400],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showRequestMeetingDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    int duration = 30;
    DateTime selectedDateTime = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Request New Meeting',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Meeting Title',
                        hintText: 'e.g., Career Guidance',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'What would you like to discuss?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Duration: '),
                        Expanded(
                          child: Slider(
                            value: duration.toDouble(),
                            min: 15,
                            max: 120,
                            divisions: 7,
                            label: '$duration min',
                            onChanged: (value) {
                              setState(() {
                                duration = value.round();
                              });
                            },
                          ),
                        ),
                        Text('$duration min'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty &&
                        descriptionController.text.trim().isNotEmpty) {
                      _createMeetingRequest(
                        titleController.text.trim(),
                        descriptionController.text.trim(),
                        duration,
                        selectedDateTime,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Send Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _createMeetingRequest(
    String title,
    String description,
    int duration,
    DateTime time,
  ) {
    final newRequest = MeetingRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      requesterName: 'John Doe', // In real app, get from user profile
      requesterRole: 'Student', // In real app, get from user role
      title: title,
      description: description,
      requestedTime: time,
      duration: duration,
    );

    setState(() {
      _meetingRequests.add(newRequest);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meeting request sent!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _acceptMeetingRequest(String requestId) {
    setState(() {
      final request = _meetingRequests.firstWhere((r) => r.id == requestId);
      request.status = 'accepted';

      // Create scheduled meeting from accepted request
      final newMeeting = MeetingRoom(
        id: 'meeting_${DateTime.now().millisecondsSinceEpoch}',
        title: request.title,
        participants: ['John Doe', request.requesterName],
        scheduledTime: request.requestedTime,
        duration: request.duration,
      );

      _scheduledMeetings.add(newMeeting);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meeting request accepted!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _rejectMeetingRequest(String requestId) {
    setState(() {
      final request = _meetingRequests.firstWhere((r) => r.id == requestId);
      request.status = 'rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meeting request declined'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _joinMeeting(MeetingRoom meeting) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            MeetingRoomPage(meeting: meeting, onMeetingEnd: _endMeeting),
      ),
    );
  }

  void _endMeeting(String meetingId, List<MeetingMessage> messages) {
    setState(() {
      final meeting = _scheduledMeetings.firstWhere((m) => m.id == meetingId);
      meeting.isActive = false;
      meeting.messages.addAll(messages);
      meeting.startedAt = null;

      // Move to history
      _meetingHistory.insert(0, meeting);
      _scheduledMeetings.remove(meeting);
    });

    _meetingTimer?.cancel();
  }

  void _showMeetingDetails(MeetingRoom meeting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Meeting Details',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title: ${meeting.title}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'Participants: ${meeting.participants.join(", ")}',
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${_formatTime(meeting.scheduledTime)}',
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${meeting.duration} minutes',
                style: GoogleFonts.inter(),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now);

    if (difference.inDays == 0) {
      return 'Today at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days from now';
    } else {
      return '${time.day}/${time.month}/${time.year} at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class MeetingRoomPage extends StatefulWidget {
  final MeetingRoom meeting;
  final Function(String, List<MeetingMessage>) onMeetingEnd;

  const MeetingRoomPage({
    super.key,
    required this.meeting,
    required this.onMeetingEnd,
  });

  @override
  State<MeetingRoomPage> createState() => _MeetingRoomPageState();
}

class _MeetingRoomPageState extends State<MeetingRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isAudioEnabled = false;
  bool _isVideoEnabled = false;
  bool _isScreenSharing = false;

  @override
  void initState() {
    super.initState();
    widget.meeting.isActive = true;
    widget.meeting.startedAt = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });

      // Check if meeting should end (minimum 5 minutes)
      if (_secondsElapsed >= widget.meeting.duration * 60) {
        _endMeeting();
      }
    });
  }

  void _endMeeting() {
    widget.onMeetingEnd(widget.meeting.id, widget.meeting.messages);
    Navigator.of(context).pop();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      widget.meeting.messages.add(
        MeetingMessage(
          senderName: 'John Doe', // In real app, get from current user
          message: _messageController.text.trim(),
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final minDuration = 5 * 60; // 5 minutes minimum
    final canEndMeeting = _secondsElapsed >= minDuration;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.meeting.title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatDuration(_secondsElapsed),
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: canEndMeeting ? _endMeeting : null,
            icon: const Icon(Icons.call_end),
            tooltip: canEndMeeting
                ? 'End Meeting'
                : 'Meeting must be at least 5 minutes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Video area (placeholder)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.video_call,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Meeting in Progress',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Participants: ${widget.meeting.participants.join(", ")}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Control buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.grey[850],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: _isAudioEnabled ? Icons.mic : Icons.mic_off,
                  label: _isAudioEnabled ? 'Mute' : 'Unmute',
                  color: _isAudioEnabled ? Colors.white : Colors.red,
                  onPressed: () {
                    setState(() {
                      _isAudioEnabled = !_isAudioEnabled;
                    });
                  },
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  label: _isVideoEnabled ? 'Stop Video' : 'Start Video',
                  color: _isVideoEnabled ? Colors.white : Colors.grey,
                  onPressed: () {
                    setState(() {
                      _isVideoEnabled = !_isVideoEnabled;
                    });
                  },
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.screen_share,
                  label: _isScreenSharing ? 'Stop Share' : 'Share Screen',
                  color: _isScreenSharing ? Colors.green : Colors.white,
                  onPressed: () {
                    setState(() {
                      _isScreenSharing = !_isScreenSharing;
                    });
                  },
                ),
                const SizedBox(width: 20),
                _buildControlButton(
                  icon: Icons.more_vert,
                  label: 'More',
                  color: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('More options coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Chat section
          Container(
            height: 200,
            color: Colors.grey[800],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Meeting Chat',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.meeting.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.meeting.messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[600],
                              child: Text(
                                message.senderName[0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        message.senderName,
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    message.message,
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[200],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[700]!)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[700],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.send, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
