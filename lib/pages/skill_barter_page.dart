import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SkillBarterPage extends StatefulWidget {
  const SkillBarterPage({super.key});

  @override
  State<SkillBarterPage> createState() => _SkillBarterPageState();
}

class _SkillBarterPageState extends State<SkillBarterPage>
    with TickerProviderStateMixin {
  final TextEditingController _skillOfferedController = TextEditingController();
  final TextEditingController _skillWantedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<SkillExchange> _skillExchanges = [];
  List<SkillExchange> _mySkills = [];
  List<SkillExchange> _filteredSkills = [];
  List<SkillExchange> _recommendedSkills = [];
  List<Map<String, dynamic>> _myReviews = [];
  List<Map<String, dynamic>> _exchangeHistory = [];

  String _selectedCategory = 'All';
  String _sortBy = 'rating';
  bool _showRecommended = false;
  bool _isSearchActive = false;

  // New state variables for enhanced features
  String _availabilityStatus = 'Available';
  List<String> _myVerifiedSkills = ['Flutter', 'Dart'];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = [
    'All',
    'Programming',
    'Design',
    'Marketing',
    'Business',
    'Languages',
    'Music',
    'Sports',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _loadSkillExchanges();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _skillOfferedController.dispose();
    _skillWantedController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Search functionality
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSkills = _skillExchanges;
        _isSearchActive = false;
      });
      return;
    }

    setState(() {
      _isSearchActive = true;
      _filteredSkills = _skillExchanges.where((exchange) {
        return exchange.skillOffered.toLowerCase().contains(query.toLowerCase()) ||
               exchange.skillWanted.toLowerCase().contains(query.toLowerCase()) ||
               exchange.userName.toLowerCase().contains(query.toLowerCase()) ||
               exchange.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Sort exchanges
  void _sortSkillExchanges() {
    setState(() {
      switch (_sortBy) {
        case 'rating':
          _skillExchanges.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'barter_count':
          _skillExchanges.sort((a, b) => b.barterCount.compareTo(a.barterCount));
          break;
        case 'recent':
          // For now, sort by barter count as recent indicator
          _skillExchanges.sort((a, b) => b.barterCount.compareTo(a.barterCount));
          break;
      }
      _filteredSkills = _getFilteredSkills();
      if (_isSearchActive) {
        _performSearch(_searchController.text);
      }
    });
  }

  Future<void> _loadSkillExchanges() async {
    // Load skill exchanges from shared preferences or backend
    // For now, load some mock data
    setState(() {
      _skillExchanges = [
        SkillExchange(
          id: '1',
          userName: 'Sarah Johnson',
          userRole: 'Senior Developer',
          skillOffered: 'Flutter Development',
          categoryOffered: 'Programming',
          skillWanted: 'UI/UX Design',
          categoryWanted: 'Design',
          description: 'I can help you build beautiful Flutter apps. Looking to learn design principles.',
          rating: 4.8,
          barterCount: 12,
        ),
        SkillExchange(
          id: '2',
          userName: 'Mike Chen',
          userRole: 'Marketing Manager',
          skillOffered: 'Digital Marketing',
          categoryOffered: 'Marketing',
          skillWanted: 'Python Programming',
          categoryWanted: 'Programming',
          description: 'Experienced in SEO, social media, and content marketing. Want to learn Python for data analysis.',
          rating: 4.6,
          barterCount: 8,
        ),
        SkillExchange(
          id: '3',
          userName: 'Alex Rodriguez',
          userRole: 'Student',
          skillOffered: 'Spanish Language',
          categoryOffered: 'Languages',
          skillWanted: 'JavaScript',
          categoryWanted: 'Programming',
          description: 'Native Spanish speaker, can help with language learning. Looking for JS tutorials.',
          rating: 4.9,
          barterCount: 15,
        ),
        SkillExchange(
          id: '4',
          userName: 'Lisa Thompson',
          userRole: 'Designer',
          skillOffered: 'Graphic Design',
          categoryOffered: 'Design',
          skillWanted: 'Public Speaking',
          categoryWanted: 'Business',
          description: 'Adobe Creative Suite expert. Need help overcoming fear of public speaking.',
          rating: 4.7,
          barterCount: 6,
        ),
        SkillExchange(
          id: '5',
          userName: 'David Kim',
          userRole: 'Entrepreneur',
          skillOffered: 'Business Strategy',
          categoryOffered: 'Business',
          skillWanted: 'Guitar Lessons',
          categoryWanted: 'Music',
          description: 'Helped 3 startups scale. Looking for guitar lessons as a hobby.',
          rating: 4.5,
          barterCount: 3,
        ),
      ];

      _mySkills = [
        SkillExchange(
          id: 'my1',
          userName: 'You',
          userRole: 'Student/Developer',
          skillOffered: 'Dart/Flutter',
          categoryOffered: 'Programming',
          skillWanted: 'Mentoring',
          categoryWanted: 'Business',
          description: 'I can teach Dart and Flutter development. Looking for business mentorship.',
          rating: 0.0,
          barterCount: 0,
        ),
      ];
    });
  }

  List<SkillExchange> _getFilteredSkills() {
    if (_selectedCategory == 'All') {
      return _skillExchanges;
    }
    return _skillExchanges.where((exchange) =>
        exchange.categoryOffered == _selectedCategory ||
        exchange.categoryWanted == _selectedCategory).toList();
  }

  void _showAddSkillDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String offeredCategory = 'Programming';
        String wantedCategory = 'Programming';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 12),
                  Text(
                    'Create Skill Exchange',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Skill Offered
                    TextField(
                      controller: _skillOfferedController,
                      decoration: const InputDecoration(
                        labelText: 'Skill You Offer',
                        hintText: 'e.g., Python Programming',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Offered Category
                    DropdownButtonFormField<String>(
                      value: offeredCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.skip(1).map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          offeredCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Skill Wanted
                    TextField(
                      controller: _skillWantedController,
                      decoration: const InputDecoration(
                        labelText: 'Skill You Want',
                        hintText: 'e.g., UI/UX Design',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Wanted Category
                    DropdownButtonFormField<String>(
                      value: wantedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.skip(1).map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          wantedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Tell others about your exchange offer...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_skillOfferedController.text.isNotEmpty &&
                        _skillWantedController.text.isNotEmpty) {
                      // Add the skill exchange
                      final newExchange = SkillExchange(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userName: 'You',
                        userRole: 'Student/Developer',
                        skillOffered: _skillOfferedController.text,
                        categoryOffered: offeredCategory,
                        skillWanted: _skillWantedController.text,
                        categoryWanted: wantedCategory,
                        description: _descriptionController.text,
                        rating: 0.0,
                        barterCount: 0,
                      );

                      setState(() {
                        _mySkills.add(newExchange);
                      });

                      // Clear controllers
                      _skillOfferedController.clear();
                      _skillWantedController.clear();
                      _descriptionController.clear();

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Skill exchange posted successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                  child: const Text('Post Exchange'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedSkills = _isSearchActive ? _filteredSkills : _getFilteredSkills();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Skill Barter',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddSkillDialog,
              tooltip: 'Add Skill Exchange',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SkillSearchDelegate(
                    skillExchanges: _skillExchanges,
                    onSearchResult: (result) {
                      setState(() {
                        _filteredSkills = result;
                        _isSearchActive = true;
                      });
                    },
                  ),
                );
              },
              tooltip: 'Search Skills',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Search for skills, users, or descriptions...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      suffixIcon: _isSearchActive
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey.shade600),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // Tabs
                const TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_horiz, size: 18),
                          SizedBox(width: 4),
                          Text('All'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lightbulb_outline, size: 18),
                          SizedBox(width: 4),
                          Text('My Exchanges'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.recommend, size: 18),
                          SizedBox(width: 4),
                          Text('Recommended'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 18),
                          SizedBox(width: 4),
                          Text('History'),
                        ],
                      ),
                    ),
                  ],
                  indicatorColor: Colors.purple,
                  labelColor: Colors.purple,
                  unselectedLabelColor: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // All Exchanges Tab
            _buildAllExchangesTab(),

            // My Exchanges Tab
            _buildMyExchangesTab(),

            // Recommended Tab
            _buildRecommendedTab(),

            // History Tab
            _buildHistoryTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddSkillDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Exchange'),
          backgroundColor: Colors.purple.shade600,
        ),
      ),
    );
  }

  Widget _buildAllExchangesTab() {
    final displayedSkills = _isSearchActive ? _filteredSkills : _getFilteredSkills();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort and Filter Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Text('Sort by:', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'rating', child: Text('Rating')),
                      DropdownMenuItem(value: 'barter_count', child: Text('Popular')),
                      DropdownMenuItem(value: 'recent', child: Text('Recent')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _sortSkillExchanges();
                      });
                    },
                    underline: Container(),
                  ),
                ],
              ),
            ),

            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade50,
                    Colors.blue.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.purple.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.swap_horiz,
                        size: 32,
                        color: Colors.purple.shade600,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exchange Knowledge',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Students ↔ Alumni: Share skills, gain new knowledge',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.purple.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatChip('${_skillExchanges.length}', 'Active Exchanges', Colors.blue),
                      const SizedBox(width: 12),
                      _buildStatChip('${_skillExchanges.fold(0, (sum, item) => sum + item.barterCount)}', 'Total Trades', Colors.green),
                      const SizedBox(width: 12),
                      _buildStatChip('4.7★', 'Avg Rating', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Filter
            Text(
              'Filter by Category',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey.shade100,
                      selectedColor: Colors.purple.shade100,
                      checkmarkColor: Colors.purple.shade700,
                      labelStyle: GoogleFonts.inter(
                        color: isSelected ? Colors.purple.shade700 : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Available Skill Exchanges
            Text(
              'Available Skill Exchanges',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (displayedSkills.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No skill exchanges found',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ...displayedSkills.map((exchange) => _buildSkillExchangeCard(exchange)),
            ],

            const SizedBox(height: 24),
          ,
        ),
      ),
    );
  }

  Widget _buildMyExchangesTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child: Text('Y', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Profile',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: $_availabilityStatus',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _availabilityStatus = value;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Available', child: Text('Available')),
                      const PopupMenuItem(value: 'Busy', child: Text('Busy')),
                      const PopupMenuItem(value: 'Away', child: Text('Away')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _availabilityStatus == 'Available' ? Icons.circle : _availabilityStatus == 'Busy' ? Icons.circle : Icons.pause_circle,
                            size: 12,
                            color: _availabilityStatus == 'Available' ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(_availabilityStatus),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Verified Skills
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Verified Skills',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _myVerifiedSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(skill, style: GoogleFonts.inter(fontSize: 12, color: Colors.green.shade700)),
                            const SizedBox(width: 4),
                            Icon(Icons.check_circle, size: 12, color: Colors.green.shade700),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // My Skill Exchanges
            Text(
              'My Skill Exchanges',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (_mySkills.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No exchanges yet. Create your first skill exchange!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ..._mySkills.map((exchange) => _buildSkillExchangeCard(exchange, isMySkill: true)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended For You',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your skills and interests',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Mock recommended exchanges
            ..._skillExchanges.take(3).map((exchange) => _buildSkillExchangeCard(exchange, showRecommendedBadge: true)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exchange History',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your completed skill exchanges',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Mock history
            if (_exchangeHistory.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No exchange history yet',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // History cards would go here
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillExchangeCard(SkillExchange exchange, {bool isMySkill = false, bool showRecommendedBadge = false}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.purple.shade100,
                  child: Icon(
                    isMySkill ? Icons.person : Icons.school,
                    color: Colors.purple.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exchange.userName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exchange.userRole,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isMySkill) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 12, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${exchange.rating}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Skills Exchange
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Offering
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          color: Colors.green.shade700,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offering',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              exchange.skillOffered,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                exchange.categoryOffered,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 12),

                  // Seeking
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.blue.shade700,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seeking',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              exchange.skillWanted,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                exchange.categoryWanted,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
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

            const SizedBox(height: 16),

            // Description
            Text(
              exchange.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            if (!isMySkill) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Contact user action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contact request sent to ${exchange.userName}!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Contact'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      // Favorite action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to favorites!'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Edit action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit feature coming soon!'),
                          backgroundColor: Colors.blue,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade700,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Delete action
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Skill Exchange'),
                          content: const Text('Are you sure you want to delete this skill exchange?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _mySkills.removeWhere((skill) => skill.id == exchange.id);
                                });
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Skill exchange deleted!'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SkillExchange {
  final String id;
  final String userName;
  final String userRole;
  final String skillOffered;
  final String categoryOffered;
  final String skillWanted;
  final String categoryWanted;
  final String description;
  final double rating;
  final int barterCount;

  SkillExchange({
    required this.id,
    required this.userName,
    required this.userRole,
    required this.skillOffered,
    required this.categoryOffered,
    required this.skillWanted,
    required this.categoryWanted,
    required this.description,
    required this.rating,
    required this.barterCount,
  });
}

class SkillSearchDelegate extends SearchDelegate<List<SkillExchange>> {
  final List<SkillExchange> skillExchanges;
  final Function(List<SkillExchange>) onSearchResult;

  SkillSearchDelegate({
    required this.skillExchanges,
    required this.onSearchResult,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, skillExchanges);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _performSearch(query);

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final exchange = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Icon(Icons.school, color: Colors.purple.shade600),
          ),
          title: Text(
            '${exchange.skillOffered} ↔ ${exchange.skillWanted}',
          ),
          subtitle: Text(
            exchange.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            onSearchResult(results);
            close(context, results);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = skillExchanges.where((exchange) {
      return exchange.skillOffered.toLowerCase().contains(query.toLowerCase()) ||
             exchange.skillWanted.toLowerCase().contains(query.toLowerCase()) ||
             exchange.userName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final exchange = suggestions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Icon(Icons.school, color: Colors.purple.shade600),
          ),
          title: Text('${exchange.skillOffered} → ${exchange.skillWanted}'),
          subtitle: Text('by ${exchange.userName}'),
          onTap: () {
            query = exchange.skillOffered;
            showResults(context);
          },
        );
      },
    );
  }

  List<SkillExchange> _performSearch(String query) {
    if (query.isEmpty) {
      return skillExchanges;
    }

    return skillExchanges.where((exchange) {
      return exchange.skillOffered.toLowerCase().contains(query.toLowerCase()) ||
             exchange.skillWanted.toLowerCase().contains(query.toLowerCase()) ||
             exchange.userName.toLowerCase().contains(query.toLowerCase()) ||
             exchange.description.toLowerCase().contains(query.toLowerCase()) ||
             exchange.categoryOffered.toLowerCase().contains(query.toLowerCase()) ||
             exchange.categoryWanted.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
