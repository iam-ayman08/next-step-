import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudyGroup {
  final String id;
  final String name;
  final String subject;
  final String description;
  final String creatorName;
  final String creatorId;
  final List<String> members;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? meetingTime;
  final String meetingPlatform;
  final bool isPrivate;

  StudyGroup({
    required this.id,
    required this.name,
    required this.subject,
    required this.description,
    required this.creatorName,
    required this.creatorId,
    required this.members,
    required this.tags,
    required this.createdAt,
    this.meetingTime,
    this.meetingPlatform = 'Virtual Meeting',
    this.isPrivate = false,
  });
}

class StudySession {
  final String id;
  final String title;
  final String groupId;
  final DateTime scheduledTime;
  final int duration; // minutes
  final List<String> participants;
  final String agenda;
  final bool isCompleted;

  StudySession({
    required this.id,
    required this.title,
    required this.groupId,
    required this.scheduledTime,
    required this.duration,
    required this.participants,
    required this.agenda,
    this.isCompleted = false,
  });
}

class SharedResource {
  final String id;
  final String title;
  final String description;
  final String fileUrl;
  final String uploadedBy;
  final DateTime uploadedAt;
  final List<String> tags;
  final int downloads;

  SharedResource({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.tags,
    this.downloads = 0,
  });
}

class StudyGroupsPage extends StatefulWidget {
  const StudyGroupsPage({super.key});

  @override
  State<StudyGroupsPage> createState() => _StudyGroupsPageState();
}

class _StudyGroupsPageState extends State<StudyGroupsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<StudyGroup> _studyGroups = [
    StudyGroup(
      id: '1',
      name: 'Data Structures Study Group',
      subject: 'Computer Science',
      description:
          'Weekly sessions covering algorithms and data structures. Perfect for CS majors preparing for interviews.',
      creatorName: 'Alice Johnson',
      creatorId: 'alice123',
      members: ['Alice Johnson', 'Bob Smith', 'Charlie Brown', 'Diana Davis'],
      tags: ['CS', 'Algorithms', 'Interview Prep'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      meetingTime: DateTime.now().add(const Duration(hours: 2)),
    ),
    StudyGroup(
      id: '2',
      name: 'Organic Chemistry Lab Prep',
      subject: 'Chemistry',
      description:
          'Hands-on lab preparation and problem solving for organic chemistry students.',
      creatorName: 'Professor Smith',
      creatorId: 'prof_smith',
      members: ['Emma Wilson', 'Frank Garcia', 'Grace Lee', 'Henry Taylor'],
      tags: ['Chemistry', 'Lab', 'Problem Solving'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isPrivate: true,
    ),
    StudyGroup(
      id: '3',
      name: 'Calculus I Study Circle',
      subject: 'Mathematics',
      description:
          'Beginner-friendly calculus study group with weekly problem sessions.',
      creatorName: 'John Davis',
      creatorId: 'john_d',
      members: ['John Davis', 'Karen Miller', 'Lisa Wong'],
      tags: ['Math', 'Calculus', 'Beginner'],
      createdAt: DateTime.now().subtract(const Duration(hours: 24)),
      meetingTime: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  final List<SharedResource> _sharedResources = [
    SharedResource(
      id: '1',
      title: 'CS Fundamentals Cheat Sheet',
      description: 'Comprehensive cheat sheet covering all core CS concepts',
      fileUrl: 'https://example.com/cs-cheat-sheet.pdf',
      uploadedBy: 'Alice Johnson',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 12)),
      tags: ['CS', 'Study Guide', 'Cheat Sheet'],
      downloads: 45,
    ),
  ];

  List<StudyGroup> _filteredGroups = [];
  String _selectedSubject = 'All Subjects';
  bool _showMyGroups = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _filteredGroups = _studyGroups;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterGroups(String query) {
    setState(() {
      if (query.isEmpty && _selectedSubject == 'All Subjects') {
        _filteredGroups = _showMyGroups
            ? _studyGroups
                  .where((group) => group.members.contains('John Doe'))
                  .toList()
            : _studyGroups;
      } else {
        _filteredGroups = _studyGroups.where((group) {
          final matchesQuery =
              query.isEmpty ||
              group.name.toLowerCase().contains(query.toLowerCase()) ||
              group.subject.toLowerCase().contains(query.toLowerCase()) ||
              group.tags.any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()),
              );

          final matchesSubject =
              _selectedSubject == 'All Subjects' ||
              group.subject == _selectedSubject;

          final matchesMyGroups =
              !_showMyGroups || group.members.contains('John Doe');

          return matchesQuery && matchesSubject && matchesMyGroups;
        }).toList();
      }
    });
  }

  void _joinGroup(String groupId) {
    final group = _studyGroups.firstWhere((g) => g.id == groupId);
    if (!group.members.contains('John Doe')) {
      setState(() {
        group.members.add('John Doe');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Joined study group successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _leaveGroup(String groupId) {
    final group = _studyGroups.firstWhere((g) => g.id == groupId);
    if (group.members.contains('John Doe') && group.creatorName != 'John Doe') {
      setState(() {
        group.members.remove('John Doe');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Left study group'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedSubject = 'Computer Science';
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Create Study Group',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'e.g., Calculus Study Circle',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSubject,
                      items:
                          [
                            'Computer Science',
                            'Mathematics',
                            'Physics',
                            'Chemistry',
                            'Biology',
                            'Engineering',
                            'Business',
                            'Other',
                          ].map((String subject) {
                            return DropdownMenuItem<String>(
                              value: subject,
                              child: Text(subject),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSubject = newValue!;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief description of the study group',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Private Group'),
                      value: isPrivate,
                      onChanged: (bool value) {
                        setState(() {
                          isPrivate = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty &&
                        descriptionController.text.trim().isNotEmpty) {
                      final newGroup = StudyGroup(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        subject: selectedSubject,
                        description: descriptionController.text.trim(),
                        creatorName: 'John Doe',
                        creatorId: 'john_doe',
                        members: ['John Doe'],
                        tags: [selectedSubject],
                        createdAt: DateTime.now(),
                        isPrivate: isPrivate,
                      );

                      setState(() {
                        _studyGroups.insert(0, newGroup);
                        _filterGroups('');
                      });

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Study group created successfully!',
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create'),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Study Groups',
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
              Icons.add,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _showCreateGroupDialog,
            tooltip: 'Create Study Group',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[400]
              : Colors.grey[600],
          tabs: const [
            Tab(
              child: Text(
                'All Groups',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Tab(
              child: Text(
                'My Groups',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Tab(
              child: Text(
                'Resources',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Tab(
              child: Text(
                'Sessions',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search groups, subjects, or tags...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterGroups('');
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
                  ),
                  onChanged: _filterGroups,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text(_selectedSubject),
                        selected: _selectedSubject != 'All Subjects',
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedSubject = selected
                                ? 'Computer Science'
                                : 'All Subjects';
                            _filterGroups(_searchController.text);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('My Groups'),
                        selected: _showMyGroups,
                        onSelected: (bool selected) {
                          setState(() {
                            _showMyGroups = selected;
                            _filterGroups(_searchController.text);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllGroupsTab(),
                _buildMyGroupsTab(),
                _buildResourcesTab(),
                _buildSessionsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        tooltip: 'Create Study Group',
        child: const Icon(Icons.group_add),
      ),
    );
  }

  Widget _buildAllGroupsTab() {
    if (_filteredGroups.isEmpty) {
      return _buildEmptyState(
        'No study groups found',
        'Try adjusting your search or create a new group.',
        Icons.group,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredGroups.length,
      itemBuilder: (context, index) {
        final group = _filteredGroups[index];
        final isMember = group.members.contains('John Doe');

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
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                          width: 2.5,
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
                          group.subject.substring(0, 2).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: -0.5,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
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
                              ),
                              if (group.isPrivate)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.amber.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Private',
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber[600],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
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
                              '${group.members.length} members • ${group.subject}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  group.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[200]
                        : Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: group.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (group.meetingTime != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]!.withValues(alpha: 0.5)
                          : Colors.grey[100]!.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Next meeting: ${_formatTime(group.meetingTime!)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isMember
                              ? const LinearGradient(
                                  colors: [Colors.red, Colors.redAccent],
                                )
                              : LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.secondary,
                                    Theme.of(context).colorScheme.secondary
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => isMember
                              ? _leaveGroup(group.id)
                              : _joinGroup(group.id),
                          icon: Icon(
                            isMember ? Icons.exit_to_app : Icons.group_add,
                            size: 18,
                          ),
                          label: Text(isMember ? 'Leave Group' : 'Join Group'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
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
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => _showGroupDetails(group),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600],
                        ),
                        tooltip: 'Group Details',
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
      },
    );
  }

  Widget _buildMyGroupsTab() {
    final myGroups = _studyGroups
        .where((group) => group.members.contains('John Doe'))
        .toList();

    if (myGroups.isEmpty) {
      return _buildEmptyState(
        'You haven\'t joined any groups yet',
        'Browse and join study groups that interest you.',
        Icons.group_work,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myGroups.length,
      itemBuilder: (context, index) => _buildGroupCard(myGroups[index]),
    );
  }

  Widget _buildGroupCard(StudyGroup group) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    group.subject.substring(0, 2).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Text(
                        '${group.members.length} members',
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
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _joinMeeting(group.id, 'Study Session'),
                    icon: const Icon(Icons.video_call, size: 16),
                    label: const Text('Start Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showGroupDetails(group),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesTab() {
    if (_sharedResources.isEmpty) {
      return _buildEmptyState(
        'No shared resources yet',
        'Group members can share study materials here.',
        Icons.library_books,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sharedResources.length,
      itemBuilder: (context, index) {
        final resource = _sharedResources[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.file_present, color: Colors.blue),
            ),
            title: Text(
              resource.title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'By ${resource.uploadedBy} • ${resource.downloads} downloads',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                // Handle download
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download started')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    return _buildEmptyState(
      'No study sessions scheduled',
      'Create or join study groups to schedule sessions.',
      Icons.schedule,
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[500]
                    : Colors.grey[400],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _joinMeeting(String groupId, String sessionType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining $sessionType...'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showGroupDetails(StudyGroup group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            group.name,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject: ${group.subject}', style: GoogleFonts.inter()),
                const SizedBox(height: 8),
                Text(
                  'Created by: ${group.creatorName}',
                  style: GoogleFonts.inter(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Members: ${group.members.length}',
                  style: GoogleFonts.inter(),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${_formatDate(group.createdAt)}',
                  style: GoogleFonts.inter(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Description:',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(group.description, style: GoogleFonts.inter(height: 1.5)),
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

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
