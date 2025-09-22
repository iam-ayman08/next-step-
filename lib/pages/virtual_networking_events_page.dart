import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VirtualNetworkingEventsPage extends StatefulWidget {
  const VirtualNetworkingEventsPage({super.key});

  @override
  State<VirtualNetworkingEventsPage> createState() =>
      _VirtualNetworkingEventsPageState();
}

class _VirtualNetworkingEventsPageState
    extends State<VirtualNetworkingEventsPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Map<String, dynamic>> _upcomingEvents = [
    {
      'title': 'Tech Leaders Summit 2024',
      'description':
          'Connect with industry leaders and explore emerging technologies',
      'date': '2024-09-25',
      'time': '2:00 PM - 5:00 PM',
      'duration': '3 hours',
      'attendees': 150,
      'maxAttendees': 200,
      'host': 'Sarah Johnson',
      'company': 'Google',
      'category': 'Technology',
      'tags': ['AI', 'Leadership', 'Innovation'],
      'isRegistered': true,
      'isLive': false,
      'platform': 'Zoom',
      'meetingLink': 'zoom.us/meeting123',
      'price': 'Free',
      'level': 'Executive',
      'prerequisites': ['Professional experience', 'LinkedIn profile'],
    },
    {
      'title': 'Startup Networking Mixer',
      'description': 'Meet fellow entrepreneurs and potential investors',
      'date': '2024-09-28',
      'time': '6:00 PM - 8:00 PM',
      'duration': '2 hours',
      'attendees': 75,
      'maxAttendees': 100,
      'host': 'Michael Chen',
      'company': 'StartupHub',
      'category': 'Entrepreneurship',
      'tags': ['Startups', 'Investors', 'Networking'],
      'isRegistered': false,
      'isLive': false,
      'platform': 'Microsoft Teams',
      'meetingLink': 'teams.meeting456',
      'price': '\$25',
      'level': 'All Levels',
      'prerequisites': ['Business idea or startup experience'],
    },
    {
      'title': 'Women in Tech Roundtable',
      'description': 'Discussion on career advancement and work-life balance',
      'date': '2024-10-02',
      'time': '11:00 AM - 12:30 PM',
      'duration': '1.5 hours',
      'attendees': 45,
      'maxAttendees': 50,
      'host': 'Emily Rodriguez',
      'company': 'WomenTech Network',
      'category': 'Career Development',
      'tags': ['Women in Tech', 'Career', 'Mentorship'],
      'isRegistered': true,
      'isLive': false,
      'platform': 'Google Meet',
      'meetingLink': 'meet.google.com/abc123',
      'price': 'Free',
      'level': 'Mid to Senior',
      'prerequisites': ['Tech industry experience'],
    },
  ];

  final List<Map<String, dynamic>> _pastEvents = [
    {
      'title': 'AI & Machine Learning Workshop',
      'description': 'Hands-on workshop on ML fundamentals',
      'date': '2024-09-15',
      'time': '10:00 AM - 4:00 PM',
      'attendees': 120,
      'rating': 4.8,
      'feedback': 'Excellent workshop with great practical examples',
      'recordingAvailable': true,
      'materialsAvailable': true,
    },
    {
      'title': 'Product Management Masterclass',
      'description': 'Learn product strategy from industry experts',
      'date': '2024-09-10',
      'time': '1:00 PM - 5:00 PM',
      'attendees': 85,
      'rating': 4.6,
      'feedback': 'Very insightful session on product development',
      'recordingAvailable': true,
      'materialsAvailable': false,
    },
  ];

  final List<Map<String, dynamic>> _myEvents = [
    {
      'title': 'Tech Leaders Summit 2024',
      'date': '2024-09-25',
      'time': '2:00 PM',
      'status': 'upcoming',
      'reminder': true,
    },
    {
      'title': 'Women in Tech Roundtable',
      'date': '2024-10-02',
      'time': '11:00 AM',
      'status': 'upcoming',
      'reminder': false,
    },
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Technology',
    'Career Development',
    'Entrepreneurship',
    'Industry Specific',
  ];

  int _currentTabIndex = 0;
  final List<String> _tabs = ['Upcoming', 'My Events', 'Past Events'];

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
          'Virtual Networking Events',
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
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(),
            tooltip: 'Filters',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(),
            tooltip: 'Search',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          heroTag: "virtual_events_fab",
          onPressed: () => _createEvent(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Create Event'),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildUpcomingEvents();
      case 1:
        return _buildMyEvents();
      case 2:
        return _buildPastEvents();
      default:
        return _buildUpcomingEvents();
    }
  }

  Widget _buildUpcomingEvents() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _upcomingEvents.length,
      itemBuilder: (context, index) {
        return _buildEventCard(_upcomingEvents[index]);
      },
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isRegistered = event['isRegistered'] as bool;
    final attendees = event['attendees'] as int;
    final maxAttendees = event['maxAttendees'] as int;
    final spotsLeft = maxAttendees - attendees;

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
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and category
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
                    Icons.event_rounded,
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
                        event['title'],
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                          event['category'],
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
                      colors: isRegistered
                          ? [
                              Colors.green.withValues(alpha: 0.15),
                              Colors.green.withValues(alpha: 0.08),
                            ]
                          : [
                              Colors.orange.withValues(alpha: 0.15),
                              Colors.orange.withValues(alpha: 0.08),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isRegistered ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isRegistered ? 'Registered' : 'Not Registered',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isRegistered ? Colors.green : Colors.orange,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              event['description'],
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

            // Host info
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
                  Container(
                    width: 40,
                    height: 40,
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
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        event['host']
                            .toString()
                            .split(' ')
                            .map((n) => n[0])
                            .join(''),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.secondary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hosted by ${event['host']}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          event['company'],
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

            const SizedBox(height: 16),

            // Event details
            Row(
              children: [
                Expanded(
                  child: _buildEventDetail(
                    Icons.calendar_today_rounded,
                    event['date'],
                  ),
                ),
                Expanded(
                  child: _buildEventDetail(
                    Icons.access_time_rounded,
                    event['time'],
                  ),
                ),
                Expanded(
                  child: _buildEventDetail(
                    Icons.people_rounded,
                    '$attendees/$maxAttendees',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (event['tags'] as List<String>).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!.withValues(alpha: 0.8)
                            : Colors.grey[200]!.withValues(alpha: 0.8),
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]!.withValues(alpha: 0.6)
                            : Colors.grey[100]!.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]!.withValues(alpha: 0.5)
                          : Colors.grey[300]!.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[200]
                          : Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Price and level info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: event['price'] == 'Free'
                          ? [
                              Colors.green.withValues(alpha: 0.15),
                              Colors.green.withValues(alpha: 0.08),
                            ]
                          : [
                              Colors.blue.withValues(alpha: 0.15),
                              Colors.blue.withValues(alpha: 0.08),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          (event['price'] == 'Free'
                                  ? Colors.green
                                  : Colors.blue)
                              .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    event['price'],
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: event['price'] == 'Free'
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!.withValues(alpha: 0.5)
                        : Colors.grey[200]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['level'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[200]
                          : Colors.grey[700],
                    ),
                  ),
                ),
                const Spacer(),
                if (spotsLeft > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withValues(alpha: 0.15),
                          Colors.orange.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$spotsLeft spots left',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                if (!isRegistered)
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
                      child: ElevatedButton(
                        onPressed: () => _registerForEvent(event),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  )
                else
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
                        onPressed: () => _joinEvent(event),
                        icon: const Icon(Icons.video_call_rounded, size: 18),
                        label: const Text('Join Event'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!.withValues(alpha: 0.5)
                        : Colors.grey[200]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _shareEvent(event),
                    icon: Icon(
                      Icons.share_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!.withValues(alpha: 0.5)
                        : Colors.grey[200]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _addToCalendar(event),
                    icon: Icon(
                      Icons.calendar_today_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
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
  }

  Widget _buildEventDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMyEvents() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myEvents.length,
      itemBuilder: (context, index) {
        return _buildMyEventCard(_myEvents[index]);
      },
    );
  }

  Widget _buildMyEventCard(Map<String, dynamic> event) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.event, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event['date']} at ${event['time']}',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event['status'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (event['reminder'])
                  Text(
                    'Reminder set',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.blue),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastEvents() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastEvents.length,
      itemBuilder: (context, index) {
        return _buildPastEventCard(_pastEvents[index]);
      },
    );
  }

  Widget _buildPastEventCard(Map<String, dynamic> event) {
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
                  child: Text(
                    event['title'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      event['rating'].toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event['description'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEventDetail(Icons.calendar_today, event['date']),
                const SizedBox(width: 16),
                _buildEventDetail(Icons.access_time, event['time']),
                const SizedBox(width: 16),
                _buildEventDetail(
                  Icons.people,
                  '${event['attendees']} attended',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${event['feedback']}"',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (event['recordingAvailable'])
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _watchRecording(event),
                      icon: const Icon(Icons.play_circle, size: 16),
                      label: const Text('Watch Recording'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (event['recordingAvailable'] && event['materialsAvailable'])
                  const SizedBox(width: 8),
                if (event['materialsAvailable'])
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadMaterials(event),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Materials'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
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

  void _showFilters() {
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
              'Filter Events',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Filter options would go here
            Text(
              'Advanced filtering options will be displayed here.',
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

  void _showSearch() {
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
              'Search Events',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Search options would go here
            Text(
              'Advanced search options will be displayed here.',
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

  void _registerForEvent(Map<String, dynamic> event) {
    setState(() {
      event['isRegistered'] = true;
      event['attendees'] = (event['attendees'] as int) + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully registered for ${event['title']}!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _joinEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining ${event['title']}...'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _shareEvent(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event link copied to clipboard!')),
    );
  }

  void _addToCalendar(Map<String, dynamic> event) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Event added to calendar!')));
  }

  void _watchRecording(Map<String, dynamic> event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening recording for ${event['title']}...')),
    );
  }

  void _downloadMaterials(Map<String, dynamic> event) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading materials...')));
  }

  void _createEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create event feature coming soon!')),
    );
  }
}
