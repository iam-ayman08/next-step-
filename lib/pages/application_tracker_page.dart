import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_application_page.dart';
import 'application_detail_page.dart';

class ApplicationTrackerPage extends StatefulWidget {
  const ApplicationTrackerPage({super.key});

  @override
  State<ApplicationTrackerPage> createState() => _ApplicationTrackerPageState();
}

class _ApplicationTrackerPageState extends State<ApplicationTrackerPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _applications = [
    {
      'id': '1',
      'company': 'TechCorp Solutions',
      'position': 'Software Engineer Intern',
      'location': 'New York, NY',
      'status':
          'submitted', // submitted, under_review, interview_scheduled, rejected, accepted, withdrawn
      'applicationDate': '2024-09-10',
      'lastUpdate': '2024-09-16',
      'applicationMethod':
          'online_portal', // online_portal, email, referral, walk_in
      'nextSteps': 'Technical interview scheduled for Sept 20',
      'notes': 'Submitted with AI-optimized resume',
      'salaryRange': '\$25-35/hour',
      'applicationUrl': 'https://techcorp.candidate.com/jhz3fn',
      'recruiterName': 'Sarah Johnson',
      'recruiterContact': 'sarah.johnson@techcorp.com',
      'followUpDate': '2024-09-18',
      'priority': 'high', // high, medium, low
    },
    {
      'id': '2',
      'company': 'DataDriven Inc',
      'position': 'Data Analyst',
      'location': 'San Francisco, CA',
      'status': 'interview_scheduled',
      'applicationDate': '2024-09-08',
      'lastUpdate': '2024-09-15',
      'applicationMethod': 'referral',
      'nextSteps': 'Phone interview scheduled for Sept 18',
      'notes': 'Applied via Michael Chens referral',
      'salaryRange': '\$70,000-90,000/year',
      'applicationUrl': '',
      'recruiterName': 'John Smith',
      'recruiterContact': 'john.smith@datadriven.com',
      'followUpDate': '2024-09-17',
      'priority': 'high',
    },
    {
      'id': '3',
      'company': 'Creative Studios',
      'position': 'UX Designer',
      'location': 'Remote',
      'status': 'under_review',
      'applicationDate': '2024-09-12',
      'lastUpdate': '2024-09-14',
      'applicationMethod': 'online_portal',
      'nextSteps': 'Waiting for portfolio review',
      'notes': 'Included portfolio link and case studies',
      'salaryRange': '\$50-80/hour',
      'applicationUrl': 'https://creativestudios.com/careers/ux-designer',
      'recruiterName': '',
      'recruiterContact': '',
      'followUpDate': '2024-09-21',
      'priority': 'medium',
    },
    {
      'id': '4',
      'company': 'Growth Agency',
      'position': 'Marketing Coordinator',
      'location': 'Chicago, IL',
      'status': 'rejected',
      'applicationDate': '2024-09-05',
      'lastUpdate': '2024-09-13',
      'applicationMethod': 'online_portal',
      'nextSteps': 'Position filled by another candidate',
      'notes': 'Received polite rejection email',
      'salaryRange': '\$45,000-55,000/year',
      'applicationUrl': '',
      'recruiterName': 'Lisa Chen',
      'recruiterContact': 'lisa.chen@growthagency.com',
      'followUpDate': '',
      'priority': 'low',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Active',
    'Interview',
    'Rejected',
    'Accepted',
  ];
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

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
    _loadApplications();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredApplications {
    List<Map<String, dynamic>> filtered = _applications;

    // Apply filter
    if (_selectedFilter == 'Active') {
      filtered = _applications
          .where(
            (app) =>
                app['status'] == 'submitted' || app['status'] == 'under_review',
          )
          .toList();
    } else if (_selectedFilter == 'Interview') {
      filtered = _applications
          .where((app) => app['status'] == 'interview_scheduled')
          .toList();
    } else if (_selectedFilter == 'Rejected') {
      filtered = _applications
          .where((app) => app['status'] == 'rejected')
          .toList();
    } else if (_selectedFilter == 'Accepted') {
      filtered = _applications
          .where((app) => app['status'] == 'accepted')
          .toList();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered.where((app) {
        return app['company'].toLowerCase().contains(searchText) ||
            app['position'].toLowerCase().contains(searchText) ||
            app['location'].toLowerCase().contains(searchText) ||
            app['notes'].toLowerCase().contains(searchText);
      }).toList();
    }

    return filtered;
  }

  void _addNewApplication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddApplicationPage(onApplicationAdded: _addApplication),
      ),
    );
  }

  void _addApplication(Map<String, dynamic> application) {
    setState(() {
      _applications.insert(0, application);
    });
    _saveApplications();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Application added successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _viewApplicationDetails(Map<String, dynamic> application) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationDetailPage(
          application: application,
          onApplicationUpdated: _updateApplication,
        ),
      ),
    );
  }

  void _updateApplication(Map<String, dynamic> updatedApplication) {
    setState(() {
      final index = _applications.indexWhere(
        (app) => app['id'] == updatedApplication['id'],
      );
      if (index != -1) {
        _applications[index] = updatedApplication;
      }
    });
    _saveApplications();
  }

  Future<void> _loadApplications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? applicationsJson = prefs.getString('tracked_applications');

      if (applicationsJson != null) {
        List<dynamic> decodedApplications = json.decode(applicationsJson);
        setState(() {
          _applications.clear();
          _applications.addAll(
            decodedApplications.map((app) => Map<String, dynamic>.from(app)),
          );
        });
      }
    } catch (e) {
      print('Error loading applications: $e');
    }
    _saveApplications(); // Save defaults if loading failed
  }

  Future<void> _saveApplications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String applicationsJson = json.encode(_applications);
      await prefs.setString('tracked_applications', applicationsJson);
    } catch (e) {
      print('Error saving applications: $e');
    }
  }

  void _deleteApplication(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Application'),
          content: const Text(
            'Are you sure you want to delete this application?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _applications.removeWhere((app) => app['id'] == id);
                });
                _saveApplications();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshApplications() async {
    await Future.delayed(const Duration(seconds: 1));
    await _loadApplications();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Applications refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.blue;
      case 'under_review':
        return Colors.orange;
      case 'interview_scheduled':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'accepted':
        return Colors.green;
      case 'withdrawn':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'interview_scheduled':
        return 'Interview Scheduled';
      case 'rejected':
        return 'Rejected';
      case 'accepted':
        return 'Accepted';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'submitted':
        return Icons.send;
      case 'under_review':
        return Icons.hourglass_empty;
      case 'interview_scheduled':
        return Icons.calendar_today;
      case 'rejected':
        return Icons.cancel;
      case 'accepted':
        return Icons.check_circle;
      case 'withdrawn':
        return Icons.undo;
      default:
        return Icons.help_outline;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
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
          'Application Tracker',
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
            icon: Icon(
              Icons.show_chart,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: () => _showStatsDialog(),
            tooltip: 'View Statistics',
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
                    hintText: 'Search applications...',
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
        onRefresh: _refreshApplications,
        color: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        child: _filteredApplications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "No applications found",
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
                      "Try adjusting your search or add a new application",
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
                      onPressed: _addNewApplication,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Application'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredApplications.length,
                itemBuilder: (context, index) {
                  final application = _filteredApplications[index];
                  return AnimatedBuilder(
                    animation: _fabAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - _fabAnimation.value)),
                        child: Opacity(
                          opacity: _fabAnimation.value,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[850]!.withValues(alpha: 0.9)
                                      : Colors.white,
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]!.withValues(alpha: 0.7)
                                      : Colors.grey[50]!.withValues(alpha: 0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStatusColor(
                                    application['status'],
                                  ).withValues(alpha: 0.08),
                                  spreadRadius: 2,
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: _getStatusColor(
                                  application['status'],
                                ).withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => _viewApplicationDetails(application),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with company and priority
                                    Row(
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.25),
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.15),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withValues(alpha: 0.4),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.2),
                                                spreadRadius: 1,
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.business_rounded,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              size: 24,
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
                                                application['position'],
                                                style: GoogleFonts.inter(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color,
                                                  letterSpacing: -0.3,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                application['company'],
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
                                        // Status and priority indicator
                                        Column(
                                          children: [
                                            // Status chip
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getStatusColor(
                                                      application['status'],
                                                    ).withValues(alpha: 0.15),
                                                    _getStatusColor(
                                                      application['status'],
                                                    ).withValues(alpha: 0.08),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: _getStatusColor(
                                                    application['status'],
                                                  ).withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _getStatusIcon(
                                                      application['status'],
                                                    ),
                                                    size: 14,
                                                    color: _getStatusColor(
                                                      application['status'],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _getStatusText(
                                                      application['status'],
                                                    ),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _getStatusColor(
                                                        application['status'],
                                                      ),
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Priority indicator
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    _getPriorityColor(
                                                      application['priority'] ??
                                                          'medium',
                                                    ),
                                                    _getPriorityColor(
                                                      application['priority'] ??
                                                          'medium',
                                                    ).withValues(alpha: 0.8),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _getPriorityColor(
                                                      application['priority'] ??
                                                          'medium',
                                                    ).withValues(alpha: 0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Details row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[700]!
                                                            .withValues(
                                                              alpha: 0.5,
                                                            )
                                                      : Colors.grey[200]!
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on_rounded,
                                                      size: 14,
                                                      color:
                                                          Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.grey[300]
                                                          : Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        application['location'],
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Theme.of(
                                                                    context,
                                                                  ).brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.grey[300]
                                                              : Colors
                                                                    .grey[600],
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[700]!
                                                            .withValues(
                                                              alpha: 0.5,
                                                            )
                                                      : Colors.grey[200]!
                                                            .withValues(
                                                              alpha: 0.8,
                                                            ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .calendar_today_rounded,
                                                      size: 14,
                                                      color:
                                                          Theme.of(
                                                                context,
                                                              ).brightness ==
                                                              Brightness.dark
                                                          ? Colors.grey[300]
                                                          : Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Applied ${_formatDate(application['applicationDate'])}',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Theme.of(
                                                                  context,
                                                                ).brightness ==
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
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.green.withValues(
                                                      alpha: 0.15,
                                                    ),
                                                    Colors.green.withValues(
                                                      alpha: 0.08,
                                                    ),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.green
                                                      .withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                application['salaryRange'] ??
                                                    'Salary not specified',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Updated ${_formatDate(application['lastUpdate'])}',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[500]
                                                    : Colors.grey[400],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // Next steps or notes preview
                                    if (application['nextSteps'] != null &&
                                        application['nextSteps']
                                            .toString()
                                            .isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[700]!
                                                        .withValues(alpha: 0.8)
                                                  : Colors.grey[200]!
                                                        .withValues(alpha: 0.8),
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[600]!
                                                        .withValues(alpha: 0.6)
                                                  : Colors.grey[100]!
                                                        .withValues(alpha: 0.6),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[600]!.withValues(
                                                    alpha: 0.5,
                                                  )
                                                : Colors.grey[300]!.withValues(
                                                    alpha: 0.5,
                                                  ),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.flag_rounded,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Next: ${application['nextSteps']}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.grey[200]
                                                      : Colors.grey[700],
                                                  height: 1.4,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Action buttons
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _viewApplicationDetails(
                                                    application,
                                                  ),
                                              icon: const Icon(
                                                Icons.visibility_rounded,
                                                size: 16,
                                              ),
                                              label: Text(
                                                'View Details',
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[700]!.withValues(
                                                    alpha: 0.5,
                                                  )
                                                : Colors.grey[200]!.withValues(
                                                    alpha: 0.8,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () => _deleteApplication(
                                              application['id'],
                                            ),
                                            icon: Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red[400],
                                              size: 20,
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
          heroTag: "application_tracker_fab",
          onPressed: _addNewApplication,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          tooltip: 'Add New Application',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showStatsDialog() {
    int totalApplications = _applications.length;
    int activeApplications = _applications
        .where(
          (app) =>
              app['status'] == 'submitted' || app['status'] == 'under_review',
        )
        .length;
    int interviews = _applications
        .where((app) => app['status'] == 'interview_scheduled')
        .length;
    int accepted = _applications
        .where((app) => app['status'] == 'accepted')
        .length;
    int rejected = _applications
        .where((app) => app['status'] == 'rejected')
        .length;
    double successRate = totalApplications > 0
        ? (accepted / totalApplications) * 100
        : 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Application Statistics',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatRow(
                  'Total Applications',
                  totalApplications.toString(),
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Active Applications',
                  activeApplications.toString(),
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Interviews Scheduled',
                  interviews.toString(),
                  Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Accepted Offers',
                  accepted.toString(),
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Rejected Applications',
                  rejected.toString(),
                  Colors.red,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    'Success Rate: ${successRate.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'today';
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.month}/${date.day}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
