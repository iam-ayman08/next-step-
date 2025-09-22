import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectionSuggestionsPage extends StatefulWidget {
  const ConnectionSuggestionsPage({super.key});

  @override
  State<ConnectionSuggestionsPage> createState() =>
      _ConnectionSuggestionsPageState();
}

class _ConnectionSuggestionsPageState extends State<ConnectionSuggestionsPage>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Map<String, dynamic>> _connectionSuggestions = [
    {
      'id': '1',
      'name': 'Alex Chen',
      'position': 'Senior Product Manager',
      'company': 'Microsoft',
      'location': 'Seattle, WA',
      'mutualConnections': 3,
      'commonInterests': ['Product Strategy', 'AI/ML', 'Tech Innovation'],
      'reason': 'Based on your interest in AI/ML and shared connections',
      'compatibilityScore': 95,
      'availability': 'Available for coffee chats',
      'recentActivity': 'Posted about AI product development',
      'profileCompleteness': 98,
      'responseRate': 88,
      'isPremium': true,
      'tags': ['High Match', 'Mutual Interests', 'Available'],
      'suggestedMessage':
          'Hi Alex, I saw your post about AI product development and found it really insightful. I\'m also working on similar projects and would love to connect!',
    },
    {
      'id': '2',
      'name': 'Sarah Rodriguez',
      'position': 'UX Research Lead',
      'company': 'Google',
      'location': 'Mountain View, CA',
      'mutualConnections': 5,
      'commonInterests': ['UX Design', 'User Research', 'Design Systems'],
      'reason':
          'Strong alignment with your design background and research interests',
      'compatibilityScore': 92,
      'availability': 'Open to mentoring',
      'recentActivity': 'Published article on UX research methods',
      'profileCompleteness': 95,
      'responseRate': 94,
      'isPremium': false,
      'tags': ['Design Expert', 'Mentor Available', 'Research Focus'],
      'suggestedMessage':
          'Hello Sarah, I really enjoyed your article on UX research methods. As someone transitioning into UX, I\'d love to learn more about your experience!',
    },
    {
      'id': '3',
      'name': 'Marcus Johnson',
      'position': 'Engineering Director',
      'company': 'Amazon',
      'location': 'Seattle, WA',
      'mutualConnections': 2,
      'commonInterests': [
        'System Architecture',
        'Team Leadership',
        'Scalability',
      ],
      'reason': 'Matches your career goals and technical expertise',
      'compatibilityScore': 89,
      'availability': 'Limited availability',
      'recentActivity': 'Spoke at Tech Leadership Summit',
      'profileCompleteness': 97,
      'responseRate': 76,
      'isPremium': true,
      'tags': ['Leadership', 'Technical Expert', 'Speaker'],
      'suggestedMessage':
          'Hi Marcus, I was impressed by your talk at the Tech Leadership Summit. I\'m interested in engineering leadership and would appreciate any advice you might have.',
    },
    {
      'id': '4',
      'name': 'Emily Watson',
      'position': 'Startup Founder',
      'company': 'TechFlow',
      'location': 'San Francisco, CA',
      'mutualConnections': 1,
      'commonInterests': [
        'Entrepreneurship',
        'Product Development',
        'Innovation',
      ],
      'reason':
          'Aligned with your entrepreneurial interests and startup experience',
      'compatibilityScore': 87,
      'availability': 'Very busy but responsive',
      'recentActivity': 'Raised Series A funding',
      'profileCompleteness': 93,
      'responseRate': 82,
      'isPremium': false,
      'tags': ['Entrepreneur', 'Funding Expert', 'Product Focused'],
      'suggestedMessage':
          'Hello Emily, congratulations on your Series A! I\'m working on a startup idea and would love to hear about your journey and any advice for early-stage founders.',
    },
    {
      'id': '5',
      'name': 'David Park',
      'position': 'Data Science Manager',
      'company': 'Netflix',
      'location': 'Los Angeles, CA',
      'mutualConnections': 4,
      'commonInterests': ['Machine Learning', 'Data Analytics', 'Python'],
      'reason': 'Perfect match for your data science interests and skill set',
      'compatibilityScore': 94,
      'availability': 'Available for technical discussions',
      'recentActivity': 'Published ML research paper',
      'profileCompleteness': 96,
      'responseRate': 91,
      'isPremium': true,
      'tags': ['ML Expert', 'Researcher', 'Python Specialist'],
      'suggestedMessage':
          'Hi David, I read your recent ML research paper and found your approach fascinating. I\'m working on similar problems and would love to discuss your methodology.',
    },
  ];

  final List<Map<String, dynamic>> _connectionFilters = [
    {'name': 'High Compatibility', 'count': 12, 'selected': true},
    {'name': 'Mutual Connections', 'count': 8, 'selected': false},
    {'name': 'Same Industry', 'count': 15, 'selected': false},
    {'name': 'Mentors Available', 'count': 6, 'selected': false},
    {'name': 'Recent Activity', 'count': 9, 'selected': false},
    {'name': 'Location Match', 'count': 4, 'selected': false},
  ];

  final List<Map<String, dynamic>> _weeklyGoals = [
    {
      'goal': 'Send 5 connection requests',
      'current': 2,
      'target': 5,
      'color': Colors.blue,
    },
    {
      'goal': 'Schedule 2 informational interviews',
      'current': 1,
      'target': 2,
      'color': Colors.green,
    },
    {
      'goal': 'Follow up with 3 pending connections',
      'current': 0,
      'target': 3,
      'color': Colors.orange,
    },
  ];

  String _selectedSortBy = 'Compatibility';
  final List<String> _sortOptions = [
    'Compatibility',
    'Mutual Connections',
    'Recent Activity',
    'Response Rate',
  ];

  bool _showFilters = false;
  int _currentTabIndex = 0;
  final List<String> _tabs = ['Suggestions', 'Filters', 'Progress'];

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Connection Suggestions',
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
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filters',
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
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentTabIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _currentTabIndex == index
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _tabs[index],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _currentTabIndex == index
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Tab Content
          Expanded(child: _buildTabContent()),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          heroTag: "connection_suggestions_fab",
          onPressed: () => _refreshSuggestions(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTabIndex) {
      case 0:
        return _buildSuggestionsTab();
      case 1:
        return _buildFiltersTab();
      case 2:
        return _buildProgressTab();
      default:
        return _buildSuggestionsTab();
    }
  }

  Widget _buildSuggestionsTab() {
    return Column(
      children: [
        // Sort dropdown
        if (_showFilters)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Sort by:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSortBy,
                      items: _sortOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(
                            option,
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSortBy = value!;
                        });
                      },
                      underline: const SizedBox(),
                      isExpanded: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Suggestions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _connectionSuggestions.length,
            itemBuilder: (context, index) {
              return _buildSuggestionCard(_connectionSuggestions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion) {
    final compatibilityScore = suggestion['compatibilityScore'] as int;
    final isPremium = suggestion['isPremium'] as bool;

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
                          suggestion['name']
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
                    if (isPremium)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber,
                                Colors.amber.withValues(alpha: 0.8),
                              ],
                            ),
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 12,
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
                              suggestion['name'],
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
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCompatibilityColor(
                                    compatibilityScore,
                                  ).withValues(alpha: 0.15),
                                  _getCompatibilityColor(
                                    compatibilityScore,
                                  ).withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getCompatibilityColor(
                                  compatibilityScore,
                                ).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$compatibilityScore%',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _getCompatibilityColor(
                                  compatibilityScore,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${suggestion['position']} at ${suggestion['company']}',
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
                                const SizedBox(width: 6),
                                Text(
                                  suggestion['location'],
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
                                  Icons.people_rounded,
                                  size: 14,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${suggestion['mutualConnections']} mutual',
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

            // Reason for suggestion
            Container(
              padding: const EdgeInsets.all(14),
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
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lightbulb_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion['reason'],
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Common interests
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (suggestion['commonInterests'] as List<String>).map((
                interest,
              ) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]!.withValues(alpha: 0.8)
                            : Colors.grey[200]!.withValues(alpha: 0.8),
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[600]!.withValues(alpha: 0.6)
                            : Colors.grey[100]!.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[600]!.withValues(alpha: 0.5)
                          : Colors.grey[300]!.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[200]
                          : Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (suggestion['tags'] as List<String>).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTagColor(tag).withValues(alpha: 0.15),
                        _getTagColor(tag).withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTagColor(tag).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _getTagColor(tag),
                      letterSpacing: -0.2,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Recent activity
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[700]!.withValues(alpha: 0.5)
                    : Colors.grey[200]!.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion['recentActivity'],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
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
                      onPressed: () => _sendConnectionRequest(suggestion),
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
                ),
                const SizedBox(width: 12),
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
                      onPressed: () => _useSuggestedMessage(suggestion),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
                    onPressed: () => _viewProfile(suggestion),
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

  Widget _buildFiltersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Filter Suggestions',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),

        ..._connectionFilters.map((filter) => _buildFilterItem(filter)),

        const SizedBox(height: 24),

        Text(
          'Advanced Filters',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),

        // Industry filter
        _buildAdvancedFilter('Industry', [
          'Technology',
          'Design',
          'Business',
          'Healthcare',
        ]),
        const SizedBox(height: 12),

        // Company size filter
        _buildAdvancedFilter('Company Size', [
          'Startup',
          'Small',
          'Medium',
          'Large',
          'Enterprise',
        ]),
        const SizedBox(height: 12),

        // Experience level filter
        _buildAdvancedFilter('Experience Level', [
          'Entry',
          'Mid',
          'Senior',
          'Executive',
        ]),
        const SizedBox(height: 12),

        // Location preference
        _buildAdvancedFilter('Location', [
          'Same City',
          'Same State',
          'Remote Friendly',
          'Any',
        ]),
      ],
    );
  }

  Widget _buildFilterItem(Map<String, dynamic> filter) {
    final isSelected = filter['selected'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(
          filter['name'],
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        subtitle: Text(
          '${filter['count']} suggestions',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
        value: isSelected,
        onChanged: (value) {
          setState(() {
            filter['selected'] = value;
          });
        },
        activeColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildAdvancedFilter(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(
                option,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              selected: false, // This would be managed by state
              onSelected: (selected) {
                // Handle filter selection
              },
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              selectedColor: Theme.of(context).colorScheme.secondary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Weekly Progress',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),

        ..._weeklyGoals.map((goal) => _buildProgressItem(goal)),

        const SizedBox(height: 24),

        Text(
          'Connection Stats',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Requests Sent',
                '12',
                Icons.send,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Responses',
                '8',
                Icons.reply,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Meetings',
                '3',
                Icons.calendar_today,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Success Rate',
                '67%',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressItem(Map<String, dynamic> goal) {
    final progress = goal['target'] > 0
        ? (goal['current'] / goal['target'])
        : 0.0;
    final color = goal['color'] as Color;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal['goal'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${goal['current']}/${goal['target']}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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

  Color _getCompatibilityColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'High Match':
        return Colors.green;
      case 'Mutual Interests':
        return Colors.blue;
      case 'Available':
        return Colors.purple;
      case 'Design Expert':
        return Colors.pink;
      case 'Mentor Available':
        return Colors.teal;
      case 'Research Focus':
        return Colors.indigo;
      case 'Leadership':
        return Colors.deepOrange;
      case 'Technical Expert':
        return Colors.cyan;
      case 'Speaker':
        return Colors.amber;
      case 'Entrepreneur':
        return Colors.lime;
      case 'Funding Expert':
        return Colors.deepPurple;
      case 'Product Focused':
        return Colors.lightGreen;
      case 'ML Expert':
        return Colors.red;
      case 'Researcher':
        return Colors.brown;
      case 'Python Specialist':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
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
              'Sort Options',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 16),
            // Sort options would be implemented here
            Text(
              'Sort options will be displayed here.',
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

  void _sendConnectionRequest(Map<String, dynamic> suggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection request sent to ${suggestion['name']}!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _useSuggestedMessage(Map<String, dynamic> suggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suggested message copied for ${suggestion['name']}!'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _viewProfile(Map<String, dynamic> suggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${suggestion['name']}\'s profile...'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _refreshSuggestions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing connection suggestions...')),
    );
  }
}
