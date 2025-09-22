import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddApplicationPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplicationAdded;

  const AddApplicationPage({super.key, required this.onApplicationAdded});

  @override
  State<AddApplicationPage> createState() => _AddApplicationPageState();
}

class _AddApplicationPageState extends State<AddApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryMinController = TextEditingController();
  final TextEditingController _salaryMaxController = TextEditingController();
  final TextEditingController _applicationUrlController =
      TextEditingController();
  final TextEditingController _recruiterNameController =
      TextEditingController();
  final TextEditingController _recruiterContactController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedStatus = 'submitted';
  String _selectedMethod = 'online_portal';
  String _selectedPriority = 'medium';
  String _selectedCompensationType = 'year';
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
  final List<String> _compensationTypes = ['year', 'month', 'hour', 'project'];

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _applicationUrlController.dispose();
    _recruiterNameController.dispose();
    _recruiterContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveApplication() {
    if (_formKey.currentState!.validate()) {
      final application = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'company': _companyController.text.trim(),
        'position': _positionController.text.trim(),
        'location': _locationController.text.trim(),
        'status': _selectedStatus,
        'applicationDate': DateTime.now().toIso8601String().split('T')[0],
        'lastUpdate': DateTime.now().toIso8601String().split('T')[0],
        'applicationMethod': _selectedMethod,
        'nextSteps': '',
        'notes': _notesController.text.trim(),
        'salaryRange': _buildSalaryRange(),
        'applicationUrl': _applicationUrlController.text.trim(),
        'recruiterName': _recruiterNameController.text.trim(),
        'recruiterContact': _recruiterContactController.text.trim(),
        'followUpDate': '',
        'priority': _selectedPriority,
      };

      widget.onApplicationAdded(application);
      Navigator.of(context).pop();
    }
  }

  String _buildSalaryRange() {
    String min = _salaryMinController.text.trim();
    String max = _salaryMaxController.text.trim();

    if (min.isEmpty && max.isEmpty) {
      return '';
    } else if (min.isEmpty) {
      return '\$$max/$_selectedCompensationType';
    } else if (max.isEmpty) {
      return '\$$min/$_selectedCompensationType';
    } else {
      return '\$$min-\$$max/$_selectedCompensationType';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Add New Application',
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
            onPressed: _saveApplication,
            child: Text(
              'Save',
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
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.assignment_add,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Track New Application',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep track of your job applications',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Company and Position (Required)
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
                          'Position & Company',
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
                    TextFormField(
                      controller: _positionController,
                      decoration: InputDecoration(
                        hintText: 'Position title (e.g., Software Engineer)',
                        prefixIcon: const Icon(Icons.work),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a position';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        hintText: 'Company name (e.g., TechCorp Solutions)',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
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
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Location and Status
              Row(
                children: [
                  Expanded(
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
                            color: Colors.blue.withValues(alpha: 0.08),
                            spreadRadius: 2,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.1),
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
                                      Colors.blue.withValues(alpha: 0.2),
                                      Colors.blue.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Location',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'New York, NY or Remote',
                              prefixIcon: const Icon(Icons.location_on),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                            color: Colors.orange.withValues(alpha: 0.08),
                            spreadRadius: 2,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.1),
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
                                      Colors.orange.withValues(alpha: 0.2),
                                      Colors.orange.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.flag,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Status',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: _statuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  _formatStatus(status),
                                  style: GoogleFonts.inter(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a status';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Application Method and Priority
              Row(
                children: [
                  Expanded(
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
                                  Icons.send,
                                  color: Colors.purple,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Application Method',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedMethod,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: _methods.map((method) {
                              return DropdownMenuItem(
                                value: method,
                                child: Text(
                                  _formatMethod(method),
                                  style: GoogleFonts.inter(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                            color: Colors.red.withValues(alpha: 0.08),
                            spreadRadius: 2,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.1),
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
                                      Colors.red.withValues(alpha: 0.2),
                                      Colors.red.withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Priority',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedPriority,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: _priorities.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(
                                  _formatPriority(priority),
                                  style: GoogleFonts.inter(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Compensation
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
                          'Compensation (Optional)',
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
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _salaryMinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Min',
                              prefixIcon: const Icon(Icons.attach_money),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _salaryMaxController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Max',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCompensationType,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: _compensationTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  '/$type',
                                  style: GoogleFonts.inter(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCompensationType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Application URL
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
                      color: Colors.teal.withValues(alpha: 0.08),
                      spreadRadius: 2,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.1),
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
                                Colors.teal.withValues(alpha: 0.2),
                                Colors.teal.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.link,
                            color: Colors.teal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Application URL (Optional)',
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _applicationUrlController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: 'Link to application portal or job posting',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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
                          'Recruiter Information (Optional)',
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _recruiterNameController,
                            decoration: InputDecoration(
                              hintText: 'Recruiter name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _recruiterContactController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email or phone',
                              prefixIcon: const Icon(Icons.contact_mail),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Notes
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
                          'Additional Notes (Optional)',
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Any additional notes or reminders...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              Container(
                width: double.infinity,
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
                  onPressed: _saveApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Save Application',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
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
}
