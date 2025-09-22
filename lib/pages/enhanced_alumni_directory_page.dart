import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedAlumniDirectoryPage extends StatefulWidget {
  const EnhancedAlumniDirectoryPage({super.key});

  @override
  State<EnhancedAlumniDirectoryPage> createState() =>
      _EnhancedAlumniDirectoryPageState();
}

class _EnhancedAlumniDirectoryPageState
    extends State<EnhancedAlumniDirectoryPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Map<String, dynamic>> _alumniProfiles = [
    {
      'id': '1',
      'name': 'Sarah Johnson',
      'position': 'Senior Software Engineer',
      'company': 'Google',
      'location': 'Mountain View, CA',
      'graduationYear': '2018',
      'department': 'Computer Science',
      'skills': [
        'Flutter',
        'Dart',
        'Mobile Development',
        'Leadership',
        'Team Management',
      ],
      'experience': '6+ years',
      'connections': 150,
      'isConnected': false,
      'hasPendingRequest': false,
      'isAvailable': true,
      'lastActive': '2 hours ago',
      'bio':
          'Passionate about mentoring and helping students grow in their tech careers. Love building scalable mobile applications.',
      'achievements': [
        'Google Top Contributor',
        'Tech Speaker',
        'Open Source Contributor',
      ],
      'interests': [
        'Mobile Development',
        'AI/ML',
        'Mentoring',
        'Tech Communities',
      ],
      'languages': ['English', 'Spanish'],
      'availability': 'Available for coffee chats and career advice',
      'responseRate': 95,
      'rating': 4.8,
      'profileCompleteness': 95,
    },
    {
      'id': '2',
      'name': 'Michael Chen',
      'position': 'Product Manager',
      'company': 'Microsoft',
      'location': 'Seattle, WA',
      'graduationYear': '2017',
      'department': 'Information Technology',
      'skills': [
        'Product Strategy',
        'Agile',
        'Data Analysis',
        'Team Leadership',
        'User Research',
      ],
      'experience': '7+ years',
      'connections': 200,
      'isConnected': true,
      'hasPendingRequest': false,
      'isAvailable': true,
      'lastActive': '1 day ago',
      'bio':
          'Product leader passionate about building products that matter. Love connecting students with opportunities.',
      'achievements': [
        'Product of the Year',
        'Mentor of the Year',
        'Tech Conference Speaker',
      ],
      'interests': [
        'Product Management',
        'UX Design',
        'Startups',
        'Innovation',
      ],
      'languages': ['English', 'Mandarin'],
      'availability': 'Open to networking and referrals',
      'responseRate': 88,
      'rating': 4.9,
      'profileCompleteness': 98,
    },
    {
      'id': '3',
      'name': 'Emily Rodriguez',
      'position': 'UX Designer',
      'company': 'Adobe',
      'location': 'San Francisco, CA',
      'graduationYear': '2019',
      'department': 'Design',
      'skills': [
        'UI/UX Design',
        'Figma',
        'User Research',
        'Prototyping',
        'Design Systems',
      ],
      'experience': '5+ years',
      'connections': 120,
      'isConnected': false,
      'hasPendingRequest': true,
      'isAvailable': false,
      'lastActive': '3 days ago',
      'bio':
          'Design enthusiast who enjoys mentoring aspiring designers and creating beautiful user experiences.',
      'achievements': [
        'Adobe Design Awards',
        'Design Mentor',
        'Portfolio Featured',
      ],
      'interests': [
        'UX Design',
        'Design Thinking',
        'Accessibility',
        'Creative Coding',
      ],
      'languages': ['English', 'Spanish'],
      'availability': 'Available for design reviews and career guidance',
      'responseRate': 92,
      'rating': 4.7,
      'profileCompleteness': 90,
    },
    {
      'id': '4',
      'name': 'David Kim',
      'position': 'Data Scientist',
      'company': 'Amazon',
      'location': 'Seattle, WA',
      'graduationYear': '2016',
      'department': 'Mathematics',
      'skills': [
        'Python',
        'Machine Learning',
        'SQL',
        'Statistics',
        'Deep Learning',
      ],
      'experience': '8+ years',
      'connections': 180,
      'isConnected': false,
      'hasPendingRequest': false,
      'isAvailable': true,
      'lastActive': '5 hours ago',
      'bio':
          'Data science mentor passionate about AI and machine learning education.',
      'achievements': ['Kaggle Master', 'Published Researcher', 'Tech Speaker'],
      'interests': [
        'Machine Learning',
        'Data Science',
        'AI Ethics',
        'Research',
      ],
      'languages': ['English', 'Korean'],
      'availability': 'Happy to discuss data science career paths',
      'responseRate': 85,
      'rating': 4.6,
      'profileCompleteness': 93,
    },
    {
      'id': '5',
      'name': 'Lisa Thompson',
      'position': 'Engineering Manager',
      'company': 'Netflix',
      'location': 'Los Angeles, CA',
      'graduationYear': '2015',
      'department': 'Computer Science',
      'skills': [
        'Engineering Management',
        'Leadership',
        'System Design',
        'Team Building',
      ],
      'experience': '9+ years',
      'connections': 250,
      'isConnected': false,
      'hasPendingRequest': false,
      'isAvailable': true,
      'lastActive': '1 hour ago',
      'bio':
          'Engineering leader focused on building high-performing teams and scalable systems.',
      'achievements': [
        'Engineering Excellence Award',
        'Diversity Champion',
        'Tech Leader',
      ],
      'interests': [
        'Engineering Leadership',
        'Team Culture',
        'Scalability',
        'Innovation',
      ],
      'languages': ['English'],
      'availability': 'Available for leadership discussions and career advice',
      'responseRate': 78,
      'rating': 4.9,
      'profileCompleteness': 97,
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Connected',
    'Available',
    'Pending',
    'Top Rated',
  ];

  String _selectedDepartment = 'All';
  final List<String> _departments = [
    'All',
    'Computer Science',
    'Information Technology',
    'Design',
    'Mathematics',
    'Business',
  ];

  String _selectedLocation = 'All';
  final List<String> _locations = [
    'All',
    'Mountain View, CA',
    'Seattle, WA',
    'San Francisco, CA',
    'Los Angeles, CA',
  ];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _skillSearchController = TextEditingController();

  bool _showAdvancedFilters = false;

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
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    _skillSearchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlumni {
    List<Map<String, dynamic>> filtered = _alumniProfiles;

    // Apply main filter
    switch (_selectedFilter) {
      case 'Connected':
        filtered = filtered
            .where((alumni) => alumni['isConnected'] == true)
            .toList();
        break;
      case 'Available':
        filtered = filtered
            .where((alumni) => alumni['isAvailable'] == true)
            .toList();
        break;
      case 'Pending':
        filtered = filtered
            .where((alumni) => alumni['hasPendingRequest'] == true)
            .toList();
        break;
      case 'Top Rated':
        filtered = filtered
            .where((alumni) => (alumni['rating'] as double) >= 4.5)
            .toList();
        break;
    }

    // Apply department filter
    if (_selectedDepartment != 'All') {
      filtered = filtered
          .where((alumni) => alumni['department'] == _selectedDepartment)
          .toList();
    }

    // Apply location filter
    if (_selectedLocation != 'All') {
      filtered = filtered
          .where((alumni) => alumni['location'] == _selectedLocation)
          .toList();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered.where((alumni) {
        return alumni['name'].toLowerCase().contains(searchText) ||
            alumni['position'].toLowerCase().contains(searchText) ||
            alumni['company'].toLowerCase().contains(searchText) ||
            alumni['department'].toLowerCase().contains(searchText) ||
            (alumni['skills'] as List<String>).any(
              (skill) => skill.toLowerCase().contains(searchText),
            ) ||
            (alumni['interests'] as List<String>).any(
              (interest) => interest.toLowerCase().contains(searchText),
            );
      }).toList();
    }

    // Apply skill search
    if (_skillSearchController.text.isNotEmpty) {
      final skillText = _skillSearchController.text.toLowerCase();
      filtered = filtered.where((alumni) {
        return (alumni['skills'] as List<String>).any(
          (skill) => skill.toLowerCase().contains(skillText),
        );
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Alumni Directory',
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () =>
                setState(() => _showAdvancedFilters = !_showAdvancedFilters),
            tooltip: 'Advanced Filters',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(),
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          _buildSearchAndFilters(),

          // Advanced Filters (expandable)
          if (_showAdvancedFilters) _buildAdvancedFilters(),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredAlumni.length} alumni found',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _clearAllFilters(),
                  child: Text(
                    'Clear Filters',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alumni List
          Expanded(
            child: _filteredAlumni.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAlumni.length,
                    itemBuilder: (context, index) {
                      return _buildAlumniCard(_filteredAlumni[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          heroTag: "alumni_directory_fab",
          onPressed: () => _exportDirectory(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]!
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Main search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name, position, company, or skills...',
              prefixIcon: const Icon(Icons.search),
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
                  : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Quick filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Theme.of(context).textTheme.bodyMedium?.color,
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
                    selectedColor: Theme.of(context).colorScheme.secondary,
                    checkmarkColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]!
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Filters',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 12),

          // Skill search
          TextField(
            controller: _skillSearchController,
            decoration: InputDecoration(
              hintText: 'Search by specific skills...',
              prefixIcon: const Icon(Icons.code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
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

          // Department and Location filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedDepartment,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                  items: _departments.map((dept) {
                    return DropdownMenuItem(value: dept, child: Text(dept));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDepartment = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                  items: _locations.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniCard(Map<String, dynamic> alumni) {
    final isConnected = alumni['isConnected'] as bool;
    final hasPendingRequest = alumni['hasPendingRequest'] as bool;
    final isAvailable = alumni['isAvailable'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and basic info
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
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
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          alumni['name']
                              .toString()
                              .split(' ')
                              .map((n) => n[0])
                              .join(''),
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    if (isAvailable)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.green,
                                Colors.green.withValues(alpha: 0.8),
                              ],
                            ),
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alumni['name'],
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.15),
                                  Colors.amber.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  alumni['rating'].toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${alumni['position']} at ${alumni['company']}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]!.withValues(alpha: 0.5)
                                  : Colors.grey[200]!.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  alumni['location'],
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]!.withValues(alpha: 0.5)
                                  : Colors.grey[200]!.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Class of ${alumni['graduationYear']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
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
              ],
            ),

            const SizedBox(height: 20),

            // Bio
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]!.withValues(alpha: 0.5)
                    : Colors.grey[100]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                alumni['bio'],
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[200]
                      : Colors.grey[700],
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 16),

            // Skills
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (alumni['skills'] as List<String>).take(4).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.15),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.08),
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
                    skill,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Stats and availability
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '${alumni['connections']}',
                    'Connections',
                    Icons.people_rounded,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '${alumni['responseRate']}%',
                    'Response Rate',
                    Icons.message_rounded,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    alumni['lastActive'],
                    'Active',
                    Icons.access_time_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                if (!isConnected && !hasPendingRequest)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _sendConnectionRequest(alumni),
                        icon: const Icon(Icons.person_add_rounded, size: 18),
                        label: Text(
                          'Connect',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (hasPendingRequest)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withValues(alpha: 0.15),
                            Colors.orange.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Request Pending',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  )
                else if (isConnected)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: OutlinedButton.icon(
                              onPressed: () => _sendMessage(alumni),
                              icon: const Icon(Icons.message_rounded, size: 16),
                              label: Text(
                                'Message',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.purple.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: OutlinedButton.icon(
                              onPressed: () => _requestReferral(alumni),
                              icon: const Icon(
                                Icons.card_giftcard_rounded,
                                size: 16,
                              ),
                              label: Text(
                                'Referral',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                foregroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]!.withValues(alpha: 0.5)
                        : Colors.grey[200]!.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _viewFullProfile(alumni),
                    icon: Icon(
                      Icons.visibility_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
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

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[500]
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            "No alumni found",
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _clearAllFilters(),
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
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

  void _showSortOptions() {
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
              'Sort Alumni',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Sort options would go here
            Text(
              'Sorting options will be displayed here.',
              style: GoogleFonts.inter(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendConnectionRequest(Map<String, dynamic> alumni) {
    setState(() {
      alumni['hasPendingRequest'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection request sent to ${alumni['name']}!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _sendMessage(Map<String, dynamic> alumni) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${alumni['name']}...'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _requestReferral(Map<String, dynamic> alumni) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral request sent to ${alumni['name']}!'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _viewFullProfile(Map<String, dynamic> alumni) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${alumni['name']}\'s full profile...'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedDepartment = 'All';
      _selectedLocation = 'All';
      _searchController.clear();
      _skillSearchController.clear();
    });
  }

  void _exportDirectory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting alumni directory...')),
    );
  }
}
