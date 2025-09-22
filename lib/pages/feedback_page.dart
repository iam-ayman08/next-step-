import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _rating = 0;
  String _selectedCategory = 'General';
  String _selectedPriority = 'Medium';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  final bool _includeDeviceInfo = true;
  List<Map<String, dynamic>> _previousFeedback = [];
  final List<XFile> _attachedImages = [];
  String? _deviceInfo;
  String? _appInfo;

  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'UI/UX',
    'Performance',
    'Account Issues',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];

  final Map<String, String> _feedbackTemplates = {
    'Bug Report':
        'I encountered a bug when [describe what you were doing]. The issue is [describe the problem]. Expected behavior: [what should happen]. Actual behavior: [what actually happened].',
    'Feature Request':
        'I would like to suggest a new feature: [describe the feature]. This would help with [explain the benefit].',
    'UI/UX':
        'I noticed an issue with the user interface: [describe the UI problem]. It would be better if [suggest improvement].',
    'Performance':
        'I experienced performance issues when [describe when it happens]. The app feels [slow/laggy/unresponsive].',
  };

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _loadPreviousFeedback();
    _loadDeviceAndAppInfo();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
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
    _animationController.forward();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceAndAppInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String deviceInfoString = '';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceInfoString =
            'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceInfoString = 'iOS ${iosInfo.systemVersion}, ${iosInfo.model}';
      }

      setState(() {
        _deviceInfo = deviceInfoString;
        _appInfo =
            '${packageInfo.appName} v${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _pickScreenshot() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _attachedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  void _applyTemplate(String category) {
    if (_feedbackTemplates.containsKey(category)) {
      setState(() {
        _feedbackController.text = _feedbackTemplates[category]!;
      });
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      case 'Critical':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  Future<void> _loadPreviousFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? feedbackJson = prefs.getString('user_feedback');
    if (feedbackJson != null) {
      try {
        List<dynamic> decoded = json.decode(feedbackJson);
        setState(() {
          _previousFeedback = decoded
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        });
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _saveFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final feedback = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'rating': _rating,
      'category': _selectedCategory,
      'feedback': _feedbackController.text.trim(),
      'email': _isAnonymous ? null : _emailController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
      'isAnonymous': _isAnonymous,
    };

    _previousFeedback.insert(0, feedback);

    // Keep only last 10 feedback entries
    if (_previousFeedback.length > 10) {
      _previousFeedback = _previousFeedback.sublist(0, 10);
    }

    await prefs.setString('user_feedback', json.encode(_previousFeedback));
  }

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide a rating'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    await _saveFeedback();

    setState(() => _isSubmitting = false);

    // Reset form
    _rating = 0;
    _selectedCategory = 'General';
    _feedbackController.clear();
    _emailController.clear();
    _isAnonymous = false;
    _formKey.currentState!.reset();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Thank you for your feedback!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: index < _rating ? Colors.amber : Colors.grey[400],
            size: 32,
          ),
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildPreviousFeedback() {
    if (_previousFeedback.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'Your Previous Feedback',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 16),
        ..._previousFeedback.map(
          (feedback) => Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < (feedback['rating'] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: index < (feedback['rating'] ?? 0)
                                ? Colors.amber
                                : Colors.grey[400],
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feedback['category'] ?? 'General',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback['feedback'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(feedback['timestamp']),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500]
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown time';

    try {
      DateTime dateTime = DateTime.parse(timestamp);
      Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Enhanced Feedback',
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
          if (_feedbackTemplates.containsKey(_selectedCategory))
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () => _applyTemplate(_selectedCategory),
              tooltip: 'Use template',
            ),
        ],
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
                          Icons.feedback,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Share Your Feedback',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help us improve your experience',
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

                // Rating Section
                Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
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
                              child: Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'How would you rate your experience?',
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
                        _buildStarRating(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Category and Priority Row
                Row(
                  children: [
                    Expanded(child: _buildCategoryDropdown()),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(
                            Icons.flag,
                            color: _getPriorityColor(_selectedPriority),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(
                              priority,
                              style: TextStyle(
                                color: _getPriorityColor(priority),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Feedback Text with Template Hint
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Your Feedback',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                            if (_feedbackTemplates.containsKey(
                              _selectedCategory,
                            ))
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.lightbulb,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _feedbackController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText:
                                _feedbackTemplates.containsKey(
                                  _selectedCategory,
                                )
                                ? 'Tap the lightbulb icon to use a template, or write your own feedback...'
                                : 'Tell us what you think...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please provide your feedback';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Screenshot Attachment
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Screenshots (Optional)',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_attachedImages.isNotEmpty) ...[
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _attachedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: FileImage(
                                            File(_attachedImages[index].path),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 16,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.7,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: _pickScreenshot,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            _attachedImages.isEmpty
                                ? 'Add Screenshot'
                                : 'Add Another',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Contact Info
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email (optional)',
                            hintText: 'For follow-up questions',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: Text(
                            'Submit anonymously',
                            style: GoogleFonts.inter(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          value: _isAnonymous,
                          onChanged: (value) {
                            setState(() {
                              _isAnonymous = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Device Info (if available)
                if (_deviceInfo != null || _appInfo != null) ...[
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Device Information',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_deviceInfo != null)
                            Text(
                              'Device: $_deviceInfo',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          if (_appInfo != null)
                            Text(
                              'App: $_appInfo',
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
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: _isSubmitting ? 0 : 4,
                      shadowColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.3),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send),
                              const SizedBox(width: 8),
                              Text(
                                'Submit Feedback',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Previous Feedback
                _buildPreviousFeedback(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          heroTag: "screenshot_fab",
          onPressed: _pickScreenshot,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          tooltip: 'Add Screenshot',
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}
