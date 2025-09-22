import 'package:flutter/material.dart';

enum MessageType {
  text,
  image,
  file,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentName;
  final bool isRead;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    DateTime? timestamp,
    this.attachmentUrl,
    this.attachmentName,
    this.isRead = false,
    this.replyToMessageId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString(),
      'status': status.toString(),
      'timestamp': timestamp.toString(),
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
      'isRead': isRead,
      'replyToMessageId': replyToMessageId,
    };
  }

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      receiverId: json['receiverId'],
      content: json['content'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      attachmentUrl: json['attachmentUrl'],
      attachmentName: json['attachmentName'],
      isRead: json['isRead'] ?? false,
      replyToMessageId: json['replyToMessageId'],
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    String? attachmentUrl,
    String? attachmentName,
    bool? isRead,
    String? replyToMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      isRead: isRead ?? this.isRead,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
}

class Conversation {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final Map<String, dynamic> participants;

  Conversation({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.participants,
    this.unreadCount = 0,
  });

  String get conversationName {
    if (participantIds.length == 2) {
      // One-on-one conversation
      String otherUserId = participantIds.where((id) => id != 'current_user_id').first;
      return participants[otherUserId]?['name'] ?? 'Unknown User';
    } else {
      // Group conversation
      return 'Group Chat (${participantIds.length} members)';
    }
  }

  String get conversationAvatar {
    if (participantIds.length == 2) {
      String otherUserId = participantIds.where((id) => id != 'current_user_id').first;
      return participants[otherUserId]?['avatar'] ?? '';
    }
    return 'group_chat'; // Placeholder for group avatar
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toString(),
      'unreadCount': unreadCount,
      'participants': participants,
    };
  }

  static Conversation fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participantIds: List<String>.from(json['participantIds']),
      lastMessage: json['lastMessage'],
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      unreadCount: json['unreadCount'] ?? 0,
      participants: Map<String, dynamic>.from(json['participants']),
    );
  }

  Conversation copyWith({
    String? id,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    Map<String, dynamic>? participants,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      participants: participants ?? this.participants,
    );
  }
}

class TypingIndicator {
  final String userId;
  final String conversationId;
  final bool isTyping;

  TypingIndicator({
    required this.userId,
    required this.conversationId,
    this.isTyping = false,
  });
}
