import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming these classes exist or will be created
class ProfilePage extends StatefulWidget {
  final String role;
  const ProfilePage({super.key, required this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  bool _isEditing = false;
  bool _isLoading = false;

  // Profile data
  String _name = "";
  String _email = "";
  String _bio = "";
  String _location = "";
  String _phone = "";
  String _linkedin = "";
  String _website = "";
  List<String> _skills = [];
  String _currentPosition = "";
  String _company = "";
  String _education = "";
  String _graduationYear = "";
  String _rollNumber = "";
  List<String> _achievements = [];
  List<String> _interests = [];

  // Gamification data
  int _totalPoints = 0;
  String _currentLevel = "Beginner";
  List<String> _earnedBadges = [];
  double _completionProgress = 0.0;
  final Map<String, int> _skillEndorsements = {};

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _currentPositionController =
      TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _graduationYearController =
      TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _achievementsController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();

  late AnimationController _editAnimationController;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _editAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _skillsController.dispose();
    _currentPositionController.dispose();
    _companyController.dispose();
    _educationController.dispose();
    _graduationYearController.dispose();
    _rollNumberController.dispose();
    _achievementsController.dispose();
    _interestsController.dispose();
    _editAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _name = prefs.getString('profile_name') ??
          (widget.role == "student" ? "John Doe" : "Jane Smith");
      _email = prefs.getString('profile_email') ??
          (widget.role == "student" ? "john.doe@student.com" : "jane.smith@alumni.com");
      _bio = prefs.getString('profile_bio') ??
          "Passionate about technology and innovation. Always eager to learn and grow.";
      _location = prefs.getString('profile_location') ?? "New York, USA";
      _phone = prefs.getString('profile_phone') ?? "+1 (555) 123-4567";
      _linkedin = prefs.getString('profile_linkedin') ??
          "linkedin.com/in/${_name.toLowerCase().replaceAll(' ', '')}";
      _website = prefs.getString('profile_website') ??
          "www.${_name.toLowerCase().replaceAll(' ', '')}.com";
      _skills = prefs.getStringList('profile_skills') ??
          ["Flutter", "Dart", "Firebase", "UI/UX Design"];
      _currentPosition = prefs.getString('profile_position') ??
          (widget.role == "student" ? "Computer Science Student" : "Software Engineer");
      _company = prefs.getString('profile_company') ??
          (widget.role == "student" ? "University" : "Tech Corp");
      _education = prefs.getString('profile_education') ??
          "Bachelor of Computer Science";
      _graduationYear = prefs.getString('profile_graduation_year') ??
          (widget.role == "student" ? "2025" : "2020");
      _rollNumber = prefs.getString('profile_roll_number') ??
          (widget.role == "student" ? "CS2021001" : "");
      _achievements = prefs.getStringList('profile_achievements') ??
          ["Dean's List", "Hackathon Winner", "Open Source Contributor"];
      _interests = prefs.getStringList('profile_interests') ??
          ["Machine Learning", "Mobile Development", "Entrepreneurship"];
    });

    _updateControllers();
    _calculateProfileCompletion();
    _initializeGamificationData();
  }

  void _calculateProfileCompletion() {
    int completedFields = 0;
    int totalFields = 9;

    if (_name.isNotEmpty && _name != "John Doe" && _name != "Jane Smith") {
      completedFields++;
    }
    if (_email.isNotEmpty && !_email.contains("test.com")) completedFields++;
    if (_bio.isNotEmpty && _bio != "Passionate about technology and innovation. Always eager to learn and grow.") {
      completedFields++;
    }
    if (_location.isNotEmpty && _location != "New York, USA") completedFields++;
    if (_phone.isNotEmpty && _phone != "+1 (555) 123-4567") completedFields++;
    if (_linkedin.isNotEmpty && !_linkedin.contains("linkedin.com/in/")) {
      completedFields++;
    }
    if (_website.isNotEmpty && !_website.contains("www.") && !_website.contains(".com")) {
      completedFields++;
    }
    if (_skills.isNotEmpty && !_skills.contains("Flutter")) completedFields++;
    if (_currentPosition.isNotEmpty && !_currentPosition.contains("Student") &&
        !_currentPosition.contains("Software Engineer")) {
      completedFields++;
    }

    setState(() {
      _completionProgress = completedFields / totalFields;
    });
  }

  void _initializeGamificationData() {
    int level = 1;
    if (_completionProgress >= 0.8) level = 3;
    else if (_completionProgress >= 0.6) level = 2;

    int points = (_completionProgress * 100).round() + (_skills.length * 5) + (_achievements.length * 10);

    List<String> badges = [];
    if (_completionProgress >= 0.3) badges.add("First Steps");
    if (_completionProgress >= 0.7) badges.add("Profile Master");
    if (_skills.length >= 3) badges.add("Network Builder");
    if (_achievements.length >= 2) badges.add("Opportunity Seeker");
    if (_currentPosition.isNotEmpty) badges.add("Forum Contributor");

    setState(() {
      _currentLevel = level == 1 ? "Beginner" : level == 2 ? "Intermediate" : "Advanced";
      _totalPoints = points;
      _earnedBadges = badges;
    });
  }

  void _updateControllers() {
    _nameController.text = _name;
    _emailController.text = _email;
    _bioController.text = _bio;
    _locationController.text = _location;
    _phoneController.text = _phone;
    _linkedinController.text = _linkedin;
    _websiteController.text = _website;
    _skillsController.text = _skills.join(', ');
    _currentPositionController.text = _currentPosition;
    _companyController.text = _company;
    _educationController.text = _education;
    _graduationYearController.text = _graduationYear;
    _rollNumberController.text = _rollNumber;
    _achievementsController.text = _achievements.join(', ');
    _interestsController.text = _interests.join(', ');
  }

  Future<void> _saveProfileData() async {
    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_name', _nameController.text);
    await prefs.setString('profile_email', _emailController.text);
    await prefs.setString('profile_bio', _bioController.text);
    await prefs.setString('profile_location', _locationController.text);
    await prefs.setString('profile_phone', _phoneController.text);
    await prefs.setString('profile_linkedin', _linkedinController.text);
    await prefs.setString('profile_website', _websiteController.text);
    await prefs.setStringList('profile_skills', _skillsController.text.split(',').map((s) => s.trim()).toList());
    await prefs.setString('profile_position', _currentPositionController.text);
    await prefs.setString('profile_company', _companyController.text);
    await prefs.setString('profile_education', _educationController.text);
    await prefs.setString('profile_graduation_year', _graduationYearController.text);
    await prefs.setString('profile_roll_number', _rollNumberController.text);
    await prefs.setStringList('profile_achievements', _achievementsController.text.split(',').map((s) => s.trim()).toList());
    await prefs.setStringList('profile_interests', _interestsController.text.split(',').map((s) => s.trim()).toList());

    await _loadProfileData();

    setState(() {
      _isEditing = false;
      _isLoading = false;
    });

    _editAnimationController.reverse();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Profile updated successfully!"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _cancelEditing() {
    _updateControllers();
    setState(() => _isEditing = false);
    _editAnimationController.reverse();
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                subtitle: const Text('Toggle between light and dark mode'),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: null, // Theme toggle disabled - light theme only
                  activeThumbColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
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

  // UI Helper Methods

  Widget _buildProfileSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String label, String value,
      {TextEditingController? controller, bool isEditing = false, int maxLines = 1}) {
    if (isEditing && controller != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.secondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[50],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor() {
    if (_completionProgress >= 0.8) return Colors.green;
    if (_completionProgress >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getBadgeColor(String badge) {
    switch (badge.toLowerCase()) {
      case 'first steps': return Colors.blue;
      case 'profile master': return Colors.purple;
      case 'network builder': return Colors.green;
      case 'opportunity seeker': return Colors.orange;
      case 'forum contributor': return Colors.teal;
      default: return Theme.of(context).colorScheme.secondary;
    }
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge.toLowerCase()) {
      case 'first steps': return Icons.start;
      case 'profile master': return Icons.verified;
      case 'network builder': return Icons.people;
      case 'opportunity seeker': return Icons.business;
      case 'forum contributor': return Icons.forum;
      default: return Icons.emoji_events;
    }
  }

  Widget _buildSkillsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(skill, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.secondary)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Icon(Icons.thumb_up, size: 12, color: Theme.of(context).colorScheme.secondary),
                  ),
                  Text('${_skillEndorsements[skill] ?? 0}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.secondary)),
                ],
              ),
            )
          ).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: Text(_isEditing ? 'Edit Profile' : 'Profile', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).appBarTheme.titleTextStyle?.color)),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () {
                setState(() => _isEditing = true);
                _editAnimationController.forward();
              },
            )
          else
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).appBarTheme.foregroundColor),
                  onPressed: _cancelEditing,
                ),
                IconButton(
                  icon: Icon(Icons.check, color: Theme.of(context).appBarTheme.foregroundColor),
                  onPressed: _isLoading ? null : _saveProfileData,
                ),
              ],
            ),
          IconButton(
            icon: Icon(Icons.settings, color: Theme.of(context).appBarTheme.foregroundColor),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Profile Picture
            Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 3),
                    boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Center(child: Image(image: AssetImage('nextstep_logo.png'), width: 90, height: 90)),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                      ),
                      child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.onSecondary, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // Name
            _isEditing
                ? TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  )
                : Text(_name, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 8),
            // Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 1),
              ),
              child: Text(widget.role == "student" ? "🎓 Student" : "🧑‍💼 Alumni", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.secondary)),
            ),
            const SizedBox(height: 16),
            // Bio
            _isEditing
                ? TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                    decoration: InputDecoration(
                      hintText: "Tell us about yourself...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  )
                : Text(_bio, style: GoogleFonts.inter(fontSize: 16, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 24),

            // Profile Completion Progress and Gamification
            if (!_isEditing) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Profile Level: $_currentLevel', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                Icon(Icons.stars, size: 16, color: Theme.of(context).colorScheme.secondary),
                                const SizedBox(width: 4),
                                Text('$_totalPoints pts', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: _completionProgress, backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor())),
                      const SizedBox(height: 8),
                      Text('${(_completionProgress * 100).round()}% Complete', style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600])),
                      if (_earnedBadges.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Earned Badges', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _earnedBadges.map((badge) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(badge).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getBadgeColor(badge), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getBadgeIcon(badge), size: 16, color: _getBadgeColor(badge)),
                                  const SizedBox(width: 6),
                                  Text(badge, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _getBadgeColor(badge))),
                                ],
                              ),
                            )
                          ).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Profile Details
            Card(
              elevation: 8,
              shadowColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Basic Information
                    _buildProfileSection(context, "Basic Information", [
                      _buildProfileItem(context, Icons.email, "Email", _email, controller: _emailController, isEditing: _isEditing),
                      _buildProfileItem(context, Icons.location_on, "Location", _location, controller: _locationController, isEditing: _isEditing),
                      _buildProfileItem(context, Icons.phone, "Phone", _phone, controller: _phoneController, isEditing: _isEditing),
                    ]),
                    const Divider(height: 32),
                    // Professional Information
                    _buildProfileSection(context, "Professional", [
                      _buildProfileItem(context, Icons.business_center, "Current Position", _currentPosition, controller: _currentPositionController, isEditing: _isEditing),
                      _buildProfileItem(context, Icons.business, "Company", _company, controller: _companyController, isEditing: _isEditing),
                      _buildProfileItem(context, Icons.link, "LinkedIn", _linkedin, controller: _linkedinController, isEditing: _isEditing),
                      _buildProfileItem(context, Icons.language, "Website", _website, controller: _websiteController, isEditing: _isEditing),
                    ]),
                    const Divider(height: 32),
                    // Education
                    _buildProfileSection(context, "Education", [
                      _buildProfileItem(context, Icons.school, "Education", _education, controller: _educationController, isEditing: _isEditing),
                      if (widget.role == "student") _buildProfileItem(context, Icons.badge, "Roll Number", _rollNumber, controller: _rollNumberController, isEditing: _isEditing),
                      _buildProfileItem(context, Icons.calendar_today, "Graduation Year", _graduationYear, controller: _graduationYearController, isEditing: _isEditing),
                    ]),
                    const Divider(height: 32),
                    // Skills
                    _buildProfileSection(context, "Skills", [
                      if (_isEditing)
                        _buildProfileItem(context, Icons.code, "Skills", _skills.join(', '), controller: _skillsController, isEditing: _isEditing, maxLines: 2)
                      else _buildSkillsSection(context),
                    ]),
                    const Divider(height: 32),
                    // Achievements
                    _buildProfileSection(context, "Achievements", [
                      _buildProfileItem(context, Icons.emoji_events, "Achievements", _achievements.join(', '), controller: _achievementsController, isEditing: _isEditing, maxLines: 3),
                    ]),
                    const Divider(height: 32),
                    // Interests
                    _buildProfileSection(context, "Interests", [
                      _buildProfileItem(context, Icons.favorite, "Interests", _interests.join(', '), controller: _interestsController, isEditing: _isEditing, maxLines: 2),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading) const CircularProgressIndicator()
            else if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _cancelEditing,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveProfileData,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
