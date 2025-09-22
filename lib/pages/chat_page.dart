import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/messaging_service.dart';
import '../models/message_model.dart';

class ChatPage extends StatefulWidget {
  final Conversation conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late MessagingService _messagingService;

  bool _isTyping = false;
  bool _showScrollToBottom = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _messagingService = context.read<MessagingService>();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isAtBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 100;

      if (_showScrollToBottom != !isAtBottom) {
        setState(() {
          _showScrollToBottom = !isAtBottom;
        });
      }

      if (isAtBottom) {
        _unreadCount = 0;
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _messageController.clear();
    setState(() => _isTyping = false);

    try {
      await _messagingService.sendMessage(
        conversationId: widget.conversation.id,
        content: messageText,
      );

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onTypingChanged(String text) {
    final wasTyping = _isTyping;
    final isTyping = text.trim().isNotEmpty;

    if (wasTyping != isTyping) {
      setState(() => _isTyping = isTyping);
      _messagingService.sendTypingIndicator(widget.conversation.id, isTyping);
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year.toString().substring(2)}';
    }
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  if (message.attachmentUrl != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 16,
                            color: isMe ? Colors.white70 : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            message.attachmentName ?? 'Attachment',
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white70
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (message.status != MessageStatus.sending) ...[
              Padding(
                padding: EdgeInsets.only(
                  left: isMe ? 0 : 16,
                  right: isMe ? 16 : 0,
                  top: 2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMe) ...[
                      Icon(
                        message.status == MessageStatus.read
                            ? Icons.done_all
                            : Icons.done,
                        size: 12,
                        color: message.status == MessageStatus.read
                            ? Colors.blue[200]
                            : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      message.status == MessageStatus.read
                          ? 'Read'
                          : message.status == MessageStatus.delivered
                          ? 'Delivered'
                          : message.status == MessageStatus.sent
                          ? 'Sent'
                          : 'Sending...',
                      style: TextStyle(
                        color: isMe
                            ? Colors.white70
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Theme.of(context).colorScheme.secondary,
                size: 12,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI is typing',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatMessageTime(date),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[300]
                : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.conversation.participantIds.length > 2
                    ? Colors.purple.withOpacity(0.1)
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ),
              child: widget.conversation.participantIds.length > 2
                  ? Icon(
                      Icons.group,
                      color: Colors.purple,
                      size: 20,
                    )
                  : Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.conversationName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.conversation.participantIds.length > 2
                        ? '${widget.conversation.participantIds.length} members'
                        : 'Online', // In real app, check actual online status
                    style: TextStyle(
                      fontSize: 12,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]!.withOpacity(0.3)
                        : Colors.grey[50]!.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Consumer<MessagingService>(
                builder: (context, messagingService, child) {
                  final messages = messagingService.getMessagesForConversation(widget.conversation.id);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  if (messages.isEmpty) {
                    return _buildEmptyChatState();
                  }

                  return Stack(
                    children: [
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          // Check if we need to show date separator
                          Widget? dateSeparator;
                          if (index == 0 ||
                              !_isSameDay(messages[index - 1].timestamp, message.timestamp)) {
                            dateSeparator = _buildDateSeparator(message.timestamp);
                          }

                          return Column(
                            children: [
                              if (dateSeparator != null) dateSeparator,
                              _buildMessageBubble(message, message.senderId == 'current_user_id'),
                            ],
                          );
                        },
                      ),

                      // Scroll to bottom button
                      if (_showScrollToBottom)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.small(
                            onPressed: _scrollToBottom,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            child: const Icon(Icons.arrow_downward),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]!
                      : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]!
                              : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.attach_file,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed: () {
                              // Attachment functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Attachment feature coming soon!')),
                              );
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: 5,
                              minLines: 1,
                              onChanged: _onTypingChanged,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.emoji_emotions,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            onPressed: () {
                              // Emoji picker
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Emoji picker coming soon!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isTyping ? Icons.send : Icons.mic,
                        color: Colors.white,
                      ),
                      onPressed: _isTyping ? _sendMessage : () {
                        // Voice message functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voice messages coming soon!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin chatting',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showChatOptions(BuildContext context) {
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
              'Chat Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Messages'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search coming soon!')),
                );
              },
            ),
            if (widget.conversation.participantIds.length > 2)
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Add Members'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add members coming soon!')),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Mute Notifications'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mute notifications coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Conversation'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
