import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AIResumeBuilderPage extends StatefulWidget {
  const AIResumeBuilderPage({super.key});

  @override
  State<AIResumeBuilderPage> createState() => _AIResumeBuilderPageState();
}

class _AIResumeBuilderPageState extends State<AIResumeBuilderPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _projectsController = TextEditingController();
  final TextEditingController _certificationsController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();

  String _selectedTemplate = 'Modern';
  File? _profileImage;
  bool _isGenerating = false;
  bool _isPreviewMode = false;
  bool _autoSave = true;
  String? _lastSaved;
  Timer? _autoSaveTimer;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // AI Suggestions
  bool _showSuggestions = false;

  // Resume Scoring
  int _resumeScore = 0;
  String _scoreFeedback = '';
  double _completionProgress = 0.0;

  // Advanced Features
  List<String> _resumeAnalysis = [];
  Map<String, dynamic> _jobMatchSuggestions = {};
  bool _showAdvancedAnalysis = false;
  String _targetJobTitle = '';
  String _targetIndustry = '';

  // New Advanced Features
  List<String> _skillSuggestions = [];
  List<String> _atsKeywords = [];
  bool _atsOptimizationEnabled = false;
  double _atsScore = 0.0;
  String _atsRecommendations = '';
  bool _linkedinImport = false;
  List<String> _socialLinks = [];
  Map<String, bool> _exportFormats = {
    'PDF': true,
    'Word': false,
    'JSON': false,
    'Plain Text': false,
  };

  // Achievement quantification
  Map<String, String> _achievementExamples = {
    'Increased sales by 25%': 'Specify the time period, team size, and dollar amount',
    'Led development team': 'Mention team size, project scope, and technologies used',
    'Improved process efficiency': 'Include metrics, time saved, and methodology used',
  };

  // Template customization
  Color _accentColor = Colors.blue;
  String _fontFamily = 'Inter';
  double _fontSize = 12.0;

  final List<Map<String, dynamic>> _enhancedTemplates = [
    {
      'name': 'Modern',
      'icon': Icons.style,
      'color': Colors.blue,
      'description': 'Clean and contemporary design',
      'features': ['Two-column layout', 'Clean typography', 'Color accents'],
    },
    {
      'name': 'Classic',
      'icon': Icons.article,
      'color': Colors.grey,
      'description': 'Traditional professional format',
      'features': ['Single-column', 'Serif fonts', 'Formal structure'],
    },
    {
      'name': 'Creative',
      'icon': Icons.palette,
      'color': Colors.purple,
      'description': 'Bold and artistic presentation',
      'features': ['Unique layouts', 'Bold colors', 'Creative typography'],
    },
    {
      'name': 'Minimal',
      'icon': Icons.cleaning_services,
      'color': Colors.green,
      'description': 'Simple and elegant approach',
      'features': ['Whitespace', 'Simple fonts', 'Clean lines'],
    },
    {
      'name': 'Professional',
      'icon': Icons.business,
      'color': Colors.indigo,
      'description': 'Corporate-ready template',
      'features': ['Executive style', 'Achievement focus', 'Professional appearance'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _loadResumeData();
    _setupAutoSaveListeners();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoSaveTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _projectsController.dispose();
    _certificationsController.dispose();
    _languagesController.dispose();
    _achievementsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _generateResume() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isGenerating = true);

      // Simulate AI processing
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isGenerating = false;
        _isPreviewMode = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resume generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _downloadResume() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume PDF download started!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showLinkedInImportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import from LinkedIn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Connect your LinkedIn profile to automatically import your professional information.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  // Simulate LinkedIn import
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('LinkedIn import feature coming soon! For now, manually enter your information.'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.link),
                label: const Text('Connect LinkedIn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B5), // LinkedIn blue
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _performAtsOptimization() {
    // Simulate ATS analysis and provide sample keywords
    setState(() {
      _atsKeywords = [
        'Software Development',
        'Project Management',
        'Team Leadership',
        'Agile Methodology',
        'Problem Solving',
        'Communication Skills',
        'Data Analysis',
        'Quality Assurance',
      ];
      _atsScore = 0.75; // 75% ATS score
      _atsRecommendations = 'Your resume has good ATS compatibility. Consider adding more industry-specific keywords.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ATS optimization analysis completed!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Advanced resume analysis method
  void _performAdvancedAnalysis() {
    setState(() {
      _resumeAnalysis = [
        'Strong professional summary with key achievements highlighted',
        'Well-structured work experience section with quantified results',
        'Good mix of technical and soft skills',
        'Education section clearly presented',
        'Consider adding more specific industry keywords',
        'Profile image enhances professional appearance',
      ];

      _jobMatchSuggestions = {
        'Software Engineer': 'Your experience aligns well with software engineering roles. Consider highlighting programming languages and frameworks.',
        'Project Manager': 'Your skills show strong project management potential. Add more metrics about team leadership.',
        'Product Manager': 'Good foundation for product roles. Focus on user experience and business analysis.',
        'Data Analyst': 'Technical skills support data analysis roles. Consider adding analytics tools proficiency.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isPreviewMode ? 'Resume Preview' : 'AI Resume Builder',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          if (_isPreviewMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isPreviewMode = false);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isPreviewMode = true);
                }
              },
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isPreviewMode ? _buildResumePreview() : _buildForm(),
      ),
      floatingActionButton: _isPreviewMode
          ? FloatingActionButton.extended(
              onPressed: _downloadResume,
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            )
          : null,
    );
  }

  Widget _buildForm() {
    _calculateResumeScore();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resume Progress and Score
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getScoreColor().withOpacity(0.25),
                                _getScoreColor().withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _resumeScore >= 80
                                ? Icons.star_rounded
                                : _resumeScore >= 60
                                ? Icons.trending_up_rounded
                                : Icons.edit_rounded,
                            color: _getScoreColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resume Progress',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(_completionProgress * 100).round()}% Complete',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getScoreColor().withOpacity(0.15),
                                _getScoreColor().withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_resumeScore/100',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _getScoreColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: _completionProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _scoreFeedback,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.4,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Template Selection
            Text(
              'Choose Template',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _enhancedTemplates.length,
                itemBuilder: (context, index) {
                  final template = _enhancedTemplates[index];
                  final templateName = template['name'] as String;
                  final templateIcon = template['icon'] as IconData;
                  final templateColor = template['color'] as Color;
                  final isSelected = _selectedTemplate == templateName;

                  return Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 16),
                    child: InkWell(
                      onTap: () {
                        setState(() => _selectedTemplate = templateName);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isSelected
                                ? [templateColor.withOpacity(0.15), templateColor.withOpacity(0.08)]
                                : [Colors.white, Colors.grey[50]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? templateColor : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(templateIcon, color: isSelected ? templateColor : Colors.grey, size: 24),
                            const SizedBox(height: 8),
                            Text(
                              templateName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? templateColor : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              template['description'] as String,
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: _profileImage != null
                        ? ClipOval(child: Image.file(_profileImage!, fit: BoxFit.cover))
                        : const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Personal Information
            _buildSectionTitle('Personal Information'),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name *'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email *'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),

            const SizedBox(height: 32),

            // Professional Summary
            _buildSectionTitle('Professional Summary'),
            TextFormField(
              controller: _summaryController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Professional Summary',
                hintText: 'Brief summary of your professional background and goals',
              ),
            ),

            const SizedBox(height: 32),

            // Work Experience
            _buildSectionTitle('Work Experience'),
            TextFormField(
              controller: _experienceController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Work Experience',
                hintText: 'Describe your professional experience, responsibilities, and achievements',
              ),
            ),

            const SizedBox(height: 32),

            // Education
            _buildSectionTitle('Education'),
            TextFormField(
              controller: _educationController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Education',
                hintText: 'Your educational background, degrees, certifications',
              ),
            ),

            const SizedBox(height: 32),

            // Skills
            _buildSectionTitle('Skills'),
            TextFormField(
              controller: _skillsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Skills (comma separated)',
                hintText: 'e.g., JavaScript, React, Project Management',
              ),
            ),

            const SizedBox(height: 32),

            // Advanced Features Section
            const SizedBox(height: 32),
            Text(
              'Advanced Features',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LinkedIn Import
                    Row(
                      children: [
                        const Text(
                          'Import from LinkedIn',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Switch(
                          value: _linkedinImport,
                          onChanged: (value) {
                            setState(() => _linkedinImport = value);
                            if (value) _showLinkedInImportDialog();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ATS Optimization
                    Row(
                      children: [
                        const Text(
                          'ATS Optimization',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Switch(
                          value: _atsOptimizationEnabled,
                          onChanged: (value) {
                            setState(() => _atsOptimizationEnabled = value);
                            if (value) _performAtsOptimization();
                          },
                        ),
                      ],
                    ),

                    if (_atsOptimizationEnabled && _atsKeywords.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.track_changes, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'ATS Score: ${(_atsScore * 100).round()}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Recommended Keywords:', style: TextStyle(color: Colors.blue[700])),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _atsKeywords.map((keyword) => Chip(
                                label: Text(keyword, style: const TextStyle(color: Colors.blue)),
                                backgroundColor: Colors.blue[100],
                                side: const BorderSide(color: Colors.blue, width: 1),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Export Formats
                    const Text(
                      'Export Formats',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: _exportFormats.keys.map((format) => FilterChip(
                        label: Text(format),
                        selected: _exportFormats[format] ?? false,
                        onSelected: (selected) {
                          setState(() {
                            _exportFormats[format] = selected;
                          });
                        },
                      )).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Achievement Tips
                    const Text(
                      'Achievement Examples',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ..._achievementExamples.entries.map((entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF8E1), // Amber 50 equivalent
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFFFE082), width: 1), // Amber 200 equivalent
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C5765),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              color: Color(0xFFE17E25),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Advanced Analysis Toggle
            Row(
              children: [
                const Text(
                  'Advanced Resume Analysis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Switch(
                  value: _showAdvancedAnalysis,
                  onChanged: (value) {
                    setState(() => _showAdvancedAnalysis = value);
                    if (value) _performAdvancedAnalysis();
                  },
                ),
              ],
            ),

            // Advanced Analysis Results
            if (_showAdvancedAnalysis) ...[
              const SizedBox(height: 24),
              TextFormField(
                onChanged: (value) => _targetJobTitle = value,
                decoration: const InputDecoration(labelText: 'Target Job Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                onChanged: (value) => _targetIndustry = value,
                decoration: const InputDecoration(labelText: 'Target Industry'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _performAdvancedAnalysis,
                child: const Text('Analyze Resume'),
              ),

              // Analysis Results
              if (_resumeAnalysis.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'Resume Analysis',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._resumeAnalysis.map((analysis) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(analysis)),
                    ],
                  ),
                )),
              ],

              // Job Match Suggestions
              if (_jobMatchSuggestions.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'Suggested Job Roles',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._jobMatchSuggestions.entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(entry.value as String),
                      ],
                    ),
                  ),
                )),
              ],
            ],

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateResume,
                child: _isGenerating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Generate Resume with AI'),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildResumePreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile image
              Row(
                children: [
                  if (_profileImage != null)
                    ClipOval(
                      child: Image.file(_profileImage!, width: 80, height: 80, fit: BoxFit.cover),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: const Icon(Icons.person, size: 40),
                    ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fullNameController.text,
                          style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(_emailController.text),
                        if (_phoneController.text.isNotEmpty) Text(_phoneController.text),
                        if (_locationController.text.isNotEmpty) Text(_locationController.text),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Professional Summary
              if (_summaryController.text.isNotEmpty) ...[
                _buildResumeSection('Professional Summary', _summaryController.text),
                const SizedBox(height: 24),
              ],

              // Work Experience
              if (_experienceController.text.isNotEmpty) ...[
                _buildResumeSection('Work Experience', _experienceController.text),
                const SizedBox(height: 24),
              ],

              // Education
              if (_educationController.text.isNotEmpty) ...[
                _buildResumeSection('Education', _educationController.text),
                const SizedBox(height: 24),
              ],

              // Skills
              if (_skillsController.text.isNotEmpty) ...[
                const Text('Skills', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skillsController.text
                      .split(',')
                      .map((skill) => skill.trim())
                      .where((skill) => skill.isNotEmpty)
                      .map((skill) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(skill, style: const TextStyle(color: Colors.blue)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

// Other sections would be implemented similarly...
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResumeSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(content, style: GoogleFonts.inter(fontSize: 16, height: 1.6)),
      ],
    );
  }

  void _calculateResumeScore() {
    int score = 0;
    double progress = 0.0;
    int completedFields = 0;
    const int totalFields = 7;

    if (_fullNameController.text.isNotEmpty) {
      score += 15;
      completedFields++;
    }
    if (_emailController.text.isNotEmpty) {
      score += 10;
      completedFields++;
    }
    if (_summaryController.text.isNotEmpty) {
      score += 20;
      completedFields++;
    }
    if (_experienceController.text.isNotEmpty) {
      score += 25;
      completedFields++;
    }
    if (_educationController.text.isNotEmpty) {
      score += 15;
      completedFields++;
    }
    if (_skillsController.text.isNotEmpty) {
      score += 10;
      completedFields++;
    }
    if (_profileImage != null) {
      score += 5;
    }

    progress = completedFields / totalFields;

    if (score >= 90) {
      _scoreFeedback = 'Excellent resume with strong content!';
    } else if (score >= 70) {
      _scoreFeedback = 'Good resume. Consider adding more details.';
    } else {
      _scoreFeedback = 'Resume needs more complete information.';
    }

    _resumeScore = score.clamp(0, 100);
    _completionProgress = progress;
  }

  Color _getScoreColor() {
    if (_resumeScore >= 80) return Colors.green;
    if (_resumeScore >= 60) return Colors.orange;
    return Colors.red;
  }

  Future<void> _loadResumeData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('resume_data');
    if (data != null) {
      final jsonData = json.decode(data) as Map<String, dynamic>;
      setState(() {
        _fullNameController.text = jsonData['fullName'] ?? '';
        _emailController.text = jsonData['email'] ?? '';
        _phoneController.text = jsonData['phone'] ?? '';
        _locationController.text = jsonData['location'] ?? '';
        _summaryController.text = jsonData['summary'] ?? '';
        _experienceController.text = jsonData['experience'] ?? '';
        _educationController.text = jsonData['education'] ?? '';
        _skillsController.text = jsonData['skills'] ?? '';
        _lastSaved = jsonData['savedAt'];
      });
    }
  }

  void _setupAutoSaveListeners() {
    final controllers = [
      _fullNameController,
      _emailController,
      _phoneController,
      _locationController,
      _summaryController,
      _experienceController,
      _educationController,
      _skillsController,
    ];

    for (final controller in controllers) {
      controller.addListener(() {
        _autoSaveTimer?.cancel();
        _autoSaveTimer = Timer(const Duration(seconds: 3), () async {
          final data = {
            'fullName': _fullNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'location': _locationController.text,
            'summary': _summaryController.text,
            'experience': _experienceController.text,
            'education': _educationController.text,
            'skills': _skillsController.text,
            'savedAt': DateTime.now().toString(),
          };
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('resume_data', json.encode(data));
          setState(() => _lastSaved = DateTime.now().toString().substring(0, 19));
        });
      });
    }
  }
}
