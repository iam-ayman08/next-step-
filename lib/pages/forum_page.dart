import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';
import 'package:flutter_sound/flutter_sound.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _posts = [];
  final List<Map<String, dynamic>> _stories = [];
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  FlutterSoundPlayer? _audioPlayer;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Career Advice',
    'Networking',
    'Events',
    'Projects',
    'Q&A',
    'Announcements',
  ];
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = FlutterSoundPlayer();
    _loadPosts();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer?.closePlayer();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedPosts = prefs.getStringList('forum_posts');

    if (savedPosts != null && savedPosts.isNotEmpty) {
      if (mounted) {
        setState(() {
          _posts.clear();
          for (String postJson in savedPosts) {
            try {
              Map<String, dynamic> post = _parsePostString(postJson);
              _posts.add(post);
            } catch (e) {
              // Skip invalid posts
            }
          }
        });
      }
    } else {
      // Default posts
      if (mounted) {
        setState(() {
          _posts.addAll([
            {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'author': 'John Doe',
              'role': 'Student',
              'content':
                  'Excited to share my recent project! Working on a Flutter app for alumni networking.',
              'images': <String>[],
              'audio': null,
              'timestamp': DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
              'likes': 12,
              'comments': [
                {
                  'author': 'Jane Smith',
                  'content': 'Looks amazing!',
                  'timestamp': DateTime.now()
                      .subtract(const Duration(hours: 1))
                      .toIso8601String(),
                },
                {
                  'author': 'Mike Johnson',
                  'content': 'Great work!',
                  'timestamp': DateTime.now()
                      .subtract(const Duration(minutes: 30))
                      .toIso8601String(),
                },
              ],
              'liked': false,
              'shares': 3,
            },
            {
              'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
              'author': 'Jane Smith',
              'role': 'Alumni',
              'content':
                  'Great networking event today! Met so many talented individuals.',
              'images': <String>[],
              'audio': null,
              'timestamp': DateTime.now()
                  .subtract(const Duration(hours: 5))
                  .toIso8601String(),
              'likes': 8,
              'comments': [
                {
                  'author': 'John Doe',
                  'content': 'Wish I could have been there!',
                  'timestamp': DateTime.now()
                      .subtract(const Duration(hours: 4))
                      .toIso8601String(),
                },
              ],
              'liked': false,
              'shares': 1,
            },
          ]);
        });
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
    _savePosts();
  }

  Map<String, dynamic> _parsePostString(String postStr) {
    List<String> parts = postStr.split('|');
    return {
      'id': parts[0],
      'author': parts[1],
      'role': parts[2],
      'content': parts[3],
      'images': parts[4].isEmpty ? [] : parts[4].split(','),
      'audio': parts[5] == 'null' ? null : parts[5],
      'timestamp': parts[6],
      'likes': int.tryParse(parts[7]) ?? 0,
      'comments': parts[8] == 'null' ? [] : _parseComments(parts[8]),
      'liked': parts[9] == 'true',
      'shares': int.tryParse(parts[10]) ?? 0,
    };
  }

  List<Map<String, dynamic>> _parseComments(String commentsStr) {
    if (commentsStr.isEmpty) return [];
    List<String> commentParts = commentsStr.split(';');
    return commentParts.map((comment) {
      List<String> parts = comment.split('~');
      return {'author': parts[0], 'content': parts[1], 'timestamp': parts[2]};
    }).toList();
  }

  String _formatTimestamp(String timestamp) {
    try {
      DateTime postTime = DateTime.parse(timestamp);
      Duration difference = DateTime.now().difference(postTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return timestamp;
    }
  }

  List<Map<String, dynamic>> get _filteredPosts {
    if (_selectedCategory == 'All') {
      return _posts;
    }
    return _posts
        .where((post) => post['category'] == _selectedCategory)
        .toList();
  }

  List<Map<String, dynamic>> get _trendingPosts {
    return _posts.where((post) {
      final likes = post['likes'] as int;
      final comments = post['comments'].length;
      final shares = post['shares'] as int;
      final engagement = likes + comments * 2 + shares * 3;
      return engagement >= 10; // Trending threshold
    }).toList();
  }

  void _toggleLike(int index) {
    setState(() {
      bool currentlyLiked = _posts[index]['liked'] ?? false;
      _posts[index]['liked'] = !currentlyLiked;
      _posts[index]['likes'] =
          (_posts[index]['likes'] as int) + (currentlyLiked ? -1 : 1);
    });
    _savePosts();
  }

  void _addComment(int postIndex, String comment) {
    setState(() {
      _posts[postIndex]['comments'].add({
        'author': 'John Doe', // In real app, get from current user
        'content': comment,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
    _savePosts();
  }

  void _sharePost(int index) {
    setState(() {
      _posts[index]['shares'] = (_posts[index]['shares'] as int) + 1;
    });
    _savePosts();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post shared successfully!')));
  }

  void _openMessaging() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MessagingPage()),
    );
  }

  void _createPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostPage(onPostCreated: _addPost),
      ),
    );
  }

  void _addPost(Map<String, dynamic> post) {
    setState(() {
      _posts.insert(0, post);
    });
    _savePosts();
  }

  void _deletePost(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _posts.removeAt(index);
              });
              _savePosts();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Post deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _savePosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> postStrings = _posts.map((post) {
      return '${post['id']}|${post['author']}|${post['role']}|${post['content']}|${(post['images'] as List<dynamic>).map((e) => e.toString()).join(',')}|${post['audio'] ?? 'null'}|${post['timestamp']}|${post['likes']}|${_commentsToString(post['comments'])}|${post['liked']}|${post['shares']}';
    }).toList();
    await prefs.setStringList('forum_posts', postStrings);
  }

  String _commentsToString(List<dynamic> comments) {
    return comments
        .map(
          (comment) =>
              '${comment['author']}~${comment['content']}~${comment['timestamp']}',
        )
        .join(';');
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isLargeScreen = screenWidth > 600;

    // Responsive values
    final appBarTitleSize = isSmallScreen ? 16.0 : 20.0;
    final appBarIconSize = isSmallScreen ? 20.0 : 24.0;
    final postPadding = isSmallScreen ? 12.0 : 24.0;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(isSmallScreen ? 56.0 : 64.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8.0 : 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Community Forum',
                      style: GoogleFonts.inter(
                        fontSize: appBarTitleSize,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).appBarTheme.titleTextStyle?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isSmallScreen)
                    IconButton(
                      icon: Icon(
                        _showSearch ? Icons.close : Icons.search,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                        size: appBarIconSize,
                      ),
                      onPressed: () =>
                          setState(() => _showSearch = !_showSearch),
                      tooltip: _showSearch ? 'Close search' : 'Search',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      size: appBarIconSize,
                    ),
                    onPressed: _refreshPosts,
                    tooltip: 'Refresh',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                  // Responsive popup menu
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).appBarTheme.foregroundColor,
                      size: appBarIconSize,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'messages':
                          _openMessaging();
                          break;
                        case 'create':
                          _createPost();
                          break;
                        case 'search':
                          if (isSmallScreen) {
                            setState(() => _showSearch = !_showSearch);
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (isSmallScreen)
                        PopupMenuItem(
                          value: 'search',
                          child: Row(
                            children: [
                              Icon(
                                _showSearch ? Icons.close : Icons.search,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 12),
                              Text(_showSearch ? 'Close Search' : 'Search'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'messages',
                        child: Row(
                          children: [
                            Icon(
                              Icons.message,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            const Text('Messages'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'create',
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 12),
                            const Text('Create Post'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshPosts,
                  color: Theme.of(context).colorScheme.secondary,
                  child: CustomScrollView(
                    slivers: [
                      // Stories Section with mobile responsive
                      SliverToBoxAdapter(
                        child: Container(
                          height: isSmallScreen ? 100 : 120,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                            ),
                            itemCount:
                                _stories.length + 1, // +1 for "Add Story"
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // Add Story button
                                return Container(
                                  width: isSmallScreen ? 65 : 80,
                                  margin: EdgeInsets.only(
                                    right: isSmallScreen ? 8 : 12,
                                  ),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: _createStory,
                                        child: Container(
                                          width: isSmallScreen ? 55 : 70,
                                          height: isSmallScreen ? 55 : 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.7),
                                              ],
                                            ),
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: isSmallScreen ? 24 : 30,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 2 : 4),
                                      Text(
                                        'Add Story',
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 9 : 10,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                final story = _stories[index - 1];
                                final isViewed = story['viewed'] ?? false;
                                return Container(
                                  width: isSmallScreen ? 65 : 80,
                                  margin: EdgeInsets.only(
                                    right: isSmallScreen ? 8 : 12,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => _viewStory(index - 1),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: isSmallScreen ? 55 : 70,
                                          height: isSmallScreen ? 55 : 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: isViewed
                                                ? null
                                                : LinearGradient(
                                                    colors: [
                                                      Colors.purple,
                                                      Colors.pink,
                                                      Colors.orange,
                                                    ],
                                                  ),
                                            border: Border.all(
                                              color: isViewed
                                                  ? Colors.grey[400]!
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                              width: 2,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: CircleAvatar(
                                              backgroundColor: Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                              child: Text(
                                                story['author'][0]
                                                    .toUpperCase(),
                                                style: GoogleFonts.inter(
                                                  fontSize: isSmallScreen
                                                      ? 14
                                                      : 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: isSmallScreen ? 2 : 4),
                                        Text(
                                          story['author'].split(' ')[0],
                                          style: GoogleFonts.inter(
                                            fontSize: isSmallScreen ? 9 : 10,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      // Category Filter with mobile responsiveness
                      SliverToBoxAdapter(
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: 8,
                          ),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final isSelected = _selectedCategory == category;
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(
                                    category,
                                    style: GoogleFonts.inter(
                                      fontSize: isSmallScreen ? 10 : 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(
                                      () => _selectedCategory = category,
                                    );
                                  },
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  checkmarkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Main Posts List with mobile-optimized padding
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: _filteredPosts.isEmpty
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.forum,
                                        size: isSmallScreen ? 60 : 80,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        _selectedCategory == 'All'
                                            ? "No posts yet"
                                            : "No posts in $_selectedCategory",
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 16 : 20,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Be the first to share something!",
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[500]
                                              : Colors.grey[400],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      ElevatedButton.icon(
                                        onPressed: _createPost,
                                        icon: const Icon(Icons.add),
                                        label: Text(
                                          'Create Post',
                                          style: GoogleFonts.inter(
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                          foregroundColor: Theme.of(
                                            context,
                                          ).colorScheme.onSecondary,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : 24,
                                            vertical: isSmallScreen ? 8 : 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    // Load more posts when approaching the end
                                    if (index == _filteredPosts.length - 5) {
                                      _loadMorePosts();
                                    }
                                    final post = _filteredPosts[index];
                                    return _buildPostCard(post, index);
                                  },
                                  childCount: _filteredPosts.length,
                                  // Add semantic index callback for better accessibility
                                  findChildIndexCallback: (Key key) {
                                    final ValueKey<String> valueKey =
                                        key as ValueKey<String>;
                                    for (
                                      int i = 0;
                                      i < _filteredPosts.length;
                                      i++
                                    ) {
                                      if (_filteredPosts[i]['id'] ==
                                          valueKey.value) {
                                        return i;
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            heroTag: "forum_fab",
            onPressed: _createPost,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            tooltip: 'Create Post',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int originalIndex) {
    final filteredIndex = _posts.indexOf(post);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]!.withValues(alpha: 0.9)
                : Colors.white,
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!.withValues(alpha: 0.7)
                : Colors.grey[50]!.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.08),
            spreadRadius: 2,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header with online indicator
            Row(
              children: [
                // Profile avatar with online status
                Stack(
                  children: [
                    Container(
                      width: isSmallScreen ? 40 : 52,
                      height: isSmallScreen ? 40 : 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.25),
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.15),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.4),
                          width: isSmallScreen ? 1.5 : 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: isSmallScreen ? 4 : 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          post['author'][0].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 16 : 22,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: isSmallScreen ? 12 : 16,
                        height: isSmallScreen ? 12 : 16,
                        decoration: BoxDecoration(
                          color: Colors.green[500],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[850]!
                                : Colors.white,
                            width: isSmallScreen ? 1.5 : 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post['author'],
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen ? 14 : 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 6 : 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.15),
                                  Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              post['role'],
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 9 : 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatTimestamp(post['timestamp']),
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen ? 11 : 13,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[300]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),
                          Container(
                            width: isSmallScreen ? 4 : 5,
                            height: isSmallScreen ? 4 : 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 10),
                          Icon(
                            Icons.public,
                            size: isSmallScreen ? 12 : 14,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Enhanced menu button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                      size: isSmallScreen ? 16 : 20,
                    ),
                    onPressed: () =>
                        _showPostMenu(context, post, filteredIndex),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 12 : 20),

            // Enhanced post content with better typography
            Text(
              post['content'],
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 14 : 16,
                height: 1.7,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),

            // Media content with mobile optimization
            if (post['images'] != null && post['images'].isNotEmpty) ...[
              SizedBox(height: isSmallScreen ? 12 : 20),
              _buildEnhancedImageGallery(post['images']),
            ],

            SizedBox(height: isSmallScreen ? 12 : 20),

            // Enhanced engagement section with mobile layout
            Container(
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[600]!
                        : Colors.grey[200]!,
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Engagement stats
                  Row(
                    children: [
                      _buildEngagementStat(
                        Icons.favorite_rounded,
                        '${post['likes']}',
                        Colors.red[500]!,
                      ),
                      const SizedBox(width: 20),
                      _buildEngagementStat(
                        Icons.mode_comment_rounded,
                        '${post['comments'].length}',
                        Colors.blue[500]!,
                      ),
                      const SizedBox(width: 20),
                      _buildEngagementStat(
                        Icons.share_rounded,
                        '${post['shares']}',
                        Colors.green[500]!,
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  // Enhanced action buttons with mobile layout
                  Row(
                    children: [
                      _buildActionButton(
                        icon: post['liked'] == true
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: 'Like',
                        color: post['liked'] == true ? Colors.red[500] : null,
                        onTap: () => _toggleLike(filteredIndex),
                      ),
                      _buildActionButton(
                        icon: Icons.mode_comment_outlined,
                        label: 'Comment',
                        onTap: () =>
                            _showCommentsDialog(context, filteredIndex),
                      ),
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        label: 'Share',
                        onTap: () => _sharePost(filteredIndex),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Comments preview with mobile optimization
            if (post['comments'].isNotEmpty) ...[
              SizedBox(height: isSmallScreen ? 12 : 20),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]!.withValues(alpha: 0.8)
                          : Colors.grey[50]!.withValues(alpha: 0.9),
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[750]!.withValues(alpha: 0.6)
                          : Colors.grey[100]!.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.comment_rounded,
                          size: isSmallScreen ? 14 : 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 10),
                        Text(
                          '${post['comments'].length} Comments',
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 13 : 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    ...post['comments'].take(2).map<Widget>((comment) {
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: isSmallScreen ? 12 : 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: isSmallScreen ? 28 : 36,
                              height: isSmallScreen ? 28 : 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.secondary
                                        .withValues(alpha: 0.2),
                                    Theme.of(context).colorScheme.secondary
                                        .withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  comment['author'][0].toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 10 : 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment['author'],
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 6 : 10),
                                      Text(
                                        _formatTimestamp(comment['timestamp']),
                                        style: GoogleFonts.inter(
                                          fontSize: isSmallScreen ? 10 : 12,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isSmallScreen ? 4 : 6),
                                  Text(
                                    comment['content'],
                                    style: GoogleFonts.inter(
                                      fontSize: isSmallScreen ? 12 : 14,
                                      height: 1.5,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[200]
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (post['comments'].length > 2)
                      TextButton(
                        onPressed: () =>
                            _showCommentsDialog(context, filteredIndex),
                        child: Text(
                          'View all ${post['comments'].length} comments',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: isSmallScreen ? 12 : 13,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildEngagementStat(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    color ??
                    (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600]),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      color ??
                      (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, int postIndex) {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Comments',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _posts[postIndex]['comments'].length,
                  itemBuilder: (context, commentIndex) {
                    final comment = _posts[postIndex]['comments'][commentIndex];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment['author'],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(comment['timestamp']),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment['content'],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty) {
                          _addComment(postIndex, commentController.text.trim());
                          commentController.clear();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostMenu(
    BuildContext context,
    Map<String, dynamic> post,
    int postIndex,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                post['bookmarked'] == true
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                post['bookmarked'] == true
                    ? 'Remove Bookmark'
                    : 'Bookmark Post',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleBookmark(postIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: Text(
                'Share Post',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _sharePost(postIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: Text(
                'Report Post',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _reportPost(postIndex);
              },
            ),
            if (post['author'] ==
                'John Doe') // In real app, check if current user is author
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete Post',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(postIndex);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _toggleBookmark(int index) {
    setState(() {
      _posts[index]['bookmarked'] = !(_posts[index]['bookmarked'] ?? false);
    });
    _savePosts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _posts[index]['bookmarked'] == true
              ? 'Post bookmarked!'
              : 'Bookmark removed!',
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _reportPost(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Are you sure you want to report this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Post reported')));
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedImageGallery(List<String> images) {
    if (images.length == 1) {
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenImage(imagePath: images[0]),
          ),
        ),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(File(images[0])),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Multiple images - show grid or carousel
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenImage(imagePath: images[0]),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(File(images[0])),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImage(imagePath: images[1]),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: FileImage(File(images[1])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                if (images.length > 2) ...[
                  const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullScreenImage(imagePath: images[2]),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(File(images[2])),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        if (images.length > 3)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            child: Center(
                              child: Text(
                                '+${images.length - 3}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadMorePosts() {
    setState(() {
      _posts.addAll([
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'author': 'Alex Chen',
          'role': 'Data Scientist',
          'content':
              'Excited to share my latest data visualization project! Using Flutter and D3.js for interactive charts.',
          'images': <String>[],
          'audio': null,
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 6))
              .toIso8601String(),
          'likes': 15,
          'comments': [],
          'liked': false,
          'shares': 5,
        },
        {
          'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          'author': 'Mike Johnson',
          'role': 'Product Manager',
          'content':
              'Just landed an interview at a top tech company! Any tips for PM interviews?',
          'images': <String>[],
          'audio': null,
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 8))
              .toIso8601String(),
          'likes': 22,
          'comments': [],
          'liked': false,
          'shares': 2,
        },
      ]);
    });
    _savePosts();
  }

  void _createStory() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _stories.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'author': 'John Doe',
          'image': image.path,
          'timestamp': DateTime.now().toIso8601String(),
          'viewed': false,
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 24))
              .toIso8601String(),
        });
      });
      _saveStories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story created successfully!')),
      );
    }
  }

  void _viewStory(int index) async {
    setState(() {
      _stories[index]['viewed'] = true;
    });
    _saveStories();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryViewerPage(
          stories: _stories,
          initialIndex: index,
          onStoryViewed: (storyIndex) {
            setState(() {
              _stories[storyIndex]['viewed'] = true;
            });
            _saveStories();
          },
        ),
      ),
    );
  }

  Future<void> _saveStories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storyStrings = _stories.map((story) {
      return '${story['id']}|${story['author']}|${story['image']}|${story['timestamp']}|${story['viewed']}|${story['expiresAt']}';
    }).toList();
    await prefs.setStringList('stories', storyStrings);
  }
}

class CreatePostPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onPostCreated;

  const CreatePostPage({super.key, required this.onPostCreated});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  String? _selectedAudio;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = Directory.systemTemp;
        final filePath =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecording = true;
          _selectedAudio = filePath;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start recording: $e')));
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _selectedAudio = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
    }
  }

  void _createPost() {
    if (_contentController.text.trim().isEmpty &&
        _selectedImages.isEmpty &&
        _selectedAudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please add some content, images, or audio"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final post = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author': 'John Doe',
      'role': 'Student',
      'content': _contentController.text.trim(),
      'images': _selectedImages.map((img) => img.path).toList(),
      'audio': _selectedAudio,
      'timestamp': DateTime.now().toIso8601String(),
      'likes': 0,
      'comments': [],
      'liked': false,
      'shares': 0,
    };

    widget.onPostCreated(post);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _createPost,
            child: Text(
              'Post',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedImages.isNotEmpty) ...[
              Text(
                'Selected Images (${_selectedImages.length})',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(
                                File(_selectedImages[index].path),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Add Images'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    label: Text(
                      _isRecording ? 'Stop Recording' : 'Record Audio',
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _isRecording
                            ? Colors.red
                            : Theme.of(context).colorScheme.secondary,
                      ),
                      foregroundColor: _isRecording
                          ? Colors.red
                          : Theme.of(context).colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(File(imagePath), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class MessagingPage extends StatelessWidget {
  const MessagingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Messaging Page - Coming Soon!')),
    );
  }
}

class StoryViewerPage extends StatefulWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;
  final Function(int) onStoryViewed;

  const StoryViewerPage({
    super.key,
    required this.stories,
    required this.initialIndex,
    required this.onStoryViewed,
  });

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _startAnimation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_isPaused) {
      _animationController.forward(from: 0.0);
    }
  }

  void _pauseAnimation() {
    setState(() => _isPaused = true);
    _animationController.stop();
  }

  void _resumeAnimation() {
    setState(() => _isPaused = false);
    _startAnimation();
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      widget.onStoryViewed(index);
    });
    _startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        onLongPressStart: (_) => _pauseAnimation(),
        onLongPressEnd: (_) => _resumeAnimation(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(story['image'])),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Row(
                children: widget.stories.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: index < _currentIndex
                              ? 1.0
                              : index == _currentIndex
                              ? _animationController.value
                              : 0.0,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      widget.stories[_currentIndex]['author'][0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.stories[_currentIndex]['author'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
