import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class StudyMaterialsPage extends StatefulWidget {
  const StudyMaterialsPage({Key? key}) : super(key: key);

  @override
  _StudyMaterialsPageState createState() => _StudyMaterialsPageState();
}

class _StudyMaterialsPageState extends State<StudyMaterialsPage>
    with TickerProviderStateMixin {
  // Enhanced materials data with all new features
  List<Map<String, dynamic>> _materials = [
    {
      'id': '1',
      'title': 'Data Structures and Algorithms',
      'subject_code': 'CS201',
      'subject_name': 'Computer Science',
      'description': 'Comprehensive guide to data structures and algorithms with examples',
      'is_approved': true,
      'download_count': 45,
      'rating': 4.5,
      'rating_count': 12,
      'file_type': 'pdf',
      'file_size': '2.5 MB',
      'tags': 'programming,algorithms,data structures',
      'difficulty': 'Intermediate',
      'uploader': 'Dr. Sarah Johnson',
      'uploader_role': 'Professor',
      'upload_date': '2024-09-01',
      'last_updated': '2024-09-15',
      'views': 127,
      'likes': 23,
      'bookmarks': 8,
      'comments': [
        {'user': 'John Doe', 'comment': 'Excellent material! Very helpful.', 'rating': 5, 'date': '2024-09-10'},
        {'user': 'Jane Smith', 'comment': 'Clear explanations with good examples.', 'rating': 4, 'date': '2024-09-12'},
      ],
      'prerequisites': ['Basic Programming'],
      'learning_objectives': ['Understand DS concepts', 'Implement algorithms', 'Analyze complexity'],
      'course_mapping': ['CS201', 'CS301'],
      'related_materials': ['2', '3'],
      'study_groups': 3,
      'quiz_available': true,
      'certificate_available': false,
      'estimated_time': '4 hours',
      'popularity_score': 85,
    },
    {
      'id': '2',
      'title': 'Machine Learning Fundamentals',
      'subject_code': 'CS301',
      'subject_name': 'Computer Science',
      'description': 'Introduction to machine learning concepts and techniques',
      'is_approved': true,
      'download_count': 32,
      'rating': 4.2,
      'rating_count': 8,
      'file_type': 'pdf',
      'file_size': '3.1 MB',
      'tags': 'machine learning,AI,data science',
      'difficulty': 'Advanced',
      'uploader': 'Prof. Michael Chen',
      'uploader_role': 'Professor',
      'upload_date': '2024-08-15',
      'last_updated': '2024-09-01',
      'views': 89,
      'likes': 18,
      'bookmarks': 12,
      'comments': [
        {'user': 'Alice Cooper', 'comment': 'Great introduction to ML concepts.', 'rating': 4, 'date': '2024-08-20'},
      ],
      'prerequisites': ['Statistics', 'Linear Algebra', 'Programming'],
      'learning_objectives': ['Understand ML basics', 'Implement ML algorithms', 'Evaluate models'],
      'course_mapping': ['CS301', 'CS401'],
      'related_materials': ['1', '3'],
      'study_groups': 5,
      'quiz_available': true,
      'certificate_available': true,
      'estimated_time': '6 hours',
      'popularity_score': 78,
    },
    {
      'id': '3',
      'title': 'Database Design Principles',
      'subject_code': 'CS401',
      'subject_name': 'Computer Science',
      'description': 'Best practices for database design and normalization',
      'is_approved': false,
      'download_count': 0,
      'rating': 0,
      'rating_count': 0,
      'file_type': 'pdf',
      'file_size': '1.8 MB',
      'tags': 'database,design,sql',
      'difficulty': 'Intermediate',
      'uploader': 'Dr. Emily Rodriguez',
      'uploader_role': 'Alumni',
      'upload_date': '2024-09-20',
      'last_updated': '2024-09-20',
      'views': 15,
      'likes': 2,
      'bookmarks': 1,
      'comments': [],
      'prerequisites': ['Basic SQL'],
      'learning_objectives': ['Design databases', 'Normalize tables', 'Optimize queries'],
      'course_mapping': ['CS401'],
      'related_materials': ['1', '2'],
      'study_groups': 0,
      'quiz_available': false,
      'certificate_available': false,
      'estimated_time': '3 hours',
      'popularity_score': 12,
    },
  ];

  // User data and analytics
  Map<String, dynamic> _userProfile = {
    'name': 'Current User',
    'role': 'Student',
    'reputation_score': 150,
    'total_uploads': 5,
    'total_downloads': 23,
    'helpful_votes': 12,
    'study_streak': 7,
    'badges': ['Early Adopter', 'Helpful Contributor', 'Study Enthusiast'],
  };

  // Advanced filtering and search
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  String _sortBy = 'Popularity';
  RangeValues _ratingRange = const RangeValues(0, 5);
  RangeValues _dateRange = const RangeValues(0, 365);

  // UI state
  bool _isLoading = false;
  bool _showAdvancedFilters = false;
  int _currentTab = 0;
  bool _isGridView = false;

  // Bookmarks and favorites
  List<String> _bookmarkedMaterials = [];
  List<String> _recentlyViewed = [];

  // Analytics data
  Map<String, dynamic> _analytics = {
    'total_materials': 3,
    'total_downloads': 77,
    'total_views': 231,
    'average_rating': 4.35,
    'most_popular_category': 'Computer Science',
    'trending_materials': ['1', '2'],
  };

  final List<String> _filters = ['All', 'Approved', 'Pending', 'My Uploads'];
  final List<String> _categories = [
    'All', 'Computer Science', 'Mathematics', 'Physics', 'Chemistry',
    'Biology', 'Engineering', 'Business', 'Arts', 'Languages'
  ];
  final List<String> _difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  final List<String> _sortOptions = [
    'Popularity', 'Rating', 'Date', 'Downloads', 'Title'
  ];

  // Tab options
  final List<String> _tabs = ['Browse', 'My Materials', 'Bookmarks', 'Analytics'];

  List<Map<String, dynamic>> _getFilteredMaterials() {
    return _materials.where((material) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          material['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          material['subject_name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          material['tags'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          material['uploader'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      // Category filter
      final matchesCategory = _selectedCategory == 'All' ||
          material['subject_name'] == _selectedCategory;

      // Difficulty filter
      final matchesDifficulty = _selectedDifficulty == 'All' ||
          material['difficulty'] == _selectedDifficulty;

      // Rating filter
      final matchesRating = material['rating'] >= _ratingRange.start &&
          material['rating'] <= _ratingRange.end;

      // Date filter (days since upload)
      final uploadDate = DateTime.parse(material['upload_date']);
      final daysSinceUpload = DateTime.now().difference(uploadDate).inDays;
      final matchesDate = daysSinceUpload >= _dateRange.start &&
          daysSinceUpload <= _dateRange.end;

      // Main filter
      bool matchesFilter = true;
      switch (_selectedFilter) {
        case 'Approved':
          matchesFilter = material['is_approved'] == true;
          break;
        case 'Pending':
          matchesFilter = material['is_approved'] == false;
          break;
        case 'My Uploads':
          matchesFilter = material['uploader'] == _userProfile['name'];
          break;
        default:
          matchesFilter = true;
      }

      return matchesSearch && matchesCategory && matchesDifficulty &&
             matchesRating && matchesDate && matchesFilter;
    }).toList();
  }

  List<Map<String, dynamic>> _getSortedMaterials(List<Map<String, dynamic>> materials) {
    final sortedMaterials = List<Map<String, dynamic>>.from(materials);

    switch (_sortBy) {
      case 'Popularity':
        sortedMaterials.sort((a, b) => (b['popularity_score'] ?? 0).compareTo(a['popularity_score'] ?? 0));
        break;
      case 'Rating':
        sortedMaterials.sort((a, b) => (b['rating'] ?? 0).compareTo(a['rating'] ?? 0));
        break;
      case 'Date':
        sortedMaterials.sort((a, b) => DateTime.parse(b['upload_date']).compareTo(DateTime.parse(a['upload_date'])));
        break;
      case 'Downloads':
        sortedMaterials.sort((a, b) => (b['download_count'] ?? 0).compareTo(a['download_count'] ?? 0));
        break;
      case 'Title':
        sortedMaterials.sort((a, b) => a['title'].compareTo(b['title']));
        break;
    }

    return sortedMaterials;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMaterials = _getFilteredMaterials();

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Materials'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showAdvancedFiltersDialog(context),
              tooltip: 'Advanced Filters',
            ),
            IconButton(
              icon: const Icon(Icons.view_module),
              onPressed: () => setState(() => _isGridView = !_isGridView),
              tooltip: _isGridView ? 'List View' : 'Grid View',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showUploadDialog(context),
              tooltip: 'Upload Material',
            ),
          ],
          bottom: TabBar(
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            // Browse Tab
            _buildBrowseTab(filteredMaterials),
            // My Materials Tab
            _buildMyMaterialsTab(),
            // Bookmarks Tab
            _buildBookmarksTab(),
            // Analytics Tab
            _buildAnalyticsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showUploadDialog(context),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Upload Material'),
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${material['subject_code']} - ${material['subject_name']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (material['is_approved'])
                  Icon(Icons.verified, color: Colors.green)
                else
                  Icon(Icons.pending, color: Colors.orange),
              ],
            ),

            if (material['description'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                material['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            // Stats Row
            Row(
              children: [
                Icon(Icons.download, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${material['download_count']} downloads'),
                const SizedBox(width: 16),
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${material['rating']}/5 (${material['rating_count']} ratings)'),
                const SizedBox(width: 16),
                Text(
                  material['file_type'].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags
            if (material['tags'].isNotEmpty)
              Wrap(
                spacing: 8,
                children: material['tags'].split(',').map<Widget>((tag) =>
                  Chip(
                    label: Text(tag.trim()),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  )
                ).toList(),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Download: ${material['title']}')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rating functionality coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Rate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseTab(List<Map<String, dynamic>> materials) {
    final sortedMaterials = _getSortedMaterials(materials);

    return Column(
      children: [
        // Enhanced Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Field with AI suggestions
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search materials, subjects, or topics...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () => _showVoiceSearch(),
                    tooltip: 'Voice Search',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
              const SizedBox(height: 12),

              // Quick Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._filters.map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                    )),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () => _showAdvancedFiltersDialog(context),
                      tooltip: 'Advanced Filters',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Materials List/Grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : sortedMaterials.isEmpty
                  ? _buildEmptyState()
                  : _isGridView
                      ? _buildGridView(sortedMaterials)
                      : _buildListView(sortedMaterials),
        ),
      ],
    );
  }

  Widget _buildMyMaterialsTab() {
    final myMaterials = _materials.where((material) =>
        material['uploader'] == _userProfile['name']).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'My Uploads',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${myMaterials.length} materials',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: myMaterials.isEmpty
              ? _buildEmptyState(message: 'You haven\'t uploaded any materials yet')
              : ListView.builder(
                  itemCount: myMaterials.length,
                  itemBuilder: (context, index) {
                    final material = myMaterials[index];
                    return _buildMyMaterialCard(material);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBookmarksTab() {
    final bookmarkedMaterials = _materials.where((material) =>
        _bookmarkedMaterials.contains(material['id'])).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Bookmarks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${bookmarkedMaterials.length} saved',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: bookmarkedMaterials.isEmpty
              ? _buildEmptyState(message: 'No bookmarked materials yet')
              : ListView.builder(
                  itemCount: bookmarkedMaterials.length,
                  itemBuilder: (context, index) {
                    final material = bookmarkedMaterials[index];
                    return _buildMaterialCard(material);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // User Stats
          _buildAnalyticsCard(
            'My Statistics',
            [
              _buildStatItem('Total Downloads', '${_userProfile['total_downloads']}', Icons.download),
              _buildStatItem('Uploads', '${_userProfile['total_uploads']}', Icons.upload),
              _buildStatItem('Reputation', '${_userProfile['reputation_score']}', Icons.stars),
              _buildStatItem('Study Streak', '${_userProfile['study_streak']} days', Icons.whatshot),
            ],
          ),

          const SizedBox(height: 16),

          // Platform Analytics
          _buildAnalyticsCard(
            'Platform Overview',
            [
              _buildStatItem('Total Materials', '${_analytics['total_materials']}', Icons.library_books),
              _buildStatItem('Total Downloads', '${_analytics['total_downloads']}', Icons.download),
              _buildStatItem('Total Views', '${_analytics['total_views']}', Icons.visibility),
              _buildStatItem('Avg Rating', '${_analytics['average_rating']}', Icons.star),
            ],
          ),

          const SizedBox(height: 16),

          // Badges
          _buildAnalyticsCard(
            'Achievements',
            (_userProfile['badges'] as List<String>).map((badge) =>
              _buildStatItem(badge, '', Icons.emoji_events)
            ).toList(),
          ),

          const SizedBox(height: 16),

          // Popular Categories
          _buildAnalyticsCard(
            'Popular Categories',
            [
              _buildStatItem('Computer Science', 'Most Popular', Icons.computer),
              _buildStatItem('Mathematics', 'Growing', Icons.calculate),
              _buildStatItem('Engineering', 'Trending', Icons.engineering),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String message = 'No study materials found'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> materials) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return _buildMaterialGridCard(material);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> materials) {
    return ListView.builder(
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
        return _buildMaterialCard(material);
      },
    );
  }

  Widget _buildMaterialGridCard(Map<String, dynamic> material) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material preview area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getFileTypeColor(material['file_type']).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Icon(
                _getFileTypeIcon(material['file_type']),
                size: 48,
                color: _getFileTypeColor(material['file_type']),
              ),
            ),
          ),

          // Material info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material['title'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    material['subject_name'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber),
                      Text(
                        '${material['rating']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        '${material['download_count']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Icon(Icons.download, size: 12, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyMaterialCard(Map<String, dynamic> material) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${material['subject_code']} - ${material['subject_name']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditMaterialDialog(material);
                        break;
                      case 'delete':
                        _showDeleteMaterialDialog(material);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.download, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${material['download_count']} downloads'),
                const SizedBox(width: 16),
                Icon(Icons.visibility, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${material['views']} views'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: material['is_approved'] ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    material['is_approved'] ? 'Approved' : 'Pending',
                    style: TextStyle(
                      color: material['is_approved'] ? Colors.green : Colors.orange,
                      fontSize: 12,
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

  Widget _buildAnalyticsCard(String title, List<Widget> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Advanced Filters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category Filter
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((category) =>
                    DropdownMenuItem(value: category, child: Text(category))
                  ).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),

                const SizedBox(height: 16),

                // Difficulty Filter
                DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: _difficulties.map((difficulty) =>
                    DropdownMenuItem(value: difficulty, child: Text(difficulty))
                  ).toList(),
                  onChanged: (value) => setState(() => _selectedDifficulty = value!),
                ),

                const SizedBox(height: 16),

                // Sort By
                DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: const InputDecoration(labelText: 'Sort By'),
                  items: _sortOptions.map((option) =>
                    DropdownMenuItem(value: option, child: Text(option))
                  ).toList(),
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),

                const SizedBox(height: 16),

                // Rating Range
                Text('Rating Range: ${_ratingRange.start.round()} - ${_ratingRange.end.round()}'),
                RangeSlider(
                  values: _ratingRange,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  labels: RangeLabels(
                    _ratingRange.start.round().toString(),
                    _ratingRange.end.round().toString(),
                  ),
                  onChanged: (value) => setState(() => _ratingRange = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _UploadMaterialSheet(
        onMaterialUploaded: (material) {
          setState(() {
            _materials.insert(0, material);
            _userProfile['total_uploads'] = (_userProfile['total_uploads'] as int) + 1;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Material "${material['title']}" uploaded successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  void _showVoiceSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice search functionality coming soon!')),
    );
  }

  void _showEditMaterialDialog(Map<String, dynamic> material) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit functionality for: ${material['title']}')),
    );
  }

  void _showDeleteMaterialDialog(Map<String, dynamic> material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text('Are you sure you want to delete "${material['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _materials.removeWhere((m) => m['id'] == material['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Material deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf': return Colors.red;
      case 'doc': case 'docx': return Colors.blue;
      case 'ppt': case 'pptx': return Colors.orange;
      case 'xls': case 'xlsx': return Colors.green;
      case 'txt': return Colors.grey;
      case 'jpg': case 'jpeg': case 'png': return Colors.purple;
      case 'mp4': case 'avi': case 'mov': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'xls': case 'xlsx': return Icons.table_chart;
      case 'txt': return Icons.text_snippet;
      case 'jpg': case 'jpeg': case 'png': return Icons.image;
      case 'mp4': case 'avi': case 'mov': return Icons.video_file;
      default: return Icons.insert_drive_file;
    }
  }
}

class _UploadMaterialSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onMaterialUploaded;

  const _UploadMaterialSheet({required this.onMaterialUploaded});

  @override
  __UploadMaterialSheetState createState() => __UploadMaterialSheetState();
}

class __UploadMaterialSheetState extends State<_UploadMaterialSheet> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _subjectNameController = TextEditingController();
  final _tagsController = TextEditingController();
  final _prerequisitesController = TextEditingController();
  final _objectivesController = TextEditingController();
  final _estimatedTimeController = TextEditingController();

  // Form data
  String _selectedCategory = 'Computer Science';
  String _selectedDifficulty = 'Intermediate';
  bool _isApproved = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // File data
  PlatformFile? _selectedFile;
  String _fileName = '';
  String _fileSize = '';
  String _fileType = '';

  final List<String> _categories = [
    'Computer Science', 'Mathematics', 'Physics', 'Chemistry',
    'Biology', 'Engineering', 'Business', 'Arts', 'Languages'
  ];

  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectCodeController.dispose();
    _subjectNameController.dispose();
    _tagsController.dispose();
    _prerequisitesController.dispose();
    _objectivesController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx',
          'txt', 'jpg', 'jpeg', 'png', 'mp4', 'avi', 'mov'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _fileName = _selectedFile!.name;
          _fileSize = _formatFileSize(_selectedFile!.size);
          _fileType = _selectedFile!.extension ?? 'unknown';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).round()} MB';
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _uploadProgress = i / 100.0;
        });
      }

      // Create new material
      final newMaterial = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'subject_code': _subjectCodeController.text,
        'subject_name': _selectedCategory,
        'description': _descriptionController.text,
        'is_approved': _isApproved,
        'download_count': 0,
        'rating': 0.0,
        'rating_count': 0,
        'file_type': _fileType,
        'file_size': _fileSize,
        'tags': _tagsController.text,
        'difficulty': _selectedDifficulty,
        'uploader': 'Current User',
        'uploader_role': 'Student',
        'upload_date': DateTime.now().toIso8601String(),
        'last_updated': DateTime.now().toIso8601String(),
        'views': 0,
        'likes': 0,
        'bookmarks': 0,
        'comments': [],
        'prerequisites': _prerequisitesController.text.split(',').map((s) => s.trim()).toList(),
        'learning_objectives': _objectivesController.text.split(',').map((s) => s.trim()).toList(),
        'course_mapping': [_subjectCodeController.text],
        'related_materials': [],
        'study_groups': 0,
        'quiz_available': false,
        'certificate_available': false,
        'estimated_time': _estimatedTimeController.text,
        'popularity_score': 0,
      };

      widget.onMaterialUploaded(newMaterial);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.upload_file,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Upload Study Material',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // File Selection
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile == null ? Icons.cloud_upload : Icons.insert_drive_file,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile == null
                            ? 'Tap to select file'
                            : 'File Selected: $_fileName',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Size: $_fileSize | Type: $_fileType',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Basic Information
              Text(
                'Material Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Material Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) =>
                  DropdownMenuItem(value: category, child: Text(category))
                ).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),

              const SizedBox(height: 16),

              // Subject Code
              TextFormField(
                controller: _subjectCodeController,
                decoration: const InputDecoration(
                  labelText: 'Subject Code (e.g., CS201)',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter subject code' : null,
              ),

              const SizedBox(height: 16),

              // Difficulty
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty Level',
                  prefixIcon: Icon(Icons.trending_up),
                  border: OutlineInputBorder(),
                ),
                items: _difficulties.map((difficulty) =>
                  DropdownMenuItem(value: difficulty, child: Text(difficulty))
                ).toList(),
                onChanged: (value) => setState(() => _selectedDifficulty = value!),
                validator: (value) => value == null ? 'Please select difficulty' : null,
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter description' : null,
              ),

              const SizedBox(height: 16),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., programming, algorithms, data structures',
                ),
              ),

              const SizedBox(height: 16),

              // Prerequisites
              TextFormField(
                controller: _prerequisitesController,
                decoration: const InputDecoration(
                  labelText: 'Prerequisites (comma-separated)',
                  prefixIcon: Icon(Icons.assignment),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Basic Programming, Mathematics',
                ),
              ),

              const SizedBox(height: 16),

              // Learning Objectives
              TextFormField(
                controller: _objectivesController,
                decoration: const InputDecoration(
                  labelText: 'Learning Objectives (comma-separated)',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Understand concepts, Implement algorithms',
                ),
              ),

              const SizedBox(height: 16),

              // Estimated Time
              TextFormField(
                controller: _estimatedTimeController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Study Time',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2 hours, 1 week',
                ),
                validator: (value) => value!.isEmpty ? 'Please enter estimated time' : null,
              ),

              const SizedBox(height: 24),

              // Upload Progress
              if (_isUploading) ...[
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text(
                  'Uploading... ${(_uploadProgress * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUploading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadMaterial,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Upload Material'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
