import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_service.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'ai',
      'message': 'Hello! I\'m your AI assistant. How can I help you today?',
      'timestamp': DateTime.now(),
      'isTyping': false,
      'suggestions': [
        'Tell me about job opportunities',
        'Help with resume',
        'Career advice',
      ],
    },
  ];

  bool _isTyping = false;
  bool _isAiTyping = false;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _messageAnimationController;
  late Animation<double> _messageAnimation;

  final List<String> _quickSuggestions = [
    'Help me improve my resume',
    'Find job opportunities',
    'Career advice',
    'Interview preparation',
    'Networking tips',
    'Skill development',
  ];

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

    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _messageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _messageAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _fabAnimationController.forward();
    _messageAnimationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _messageAnimationController.dispose();
    super.dispose();
  }

  void _sendMessage([String? quickMessage]) async {
    final message = quickMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    // Get API key from AIService constant
    final String apiKey = AIService.openaiApiKey;
    if (apiKey.isEmpty || apiKey == 'your-openai-api-key-here') {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'message':
              'To enable AI chat features, please set your OpenAI API key in the AIService configuration. Contact your administrator or developer for setup assistance.',
          'timestamp': DateTime.now(),
          'isTyping': false,
          'suggestions': ['Learn more about AI setup'],
        });
      });
      return;
    }

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': message,
        'timestamp': DateTime.now(),
        'isTyping': false,
      });
      _isTyping = false;
      _isAiTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Use real AI service
      final aiService = AIService(apiKey);
      final aiResponse = await aiService.generateResponse(
        message,
        maxTokens: 500,
      );

      setState(() {
        _isAiTyping = false;
        _messages.add({
          'sender': 'ai',
          'message': aiResponse,
          'timestamp': DateTime.now(),
          'isTyping': false,
          'suggestions': _getContextualSuggestions(message),
        });
      });
    } catch (e) {
      // Fallback to simulated response if AI fails
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isAiTyping = false;
        _messages.add({
          'sender': 'ai',
          'message': _generateAIResponse(message),
          'timestamp': DateTime.now(),
          'isTyping': false,
          'suggestions': _getContextualSuggestions(message),
        });
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI service failed, using fallback: $e'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    _scrollToBottom();
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('resume') || message.contains('cv')) {
      return 'I can help you improve your resume! The AI Resume Builder in this app can analyze your experience and create a professional resume. Would you like me to guide you through the process?';
    } else if (message.contains('job') || message.contains('opportunity')) {
      return 'Great! I can help you find job opportunities. Check out the Opportunities page where you can search for jobs, apply directly, and even get AI-powered recommendations based on your profile.';
    } else if (message.contains('network') || message.contains('connect')) {
      return 'Networking is key to career success! The Networking page lets you connect with alumni, send messages, and request referrals. You can filter by industry, location, and graduation year.';
    } else if (message.contains('interview')) {
      return 'Interview preparation is crucial! I recommend practicing common questions, researching the company, and preparing stories about your experience. Would you like specific tips for your field?';
    } else if (message.contains('skill') || message.contains('learn')) {
      return 'Continuous learning is essential! Consider online courses, certifications, or hands-on projects. What skills are you interested in developing?';
    } else {
      return 'That\'s an interesting question! I\'m here to help with career advice, resume building, job searching, networking, and professional development. What specific area would you like to focus on?';
    }
  }

  List<String> _getContextualSuggestions(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('resume')) {
      return [
        'Upload my resume for review',
        'Resume formatting tips',
        'Tailor resume for specific job',
      ];
    } else if (message.contains('job')) {
      return [
        'Search for remote jobs',
        'Entry-level opportunities',
        'Jobs in my field',
      ];
    } else if (message.contains('network')) {
      return [
        'Find alumni in my industry',
        'Mentorship opportunities',
        'Professional groups',
      ];
    } else {
      return [
        'Career path guidance',
        'Salary negotiation tips',
        'Work-life balance advice',
      ];
    }
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

  void _showQuickActions() {
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
              'Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickSuggestions
                  .map(
                    (suggestion) => ActionChip(
                      label: Text(suggestion),
                      onPressed: () {
                        Navigator.pop(context);
                        _sendMessage(suggestion);
                      },
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      labelStyle: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  ),
                ),
                Text(
                  _isAiTyping ? 'Typing...' : 'Online',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _isAiTyping ? Colors.green : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showQuickActions,
            tooltip: 'Quick Actions',
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
                        ? Colors.grey[900]!.withValues(alpha: 0.3)
                        : Colors.grey[50]!.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isAiTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isAiTyping && index == _messages.length) {
                    return _buildTypingIndicator();
                  }

                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';

                  return AnimatedBuilder(
                    animation: _messageAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _messageAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: isUser
                                ? const Offset(1, 0)
                                : const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(_messageAnimation),
                          child: _buildMessageBubble(message, isUser),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Quick Suggestions (show only for last AI message)
          if (_messages.isNotEmpty &&
              _messages.last['sender'] == 'ai' &&
              _messages.last['suggestions'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (_messages.last['suggestions'] as List<String>).map(
                    (suggestion) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            suggestion,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          onPressed: () => _sendMessage(suggestion),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.1),
                          labelStyle: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),

          // Input Area
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
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.mic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            // Voice input functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice input coming soon!'),
                              ),
                            );
                          },
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      onChanged: (value) {
                        setState(() {
                          _isTyping = value.isNotEmpty;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ScaleTransition(
                  scale: _fabAnimation,
                  child: FloatingActionButton(
                    heroTag: "chat_send",
                    onPressed: _isTyping ? () => _sendMessage() : null,
                    backgroundColor: _isTyping
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    elevation: _isTyping ? 6 : 0,
                    child: Icon(_isTyping ? Icons.send : Icons.send_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                    message['message']!,
                    style: GoogleFonts.inter(
                      color: isUser
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  if (!isUser && message['suggestions'] != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Quick suggestions:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (message['suggestions'] as List<String>)
                                .map((suggestion) {
                              return InkWell(
                                onTap: () => _sendMessage(suggestion),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    suggestion,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTimestamp(message['timestamp']),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: const Radius.circular(4),
            bottomRight: const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Text(
              'AI is thinking',
              style: GoogleFonts.inter(
                color: Theme.of(context).textTheme.bodyMedium?.color,
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
                  return AnimatedBuilder(
                    animation: _messageAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        transform: Matrix4.translationValues(
                          0,
                          -4 *
                              (index == 0
                                  ? _messageAnimation.value
                                  : index == 1
                                  ? (_messageAnimation.value - 0.3).clamp(0, 1)
                                  : (_messageAnimation.value - 0.6).clamp(
                                      0,
                                      1,
                                    )),
                          0,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
