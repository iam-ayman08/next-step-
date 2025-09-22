import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ResearchCollaborationsPage extends StatefulWidget {
  const ResearchCollaborationsPage({Key? key}) : super(key: key);

  @override
  _ResearchCollaborationsPageState createState() => _ResearchCollaborationsPageState();
}

class _ResearchCollaborationsPageState extends State<ResearchCollaborationsPage> {
  List<Map<String, dynamic>> _collaborations = [
    {
      'id': '1',
      'title': 'AI in Healthcare: Disease Prediction Models',
      'research_area': 'Artificial Intelligence',
      'description': 'Developing machine learning models for early disease detection using medical imaging and patient data.',
      'objectives': 'Create accurate prediction models, validate with real medical data, publish findings in peer-reviewed journals',
      'timeline': '12 months',
      'max_collaborators': 8,
      'current_collaborators': 3,
      'status': 'open',
      'lead_researcher': 'Dr. Sarah Johnson',
      'budget': 50000,
      'requirements': 'Experience in Python, TensorFlow, Medical Data Analysis',
      'created_date': '2024-09-01',
      'deadline': '2025-09-01',
      'tags': ['AI', 'Healthcare', 'Machine Learning', 'Medical Imaging'],
      'documents': [],
      'milestones': [
        {'title': 'Data Collection', 'completed': true, 'date': '2024-10-01'},
        {'title': 'Model Development', 'completed': false, 'date': '2024-12-01'},
        {'title': 'Validation', 'completed': false, 'date': '2025-03-01'},
        {'title': 'Publication', 'completed': false, 'date': '2025-06-01'},
      ],
      'applications': [
        {'user': 'John Doe', 'status': 'pending', 'date': '2024-09-15'},
        {'user': 'Jane Smith', 'status': 'accepted', 'date': '2024-09-10'},
      ],
      'progress': 25,
      'likes': 15,
      'views': 127,
      'messages': 8,
      'collaborators': ['Dr. Sarah Johnson', 'Dr. Mike Chen', 'Alice Cooper'],
    },
    {
      'id': '2',
      'title': 'Sustainable Energy Storage Solutions',
      'research_area': 'Renewable Energy',
      'description': 'Research and development of next-generation battery technologies for renewable energy storage.',
      'objectives': 'Improve battery efficiency by 30%, reduce manufacturing costs, develop sustainable materials',
      'timeline': '18 months',
      'max_collaborators': 10,
      'current_collaborators': 7,
      'status': 'in_progress',
      'lead_researcher': 'Prof. Michael Chen',
      'budget': 75000,
      'requirements': 'Materials Science, Electrochemistry, Data Analysis',
      'created_date': '2024-08-15',
      'deadline': '2026-02-15',
      'tags': ['Energy', 'Sustainability', 'Materials Science', 'Battery Technology'],
      'documents': ['battery_specs.pdf', 'research_proposal.docx'],
      'milestones': [
        {'title': 'Literature Review', 'completed': true, 'date': '2024-09-15'},
        {'title': 'Material Testing', 'completed': true, 'date': '2024-11-15'},
        {'title': 'Prototype Development', 'completed': false, 'date': '2025-02-15'},
        {'title': 'Performance Testing', 'completed': false, 'date': '2025-08-15'},
      ],
      'applications': [],
      'progress': 60,
      'likes': 23,
      'views': 89,
      'messages': 15,
      'collaborators': ['Prof. Michael Chen', 'Dr. Lisa Wang', 'Tom Anderson', 'Sarah Kim', 'David Lee', 'Emma Wilson', 'Robert Chen'],
    },
    {
      'id': '3',
      'title': 'Blockchain Applications in Supply Chain',
      'research_area': 'Blockchain Technology',
      'description': 'Exploring blockchain solutions for transparent and efficient supply chain management.',
      'objectives': 'Develop smart contracts, create traceability systems, implement in real supply chains',
      'timeline': '9 months',
      'max_collaborators': 6,
      'current_collaborators': 6,
      'status': 'completed',
      'lead_researcher': 'Dr. Emily Rodriguez',
      'budget': 30000,
      'requirements': 'Blockchain Development, Smart Contracts, Supply Chain Knowledge',
      'created_date': '2024-06-01',
      'deadline': '2025-03-01',
      'tags': ['Blockchain', 'Supply Chain', 'Smart Contracts', 'Traceability'],
      'documents': ['final_report.pdf', 'smart_contracts.sol', 'demo_video.mp4'],
      'milestones': [
        {'title': 'Requirements Analysis', 'completed': true, 'date': '2024-07-01'},
        {'title': 'Smart Contract Development', 'completed': true, 'date': '2024-09-01'},
        {'title': 'Testing & Validation', 'completed': true, 'date': '2024-12-01'},
        {'title': 'Implementation', 'completed': true, 'date': '2025-02-01'},
      ],
      'applications': [],
      'progress': 100,
      'likes': 31,
      'views': 156,
      'messages': 22,
      'collaborators': ['Dr. Emily Rodriguez', 'Alex Kumar', 'Maria Garcia', 'James Wilson', 'Anna Chen', 'Peter Johnson'],
    },
  ];

  // Application system
  List<Map<String, dynamic>> _applications = [];
  List<Map<String, dynamic>> _myApplications = [];

  // Analytics data
  Map<String, dynamic> _analytics = {
    'total_collaborations': 3,
    'active_collaborations': 2,
    'completed_collaborations': 1,
    'total_applications': 2,
    'accepted_applications': 1,
    'pending_applications': 1,
    'total_views': 372,
    'total_likes': 69,
    'success_rate': 85.5,
  };

  // Advanced filtering
  String _selectedFilter = 'All';
  String _searchQuery = '';
  String _selectedResearchArea = 'All';
  RangeValues _budgetRange = const RangeValues(0, 100000);
  RangeValues _timelineRange = const RangeValues(0, 24);

  final List<String> _filters = ['All', 'Open', 'In Progress', 'Completed'];
  final List<String> _researchAreas = [
    'All', 'Artificial Intelligence', 'Machine Learning', 'Data Science',
    'Computer Science', 'Renewable Energy', 'Biotechnology', 'Healthcare',
    'Environmental Science', 'Materials Science', 'Blockchain Technology',
    'Cybersecurity', 'Robotics', 'Other'
  ];

  List<Map<String, dynamic>> _getFilteredCollaborations() {
    return _collaborations.where((collaboration) {
      final matchesSearch = _searchQuery.isEmpty ||
          collaboration['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          collaboration['research_area'].toLowerCase().contains(_searchQuery.toLowerCase());

      switch (_selectedFilter) {
        case 'Open':
          return matchesSearch && collaboration['status'] == 'open';
        case 'In Progress':
          return matchesSearch && collaboration['status'] == 'in_progress';
        case 'Completed':
          return matchesSearch && collaboration['status'] == 'completed';
        default:
          return matchesSearch;
      }
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return 'Open for Applications';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCollaborations = _getFilteredCollaborations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Collaborations'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCollaborationDialog(context),
            tooltip: 'Create Collaboration',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search collaborations...',
                    prefixIcon: const Icon(Icons.search),
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

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = filter);
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Collaborations List
          Expanded(
            child: filteredCollaborations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No research collaborations found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCollaborations.length,
                    itemBuilder: (context, index) {
                      final collaboration = filteredCollaborations[index];
                      return _buildCollaborationCard(collaboration);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCollaborationDialog(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Collaboration'),
      ),
    );
  }

  Widget _buildCollaborationCard(Map<String, dynamic> collaboration) {
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
                        collaboration['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collaboration['research_area'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(collaboration['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(collaboration['status']),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              collaboration['description'],
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Project Details
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${collaboration['current_collaborators']}/${collaboration['max_collaborators']} collaborators'),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(collaboration['timeline']),
                const SizedBox(width: 16),
                Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('₹${collaboration['budget']}'),
              ],
            ),

            const SizedBox(height: 12),

            // Lead Researcher
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Led by: ${collaboration['lead_researcher']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Objectives
            if (collaboration['objectives'].isNotEmpty)
              Text(
                'Objectives: ${collaboration['objectives']}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _showCollaborationDetails(collaboration);
                  },
                  icon: const Icon(Icons.info),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),

                if (collaboration['status'] == 'open')
                  OutlinedButton.icon(
                    onPressed: () => _showApplicationDialog(context, collaboration),
                    icon: const Icon(Icons.send),
                    label: const Text('Apply'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCollaborationDetails(Map<String, dynamic> collaboration) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        collaboration['title'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(collaboration['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(collaboration['status']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildDetailRow('Research Area', collaboration['research_area']),
                _buildDetailRow('Lead Researcher', collaboration['lead_researcher']),
                _buildDetailRow('Timeline', collaboration['timeline']),
                _buildDetailRow('Budget', '₹${collaboration['budget']}'),
                _buildDetailRow('Collaborators', '${collaboration['current_collaborators']}/${collaboration['max_collaborators']}'),

                const SizedBox(height: 16),

                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(collaboration['description']),

                const SizedBox(height: 16),

                const Text(
                  'Objectives:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(collaboration['objectives']),

                if (collaboration['requirements'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Requirements:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(collaboration['requirements']),
                ],

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    if (collaboration['status'] == 'open')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showApplicationDialog(context, collaboration);
                        },
                        child: const Text('Apply Now'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showCreateCollaborationDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _objectivesController = TextEditingController();
    final _requirementsController = TextEditingController();
    final _budgetController = TextEditingController();
    final _timelineController = TextEditingController();
    final _maxCollaboratorsController = TextEditingController();
    final _leadResearcherController = TextEditingController();

    String _selectedResearchArea = 'Artificial Intelligence';
    String _selectedStatus = 'open';

    final List<String> _researchAreas = [
      'Artificial Intelligence',
      'Machine Learning',
      'Data Science',
      'Computer Science',
      'Renewable Energy',
      'Biotechnology',
      'Healthcare',
      'Environmental Science',
      'Materials Science',
      'Blockchain Technology',
      'Cybersecurity',
      'Robotics',
      'Other'
    ];

    final List<String> _statusOptions = [
      'open',
      'in_progress',
      'completed'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.science, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('Create Research Collaboration'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Research Area
                      DropdownButtonFormField<String>(
                        value: _selectedResearchArea,
                        decoration: InputDecoration(
                          labelText: 'Research Area',
                          prefixIcon: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _researchAreas.map((String area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Text(area),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedResearchArea = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select a research area' : null,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Project Title',
                          prefixIcon: Icon(Icons.title, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter project title' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Project Description',
                          prefixIcon: Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 300,
                        validator: (value) => value!.isEmpty ? 'Please describe your project' : null,
                      ),
                      const SizedBox(height: 16),

                      // Objectives
                      TextFormField(
                        controller: _objectivesController,
                        decoration: InputDecoration(
                          labelText: 'Objectives',
                          prefixIcon: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                        maxLength: 200,
                        validator: (value) => value!.isEmpty ? 'Please enter project objectives' : null,
                      ),
                      const SizedBox(height: 16),

                      // Requirements
                      TextFormField(
                        controller: _requirementsController,
                        decoration: InputDecoration(
                          labelText: 'Requirements (Optional)',
                          prefixIcon: Icon(Icons.assignment, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                        maxLength: 150,
                      ),
                      const SizedBox(height: 16),

                      // Lead Researcher
                      TextFormField(
                        controller: _leadResearcherController,
                        decoration: InputDecoration(
                          labelText: 'Lead Researcher',
                          prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter lead researcher name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Timeline
                      TextFormField(
                        controller: _timelineController,
                        decoration: InputDecoration(
                          labelText: 'Timeline (e.g., 6 months)',
                          prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter project timeline' : null,
                      ),
                      const SizedBox(height: 16),

                      // Budget
                      TextFormField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: 'Budget (₹)',
                          prefixIcon: Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter budget' : null,
                      ),
                      const SizedBox(height: 16),

                      // Max Collaborators
                      TextFormField(
                        controller: _maxCollaboratorsController,
                        decoration: InputDecoration(
                          labelText: 'Maximum Collaborators',
                          prefixIcon: Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter maximum collaborators' : null,
                      ),
                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedStatus = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select status' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create new collaboration
                      final newCollaboration = {
                        'title': _titleController.text,
                        'research_area': _selectedResearchArea,
                        'description': _descriptionController.text,
                        'objectives': _objectivesController.text,
                        'requirements': _requirementsController.text,
                        'lead_researcher': _leadResearcherController.text,
                        'timeline': _timelineController.text,
                        'budget': int.parse(_budgetController.text),
                        'max_collaborators': int.parse(_maxCollaboratorsController.text),
                        'current_collaborators': 0,
                        'status': _selectedStatus,
                      };

                      setState(() {
                        _collaborations.insert(0, newCollaboration);
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Research collaboration created successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.add),
                  label: Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showApplicationDialog(BuildContext context, Map<String, dynamic> collaboration) {
    final _formKey = GlobalKey<FormState>();
    final _coverLetterController = TextEditingController();
    final _experienceController = TextEditingController();
    final _skillsController = TextEditingController();
    final _motivationController = TextEditingController();
    final _availabilityController = TextEditingController();

    String _selectedExperience = '1-2 years';
    String _selectedCommitment = 'Part-time (10-20 hours/week)';

    final List<String> _experienceLevels = [
      'Entry Level (0-1 year)',
      '1-2 years',
      '3-5 years',
      '5-10 years',
      '10+ years',
      'Expert/Research Level'
    ];

    final List<String> _commitmentLevels = [
      'Part-time (5-10 hours/week)',
      'Part-time (10-20 hours/week)',
      'Part-time (20-30 hours/week)',
      'Full-time (30+ hours/week)',
      'Flexible',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Apply to: ${collaboration['title']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Application Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Research Area: ${collaboration['research_area']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Led by: ${collaboration['lead_researcher']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duration: ${collaboration['timeline']} | Budget: ₹${collaboration['budget']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Experience Level
                      DropdownButtonFormField<String>(
                        value: _selectedExperience,
                        decoration: InputDecoration(
                          labelText: 'Experience Level',
                          prefixIcon: Icon(Icons.work, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _experienceLevels.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedExperience = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select experience level' : null,
                      ),
                      const SizedBox(height: 16),

                      // Commitment Level
                      DropdownButtonFormField<String>(
                        value: _selectedCommitment,
                        decoration: InputDecoration(
                          labelText: 'Time Commitment',
                          prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _commitmentLevels.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCommitment = newValue!;
                          });
                        },
                        validator: (value) => value == null ? 'Please select commitment level' : null,
                      ),
                      const SizedBox(height: 16),

                      // Skills
                      TextFormField(
                        controller: _skillsController,
                        decoration: InputDecoration(
                          labelText: 'Relevant Skills',
                          hintText: 'e.g., Python, Machine Learning, Data Analysis',
                          prefixIcon: Icon(Icons.code, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                        maxLength: 200,
                        validator: (value) => value!.isEmpty ? 'Please list your relevant skills' : null,
                      ),
                      const SizedBox(height: 16),

                      // Experience
                      TextFormField(
                        controller: _experienceController,
                        decoration: InputDecoration(
                          labelText: 'Relevant Experience',
                          hintText: 'Describe your relevant experience and background',
                          prefixIcon: Icon(Icons.business_center, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 300,
                        validator: (value) => value!.isEmpty ? 'Please describe your relevant experience' : null,
                      ),
                      const SizedBox(height: 16),

                      // Motivation
                      TextFormField(
                        controller: _motivationController,
                        decoration: InputDecoration(
                          labelText: 'Why are you interested?',
                          hintText: 'Explain your motivation and what you hope to contribute',
                          prefixIcon: Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        maxLength: 250,
                        validator: (value) => value!.isEmpty ? 'Please explain your motivation' : null,
                      ),
                      const SizedBox(height: 16),

                      // Availability
                      TextFormField(
                        controller: _availabilityController,
                        decoration: InputDecoration(
                          labelText: 'Availability',
                          hintText: 'When can you start? Any scheduling constraints?',
                          prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                        maxLength: 150,
                        validator: (value) => value!.isEmpty ? 'Please specify your availability' : null,
                      ),
                      const SizedBox(height: 16),

                      // Cover Letter
                      TextFormField(
                        controller: _coverLetterController,
                        decoration: InputDecoration(
                          labelText: 'Cover Letter',
                          hintText: 'Write a brief cover letter explaining your interest and qualifications',
                          prefixIcon: Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        maxLength: 400,
                        validator: (value) => value!.isEmpty ? 'Please write a cover letter' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Create application
                      final newApplication = {
                        'collaboration_id': collaboration['id'],
                        'collaboration_title': collaboration['title'],
                        'applicant_name': 'Current User', // In real app, get from user profile
                        'experience_level': _selectedExperience,
                        'commitment_level': _selectedCommitment,
                        'skills': _skillsController.text,
                        'experience': _experienceController.text,
                        'motivation': _motivationController.text,
                        'availability': _availabilityController.text,
                        'cover_letter': _coverLetterController.text,
                        'status': 'pending',
                        'applied_date': DateTime.now().toIso8601String(),
                      };

                      setState(() {
                        _myApplications.add(newApplication);
                        _applications.add(newApplication);
                      });

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Application submitted successfully!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.send),
                  label: Text('Submit Application'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
