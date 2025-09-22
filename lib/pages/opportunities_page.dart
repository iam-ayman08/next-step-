import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/data_service.dart';

class OpportunitiesPage extends StatefulWidget {
  const OpportunitiesPage({super.key});

  @override
  State<OpportunitiesPage> createState() => _OpportunitiesPageState();
}

class _OpportunitiesPageState extends State<OpportunitiesPage>
    with TickerProviderStateMixin {
  // Performance services
  final DataService _dataService = DataService();

  // Debounce timer for search
  Timer? _debounceTimer;

  // Data management
  List<Map<String, dynamic>> _allOpportunities = [];
  List<Map<String, dynamic>> _displayedOpportunities = [];
  final bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // Pagination
  int _currentPage = 0;
  static const int _pageSize = 10;

  // Search and filter
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Internship',
    'Full-time',
    'Contract',
    'Remote',
  ];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Animations
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late AnimationController _loadingAnimationController;

  // Default opportunities for demo
  final List<Map<String, dynamic>> _defaultOpportunities = [
    {
      'id': '1',
      'title': 'Software Engineer Intern',
      'company': 'TechCorp Solutions',
      'location': 'New York, NY',
      'type': 'Internship',
      'salary': '\$25-35/hour',
      'description':
          'Join our dynamic team to work on cutting-edge mobile applications. You\'ll collaborate with senior engineers on real projects using Flutter and Firebase.',
      'requirements': [
        'Flutter/Dart experience',
        'Git knowledge',
        'Problem-solving skills',
      ],
      'postedDate': '2 days ago',
      'applicants': 45,
      'isSaved': false,
      'isApplied': false,
      'companyLogo': 'assets/company1.png',
      'tags': ['Mobile', 'Flutter', 'Internship'],
    },
    {
      'id': '2',
      'title': 'Data Analyst',
      'company': 'DataDriven Inc',
      'location': 'San Francisco, CA',
      'type': 'Full-time',
      'salary': '\$70,000-90,000/year',
      'description':
          'We\'re looking for a data analyst to help us make sense of our growing data. You\'ll work with Python, SQL, and Tableau to create insights that drive business decisions.',
      'requirements': [
        'Python/SQL experience',
        'Data visualization',
        'Statistics knowledge',
      ],
      'postedDate': '1 week ago',
      'applicants': 23,
      'isSaved': true,
      'isApplied': false,
      'companyLogo': 'assets/company2.png',
      'tags': ['Data', 'Analytics', 'Python'],
    },
    {
      'id': '3',
      'title': 'UX/UI Designer',
      'company': 'Creative Studios',
      'location': 'Remote',
      'type': 'Contract',
      'salary': '\$50-80/hour',
      'description':
          'Design beautiful and intuitive user experiences for our client applications. Work with cross-functional teams to bring ideas to life.',
      'requirements': [
        'Figma/Sketch proficiency',
        'Portfolio',
        'User research experience',
      ],
      'postedDate': '3 days ago',
      'applicants': 67,
      'isSaved': false,
      'isApplied': true,
      'companyLogo': 'assets/company3.png',
      'tags': ['Design', 'UX/UI', 'Remote'],
    },
    {
      'id': '4',
      'title': 'Marketing Coordinator',
      'company': 'Growth Agency',
      'location': 'Chicago, IL',
      'type': 'Full-time',
      'salary': '\$45,000-55,000/year',
      'description':
          'Help drive our marketing campaigns and grow our brand presence. You\'ll work on social media, content creation, and campaign analytics.',
      'requirements': [
        'Marketing experience',
        'Social media knowledge',
        'Analytics skills',
      ],
      'postedDate': '5 days ago',
      'applicants': 31,
      'isSaved': false,
      'isApplied': false,
      'companyLogo': 'assets/company4.png',
      'tags': ['Marketing', 'Social Media', 'Content'],
    },
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
    _fabAnimationController.forward();

    // Initialize with default data
    _allOpportunities = List.from(_defaultOpportunities);
    _displayedOpportunities = List.from(_allOpportunities.take(_pageSize));
    _hasMoreData = _allOpportunities.length > _pageSize;

    // Set up search controller listener with debouncing
    _searchController.addListener(_onSearchInputChanged);

    _loadOpportunities();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchInputChanged() {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Set new timer for 300ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text;
        _currentPage = 0;
        _applyFiltersAndSearch();
      });
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 0;
      _applyFiltersAndSearch();
    });
  }

  void _applyFiltersAndSearch() {
    List<Map<String, dynamic>> filtered = List.from(_allOpportunities);

    // Apply filter first
    if (_selectedFilter == 'All') {
      filtered = _allOpportunities;
    } else if (_selectedFilter == 'Remote') {
      filtered = _allOpportunities
          .where((opp) => opp['location'] == 'Remote')
          .toList();
    } else {
      filtered = _allOpportunities
          .where((opp) => opp['type'] == _selectedFilter)
          .toList();
    }

    // Apply search if there's search text
    if (_searchQuery.isNotEmpty) {
      final searchText = _searchQuery.toLowerCase();
      filtered = filtered.where((opp) {
        return opp['title'].toLowerCase().contains(searchText) ||
            opp['company'].toLowerCase().contains(searchText) ||
            opp['location'].toLowerCase().contains(searchText) ||
            opp['description'].toLowerCase().contains(searchText) ||
            (opp['tags'] as List<String>).any(
              (tag) => tag.toLowerCase().contains(searchText),
            );
      }).toList();
    }

    // Apply pagination
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;
    _displayedOpportunities = filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
    _hasMoreData = endIndex < filtered.length;
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay for loading more data
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _currentPage++;
      _applyFiltersAndSearch();
      _isLoadingMore = false;
    });
  }

  void _toggleSave(String id) {
    setState(() {
      final opportunity = _allOpportunities.firstWhere(
        (opp) => opp['id'] == id,
      );
      opportunity['isSaved'] = !opportunity['isSaved'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _allOpportunities.firstWhere((opp) => opp['id'] == id)['isSaved']
              ? 'Opportunity saved!'
              : 'Opportunity removed from saved',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _applyToOpportunity(String id) {
    setState(() {
      final opportunity = _allOpportunities.firstWhere(
        (opp) => opp['id'] == id,
      );
      opportunity['isApplied'] = true;
      opportunity['applicants'] = (opportunity['applicants'] as int) + 1;

      // Add application record
      if (!opportunity.containsKey('applications')) {
        opportunity['applications'] = [];
      }
      (opportunity['applications'] as List).add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'applicantName': 'John Doe', // In real app, get from user profile
        'applicantEmail':
            'john.doe@email.com', // In real app, get from user profile
        'appliedDate': DateTime.now().toString(),
        'status': 'pending', // pending, reviewed, accepted, rejected
        'notes': '',
      });
    });

    _saveOpportunities();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Application submitted successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openOpportunityDetails(Map<String, dynamic> opportunity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpportunityDetailsPage(opportunity: opportunity),
      ),
    );
  }

  void _viewApplications(Map<String, dynamic> opportunity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role == 'alumni') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicationsPage(
            opportunity: opportunity,
            onApplicationUpdated: _updateOpportunity,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only alumni can view applications'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _viewAnalytics() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role == 'alumni') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalyticsPage(opportunities: _allOpportunities),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only alumni can view analytics'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _createOpportunity() async {
    // Check if user is alumni (in real app, get from authentication)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    print('Current role: $role'); // Debug print

    if (role == 'alumni') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CreateOpportunityPage(onOpportunityCreated: _addOpportunity),
        ),
      );
    } else {
      // For demo purposes, allow posting if no role is set (first time user)
      if (role == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CreateOpportunityPage(onOpportunityCreated: _addOpportunity),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Current role: $role. Only alumni can post job opportunities. Please login as alumni.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _addOpportunity(Map<String, dynamic> opportunity) {
    print('Adding opportunity: ${opportunity['title']}'); // Debug print
    setState(() {
      _allOpportunities.insert(0, opportunity);
      _applyFiltersAndSearch(); // Re-apply filters after adding
    });
    print(
      'Opportunities list now has ${_allOpportunities.length} items',
    ); // Debug print
    _saveOpportunities(); // Save to persistent storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opportunity posted successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _loadOpportunities() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? opportunitiesJson = prefs.getString('opportunities');

      if (opportunitiesJson != null) {
        List<dynamic> decodedOpportunities = json.decode(opportunitiesJson);
        setState(() {
          _allOpportunities.clear();
          _allOpportunities.addAll(
            decodedOpportunities.map((opp) => Map<String, dynamic>.from(opp)),
          );
          _applyFiltersAndSearch(); // Apply filters to loaded data
        });
        print('Loaded ${_allOpportunities.length} opportunities from storage');
      } else {
        // If no stored opportunities, keep the default ones
        _saveOpportunities(); // Save the default opportunities
        print('No stored opportunities found, using defaults');
      }
    } catch (e) {
      print('Error loading opportunities: $e');
      // If there's an error, keep the default opportunities
    }
  }

  Future<void> _saveOpportunities() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String opportunitiesJson = json.encode(_allOpportunities);
      await prefs.setString('opportunities', opportunitiesJson);
      print('Saved ${_allOpportunities.length} opportunities to storage');
    } catch (e) {
      print('Error saving opportunities: $e');
    }
  }

  void _editOpportunity(Map<String, dynamic> opportunity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role == 'alumni') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditOpportunityPage(
            opportunity: opportunity,
            onOpportunityUpdated: _updateOpportunity,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only alumni can edit job opportunities'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _deleteOpportunity(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');

    if (role == 'alumni') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Opportunity'),
            content: const Text(
              'Are you sure you want to delete this opportunity? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _allOpportunities.removeWhere((opp) => opp['id'] == id);
                    _applyFiltersAndSearch(); // Re-apply filters after deletion
                  });
                  _saveOpportunities();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opportunity deleted successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only alumni can delete job opportunities'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _updateOpportunity(Map<String, dynamic> updatedOpportunity) {
    setState(() {
      final index = _allOpportunities.indexWhere(
        (opp) => opp['id'] == updatedOpportunity['id'],
      );
      if (index != -1) {
        _allOpportunities[index] = updatedOpportunity;
        _applyFiltersAndSearch(); // Re-apply filters after update
      }
    });
    _saveOpportunities();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opportunity updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _refreshOpportunities() async {
    // Simulate network delay for refresh animation
    await Future.delayed(const Duration(seconds: 1));
    await _loadOpportunities();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opportunities refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Opportunities',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          // Analytics button (only for alumni)
          FutureBuilder<String?>(
            future: SharedPreferences.getInstance().then(
              (prefs) => prefs.getString('role'),
            ),
            builder: (context, snapshot) {
              if (snapshot.data == 'alumni') {
                return IconButton(
                  icon: Icon(
                    Icons.analytics,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                  onPressed: _viewAnalytics,
                  tooltip: 'View Analytics',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search opportunities...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = _selectedFilter == filter;
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            filter,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).brightness ==
                                        Brightness.dark
                                  ? Colors.white70
                                  : Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color ??
                                        Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          checkmarkColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOpportunities,
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        child: _displayedOpportunities.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No opportunities found",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try adjusting your search or filters",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[500]
                            : Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _displayedOpportunities.length,
                itemBuilder: (context, index) {
                  final opportunity = _displayedOpportunities[index];
                  return AnimatedBuilder(
                    animation: _fabAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _fabAnimation.value)),
                        child: Opacity(
                          opacity: _fabAnimation.value,
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            shadowColor: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.2),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _openOpportunityDetails(opportunity),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[850]!.withValues(
                                              alpha: 0.9,
                                            )
                                          : Colors.white,
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]!.withValues(
                                              alpha: 0.7,
                                            )
                                          : Colors.grey[50]!.withValues(
                                              alpha: 0.9,
                                            ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withValues(alpha: 0.3)
                                          : Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                      spreadRadius: 2,
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]!.withValues(
                                            alpha: 0.5,
                                          )
                                        : Colors.grey[200]!.withValues(
                                            alpha: 0.8,
                                          ),
                                    width: 1,
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with company and action buttons
                                    Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.business,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                opportunity['title'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color,
                                                  height: 1.2,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                opportunity['company'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Action buttons row
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Edit button (only for alumni)
                                            FutureBuilder<String?>(
                                              future:
                                                  SharedPreferences.getInstance()
                                                      .then(
                                                        (prefs) => prefs
                                                            .getString('role'),
                                                      ),
                                              builder: (context, snapshot) {
                                                if (snapshot.data == 'alumni') {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 4,
                                                        ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color:
                                                            Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600],
                                                        size: 22,
                                                      ),
                                                      onPressed: () =>
                                                          _editOpportunity(
                                                            opportunity,
                                                          ),
                                                      tooltip:
                                                          'Edit opportunity',
                                                      style: IconButton.styleFrom(
                                                        backgroundColor:
                                                            Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.grey[800]
                                                            : Colors.grey[100],
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                            // Delete button (only for alumni)
                                            FutureBuilder<String?>(
                                              future:
                                                  SharedPreferences.getInstance()
                                                      .then(
                                                        (prefs) => prefs
                                                            .getString('role'),
                                                      ),
                                              builder: (context, snapshot) {
                                                if (snapshot.data == 'alumni') {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          right: 4,
                                                        ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red[400],
                                                        size: 22,
                                                      ),
                                                      onPressed: () =>
                                                          _deleteOpportunity(
                                                            opportunity['id'],
                                                          ),
                                                      tooltip:
                                                          'Delete opportunity',
                                                      style: IconButton.styleFrom(
                                                        backgroundColor:
                                                            Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.grey[800]
                                                            : Colors.grey[100],
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                            // Save button (for all users)
                                            Container(
                                              child: IconButton(
                                                icon: Icon(
                                                  opportunity['isSaved']
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: opportunity['isSaved']
                                                      ? Theme.of(
                                                          context,
                                                        ).colorScheme.secondary
                                                      : Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                  size: 22,
                                                ),
                                                onPressed: () => _toggleSave(
                                                  opportunity['id'],
                                                ),
                                                tooltip: opportunity['isSaved']
                                                    ? 'Remove from saved'
                                                    : 'Save opportunity',
                                                style: IconButton.styleFrom(
                                                  backgroundColor:
                                                      opportunity['isSaved']
                                                      ? Theme.of(context)
                                                            .colorScheme
                                                            .secondary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            )
                                                      : Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                      ? Colors.grey[800]
                                                      : Colors.grey[100],
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Location and type
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[800]
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                opportunity['location'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            opportunity['type'],
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Salary
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        opportunity['salary'],
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Description
                                    Text(
                                      opportunity['description'],
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        height: 1.6,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[300]
                                            : Colors.grey[700],
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 20),
                                    // Tags
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children:
                                          (opportunity['tags'] as List<String>)
                                              .map((tag) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? Colors.grey[800]
                                                        : Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.grey[700]!
                                                          : Colors.grey[200]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13,
                                                      color:
                                                          Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.grey[300]
                                                          : Colors.grey[700],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                    ),
                                    const SizedBox(height: 20),
                                    // Footer with applicants and apply button
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[800]
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: 16,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${opportunity['applicants']} applicants',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[800]
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                opportunity['postedDate'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[300]
                                                      : Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        if (!opportunity['isApplied'])
                                          Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.8),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withValues(alpha: 0.3),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _applyToOpportunity(
                                                    opportunity['id'],
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 10,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                                shadowColor: Colors.transparent,
                                              ),
                                              child: Text(
                                                'Apply Now',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.green.withValues(
                                                  alpha: 0.3,
                                                ),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  size: 18,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Applied',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    color: Colors.green[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          heroTag: "opportunities_fab",
          onPressed: _createOpportunity,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CreateOpportunityPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onOpportunityCreated;

  const CreateOpportunityPage({super.key, required this.onOpportunityCreated});

  @override
  State<CreateOpportunityPage> createState() => _CreateOpportunityPageState();
}

class _CreateOpportunityPageState extends State<CreateOpportunityPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedType = 'Full-time';
  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Freelance',
  ];

  File? _companyLogo;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _companyLogo = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_companyLogo != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Logo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _companyLogo = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _createOpportunity() {
    if (_formKey.currentState!.validate()) {
      final opportunity = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'type': _selectedType,
        'salary': _salaryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text
            .trim()
            .split(',')
            .map((req) => req.trim())
            .where((req) => req.isNotEmpty)
            .toList(),
        'postedDate': 'Just now',
        'applicants': 0,
        'isSaved': false,
        'isApplied': false,
        'companyLogo': 'assets/company_default.png',
        'tags': _tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
      };

      widget.onOpportunityCreated(opportunity);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Post New Opportunity',
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
            onPressed: _createOpportunity,
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              Text(
                'Job Title',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Software Engineer Intern',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Company
              Text(
                'Company',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  hintText: 'e.g. TechCorp Solutions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Company Logo
              Text(
                'Company Logo (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]!
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[50],
                  ),
                  child: _companyLogo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _companyLogo!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to add company logo',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Location
              Text(
                'Location',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'e.g. New York, NY or Remote',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Job Type
              Text(
                'Job Type',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _jobTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Salary
              Text(
                'Salary/Compensation',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(
                  hintText: 'e.g. \$50,000-70,000/year or \$25-35/hour',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter salary information';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Job Description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe the role, responsibilities, and what you\'re looking for...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Requirements
              Text(
                'Requirements (comma-separated)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _requirementsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Flutter experience, Git knowledge, Problem-solving skills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter job requirements';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tags
              Text(
                'Tags (comma-separated)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: 'e.g. Mobile, Flutter, Internship',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at least one tag';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Post Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createOpportunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Post Opportunity',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpportunityDetailsPage extends StatelessWidget {
  final Map<String, dynamic> opportunity;

  const OpportunityDetailsPage({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Opportunity Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(Icons.business, color: Colors.blue, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity['title'],
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        opportunity['company'],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Key details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      Icons.location_on,
                      'Location',
                      opportunity['location'],
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.work,
                      'Type',
                      opportunity['type'],
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.attach_money,
                      'Salary',
                      opportunity['salary'],
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.people,
                      'Applicants',
                      '${opportunity['applicants']}',
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      context,
                      Icons.access_time,
                      'Posted',
                      opportunity['postedDate'],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Description
            Text(
              'Description',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              opportunity['description'],
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            // Requirements
            Text(
              'Requirements',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              (opportunity['requirements'] as List<String>).length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opportunity['requirements'][index],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Tags
            Text(
              'Tags',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (opportunity['tags'] as List<String>).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Apply button
            if (!opportunity['isApplied'])
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle apply
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application submitted!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Now'),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Already Applied',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

class ApplicationsPage extends StatefulWidget {
  final Map<String, dynamic> opportunity;
  final Function(Map<String, dynamic>) onApplicationUpdated;

  const ApplicationsPage({
    super.key,
    required this.opportunity,
    required this.onApplicationUpdated,
  });

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  late List<Map<String, dynamic>> _applications;

  @override
  void initState() {
    super.initState();
    _applications = List<Map<String, dynamic>>.from(
      widget.opportunity['applications'] ?? [],
    );
  }

  void _updateApplicationStatus(String applicationId, String newStatus) {
    setState(() {
      final application = _applications.firstWhere(
        (app) => app['id'] == applicationId,
      );
      application['status'] = newStatus;
    });

    // Update the parent opportunity
    final updatedOpportunity = Map<String, dynamic>.from(widget.opportunity);
    updatedOpportunity['applications'] = _applications;
    widget.onApplicationUpdated(updatedOpportunity);
  }

  void _addNotes(String applicationId, String notes) {
    setState(() {
      final application = _applications.firstWhere(
        (app) => app['id'] == applicationId,
      );
      application['notes'] = notes;
    });

    // Update the parent opportunity
    final updatedOpportunity = Map<String, dynamic>.from(widget.opportunity);
    updatedOpportunity['applications'] = _applications;
    widget.onApplicationUpdated(updatedOpportunity);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Applications - ${widget.opportunity['title']}',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: _applications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No applications yet",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Applications will appear here once candidates apply",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final application = _applications[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Applicant header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1),
                              child: Text(
                                application['applicantName']
                                    .toString()
                                    .split(' ')
                                    .map((name) => name[0])
                                    .join(''),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    application['applicantName'],
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  Text(
                                    application['applicantEmail'],
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  application['status'],
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                application['status'].toString().toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(application['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Applied date
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Applied ${DateTime.parse(application['appliedDate']).toString().split(' ')[0]}',
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

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showStatusDialog(application),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Update Status',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showNotesDialog(application),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Add Notes',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Notes section
                        if (application['notes'] != null &&
                            application['notes'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Notes',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    application['notes'],
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
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showStatusDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Update Application Status',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Pending'),
                leading: Radio<String>(
                  value: 'pending',
                  groupValue: application['status'],
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _updateApplicationStatus(application['id'], value!);
                  },
                ),
              ),
              ListTile(
                title: const Text('Reviewed'),
                leading: Radio<String>(
                  value: 'reviewed',
                  groupValue: application['status'],
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _updateApplicationStatus(application['id'], value!);
                  },
                ),
              ),
              ListTile(
                title: const Text('Accepted'),
                leading: Radio<String>(
                  value: 'accepted',
                  groupValue: application['status'],
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _updateApplicationStatus(application['id'], value!);
                  },
                ),
              ),
              ListTile(
                title: const Text('Rejected'),
                leading: Radio<String>(
                  value: 'rejected',
                  groupValue: application['status'],
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _updateApplicationStatus(application['id'], value!);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotesDialog(Map<String, dynamic> application) {
    final notesController = TextEditingController(
      text: application['notes'] ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Notes',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter notes about this applicant...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addNotes(application['id'], notesController.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class AnalyticsPage extends StatefulWidget {
  final List<Map<String, dynamic>> opportunities;

  const AnalyticsPage({super.key, required this.opportunities});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Map<String, dynamic> _analytics;

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  void _calculateAnalytics() {
    final opportunities = widget.opportunities;

    // Basic metrics
    final totalOpportunities = opportunities.length;
    final totalApplicants = opportunities.fold<int>(
      0,
      (sum, opp) => sum + (opp['applicants'] as int),
    );
    final activeOpportunities = opportunities
        .where((opp) => opp['applicants'] > 0)
        .length;

    // Job type distribution
    final jobTypeCounts = <String, int>{};
    for (final opp in opportunities) {
      final type = opp['type'] as String;
      jobTypeCounts[type] = (jobTypeCounts[type] ?? 0) + 1;
    }

    // Location distribution
    final locationCounts = <String, int>{};
    for (final opp in opportunities) {
      final location = opp['location'] as String;
      locationCounts[location] = (locationCounts[location] ?? 0) + 1;
    }

    // Application status distribution (from all opportunities)
    final applicationStatuses = <String, int>{};
    for (final opp in opportunities) {
      final applications = opp['applications'] as List<dynamic>? ?? [];
      for (final app in applications) {
        final status = app['status'] as String;
        applicationStatuses[status] = (applicationStatuses[status] ?? 0) + 1;
      }
    }

    // Recent activity (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentOpportunities = opportunities.where((opp) {
      // For demo purposes, consider all as recent
      return true;
    }).length;

    _analytics = {
      'totalOpportunities': totalOpportunities,
      'totalApplicants': totalApplicants,
      'activeOpportunities': activeOpportunities,
      'jobTypeCounts': jobTypeCounts,
      'locationCounts': locationCounts,
      'applicationStatuses': applicationStatuses,
      'recentOpportunities': recentOpportunities,
      'averageApplicantsPerOpportunity': totalOpportunities > 0
          ? (totalApplicants / totalOpportunities).round()
          : 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Analytics Dashboard',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Total Opportunities',
                    _analytics['totalOpportunities'].toString(),
                    Icons.business,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Total Applicants',
                    _analytics['totalApplicants'].toString(),
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Active Opportunities',
                    _analytics['activeOpportunities'].toString(),
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Avg Applicants/Job',
                    _analytics['averageApplicantsPerOpportunity'].toString(),
                    Icons.analytics,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Job Type Distribution
            Text(
              'Job Type Distribution',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            _buildDistributionChart(
              context,
              _analytics['jobTypeCounts'] as Map<String, int>,
              Colors.blue,
            ),

            const SizedBox(height: 24),

            // Location Distribution
            Text(
              'Location Distribution',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            _buildDistributionChart(
              context,
              _analytics['locationCounts'] as Map<String, int>,
              Colors.green,
            ),

            const SizedBox(height: 24),

            // Application Status Distribution
            Text(
              'Application Status',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            _buildApplicationStatusChart(context),

            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildActivityItem(
                      context,
                      Icons.business,
                      '${_analytics['recentOpportunities']} opportunities posted',
                      'Last 7 days',
                      Colors.blue,
                    ),
                    const Divider(height: 16),
                    _buildActivityItem(
                      context,
                      Icons.people,
                      '${_analytics['totalApplicants']} applications received',
                      'All time',
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart(
    BuildContext context,
    Map<String, int> data,
    Color color,
  ) {
    if (data.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No data available',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedEntries.map((entry) {
            final percentage = maxValue > 0 ? (entry.value / maxValue) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildApplicationStatusChart(BuildContext context) {
    final statuses = _analytics['applicationStatuses'] as Map<String, int>;

    if (statuses.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No applications yet',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    final statusColors = {
      'pending': Colors.orange,
      'reviewed': Colors.blue,
      'accepted': Colors.green,
      'rejected': Colors.red,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: statuses.entries.map((entry) {
            final color = statusColors[entry.key] ?? Colors.grey;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
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
    );
  }
}

class EditOpportunityPage extends StatefulWidget {
  final Map<String, dynamic> opportunity;
  final Function(Map<String, dynamic>) onOpportunityUpdated;

  const EditOpportunityPage({
    super.key,
    required this.opportunity,
    required this.onOpportunityUpdated,
  });

  @override
  State<EditOpportunityPage> createState() => _EditOpportunityPageState();
}

class _EditOpportunityPageState extends State<EditOpportunityPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _companyController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _requirementsController;
  late final TextEditingController _tagsController;

  late String _selectedType;
  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Freelance',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.opportunity['title']);
    _companyController = TextEditingController(
      text: widget.opportunity['company'],
    );
    _locationController = TextEditingController(
      text: widget.opportunity['location'],
    );
    _salaryController = TextEditingController(
      text: widget.opportunity['salary'],
    );
    _descriptionController = TextEditingController(
      text: widget.opportunity['description'],
    );
    _requirementsController = TextEditingController(
      text: (widget.opportunity['requirements'] as List<String>).join(', '),
    );
    _tagsController = TextEditingController(
      text: (widget.opportunity['tags'] as List<String>).join(', '),
    );
    _selectedType = widget.opportunity['type'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _updateOpportunity() {
    if (_formKey.currentState!.validate()) {
      final updatedOpportunity = {
        'id': widget.opportunity['id'],
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'type': _selectedType,
        'salary': _salaryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text
            .trim()
            .split(',')
            .map((req) => req.trim())
            .where((req) => req.isNotEmpty)
            .toList(),
        'postedDate':
            widget.opportunity['postedDate'], // Keep original post date
        'applicants': widget.opportunity['applicants'], // Keep applicant count
        'isSaved': widget.opportunity['isSaved'], // Keep save status
        'isApplied': widget.opportunity['isApplied'], // Keep apply status
        'companyLogo': widget.opportunity['companyLogo'], // Keep logo
        'tags': _tagsController.text
            .trim()
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
      };

      widget.onOpportunityUpdated(updatedOpportunity);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Opportunity',
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
            onPressed: _updateOpportunity,
            child: Text(
              'Update',
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
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              Text(
                'Job Title',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Software Engineer Intern',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Company
              Text(
                'Company',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(
                  hintText: 'e.g. TechCorp Solutions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a company name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location
              Text(
                'Location',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'e.g. New York, NY or Remote',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Job Type
              Text(
                'Job Type',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: _jobTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Salary
              Text(
                'Salary/Compensation',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(
                  hintText: 'e.g. \$50,000-70,000/year or \$25-35/hour',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter salary information';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Job Description',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Describe the role, responsibilities, and what you\'re looking for...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a job description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Requirements
              Text(
                'Requirements (comma-separated)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _requirementsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'e.g. Flutter experience, Git knowledge, Problem-solving skills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter job requirements';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tags
              Text(
                'Tags (comma-separated)',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  hintText: 'e.g. Mobile, Flutter, Internship',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter at least one tag';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateOpportunity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Update Opportunity',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
