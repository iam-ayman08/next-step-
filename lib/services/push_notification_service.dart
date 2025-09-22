import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _messageSubscription;

  // Notification channels
  static const String _scholarshipChannelId = 'scholarships';
  static const String _projectChannelId = 'projects';
  static const String _mentorshipChannelId = 'mentorship';
  static const String _systemChannelId = 'system';

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission for notifications
      await _requestPermission();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Configure Firebase messaging
      await _configureFirebaseMessaging();

      // Set up message handlers
      _setupMessageHandlers();

      _initialized = true;
      print('✅ Push notification service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize push notifications: $e');
      _initialized = false;
    }
  }

  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: true,
        criticalAlert: true,
        provisional: false,
        announcement: true,
      );

      print('📱 Notification permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('❌ Failed to request notification permission: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel scholarshipChannel = AndroidNotificationChannel(
      _scholarshipChannelId,
      'Scholarships',
      description: 'Notifications about scholarship opportunities',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const AndroidNotificationChannel projectChannel = AndroidNotificationChannel(
      _projectChannelId,
      'Projects',
      description: 'Notifications about project updates and support',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const AndroidNotificationChannel mentorshipChannel = AndroidNotificationChannel(
      _mentorshipChannelId,
      'Mentorship',
      description: 'Notifications about mentorship requests and updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    const AndroidNotificationChannel systemChannel = AndroidNotificationChannel(
      _systemChannelId,
      'System',
      description: 'System notifications and updates',
      importance: Importance.defaultImportance,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // Register channels
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(scholarshipChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(projectChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(mentorshipChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(systemChannel);
  }

  Future<void> _configureFirebaseMessaging() async {
    // Set foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('🔥 FCM Token: $token');
      // TODO: Send token to backend for push notifications
      // await _sendTokenToBackend(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token refreshed: $newToken');
      // TODO: Update token in backend
      // _sendTokenToBackend(newToken);
    });
  }

  void _setupMessageHandlers() {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    _messageSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle message when app is opened from terminated state
    _firebaseMessaging.getInitialMessage().then(_handleInitialMessage);

    // Handle message when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('📱 Background message received: ${message.messageId}');
    // Handle background message if needed
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Foreground message received: ${message.messageId}');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? 'NextStep',
        body: notification.body ?? '',
        payload: message.data['type'] ?? 'general',
        channelId: _getChannelId(message.data['type']),
      );
    }
  }

  void _handleInitialMessage(RemoteMessage? message) {
    if (message != null) {
      print('📱 App opened from terminated state: ${message.messageId}');
      _navigateToNotification(message.data);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📱 App opened from background: ${message.messageId}');
    _navigateToNotification(message.data);
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    // Handle notification tap
    if (response.payload != null) {
      _navigateToNotification({'type': response.payload});
    }
  }

  String _getChannelId(String? type) {
    switch (type) {
      case 'scholarship':
        return _scholarshipChannelId;
      case 'project':
        return _projectChannelId;
      case 'mentorship':
        return _mentorshipChannelId;
      default:
        return _systemChannelId;
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String? payload,
    String? channelId,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'nextstep_channel',
      'NextStep Notifications',
      channelDescription: 'Notifications from NextStep platform',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      styleInformation: DefaultStyleInformation(true, true),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _navigateToNotification(Map<String, dynamic> data) {
    String? type = data['type'];
    // TODO: Navigate to appropriate page based on notification type
    print('🧭 Navigate to notification type: $type');
  }

  // Public methods for sending notifications
  Future<void> showScholarshipNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'scholarship',
      channelId: _scholarshipChannelId,
    );
  }

  Future<void> showProjectNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'project',
      channelId: _projectChannelId,
    );
  }

  Future<void> showMentorshipNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'mentorship',
      channelId: _mentorshipChannelId,
    );
  }

  Future<void> showSystemNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: 'system',
      channelId: _systemChannelId,
    );
  }

  // Subscribe to topics
  Future<void> subscribeToScholarships() async {
    await _firebaseMessaging.subscribeToTopic('scholarships');
    print('📚 Subscribed to scholarship notifications');
  }

  Future<void> subscribeToProjects() async {
    await _firebaseMessaging.subscribeToTopic('projects');
    print('💡 Subscribed to project notifications');
  }

  Future<void> subscribeToMentorship() async {
    await _firebaseMessaging.subscribeToTopic('mentorship');
    print('🤝 Subscribed to mentorship notifications');
  }

  Future<void> subscribeToAll() async {
    await subscribeToScholarships();
    await subscribeToProjects();
    await subscribeToMentorship();
    print('✅ Subscribed to all notification topics');
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromScholarships() async {
    await _firebaseMessaging.unsubscribeFromTopic('scholarships');
    print('📚 Unsubscribed from scholarship notifications');
  }

  Future<void> unsubscribeFromProjects() async {
    await _firebaseMessaging.unsubscribeFromTopic('projects');
    print('💡 Unsubscribed from project notifications');
  }

  Future<void> unsubscribeFromMentorship() async {
    await _firebaseMessaging.unsubscribeFromTopic('mentorship');
    print('🤝 Unsubscribed from mentorship notifications');
  }

  Future<void> unsubscribeFromAll() async {
    await unsubscribeFromScholarships();
    await unsubscribeFromProjects();
    await unsubscribeFromMentorship();
    print('✅ Unsubscribed from all notification topics');
  }

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _firebaseMessaging.getNotificationSettings();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    NotificationSettings settings = await getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Cleanup
  void dispose() {
    _messageSubscription?.cancel();
    _initialized = false;
  }

  // Test notification
  Future<void> showTestNotification() async {
    await showSystemNotification(
      title: 'Welcome to NextStep! 🎓',
      body: 'Your push notifications are working perfectly!',
    );
  }
}
