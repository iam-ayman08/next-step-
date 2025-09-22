import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notification service for handling push notifications and local notifications
class NotificationService {
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _notificationHistoryKey = 'notification_history';

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  NotificationSettings _settings = NotificationSettings();

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      // Configure Firebase messaging
      await _configureFirebaseMessaging();

      // Load settings
      await _loadSettings();

      _isInitialized = true;
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize notification service: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    // Request Firebase permissions
    final firebaseSettings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    debugPrint('Firebase notification permissions granted');

    // Request local notification permissions for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  // Configure Firebase messaging
  Future<void> _configureFirebaseMessaging() async {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle messages when app is opened from terminated state
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      // Send new token to server
    });
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.notification?.title}');

    if (_settings.showForegroundNotifications) {
      await _showLocalNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
      );
    }

    // Store notification in history
    await _storeNotification(message);
  }

  // Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Received background message: ${message.notification?.title}');

    // This function runs in a separate isolate
    // Store notification for when app resumes
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('background_notifications') ?? [];
    notifications.add(
      jsonEncode({
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    await prefs.setStringList('background_notifications', notifications);
  }

  // Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.notification?.title}');

    // Navigate to appropriate screen based on message data
    _navigateBasedOnMessage(message.data);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      _navigateBasedOnMessage(data);
    }
  }

  // Navigate based on message data
  void _navigateBasedOnMessage(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    // Navigate to appropriate screen based on notification type
    switch (type) {
      case 'networking':
        // Navigate to networking page
        break;
      case 'opportunity':
        // Navigate to opportunities page
        break;
      case 'message':
        // Navigate to messages
        break;
      case 'meeting':
        // Navigate to meetings page
        break;
      default:
        // Navigate to home
        break;
    }
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Show scheduled notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Scheduled notification channel',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _localNotifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      tzScheduledTime,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Store notification in history
  Future<void> _storeNotification(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_notificationHistoryKey) ?? [];

      final notificationData = {
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };

      history.insert(0, jsonEncode(notificationData));

      // Keep only last 100 notifications
      if (history.length > 100) {
        history.removeLast();
      }

      await prefs.setStringList(_notificationHistoryKey, history);
    } catch (e) {
      debugPrint('Failed to store notification: $e');
    }
  }

  // Get notification history
  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_notificationHistoryKey) ?? [];

      return history
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Failed to get notification history: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_notificationHistoryKey) ?? [];

      if (index < history.length) {
        final notification = jsonDecode(history[index]) as Map<String, dynamic>;
        notification['read'] = true;
        history[index] = jsonEncode(notification);

        await prefs.setStringList(_notificationHistoryKey, history);
      }
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  // Clear notification history
  Future<void> clearNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationHistoryKey);
    } catch (e) {
      debugPrint('Failed to clear notification history: $e');
    }
  }

  // Load notification settings
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_notificationSettingsKey);

      if (settingsString != null) {
        final settingsMap = jsonDecode(settingsString);
        _settings = NotificationSettings.fromJson(settingsMap);
      }
    } catch (e) {
      debugPrint('Failed to load notification settings: $e');
    }
  }

  // Save notification settings
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      _settings = settings;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _notificationSettingsKey,
        jsonEncode(settings.toJson()),
      );
    } catch (e) {
      debugPrint('Failed to save notification settings: $e');
    }
  }

  // Get current settings
  NotificationSettings getSettings() => _settings;

  // Send test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Test Notification',
      body:
          'This is a test notification to verify the notification system is working.',
    );
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final history = await getNotificationHistory();
      return history
          .where((notification) => !(notification['read'] ?? false))
          .length;
    } catch (e) {
      debugPrint('Failed to get unread notification count: $e');
      return 0;
    }
  }

  // Process background notifications when app resumes
  Future<void> processBackgroundNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications =
          prefs.getStringList('background_notifications') ?? [];

      for (final notificationString in notifications) {
        final notification = jsonDecode(notificationString);
        await _storeNotification(
          RemoteMessage(
            notification: RemoteNotification(
              title: notification['title'],
              body: notification['body'],
            ),
            data: notification['data'] ?? {},
          ),
        );
      }

      await prefs.remove('background_notifications');
    } catch (e) {
      debugPrint('Failed to process background notifications: $e');
    }
  }
}

// Notification settings model
class NotificationSettings {
  bool showForegroundNotifications;
  bool showNetworkingNotifications;
  bool showOpportunityNotifications;
  bool showMeetingNotifications;
  bool showMessageNotifications;
  bool enableSound;
  bool enableVibration;
  bool enableBadge;

  NotificationSettings({
    this.showForegroundNotifications = true,
    this.showNetworkingNotifications = true,
    this.showOpportunityNotifications = true,
    this.showMeetingNotifications = true,
    this.showMessageNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableBadge = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      showForegroundNotifications: json['showForegroundNotifications'] ?? true,
      showNetworkingNotifications: json['showNetworkingNotifications'] ?? true,
      showOpportunityNotifications:
          json['showOpportunityNotifications'] ?? true,
      showMeetingNotifications: json['showMeetingNotifications'] ?? true,
      showMessageNotifications: json['showMessageNotifications'] ?? true,
      enableSound: json['enableSound'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      enableBadge: json['enableBadge'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showForegroundNotifications': showForegroundNotifications,
      'showNetworkingNotifications': showNetworkingNotifications,
      'showOpportunityNotifications': showOpportunityNotifications,
      'showMeetingNotifications': showMeetingNotifications,
      'showMessageNotifications': showMessageNotifications,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'enableBadge': enableBadge,
    };
  }
}

// Notification widget for displaying notifications
class NotificationWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification['read'] ?? false;
    final timestamp = DateTime.parse(notification['timestamp']);

    return Dismissible(
      key: Key(notification['timestamp']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRead
              ? Colors.grey
              : Theme.of(context).colorScheme.secondary,
          child: Icon(
            _getNotificationIcon(notification['data']?['type']),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification['title'] ?? 'Notification',
          style: GoogleFonts.inter(
            fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
            color: isRead ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['body'] ?? '',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(timestamp),
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: onTap,
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'networking':
        return Icons.people;
      case 'opportunity':
        return Icons.work;
      case 'meeting':
        return Icons.calendar_today;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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
}

// Notification settings page
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late NotificationSettings _settings;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _settings = _notificationService.getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Notification Types'),
          _buildSwitchTile(
            'Networking Updates',
            'Get notified about new connections and networking opportunities',
            _settings.showNetworkingNotifications,
            (value) =>
                setState(() => _settings.showNetworkingNotifications = value),
          ),
          _buildSwitchTile(
            'Job Opportunities',
            'Receive notifications about new job postings',
            _settings.showOpportunityNotifications,
            (value) =>
                setState(() => _settings.showOpportunityNotifications = value),
          ),
          _buildSwitchTile(
            'Meeting Reminders',
            'Get reminded about upcoming meetings',
            _settings.showMeetingNotifications,
            (value) =>
                setState(() => _settings.showMeetingNotifications = value),
          ),
          _buildSwitchTile(
            'Messages',
            'Receive notifications for new messages',
            _settings.showMessageNotifications,
            (value) =>
                setState(() => _settings.showMessageNotifications = value),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Notification Preferences'),
          _buildSwitchTile(
            'Foreground Notifications',
            'Show notifications when app is open',
            _settings.showForegroundNotifications,
            (value) =>
                setState(() => _settings.showForegroundNotifications = value),
          ),
          _buildSwitchTile(
            'Sound',
            'Play sound for notifications',
            _settings.enableSound,
            (value) => setState(() => _settings.enableSound = value),
          ),
          _buildSwitchTile(
            'Vibration',
            'Vibrate device for notifications',
            _settings.enableVibration,
            (value) => setState(() => _settings.enableVibration = value),
          ),
          _buildSwitchTile(
            'Badge',
            'Show notification badge on app icon',
            _settings.enableBadge,
            (value) => setState(() => _settings.enableBadge = value),
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _notificationService.sendTestNotification(),
            icon: const Icon(Icons.notifications_active),
            label: const Text('Send Test Notification'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).colorScheme.secondary,
    );
  }

  void _saveSettings() async {
    await _notificationService.saveSettings(_settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
