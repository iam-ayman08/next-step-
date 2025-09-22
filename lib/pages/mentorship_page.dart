import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Find Mentor Page
class FindMentorPage extends StatefulWidget {
  const FindMentorPage({super.key});

  @override
  State<FindMentorPage> createState() => _FindMentorPageState();
}

class _FindMentorPageState extends State<FindMentorPage> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Search and filter state
  String _searchQuery = '';
  String _selectedIndustry = 'All';
  String _selectedExperience = 'All';
  String _selectedLocation = 'All';
  bool _showFilters = false;

  // Enhanced features
  final Set<String> _favoriteMentors = {};
  final List<String> _searchHistory = [];
  bool _showSearchHistory = false;

  final List<String> _industries = [
    'All',
    'Technology',
    'Finance',
    'Healthcare',
    'Education',
    'Marketing',
    'Design',
    'Engineering',
  ];

  final List<String> _experienceLevels = [
    'All',
    'Entry Level (0-2 years)',
    'Mid Level (3-5 years)',
    'Senior Level (6-10 years)',
    'Executive (10+ years)',
  ];

  final List<String> _locations = [
    'All',
    'New York',
    'San Francisco',
    'Los Angeles',
    'Chicago',
    'Remote',
    'International',
  ];

  final List<Map<String, dynamic>> _allMentors = [
    {
      'name': 'Sarah Johnson',
      'role': 'Senior Software Engineer',
      'company': 'Google',
      'expertise': 'Mobile Development, Flutter, React Native',
      'industry': 'Technology',
      'experience': 'Senior Level (6-10 years)',
      'location': 'San Francisco',
      'connections': 150,
      'rating': 4.9,
      'availability': 'Available',
      'bio': 'Passionate about mobile development and mentoring the next generation of developers.',
      'skills': ['Flutter', 'Dart', 'React Native', 'iOS', 'Android', 'Firebase'],
      'languages': ['English', 'Spanish'],
      'hourlyRate': '\$150-200',
      'responseTime': 'Within 2 hours',
      'totalSessions': 45,
      'successRate': '95%',
    },
    {
      'name': 'Michael Chen',
      'role': 'Product Manager',
      'company': 'Microsoft',
      'expertise': 'Product Strategy, UX Design, Agile',
      'industry': 'Technology',
      'experience': 'Senior Level (6-10 years)',
      'location': 'Remote',
      'connections': 200,
      'rating': 4.8,
      'availability': 'Available',
      'bio': 'Helping startups and teams build amazing products that users love.',
      'skills': ['Product Strategy', 'UX Design', 'Agile', 'Analytics', 'Leadership'],
      'languages': ['English', 'Mandarin'],
      'hourlyRate': '\$120-180',
      'responseTime': 'Within 4 hours',
      'totalSessions': 67,
      'successRate': '92%',
    },
    {
      'name': 'Emily Rodriguez',
      'role': 'Data Scientist',
      'company': 'Amazon',
      'expertise': 'Machine Learning, Python, Data Analysis',
      'industry': 'Technology',
      'experience': 'Mid Level (3-5 years)',
      'location': 'New York',
      'connections': 180,
      'rating': 4.7,
      'availability': 'Limited',
      'bio': 'Data science enthusiast with a passion for teaching and mentoring.',
      'skills': ['Python', 'Machine Learning', 'SQL', 'TensorFlow', 'Pandas', 'Statistics'],
      'languages': ['English', 'Spanish'],
      'hourlyRate': '\$100-150',
      'responseTime': 'Within 6 hours',
      'totalSessions': 34,
      'successRate': '88%',
    },
    {
      'name': 'David Kim',
      'role': 'Marketing Director',
      'company': 'Nike',
      'expertise': 'Digital Marketing, Brand Strategy, SEO',
      'industry': 'Marketing',
      'experience': 'Executive (10+ years)',
      'location': 'Remote',
      'connections': 220,
      'rating': 4.9,
      'availability': 'Available',
      'bio': 'Building brands and marketing strategies that drive real results.',
      'skills': ['Digital Marketing', 'Brand Strategy', 'SEO', 'Content Marketing', 'Analytics'],
      'languages': ['English', 'Korean'],
      'hourlyRate': '\$200-300',
      'responseTime': 'Within 1 hour',
      'totalSessions': 89,
      'successRate': '96%',
    },
    {
      'name': 'Lisa Thompson',
      'role': 'Healthcare Administrator',
      'company': 'Mayo Clinic',
      'expertise': 'Healthcare Management, Policy, Leadership',
      'industry': 'Healthcare',
      'experience': 'Senior Level (6-10 years)',
      'location': 'Remote',
      'connections': 160,
      'rating': 4.6,
      'availability': 'Available',
      'bio': 'Dedicated to improving healthcare systems and mentoring future leaders.',
      'skills': ['Healthcare Management', 'Policy Analysis', 'Leadership', 'Strategy', 'Operations'],
      'languages': ['English'],
      'hourlyRate': '\$180-250',
      'responseTime': 'Within 3 hours',
      'totalSessions': 56,
      'successRate': '91%',
    },
    {
      'name': 'Robert Wilson',
      'role': 'Finance Director',
      'company': 'Goldman Sachs',
      'expertise': 'Investment Banking, Risk Management, Financial Analysis',
      'industry': 'Finance',
      'experience': 'Executive (10+ years)',
      'location': 'New York',
      'connections': 190,
      'rating': 4.8,
      'availability': 'Limited',
      'bio': 'Guiding the next generation of finance professionals through complex markets.',
      'skills': ['Investment Banking', 'Risk Management', 'Financial Analysis', 'Strategy', 'Trading'],
      'languages': ['English', 'French'],
      'hourlyRate': '\$250-350',
      'responseTime': 'Within 2 hours',
      'totalSessions': 78,
      'successRate': '94%',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String mentorName) {
    setState(() {
      if (_favoriteMentors.contains(mentorName)) {
        _favoriteMentors.remove(mentorName);
      } else {
        _favoriteMentors.add(mentorName);
      }
    });
  }

  void _addToSearchHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _clearSearchHistory() {
    setState(() => _searchHistory.clear());
  }

  List<Map<String, dynamic>> _getFilteredMentors() {
    return _allMentors.where((mentor) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          mentor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mentor['expertise'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mentor['company'].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesIndustry =
          _selectedIndustry == 'All' || mentor['industry'] == _selectedIndustry;
      final matchesExperience =
          _selectedExperience == 'All' || mentor['experience'] == _selectedExperience;
      final matchesLocation =
          _selectedLocation == 'All' || mentor['location'] == _selectedLocation;

      return matchesSearch && matchesIndustry && matchesExperience && matchesLocation;
    }).toList();
  }

  void _showMentorDetails(Map<String, dynamic> mentor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mentor['name'][0].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor['name'],
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Text(
                            '${mentor['role']} at ${mentor['company']}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (mentor['availability'] == 'Available'
                                  ? Colors.green
                                  : mentor['availability'] == 'Limited'
                                  ? Colors.orange
                                  : Colors.red).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: mentor['availability'] == 'Available'
                                    ? Colors.green
                                    : mentor['availability'] == 'Limited'
                                    ? Colors.orange
                                    : Colors.red,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              mentor['availability'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: mentor['availability'] == 'Available'
                                    ? Colors.green
                                    : mentor['availability'] == 'Limited'
                                    ? Colors.orange
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatChip(
                        context,
                        Icons.star,
                        '${mentor['rating']}',
                        'Rating',
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip(
                        context,
                        Icons.access_time,
                        mentor['responseTime'],
                        'Response',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatChip(
                        context,
                        Icons.attach_money,
                        mentor['hourlyRate'],
                        'Rate',
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // About Section
                Text(
                  'About',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mentor['bio'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Skills Section
                Text(
                  'Skills & Expertise',
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
                  children: (mentor['skills'] as List<String>).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        skill,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Languages Section
                Text(
                  'Languages',
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
                  children: (mentor['languages'] as List<String>).map((language) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        language,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Statistics Section
                Text(
                  'Mentoring Statistics',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '${mentor['totalSessions']}',
                        'Total Sessions',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        mentor['successRate'],
                        'Success Rate',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        '${mentor['connections']}',
                        'Connections',
                        Icons.group,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendConnectionRequest(mentor['name']),
                        icon: const Icon(Icons.handshake),
                        label: const Text('Request Session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _toggleFavorite(mentor['name']),
                      icon: Icon(
                        _favoriteMentors.contains(mentor['name'])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _favoriteMentors.contains(mentor['name'])
                            ? Colors.red
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[100],
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendConnectionRequest(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session request sent to $name!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
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
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    final availabilityColor = mentor['availability'] == 'Available'
        ? Colors.green
        : mentor['availability'] == 'Limited'
        ? Colors.orange
        : Colors.red;

    return GestureDetector(
      onTap: () => _showMentorDetails(mentor),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      mentor['name'][0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mentor['name'],
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: availabilityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: availabilityColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              mentor['availability'],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: availabilityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${mentor['role']} at ${mentor['company']}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mentor['location'],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bio
            Text(
              mentor['bio'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Skills preview
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (mentor['skills'] as List<String>)
                  .take(3)
                  .map((skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      skill,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendConnectionRequest(mentor['name']),
                    icon: const Icon(Icons.handshake, size: 16),
                    label: const Text('Request Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _toggleFavorite(mentor['name']),
                  icon: Icon(
                    _favoriteMentors.contains(mentor['name'])
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _favoriteMentors.contains(mentor['name'])
                        ? Colors.red
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[100],
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
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
        title: Text(
          'Find a Mentor',
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _showSearchHistory = value.isEmpty && _searchHistory.isNotEmpty;
                          if (value.isNotEmpty) _addToSearchHistory(value);
                        });
                      },
                      onTap: () => setState(
                        () => _showSearchHistory = _searchQuery.isEmpty && _searchHistory.isNotEmpty,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search mentors by name, expertise, or company...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _searchQuery = ''),
                              ),
                            IconButton(
                              icon: Icon(
                                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                              ),
                              onPressed: () => setState(() => _showFilters = !_showFilters),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[100],
                      ),
                    ),

                    // Search History
                    if (_showSearchHistory && _searchHistory.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Searches',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _clearSearchHistory,
                                  child: Text(
                                    'Clear All',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._searchHistory.map(
                              (query) => ListTile(
                                dense: true,
                                leading: const Icon(Icons.history, size: 20),
                                title: Text(query, style: GoogleFonts.inter(fontSize: 14)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.north_west, size: 16),
                                  onPressed: () => setState(() => _searchQuery = query),
                                ),
                                onTap: () => setState(() => _searchQuery = query),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Filters
                    if (_showFilters)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Filters',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedIndustry,
                            decoration: const InputDecoration(
                              labelText: 'Industry',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _industries.map((industry) => DropdownMenuItem(
                              value: industry,
                              child: Text(industry),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedIndustry = value!),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedExperience,
                            decoration: const InputDecoration(
                              labelText: 'Experience Level',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _experienceLevels.map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedExperience = value!),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedLocation,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _locations.map((location) => DropdownMenuItem(
                              value: location,
                              child: Text(location),
                            )).toList(),
                            onChanged: (value) => setState(() => _selectedLocation = value!),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() {
                                _searchQuery = '';
                                _selectedIndustry = 'All';
                                _selectedExperience = 'All';
                                _selectedLocation = 'All';
                              }),
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Results Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Mentors (${_getFilteredMentors().length})',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    '${_getFilteredMentors().length} found',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Mentor Cards
              ..._getFilteredMentors().map((mentor) => _buildMentorCard(mentor)),

              const SizedBox(height: 32),

              // Stats Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Mentorship Statistics',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('250+', 'Active Mentors'),
                        _buildStatItem('1.2K', 'Total Sessions'),
                        _buildStatItem('95%', 'Success Rate'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
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
    );
  }
}

// Be Mentor Page
class BeMentorPage extends StatefulWidget {
  const BeMentorPage({super.key});

  @override
  State<BeMentorPage> createState() => _BeMentorPageState();
}

class _BeMentorPageState extends State<BeMentorPage> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  String _selectedIndustry = 'Technology';
  String _selectedExperience = 'Mid Level (3-5 years)';
  String _availability = 'Available';
  bool _isLoading = false;

  final List<String> _industries = [
    'Technology',
    'Finance',
    'Healthcare',
    'Education',
    'Marketing',
    'Design',
    'Engineering',
    'Business',
  ];

  final List<String> _experienceLevels = [
    'Entry Level (0-2 years)',
    'Mid Level (3-5 years)',
    'Senior Level (6-10 years)',
    'Executive (10+ years)',
  ];

  final List<String> _availabilityOptions = [
    'Available',
    'Limited',
    'Busy',
  ];

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    _expertiseController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _submitMentorProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        // Save to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_mentor', true);
        await prefs.setString('mentor_name', _nameController.text);
        await prefs.setString('mentor_title', _titleController.text);
        await prefs.setString('mentor_company', _companyController.text);
        await prefs.setString('mentor_bio', _bioController.text);
        await prefs.setString('mentor_expertise', _expertiseController.text);
        await prefs.setString('mentor_industry', _selectedIndustry);
        await prefs.setString('mentor_experience', _selectedExperience);
        await prefs.setString('mentor_availability', _availability);

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Mentor profile created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating mentor profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Become a Mentor',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 64,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Share Your Knowledge',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join our community of mentors and help shape the next generation of professionals',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form Fields
                Text(
                  'Personal Information',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Current Title/Position',
                    prefixIcon: Icon(Icons.work),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your title' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company/Organization',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your company' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedIndustry,
                  decoration: const InputDecoration(
                    labelText: 'Industry',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: _industries.map((industry) => DropdownMenuItem(
                    value: industry,
                    child: Text(industry),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedIndustry = value!),
                  validator: (value) => value == null ? 'Please select an industry' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedExperience,
                  decoration: const InputDecoration(
                    labelText: 'Experience Level',
                    prefixIcon: Icon(Icons.timeline),
                    border: OutlineInputBorder(),
                  ),
                  items: _experienceLevels.map((level) => DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  )).toList(),
                  onChanged: (value) => setState(() => _selectedExperience = value!),
                  validator: (value) => value == null ? 'Please select experience level' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _availability,
                  decoration: const InputDecoration(
                    labelText: 'Availability',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(),
                  ),
                  items: _availabilityOptions.map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  )).toList(),
                  onChanged: (value) => setState(() => _availability = value!),
                  validator: (value) => value == null ? 'Please select availability' : null,
                ),

                const SizedBox(height: 32),

                Text(
                  'Professional Information',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Professional Bio',
                    hintText: 'Tell us about your background and what makes you a great mentor...',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your bio' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _expertiseController,
                  decoration: const InputDecoration(
                    labelText: 'Areas of Expertise',
                    hintText: 'e.g., Mobile Development, Product Strategy, Data Science',
                    prefixIcon: Icon(Icons.lightbulb),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your expertise' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _skillsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Skills to Share',
                    hintText: 'List the skills you can help others develop (comma-separated)',
                    prefixIcon: Icon(Icons.code),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your skills' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _languagesController,
                  decoration: const InputDecoration(
                    labelText: 'Languages',
                    hintText: 'Languages you speak (comma-separated)',
                    prefixIcon: Icon(Icons.language),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter languages' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _hourlyRateController,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Rate (Optional)',
                    hintText: 'e.g., \$100-150',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                // Benefits Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Benefits of Being a Mentor',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem('🎯 Develop leadership skills'),
                      _buildBenefitItem('🌟 Give back to the community'),
                      _buildBenefitItem('💼 Expand your professional network'),
                      _buildBenefitItem('📈 Earn recognition and rewards'),
                      _buildBenefitItem('🤝 Make a lasting impact'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitMentorProfile,
                    icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.school),
                    label: _isLoading
                        ? const Text('Creating Profile...')
                        : const Text('Become a Mentor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: Colors.green[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}

// My Matches Page
class MyMatchesPage extends StatefulWidget {
  const MyMatchesPage({super.key});

  @override
  State<MyMatchesPage> createState() => _MyMatchesPageState();
}

class _MyMatchesPageState extends State<MyMatchesPage> with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  String _selectedTab = 'Active';
  final List<String> _tabs = ['Active', 'Pending', 'Completed', 'Archived'];

  final List<Map<String, dynamic>> _activeMatches = [
    {
      'id': '1',
      'mentorName': 'Sarah Johnson',
      'mentorTitle': 'Senior Software Engineer',
      'mentorCompany': 'Google',
      'status': 'Active',
      'nextSession': 'Tomorrow, 2:00 PM',
      'topic': 'Flutter Development Best Practices',
      'progress': 0.6,
      'totalSessions': 8,
      'completedSessions': 5,
      'rating': 4.9,
      'lastActivity': '2 hours ago',
    },
    {
      'id': '2',
      'mentorName': 'Michael Chen',
      'mentorTitle': 'Product Manager',
      'mentorCompany': 'Microsoft',
      'status': 'Active',
      'nextSession': 'Friday, 10:00 AM',
      'topic': 'Product Strategy & UX Design',
      'progress': 0.3,
      'totalSessions': 6,
      'completedSessions': 2,
      'rating': 4.8,
      'lastActivity': '1 day ago',
    },
  ];

  final List<Map<String, dynamic>> _pendingMatches = [
    {
      'id': '3',
      'mentorName': 'Emily Rodriguez',
      'mentorTitle': 'Data Scientist',
      'mentorCompany': 'Amazon',
      'status': 'Pending',
      'requestDate': '3 days ago',
      'topic': 'Machine Learning Fundamentals',
      'message': 'Hi! I\'d love to learn about ML from your experience at Amazon.',
    },
  ];

  final List<Map<String, dynamic>> _completedMatches = [
    {
      'id': '4',
      'mentorName': 'David Kim',
      'mentorTitle': 'Marketing Director',
      'mentorCompany': 'Nike',
      'status': 'Completed',
      'completionDate': '2 weeks ago',
      'topic': 'Digital Marketing Strategy',
      'finalRating': 5.0,
      'sessionsCompleted': 10,
      'certificate': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getCurrentMatches() {
    switch (_selectedTab) {
      case 'Active':
        return _activeMatches;
      case 'Pending':
        return _pendingMatches;
      case 'Completed':
        return _completedMatches;
      case 'Archived':
        return [];
      default:
        return _activeMatches;
    }
  }

  void _showMatchDetails(Map<String, dynamic> match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          match['mentorName'][0].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match['mentorName'],
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Text(
                            '${match['mentorTitle']} at ${match['mentorCompany']}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(match['status']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(match['status']),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              match['status'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: _getStatusColor(match['status']),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Match Details
                if (match['status'] == 'Active') ...[
                  Text(
                    'Session Progress',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: match['progress'],
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${match['completedSessions']}/${match['totalSessions']} sessions completed',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Next Session',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    match['nextSession'],
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Topic: ${match['topic']}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                    ),
                  ),
                ] else if (match['status'] == 'Pending') ...[
                  Text(
                    'Request Details',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Request Date: ${match['requestDate']}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Topic: ${match['topic']}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Message:',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    match['message'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ] else if (match['status'] == 'Completed') ...[
                  Text(
                    'Completion Summary',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${match['finalRating']}/5.0 Rating',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed: ${match['completionDate']}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${match['sessionsCompleted']} sessions completed',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  if (match['certificate']) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Certificate Earned',
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
                ],

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    if (match['status'] == 'Active') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _scheduleSession(match),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Schedule Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else if (match['status'] == 'Pending') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _cancelRequest(match['id']),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel Request'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else if (match['status'] == 'Completed') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _requestNewMentorship(match),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Request Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleSession(Map<String, dynamic> match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session scheduled with ${match['mentorName']}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelRequest(String id) {
    setState(() {
      _pendingMatches.removeWhere((match) => match['id'] == id);
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Request cancelled'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _requestNewMentorship(Map<String, dynamic> match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New mentorship request sent to ${match['mentorName']}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.blue;
      case 'Archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return GestureDetector(
      onTap: () => _showMatchDetails(match),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.secondary,
                        Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      match['mentorName'][0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match['mentorName'],
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        '${match['mentorTitle']} at ${match['mentorCompany']}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(match['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(match['status']),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    match['status'],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _getStatusColor(match['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Match Details
            if (match['status'] == 'Active') ...[
              Text(
                'Next Session: ${match['nextSession']}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Topic: ${match['topic']}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: match['progress'],
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]
                    : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${match['completedSessions']}/${match['totalSessions']} sessions completed',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ] else if (match['status'] == 'Pending') ...[
              Text(
                'Request sent ${match['requestDate']}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                match['message'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ] else if (match['status'] == 'Completed') ...[
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${match['finalRating']}/5.0',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (match['certificate'])
                    Icon(Icons.verified, color: Colors.green, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Completed ${match['completionDate']}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Action Button
            if (match['status'] == 'Active') ...[
              ElevatedButton.icon(
                onPressed: () => _scheduleSession(match),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text('Schedule Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ] else if (match['status'] == 'Pending') ...[
              OutlinedButton.icon(
                onPressed: () => _cancelRequest(match['id']),
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Cancel Request'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ] else if (match['status'] == 'Completed') ...[
              ElevatedButton.icon(
                onPressed: () => _requestNewMentorship(match),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Request Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMatches = _getCurrentMatches();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Mentorship Matches',
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tab,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Content
            Expanded(
              child: currentMatches.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedTab == 'Active'
                                ? Icons.handshake
                                : _selectedTab == 'Pending'
                                ? Icons.pending
                                : _selectedTab == 'Completed'
                                ? Icons.check_circle
                                : Icons.archive,
                            size: 80,
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No ${_selectedTab.toLowerCase()} matches',
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
                            _selectedTab == 'Active'
                                ? 'Start by finding a mentor to begin your journey'
                                : _selectedTab == 'Pending'
                                ? 'Your pending requests will appear here'
                                : _selectedTab == 'Completed'
                                ? 'Your completed mentorships will be shown here'
                                : 'Archived matches will appear here',
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
                      itemCount: currentMatches.length,
                      itemBuilder: (context, index) {
                        return _buildMatchCard(currentMatches[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MentorshipPage extends StatefulWidget {
  const MentorshipPage({super.key});

  @override
  State<MentorshipPage> createState() => _MentorshipPageState();
}

class _MentorshipPageState extends State<MentorshipPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Filter and search state
  String _searchQuery = '';
  String _selectedIndustry = 'All';
  String _selectedExperience = 'All';
  String _selectedLocation = 'All';
  bool _showFilters = false;

  // Enhanced features state
  final Set<String> _favoriteMentors = {};
  final List<String> _searchHistory = [];
  bool _showSearchHistory = false;

  // Analytics and engagement state
  int _totalLikes = 0;
  int _totalProfileViews = 0;
  List<Map<String, dynamic>> _profileVisitors = [];
  final Map<String, bool> _unlockedFeatures = {
    'Advanced Search': false,
    'Mentor Rating': false,
    'Premium Matches': false,
    'Direct Messaging': false,
    'Video Calls': false,
  };
  List<String> _earnedBadges = [];
  bool _isDrawerOpen = false;

  // Sample data
  final List<String> _industries = [
    'All',
    'Technology',
    'Finance',
    'Healthcare',
    'Education',
    'Marketing',
  ];
  final List<String> _experienceLevels = [
    'All',
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Executive',
  ];
  final List<String> _locations = [
    'All',
    'New York',
    'San Francisco',
    'London',
    'Remote',
  ];

  final List<Map<String, dynamic>> _allMentors = [
    {
      'name': 'Sarah Johnson',
      'role': 'Senior Software Engineer',
      'company': 'Google',
      'expertise': 'Mobile Development, Flutter',
      'industry': 'Technology',
      'experience': 'Senior Level',
      'location': 'San Francisco',
      'connections': 150,
      'rating': 4.9,
      'availability': 'Available',
      'bio':
          'Passionate about mobile development and mentoring the next generation of developers.',
      'skills': ['Flutter', 'Dart', 'React Native', 'iOS', 'Android'],
      'languages': ['English', 'Spanish'],
    },
    {
      'name': 'Michael Chen',
      'role': 'Product Manager',
      'company': 'Microsoft',
      'expertise': 'Product Strategy, UX Design',
      'industry': 'Technology',
      'experience': 'Senior Level',
      'location': 'Remote',
      'connections': 200,
      'rating': 4.8,
      'availability': 'Available',
      'bio':
          'Helping startups and teams build amazing products that users love.',
      'skills': ['Product Strategy', 'UX Design', 'Agile', 'Analytics'],
      'languages': ['English', 'Mandarin'],
    },
    {
      'name': 'Emily Rodriguez',
      'role': 'Data Scientist',
      'company': 'Amazon',
      'expertise': 'Machine Learning, Python',
      'industry': 'Technology',
      'experience': 'Mid Level',
      'location': 'New York',
      'connections': 180,
      'rating': 4.7,
      'availability': 'Limited',
      'bio':
          'Data science enthusiast with a passion for teaching and mentoring.',
      'skills': ['Python', 'Machine Learning', 'SQL', 'TensorFlow', 'Pandas'],
      'languages': ['English', 'Spanish'],
    },
    {
      'name': 'David Kim',
      'role': 'Marketing Director',
      'company': 'Nike',
      'expertise': 'Digital Marketing, Brand Strategy',
      'industry': 'Marketing',
      'experience': 'Executive',
      'location': 'Remote',
      'connections': 220,
      'rating': 4.9,
      'availability': 'Available',
      'bio':
          'Building brands and marketing strategies that drive real results.',
      'skills': [
        'Digital Marketing',
        'Brand Strategy',
        'SEO',
        'Content Marketing',
      ],
      'languages': ['English', 'Korean'],
    },
    {
      'name': 'Lisa Thompson',
      'role': 'Healthcare Administrator',
      'company': 'Mayo Clinic',
      'expertise': 'Healthcare Management, Policy',
      'industry': 'Healthcare',
      'experience': 'Senior Level',
      'location': 'Remote',
      'connections': 160,
      'rating': 4.6,
      'availability': 'Available',
      'bio':
          'Dedicated to improving healthcare systems and mentoring future leaders.',
      'skills': [
        'Healthcare Management',
        'Policy Analysis',
        'Leadership',
        'Strategy',
      ],
      'languages': ['English'],
    },
    {
      'name': 'Robert Wilson',
      'role': 'Finance Director',
      'company': 'Goldman Sachs',
      'expertise': 'Investment Banking, Risk Management',
      'industry': 'Finance',
      'experience': 'Executive',
      'location': 'New York',
      'connections': 190,
      'rating': 4.8,
      'availability': 'Limited',
      'bio':
          'Guiding the next generation of finance professionals through complex markets.',
      'skills': [
        'Investment Banking',
        'Risk Management',
        'Financial Analysis',
        'Strategy',
      ],
      'languages': ['English', 'French'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _fadeAnimationController.forward();
    _initializeAnalyticsData();
  }

  Future<void> _initializeAnalyticsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _totalLikes = prefs.getInt('total_likes') ?? 0;
      _totalProfileViews = prefs.getInt('total_profile_views') ?? 0;
      _earnedBadges = prefs.getStringList('earned_badges') ?? ['Welcome Badge'];

      // Initialize sample visitors
      _profileVisitors = [
        {
          'name': 'Alex Chen',
          'role': 'Software Engineer',
          'company': 'Google',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        },
        {
          'name': 'Maria Garcia',
          'role': 'Product Manager',
          'company': 'Meta',
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        },
        {
          'name': 'David Kim',
          'role': 'Designer',
          'company': 'Apple',
          'timestamp': DateTime.now().subtract(const Duration(hours: 8)),
        },
        {
          'name': 'Sarah Johnson',
          'role': 'Data Scientist',
          'company': 'Amazon',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        },
        {
          'name': 'Mike Wilson',
          'role': 'Marketing Director',
          'company': 'Netflix',
          'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        },
      ];

      // Unlock features based on engagement
      _updateUnlockedFeatures();
    });
  }

  void _updateUnlockedFeatures() {
    setState(() {
      if (_totalLikes >= 5) {
        _unlockedFeatures['Advanced Search'] = true;
      }
      if (_totalProfileViews >= 10) {
        _unlockedFeatures['Mentor Rating'] = true;
      }
      if (_favoriteMentors.length >= 3) {
        _unlockedFeatures['Premium Matches'] = true;
      }
      if (_totalLikes >= 10 && _totalProfileViews >= 15) {
        _unlockedFeatures['Direct Messaging'] = true;
        _unlockedFeatures['Video Calls'] = true;
        if (!_earnedBadges.contains('Super Connector')) {
          _earnedBadges.add('Super Connector');
        }
      }
    });
    _saveAnalyticsData();
  }

  Future<void> _saveAnalyticsData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_likes', _totalLikes);
    await prefs.setInt('total_profile_views', _totalProfileViews);
    await prefs.setStringList('earned_badges', _earnedBadges);
  }

  void _incrementLikes() {
    setState(() {
      _totalLikes++;
    });
    _updateUnlockedFeatures();
  }

  void _incrementProfileViews() {
    setState(() {
      _totalProfileViews++;
      // Add a random new visitor
      final visitors = [
        'John Smith',
        'Emma Davis',
        'Robert Brown',
        'Lisa Wang',
        'Tom Anderson',
      ];
      final companies = ['Microsoft', 'Spotify', 'Uber', 'Stripe', 'Tesla'];
      final roles = [
        'Senior Engineer',
        'Product Designer',
        'Data Analyst',
        'Marketing Manager',
        'CTO',
      ];

      _profileVisitors.insert(0, {
        'name': visitors[_totalProfileViews % visitors.length],
        'role': roles[_totalProfileViews % roles.length],
        'company': companies[_totalProfileViews % companies.length],
        'timestamp': DateTime.now(),
      });

      if (_profileVisitors.length > 10) {
        _profileVisitors.removeLast();
      }
    });
    _updateUnlockedFeatures();
  }

  void _showVisitorsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Profile Visitors',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: _profileVisitors.length,
              itemBuilder: (context, index) {
                final visitor = _profileVisitors[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    child: Text(
                      visitor['name'][0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    visitor['name'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${visitor['role']} at ${visitor['company']}',
                    style: GoogleFonts.inter(fontSize: 12),
                  ),
                  trailing: Text(
                    _formatTimestamp(visitor['timestamp']),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _refreshMentors() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mentors refreshed!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleFavorite(String mentorName) {
    setState(() {
      if (_favoriteMentors.contains(mentorName)) {
        _favoriteMentors.remove(mentorName);
      } else {
        _favoriteMentors.add(mentorName);
      }
    });
  }

  void _addToSearchHistory(String query) {
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory.removeLast();
        }
      });
    }
  }

  void _clearSearchHistory() {
    setState(() => _searchHistory.clear());
  }

  List<Map<String, dynamic>> _getFilteredMentors() {
    return _allMentors.where((mentor) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          mentor['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mentor['expertise'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          mentor['company'].toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesIndustry =
          _selectedIndustry == 'All' || mentor['industry'] == _selectedIndustry;
      final matchesExperience =
          _selectedExperience == 'All' ||
          mentor['experience'] == _selectedExperience;
      final matchesLocation =
          _selectedLocation == 'All' || mentor['location'] == _selectedLocation;

      return matchesSearch &&
          matchesIndustry &&
          matchesExperience &&
          matchesLocation;
    }).toList();
  }

  Widget _buildMentorshipCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
              color: color.withValues(alpha: 0.15),
              spreadRadius: 2,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[600],
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMentorCard(Map<String, dynamic> mentor) {
    final availabilityColor = mentor['availability'] == 'Available'
        ? Colors.green
        : mentor['availability'] == 'Limited'
        ? Colors.orange
        : Colors.red;

    return GestureDetector(
      onTap: () => _showMentorDetails(mentor),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.058,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and basic info
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
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
                  child: Center(
                    child: Text(
                      mentor['name'][0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                              mentor['name'],
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: availabilityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: availabilityColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              mentor['availability'],
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: availabilityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${mentor['role']} at ${mentor['company']}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mentor['location'],
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
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bio preview
            Text(
              mentor['bio'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendConnectionRequest(mentor['name']),
                    icon: const Icon(Icons.handshake, size: 16),
                    label: const Text('Connect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _toggleFavorite(mentor['name']),
                  icon: Icon(
                    _favoriteMentors.contains(mentor['name'])
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _favoriteMentors.contains(mentor['name'])
                        ? Colors.red
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[100],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showMentorDetails(mentor),
                  icon: const Icon(Icons.info_outline),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[100],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendConnectionRequest(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection request sent to $name'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showMentorDetails(Map<String, dynamic> mentor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
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
                      child: Center(
                        child: Text(
                          mentor['name'][0].toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor['name'],
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Text(
                            '${mentor['role']} at ${mentor['company']}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
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
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Details
                Text(
                  'About',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mentor['bio'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Skills',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 100, // Limit skills section height
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (mentor['skills'] as List<String>)
                              .map(
                                (skill) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.1),
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
                                    skill,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _sendConnectionRequest(mentor['name']),
                    icon: const Icon(Icons.handshake),
                    label: const Text('Send Connection Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsDrawer() {
    return Drawer(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
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
                    child: const Center(
                      child: Text(
                        'JD',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          'Student',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Analytics Section
            _buildDrawerSection('Profile Analytics', [
              ListTile(
                leading: Icon(Icons.favorite, color: Colors.red),
                title: Text(
                  '$_totalLikes Likes',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Total likes received',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _incrementLikes,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.visibility,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  '$_totalProfileViews Views',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Profile visits',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: _incrementProfileViews,
                ),
              ),
              ListTile(
                leading: Icon(Icons.people, color: Colors.green),
                title: Text(
                  '${_profileVisitors.length} Visitors',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'People who viewed you',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                onTap: _showVisitorsDialog,
                trailing: const Icon(Icons.chevron_right),
              ),
            ]),

            // Badges Section
            _buildDrawerSection(
              'Earned Badges',
              _earnedBadges
                  .map(
                    (badge) => ListTile(
                      leading: _getBadgeIcon(badge),
                      title: Text(
                        badge,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _getBadgeDescription(badge),
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),

            // Unlocked Features
            _buildDrawerSection(
              'Unlocked Features',
              _unlockedFeatures.entries
                  .map(
                    (entry) => ListTile(
                      leading: Icon(
                        entry.value ? Icons.lock_open : Icons.lock,
                        color: entry.value ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontWeight: entry.value
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        entry.value ? 'Unlocked!' : 'Keep engaging to unlock',
                        style: GoogleFonts.inter(fontSize: 12),
                      ),
                      enabled: entry.value,
                    ),
                  )
                  .toList(),
            ),

            // Locked Features Preview
            _buildDrawerSection(
              'Features to Unlock',
              _unlockedFeatures.entries
                  .where((entry) => !entry.value)
                  .map(
                    (entry) => ListTile(
                      leading: Icon(Icons.lock, color: Colors.grey),
                      title: Text(
                        entry.key,
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                      subtitle: Text(
                        _getUnlockRequirement(entry.key),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
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

  Widget _buildDrawerSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _getBadgeIcon(String badge) {
    switch (badge) {
      case 'Welcome Badge':
        return Icon(Icons.emoji_events, color: Colors.amber);
      case 'Super Connector':
        return Icon(Icons.people, color: Colors.purple);
      default:
        return Icon(Icons.star, color: Colors.blue);
    }
  }

  String _getBadgeDescription(String badge) {
    switch (badge) {
      case 'Welcome Badge':
        return 'Welcome to the mentorship platform!';
      case 'Super Connector':
        return 'Great at building relationships!';
      default:
        return 'Achievement unlocked!';
    }
  }

  String _getUnlockRequirement(String feature) {
    switch (feature) {
      case 'Advanced Search':
        return 'Get 5 likes to unlock';
      case 'Mentor Rating':
        return 'Reach 10 profile views';
      case 'Premium Matches':
        return 'Favorite 3 mentors';
      case 'Direct Messaging':
        return 'Get 10 likes AND 15 views';
      case 'Video Calls':
        return 'Get 10 likes AND 15 views';
      default:
        return 'Keep engaging!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mentorship Matching',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () {
              setState(() => _isDrawerOpen = !_isDrawerOpen);
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: _buildAnalyticsDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshMentors,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.058,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.handshake,
                        size: 64,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Find Your Perfect Mentor',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect with experienced professionals who can guide your career journey',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Main Actions
                Text(
                  'Choose Your Path',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.6,
                  children: [
                    _buildMentorshipCard(
                      'Find a Mentor',
                      'Discover professionals',
                      Icons.search,
                      const Color(0xFF2196F3),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FindMentorPage()),
                      ),
                    ),
                    _buildMentorshipCard(
                      'Be a Mentor',
                      'Share your knowledge',
                      Icons.school,
                      const Color(0xFF4CAF50),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BeMentorPage()),
                      ),
                    ),
                    _buildMentorshipCard(
                      'My Matches',
                      'View connections',
                      Icons.favorite,
                      const Color(0xFFFF5722),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MyMatchesPage()),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Search and Filters
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _showSearchHistory =
                                value.isEmpty && _searchHistory.isNotEmpty;
                            if (value.isNotEmpty) _addToSearchHistory(value);
                          });
                        },
                        onTap: () => setState(
                          () => _showSearchHistory =
                              _searchQuery.isEmpty && _searchHistory.isNotEmpty,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Search mentors by name, expertise, or company...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _searchQuery = ''),
                                ),
                              IconButton(
                                icon: Icon(
                                  _showFilters
                                      ? Icons.filter_list_off
                                      : Icons.filter_list,
                                ),
                                onPressed: () => setState(
                                  () => _showFilters = !_showFilters,
                                ),
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[700]
                              : Colors.grey[100],
                        ),
                      ),

                      // Search History (if showing)
                      if (_showSearchHistory && _searchHistory.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Searches',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _clearSearchHistory,
                                    child: Text(
                                      'Clear All',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ..._searchHistory.map(
                                (query) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.history, size: 20),
                                  title: Text(
                                    query,
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.north_west,
                                      size: 16,
                                    ),
                                    onPressed: () =>
                                        setState(() => _searchQuery = query),
                                  ),
                                  onTap: () =>
                                      setState(() => _searchQuery = query),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Filters
                      if (_showFilters)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Filters',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              initialValue: _selectedIndustry,
                              decoration: const InputDecoration(
                                labelText: 'Industry',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: _industries
                                  .map(
                                    (industry) => DropdownMenuItem(
                                      value: industry,
                                      child: Text(industry),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedIndustry = value!),
                            ),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              initialValue: _selectedExperience,
                              decoration: const InputDecoration(
                                labelText: 'Experience Level',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: _experienceLevels
                                  .map(
                                    (level) => DropdownMenuItem(
                                      value: level,
                                      child: Text(level),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedExperience = value!),
                            ),

                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              initialValue: _selectedLocation,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: _locations
                                  .map(
                                    (location) => DropdownMenuItem(
                                      value: location,
                                      child: Text(location),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedLocation = value!),
                            ),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => setState(() {
                                  _searchQuery = '';
                                  _selectedIndustry = 'All';
                                  _selectedExperience = 'All';
                                  _selectedLocation = 'All';
                                }),
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear Filters'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Available Mentors
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Available Mentors (${_getFilteredMentors().length})',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      '${_getFilteredMentors().length} found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Mentor list
                ..._getFilteredMentors().map(
                  (mentor) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEnhancedMentorCard(mentor),
                  ),
                ),

                const SizedBox(height: 32),

                // Stats section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Mentorship Stats',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('250+', 'Active Mentors'),
                          _buildStatItem('1.2K', 'Mentees'),
                          _buildStatItem('95%', 'Success Rate'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
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
    );
  }
}
