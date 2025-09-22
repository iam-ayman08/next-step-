import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showTimeAgo;

  const NotificationWidget({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.showTimeAgo = true,
  }) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    _isRead = widget.notification.isRead;

    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _markAsRead() async {
    if (!_isRead) {
      try {
        await ApiService().updateNotification(
          widget.notification.id,
          {'is_read': true},
        );

        setState(() {
          _isRead = true;
        });
      } catch (e) {
        print('Failed to mark notification as read: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () {
            _markAsRead();
            widget.onTap?.call();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _isRead
                  ? Colors.grey.shade50
                  : _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRead
                    ? Colors.grey.shade200
                    : _getBorderColor(),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Notification Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getIconBackgroundColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconData(),
                          size: 20,
                          color: _getIconColor(),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Title and Type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.notification.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: _isRead ? FontWeight.normal : FontWeight.w600,
                                      color: _isRead ? Colors.grey.shade600 : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Priority Badge
                                if (widget.notification.isHighPriority) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      widget.notification.getPriorityDisplayName(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 2),

                            Text(
                              widget.notification.getTypeDisplayName(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Time and Actions
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (widget.showTimeAgo)
                            Text(
                              widget.notification.getTimeAgo(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade500,
                                fontSize: 10,
                              ),
                            ),

                          const SizedBox(height: 4),

                          // Unread indicator
                          if (!_isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Message
                  Text(
                    widget.notification.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _isRead ? Colors.grey.shade700 : null,
                      height: 1.4,
                    ),
                  ),

                  // Additional Data (if any)
                  if (widget.notification.data != null &&
                      widget.notification.data!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Information:',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatAdditionalData(widget.notification.data!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action Buttons
                  if (widget.onDismiss != null || !_isRead) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!_isRead)
                          TextButton.icon(
                            onPressed: _markAsRead,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Mark Read'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),

                        if (widget.onDismiss != null) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: widget.onDismiss,
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Dismiss'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (widget.notification.isHighPriority) {
      return widget.notification.isUrgent
          ? Colors.red.shade50
          : Colors.orange.shade50;
    }
    return Colors.white;
  }

  Color _getBorderColor() {
    if (widget.notification.isHighPriority) {
      return widget.notification.isUrgent
          ? Colors.red.shade200
          : Colors.orange.shade200;
    }
    return Colors.grey.shade200;
  }

  Color _getIconBackgroundColor() {
    if (widget.notification.isHighPriority) {
      return widget.notification.isUrgent
          ? Colors.red.shade100
          : Colors.orange.shade100;
    }
    return Colors.blue.shade50;
  }

  Color _getIconColor() {
    if (widget.notification.isHighPriority) {
      return widget.notification.isUrgent
          ? Colors.red.shade700
          : Colors.orange.shade700;
    }
    return Colors.blue.shade600;
  }

  Color _getPriorityColor() {
    switch (widget.notification.priority) {
      case 'low':
        return Colors.grey.shade600;
      case 'normal':
        return Colors.blue.shade600;
      case 'high':
        return Colors.orange.shade600;
      case 'urgent':
        return Colors.red.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getIconData() {
    switch (widget.notification.type) {
      case 'scholarship':
        return Icons.school;
      case 'project':
        return Icons.lightbulb;
      case 'mentorship':
        return Icons.people;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatAdditionalData(Map<String, dynamic> data) {
    return data.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
  }
}

// Notification List Widget
class NotificationListWidget extends StatefulWidget {
  final List<NotificationModel> notifications;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final String? filterType;

  const NotificationListWidget({
    Key? key,
    required this.notifications,
    this.onLoadMore,
    this.isLoading = false,
    this.filterType,
  }) : super(key: key);

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.notifications.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.notifications.length) {
          return _buildLoadingIndicator();
        }

        final notification = widget.notifications[index];

        // Apply filter if specified
        if (widget.filterType != null &&
            notification.type != widget.filterType) {
          return const SizedBox.shrink();
        }

        return NotificationWidget(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onDismiss: () => _handleNotificationDismiss(notification),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.filterType != null
                ? 'No ${widget.filterType} notifications'
                : 'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle notification tap based on type
    print('Tapped notification: ${notification.title}');

    // You can add navigation logic here based on notification type
    // For example, navigate to specific pages
  }

  void _handleNotificationDismiss(NotificationModel notification) {
    // Handle notification dismiss
    print('Dismissed notification: ${notification.title}');

    // You can add logic to remove from list or mark as dismissed
  }
}

// Notification Badge Widget
class NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const NotificationBadge({
    Key? key,
    required this.count,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(
          minWidth: 18,
          minHeight: 18,
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
