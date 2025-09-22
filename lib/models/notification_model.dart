class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String priority;
  final bool isRead;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      priority: json['priority'] as String,
      isRead: json['is_read'] as bool,
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'is_read': isRead,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getTypeDisplayName() {
    switch (type) {
      case 'scholarship':
        return 'Scholarship';
      case 'project':
        return 'Project';
      case 'mentorship':
        return 'Mentorship';
      case 'system':
        return 'System';
      default:
        return type;
    }
  }

  String getPriorityDisplayName() {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'normal':
        return 'Normal';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  bool get isHighPriority => priority == 'high' || priority == 'urgent';
  bool get isUrgent => priority == 'urgent';

  String getPriorityColor() {
    switch (priority) {
      case 'low':
        return 'grey';
      case 'normal':
        return 'blue';
      case 'high':
        return 'orange';
      case 'urgent':
        return 'red';
      default:
        return 'blue';
    }
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String getIconName() {
    switch (type) {
      case 'scholarship':
        return 'school';
      case 'project':
        return 'lightbulb';
      case 'mentorship':
        return 'people';
      case 'system':
        return 'info';
      default:
        return 'notifications';
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
