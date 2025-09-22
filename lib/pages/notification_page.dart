import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Job Opportunity',
      'message': 'Software Engineer position at Tech Corp is now available',
      'time': '2 hours ago',
      'type': 'job',
      'read': false,
    },
    {
      'title': 'Profile Update Reminder',
      'message': 'Complete your profile to get better job recommendations',
      'time': '1 day ago',
      'type': 'reminder',
      'read': true,
    },
    {
      'title': 'Networking Event',
      'message': 'Alumni meetup scheduled for this weekend',
      'time': '2 days ago',
      'type': 'event',
      'read': false,
    },
    {
      'title': 'Application Status Update',
      'message': 'Your application for Marketing Intern has been reviewed',
      'time': '3 days ago',
      'type': 'application',
      'read': true,
    },
    {
      'title': 'Welcome to Next Step!',
      'message': 'Thank you for joining our alumni network',
      'time': '1 week ago',
      'type': 'welcome',
      'read': true,
    },
  ];

  late AnimationController _staggerAnimationController;
  final List<Animation<double>> _itemAnimations = [];

  @override
  void initState() {
    super.initState();
    _staggerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    for (int i = 0; i < _notifications.length; i++) {
      final startTime = i * 0.1;
      final endTime = startTime + 0.4;
      _itemAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerAnimationController,
            curve: Interval(startTime, endTime, curve: Curves.easeOut),
          ),
        ),
      );
    }

    _staggerAnimationController.forward();
  }

  @override
  void dispose() {
    _staggerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotifications() async {
    // Simulate network call
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Add a new notification for demo
      _notifications.insert(0, {
        'title': 'New Connection Request',
        'message': 'Sarah Johnson wants to connect with you',
        'time': 'Just now',
        'type': 'network',
        'read': false,
      });
      // Recreate animations for new item
      _itemAnimations.insert(
        0,
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerAnimationController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        ),
      );
    });
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'job':
        return Icons.business;
      case 'reminder':
        return Icons.notifications;
      case 'event':
        return Icons.event;
      case 'application':
        return Icons.assignment;
      case 'welcome':
        return Icons.celebration;
      case 'network':
        return Icons.people;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'job':
        return const Color(0xFF4CAF50);
      case 'reminder':
        return const Color(0xFFFFC107);
      case 'event':
        return const Color(0xFF2196F3);
      case 'application':
        return const Color(0xFF9C27B0);
      case 'welcome':
        return const Color(0xFFFF5722);
      case 'network':
        return const Color(0xFF9C27B0);
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_all,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['read'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'All notifications marked as read',
                    style: GoogleFonts.inter(),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _staggerAnimationController,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _staggerAnimationController,
                          curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
                        ),
                      ),
                      child: Text(
                        "No notifications yet",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _staggerAnimationController,
                          curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
                        ),
                      ),
                      child: Text(
                        "We'll notify you when there's something new",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final animation = _itemAnimations[index];

                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - animation.value)),
                        child: Opacity(
                          opacity: animation.value,
                          child: Card(
                            elevation: notification['read'] ? 1 : 3,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  notification['read'] = true;
                                });
                                // Handle notification tap
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Opened: ${notification['title']}',
                                      style: GoogleFonts.inter(),
                                    ),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getNotificationColor(
                                          notification['type'],
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getNotificationColor(
                                              notification['type'],
                                            ).withValues(alpha: 0.2),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _getNotificationIcon(
                                          notification['type'],
                                        ),
                                        color: _getNotificationColor(
                                          notification['type'],
                                        ),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notification['title'],
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        notification['read']
                                                        ? FontWeight.normal
                                                        : FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                                ),
                                              ),
                                              if (!notification['read'])
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        spreadRadius: 1,
                                                        blurRadius: 2,
                                                        offset: const Offset(
                                                          0,
                                                          1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            notification['message'],
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            notification['time'],
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[500]
                                                  : Colors.grey[400],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
