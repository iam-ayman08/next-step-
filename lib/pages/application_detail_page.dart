import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ApplicationDetailPage extends StatefulWidget {
  final Map<String, dynamic> application;
  final Function(Map<String, dynamic>) onApplicationUpdated;

  const ApplicationDetailPage({
    super.key,
    required this.application,
    required this.onApplicationUpdated,
  });

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  late Map<String, dynamic> _application;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _applicationUrlController =
      TextEditingController();
  final TextEditingController _recruiterNameController =
      TextEditingController();
  final TextEditingController _recruiterContactController =
      TextEditingController();
  final TextEditingController _nextStepsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedStatus = '';
  String _selectedMethod = '';
  String _selectedPriority = '';

  final List<String> _statuses = [
    'submitted',
    'under_review',
    'interview_scheduled',
    'accepted',
    'rejected',
    'withdrawn',
  ];
  final List<String> _methods = [
    'online_portal',
    'email',
    'referral',
    'walk_in',
    'recruiter',
    'job_fair',
  ];
  final List<String> _priorities = ['high', 'medium', 'low'];

  @override
  void initState() {
    super.initState();
    _application = Map<String, dynamic>.from(widget.application);
    _initializeControllers();
    _selectedStatus = _application['status'] ?? 'submitted';
    _selectedMethod = _application['applicationMethod'] ?? 'online_portal';
    _selectedPriority = _application['priority'] ?? 'medium';
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _applicationUrlController.dispose();
    _recruiterNameController.dispose();
    _recruiterContactController.dispose();
    _nextStepsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _companyController.text = _application['company'] ?? '';
    _positionController.text = _application['position'] ?? '';
    _locationController.text = _application['location'] ?? '';
    _salaryController.text = _application['salaryRange'] ?? '';
    _applicationUrlController.text = _application['applicationUrl'] ?? '';
    _recruiterNameController.text = _application['recruiterName'] ?? '';
    _recruiterContactController.text = _application['recruiterContact'] ?? '';
    _nextStepsController.text = _application['nextSteps'] ?? '';
    _notesController.text = _application['notes'] ?? '';
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveChanges();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedApplication = {
        ..._application,
        'company': _companyController.text.trim(),
        'position': _positionController.text.trim(),
        'location': _locationController.text.trim(),
        'status': _selectedStatus,
        'applicationMethod': _selectedMethod,
        'priority': _selectedPriority,
        'salaryRange': _salaryController.text.trim(),
        'applicationUrl': _applicationUrlController.text.trim(),
        'recruiterName': _recruiterNameController.text.trim(),
        'recruiterContact': _recruiterContactController.text.trim(),
        'nextSteps': _nextStepsController.text.trim(),
        'notes': _notesController.text.trim(),
        'lastUpdate': DateTime.now().toIso8601String().split('T')[0],
      };

      widget.onApplicationUpdated(updatedApplication);
      setState(() {
        _application = updatedApplication;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cancelEdit() {
    _initializeControllers();
    setState(() {
      _isEditing = false;
      _selectedStatus = _application['status'] ?? 'submitted';
      _selectedMethod = _application['applicationMethod'] ?? 'online_portal';
      _selectedPriority = _application['priority'] ?? 'medium';
    });
  }

  void _scheduleFollowUp() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        setState(() {
          _application['followUpDate'] = selectedDate.toIso8601String().split(
            'T',
          )[0];
        });
        widget.onApplicationUpdated(_application);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Follow-up scheduled for ${_formatDate(_application['followUpDate'])}',
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Application Details',
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
            icon: Icon(
              Icons.calendar_today,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _scheduleFollowUp,
            tooltip: 'Schedule Follow-up',
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? 'Save Changes' : 'Edit Application',
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
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(_selectedStatus),
                            _getStatusColor(
                              _selectedStatus,
                            ).withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getStatusColor(
                              _selectedStatus,
                            ).withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getStatusIcon(_selectedStatus),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _application['position'] ?? 'Position',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'at ${_application['company'] ?? 'Company'}',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Applied ${_formatDate(_application['applicationDate'] ?? '')}',
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

              const SizedBox(height: 32),

              // Status Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(_selectedStatus).withValues(alpha: 0.15),
                      _getStatusColor(_selectedStatus).withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(
                        _selectedStatus,
                      ).withValues(alpha: 0.08),
                      spreadRadius: 2,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _getStatusColor(
                      _selectedStatus,
                    ).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(
                              _selectedStatus,
                            ).withValues(alpha: 0.2),
                            _getStatusColor(
                              _selectedStatus,
                            ).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatusIcon(_selectedStatus),
                        color: _getStatusColor(_selectedStatus),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatStatus(_selectedStatus),
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _getStatusColor(_selectedStatus),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Last updated ${_formatDate(_application['lastUpdate'] ?? _application['applicationDate'])}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Basic Information
              Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.2),
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business_center,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Basic Information',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Position',
                      controller: _positionController,
                      icon: Icons.work,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a position';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Company',
                      controller: _companyController,
                      icon: Icons.business,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a company name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Location',
                      controller: _locationController,
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Application Details
              Container(
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
                      color: Colors.purple.withValues(alpha: 0.08),
                      spreadRadius: 2,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.purple.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.withValues(alpha: 0.2),
                                Colors.purple.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.purple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Application Details',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDropdownField(
                      label: 'Status',
                      value: _selectedStatus,
                      items: _statuses,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                      formatFunction: _formatStatus,
                      icon: Icons.flag,
                      color: _getStatusColor(_selectedStatus),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Application Method',
                      value: _selectedMethod,
                      items: _methods,
                      onChanged: (value) {
                        setState(() {
                          _selectedMethod = value!;
                        });
                      },
                      formatFunction: _formatMethod,
                      icon: Icons.send,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      label: 'Priority',
                      value: _selectedPriority,
                      items: _priorities,
                      onChanged: (value) {
                        setState(() {
                          _selectedPriority = value!;
                        });
                      },
                      formatFunction: _formatPriority,
                      icon: Icons.star,
                      color: _getPriorityColor(_selectedPriority),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Compensation & Links
              Container(
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
                      color: Colors.green.withValues(alpha: 0.08),
                      spreadRadius: 2,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withValues(alpha: 0.2),
                                Colors.green.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.attach_money,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Compensation & Links',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Salary Range',
                      controller: _salaryController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Application URL',
                      controller: _applicationUrlController,
                      icon: Icons.link,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recruiter Information
              Container(
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
                      color: Colors.indigo.withValues(alpha: 0.08),
                      spreadRadius: 2,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.withValues(alpha: 0.2),
                                Colors.indigo.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.indigo,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recruiter Information',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Recruiter Name',
                      controller: _recruiterNameController,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Contact Information',
                      controller: _recruiterContactController,
                      icon: Icons.contact_mail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notes & Next Steps
              Container(
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
                      color: Colors.amber.withValues(alpha: 0.08),
                      spreadRadius: 2,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withValues(alpha: 0.2),
                                Colors.amber.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.note,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Notes & Next Steps',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'Next Steps',
                      controller: _nextStepsController,
                      icon: Icons.flag,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      label: 'Additional Notes',
                      controller: _notesController,
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              // Follow-up Information
              if (_application['followUpDate'] != null &&
                  _application['followUpDate'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.15),
                        Colors.blue.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.08),
                        spreadRadius: 2,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withValues(alpha: 0.2),
                              Colors.blue.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Follow-up scheduled for ${_formatDate(_application['followUpDate'])}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _application['followUpDate'] = '';
                          });
                          widget.onApplicationUpdated(_application);
                        },
                        tooltip: 'Remove follow-up',
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Action Buttons
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.withValues(alpha: 0.15),
                              Colors.grey.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: _cancelEdit,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide.none,
                            foregroundColor: Colors.grey[600],
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          borderRadius: BorderRadius.circular(16),
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
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            'Save Changes',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffixIconButton,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: _isEditing,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.secondary,
          ),
          suffixIcon: suffixIconButton,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]!
                  : Colors.grey[300]!,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
            ),
          ),
          filled: !_isEditing,
          fillColor: !_isEditing
              ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[50])
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.inter(
          color: _isEditing
              ? Theme.of(context).textTheme.bodyMedium?.color
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[300]
              : Colors.grey[700],
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String Function(String) formatFunction,
    required IconData icon,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        onChanged: _isEditing ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: color ?? Theme.of(context).colorScheme.secondary,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]!
                  : Colors.grey[300]!,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[700]!
                  : Colors.grey[200]!,
            ),
          ),
          filled: !_isEditing,
          fillColor: !_isEditing
              ? (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[50])
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(formatFunction(item), style: GoogleFonts.inter()),
          );
        }).toList(),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'under_review':
        return 'Under Review';
      case 'interview_scheduled':
        return 'Interview Scheduled';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return status;
    }
  }

  String _formatMethod(String method) {
    switch (method) {
      case 'online_portal':
        return 'Online Portal';
      case 'email':
        return 'Email';
      case 'referral':
        return 'Referral';
      case 'walk_in':
        return 'Walk-in';
      case 'recruiter':
        return 'Recruiter';
      case 'job_fair':
        return 'Job Fair';
      default:
        return method;
    }
  }

  String _formatPriority(String priority) {
    switch (priority) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return priority;
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
