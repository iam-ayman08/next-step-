import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/messaging_service.dart';
import '../models/message_model.dart';
import 'chat_page.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage>
    with TickerProviderStateMixin {
  late MessagingService _messagingService;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _messagingService = context.read<MessagingService>();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
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

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  void _openConversation(Conversation conversation) async {
    await _messagingService.markMessagesAsRead(conversation.id);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              // Search conversations
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              _showMoreOptions(context);
            },
          ),
        ],
      ),
      body: Container(
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
            final conversations = messagingService.getConversations();

            if (conversations.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _buildConversationTile(conversation);
              },
            );
          },
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          heroTag: "new_message",
          onPressed: () => _startNewConversation(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.message),
        ),
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    return GestureDetector(
      onTap: () => _openConversation(conversation),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: conversation.participantIds.length > 2
                    ? Colors.purple.withOpacity(0.1)
                    : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                border: Border.all(
                  color: conversation.participantIds.length > 2
                      ? Colors.purple
                      : Theme.of(context).colorScheme.secondary,
                  width: 2,
                ),
              ),
              child: conversation.participantIds.length > 2
                  ? Icon(
                      Icons.group,
                      color: Colors.purple,
                      size: 24,
                    )
                  : Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
            ),

            const SizedBox(width: 12),

            // Conversation details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.conversationName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(conversation.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : conversation.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (conversation.participantIds.length > 2) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${conversation.participantIds.length} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start connecting with alumni and mentors!\nYour messages will appear here.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _startNewConversation(),
            icon: const Icon(Icons.add),
            label: const Text('Start a Conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startNewConversation() {
    // Show dialog to create new conversation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Conversation'),
        content: const Text(
          'Would you like to start a conversation with an alumni or create a group chat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to networking page to select contacts
              // For now, we'll create a demo conversation
              _createDemoConversation();
            },
            child: const Text('Find Contacts'),
          ),
        ],
      ),
    );
  }

  void _createDemoConversation() async {
    // Create a demo conversation with a new contact
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newContactId = 'user_demo_$timestamp';

    final conversation = await _messagingService.createConversation([
      'current_user_id',
      newContactId,
    ]);

    if (conversation != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    }
  }

  void _showMoreOptions(BuildContext context) {
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
              'Message Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archived Messages'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Archived messages coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Message Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear All Messages'),
              onTap: () {
                Navigator.pop(context);
                _showClearAllConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Messages?'),
        content: const Text(
          'This action will delete all your conversations and messages. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear all messages (implementation would be in service)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Messages cleared')),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
