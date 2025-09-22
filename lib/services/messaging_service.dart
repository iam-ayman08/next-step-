import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'storage_service.dart';

class MessagingService with ChangeNotifier {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final StorageService _storage = StorageService();

  // In-memory storage for demo purposes
  final List<Conversation> _conversations = [];
  final Map<String, List<Message>> _messages = {};

  // Current user ID (will be set from auth service)
  String? _currentUserId;

  // Stream controllers for real-time updates
  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<Conversation> _conversationController = StreamController<Conversation>.broadcast();
  final StreamController<TypingIndicator> _typingController = StreamController<TypingIndicator>.broadcast();

  Stream<Message> get messageStream => _messageController.stream;
  Stream<Conversation> get conversationStream => _conversationController.stream;
  Stream<TypingIndicator> get typingStream => _typingController.stream;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;

    // Load conversations from storage
    await _loadConversations();

    // Initialize with demo data if none exists
    if (_conversations.isEmpty) {
      await _initializeDemoData();
    }

    // Simulate real-time connection (in production, this would connect to WebSocket/Server-Sent Events)
    _startMockRealtimeConnection();
  }

  Future<void> _loadConversations() async {
    try {
      final cachedConversations = await _storage.read('messaging_conversations');
      _conversations.clear();

      if (cachedConversations != null) {
        final conversationsList = json.decode(cachedConversations) as List;
        for (final cached in conversationsList) {
          final conversationData = cached as Map<String, dynamic>;
          final conversation = Conversation.fromJson(conversationData);
          _conversations.add(conversation);

          // Load messages for this conversation
          await _loadMessagesForConversation(conversation.id);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
    }
  }

  Future<void> _loadMessagesForConversation(String conversationId) async {
    try {
      final cachedMessagesString = await _storage.read('messages_$conversationId');
      _messages[conversationId] = [];

      if (cachedMessagesString != null) {
        final messagesList = json.decode(cachedMessagesString) as List;
        for (final cached in messagesList) {
          final messageData = cached as Map<String, dynamic>;
          final message = Message.fromJson(messageData);
          _messages[conversationId]!.add(message);
        }
      }

      // Sort messages by timestamp
      _messages[conversationId]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      debugPrint('Error loading messages for conversation $conversationId: $e');
    }
  }

  Future<void> _initializeDemoData() async {
    // Create demo conversations
    final demoConversations = [
      Conversation(
        id: 'conv_1',
        participantIds: [_currentUserId!, 'user_2'],
        lastMessage: 'Hey, I saw your profile and would like to connect for mentorship!',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        participants: {
          _currentUserId!: {
            'name': 'You',
            'role': 'student',
            'avatar': '',
          },
          'user_2': {
            'name': 'Sarah Johnson',
            'role': 'alumni',
            'avatar': '',
            'currentPosition': 'Senior Software Engineer at Google',
          },
        },
        unreadCount: 1,
      ),
      Conversation(
        id: 'conv_2',
        participantIds: [_currentUserId!, 'user_3'],
        lastMessage: 'Thanks for the interview tips! Really helpful.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        participants: {
          _currentUserId!: {
            'name': 'You',
            'role': 'student',
            'avatar': '',
          },
          'user_3': {
            'name': 'Michael Chen',
            'role': 'alumni',
            'avatar': '',
            'currentPosition': 'Product Manager at Microsoft',
          },
        },
      ),
      Conversation(
        id: 'conv_3',
        participantIds: [_currentUserId!, 'user_4', 'user_5'],
        lastMessage: 'The study session is scheduled for this weekend.',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 5)),
        participants: {
          _currentUserId!: {
            'name': 'You',
            'role': 'student',
            'avatar': '',
          },
          'user_4': {
            'name': 'David Kim',
            'role': 'student',
            'avatar': '',
            'currentPosition': 'Computer Science Student',
          },
          'user_5': {
            'name': 'Lisa Thompson',
            'role': 'student',
            'avatar': '',
            'currentPosition': 'Data Science Student',
          },
        },
      ),
    ];

    // Add demo messages for each conversation
    for (final conversation in demoConversations) {
      _conversations.add(conversation);
      await _saveConversation(conversation);

      // Add demo messages
      final demoMessages = _getDemoMessagesForConversation(conversation.id);
      _messages[conversation.id] = demoMessages;
      await _saveMessagesForConversation(conversation.id);
    }

    notifyListeners();
  }

  List<Message> _getDemoMessagesForConversation(String conversationId) {
    switch (conversationId) {
      case 'conv_1':
        return [
          Message(
            id: 'msg_1_1',
            senderId: 'user_2',
            senderName: 'Sarah Johnson',
            receiverId: _currentUserId!,
            content: 'Hello! I noticed you\'re studying Computer Science and have a keen interest in AI.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
          ),
          Message(
            id: 'msg_1_2',
            senderId: 'user_2',
            senderName: 'Sarah Johnson',
            receiverId: _currentUserId!,
            content: 'I\'m a Senior Software Engineer at Google working on AI/ML projects.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
          ),
          Message(
            id: 'msg_1_3',
            senderId: _currentUserId!,
            senderName: 'You',
            receiverId: 'user_2',
            content: 'Hi Sarah! That sounds amazing. I\'m really interested in AI/ML as well.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 31)),
          ),
          Message(
            id: 'msg_1_4',
            senderId: 'user_2',
            senderName: 'Sarah Johnson',
            receiverId: _currentUserId!,
            content: 'Great! Would you be interested in a mentorship session? I can share my experiences and help you navigate your career path.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ];

      case 'conv_2':
        return [
          Message(
            id: 'msg_2_1',
            senderId: _currentUserId!,
            senderName: 'You',
            receiverId: 'user_3',
            content: 'Thanks for the interview tips! They really helped me prepare for the Google interview.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ];

      case 'conv_3':
        return [
          Message(
            id: 'msg_3_1',
            senderId: 'user_4',
            senderName: 'David Kim',
            receiverId: _currentUserId!,
            content: 'Hey team! Are we still on for the study session this weekend?',
            timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          ),
          Message(
            id: 'msg_3_2',
            senderId: _currentUserId!,
            senderName: 'You',
            receiverId: 'user_4',
            content: 'Yes! I booked the study room for 10 AM Saturday.',
            timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
          ),
          Message(
            id: 'msg_3_3',
            senderId: 'user_5',
            senderName: 'Lisa Thompson',
            receiverId: 'user_4',
            content: 'Perfect! I\'ll bring the machine learning notes we discussed.',
            timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 10)),
          ),
          Message(
            id: 'msg_3_4',
            senderId: 'user_4',
            senderName: 'David Kim',
            receiverId: _currentUserId!,
            content: 'The study session is scheduled for this weekend.',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ),
        ];

      default:
        return [];
    }
  }

  void _startMockRealtimeConnection() {
    // Simulate receiving new messages periodically
    Timer.periodic(const Duration(seconds: 30), (timer) {
      _simulateIncomingMessage();
    });
  }

  void _simulateIncomingMessage() {
    if (_conversations.isEmpty) return;

    final random = DateTime.now().millisecondsSinceEpoch % _conversations.length;
    final conversation = _conversations[random];

    final mockMessages = [
      'Hey, are you free for a quick chat about your career plans?',
      'I saw you applied for that internship. Let me know if you need any help with the application.',
      'Thanks for connecting! How can I help you with your studies?',
      'Would you be interested in joining our study group?',
      'Great profile! Let\'s schedule a mentorship session.',
    ];

    final randomMessage = mockMessages[DateTime.now().millisecondsSinceEpoch % mockMessages.length];

    final newMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: conversation.participantIds.where((id) => id != _currentUserId).first,
      senderName: conversation.participants[conversation.participantIds.where((id) => id != _currentUserId).first]['name'],
      receiverId: _currentUserId!,
      content: randomMessage,
      timestamp: DateTime.now(),
    );

    // Add to conversation's messages
    _messages[conversation.id] ??= [];
    _messages[conversation.id]!.add(newMessage);

    // Update conversation's last message
    final updatedConversation = conversation.copyWith(
      lastMessage: newMessage.content,
      lastMessageTime: newMessage.timestamp,
      unreadCount: conversation.unreadCount + 1,
    );

    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _conversations[index] = updatedConversation;
    }

    // Save to storage
    _saveMessagesForConversation(conversation.id);
    _saveConversation(updatedConversation);

    // Notify listeners
    _messageController.add(newMessage);
    _conversationController.add(updatedConversation);
    notifyListeners();
  }

  Future<void> _saveConversation(Conversation conversation) async {
    try {
      // Load existing conversations
      final existingJson = await _storage.read('messaging_conversations');
      List<Map<String, dynamic>> conversationsList = [];

      if (existingJson != null) {
        conversationsList = List<Map<String, dynamic>>.from(json.decode(existingJson));
      }

      // Remove existing conversation if present
      conversationsList.removeWhere((c) => c['id'] == conversation.id);

      // Add the new/updated conversation
      conversationsList.add(conversation.toJson());

      // Save back to storage
      final updatedJson = json.encode(conversationsList);
      await _storage.write('messaging_conversations', updatedJson);
    } catch (e) {
      debugPrint('Error saving conversation: $e');
    }
  }

  Future<void> _saveMessagesForConversation(String conversationId) async {
    try {
      final messages = _messages[conversationId] ?? [];
      final messagesJson = json.encode(messages.map((m) => m.toJson()).toList());
      await _storage.write('messages_$conversationId', messagesJson);
    } catch (e) {
      debugPrint('Error saving messages for conversation $conversationId: $e');
    }
  }

  // Public API methods

  List<Conversation> getConversations() {
    _conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return List.unmodifiable(_conversations);
  }

  List<Message> getMessagesForConversation(String conversationId) {
    return List.unmodifiable(_messages[conversationId] ?? []);
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_${_currentUserId}',
      senderId: _currentUserId!,
      senderName: 'You',
      receiverId: conversationId.contains('conv_') ? 'recipient' : 'recipient', // Simplified
      content: content,
      type: type,
    );

    // Add to conversation's messages
    _messages[conversationId] ??= [];
    _messages[conversationId]!.add(message);

    // Update conversation
    final conversation = _conversations.firstWhere((c) => c.id == conversationId);
    final updatedConversation = conversation.copyWith(
      lastMessage: content,
      lastMessageTime: DateTime.now(),
    );

    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      _conversations[index] = updatedConversation;
    }

    // Save to storage
    await _saveMessagesForConversation(conversationId);
    await _saveConversation(updatedConversation);

    // Notify listeners
    _messageController.add(message);
    _conversationController.add(updatedConversation);
    notifyListeners();
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    final messages = _messages[conversationId] ?? [];
    bool hasUnread = false;

    for (int i = 0; i < messages.length; i++) {
      if (!messages[i].isRead && messages[i].receiverId == _currentUserId) {
        messages[i] = messages[i].copyWith(isRead: true);
        hasUnread = true;
      }
    }

    if (hasUnread) {
      final conversation = _conversations.firstWhere((c) => c.id == conversationId);
      final updatedConversation = conversation.copyWith(unreadCount: 0);

      final index = _conversations.indexWhere((c) => c.id == conversationId);
      if (index != -1) {
        _conversations[index] = updatedConversation;
      }

      await _saveMessagesForConversation(conversationId);
      await _saveConversation(updatedConversation);

      notifyListeners();
    }
  }

  Future<Conversation?> createConversation(List<String> participantIds) async {
    // Check if conversation already exists
    final existingConversation = _conversations.firstWhere(
      (c) {
        final otherIds = c.participantIds.where((id) => id != _currentUserId).toList();
        final incomingIds = participantIds.where((id) => id != _currentUserId).toList();
        return otherIds.toSet().containsAll(incomingIds) && incomingIds.toSet().containsAll(otherIds);
      },
      orElse: () => null as Conversation,
    );

    if (existingConversation != null) {
      return existingConversation;
    }

    // Create new conversation
    final conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    final participants = <String, dynamic>{};

    for (final id in participantIds) {
      if (id == _currentUserId) {
        participants[id] = {'name': 'You', 'role': 'student', 'avatar': ''};
      } else {
        participants[id] = {'name': 'User $id', 'role': 'alumni', 'avatar': ''}; // Demo data
      }
    }

    final conversation = Conversation(
      id: conversationId,
      participantIds: participantIds,
      lastMessage: 'Conversation started',
      lastMessageTime: DateTime.now(),
      participants: participants,
    );

    _conversations.add(conversation);
    _messages[conversationId] = [];

    await _saveConversation(conversation);
    await _saveMessagesForConversation(conversationId);

    notifyListeners();
    return conversation;
  }

  void sendTypingIndicator(String conversationId, bool isTyping) {
    final indicator = TypingIndicator(
      userId: _currentUserId!,
      conversationId: conversationId,
      isTyping: isTyping,
    );
    _typingController.add(indicator);
  }

  void dispose() {
    _messageController.close();
    _conversationController.close();
    _typingController.close();
    super.dispose();
  }
}
