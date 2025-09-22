import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NetworkingPage extends StatefulWidget {
  const NetworkingPage({super.key});

  @override
  State<NetworkingPage> createState() => _NetworkingPageState();
}

class _NetworkingPageState extends State<NetworkingPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _alumniProfiles = [
    {
      'id': '1',
      'name': 'Sarah Johnson',
      'position': 'Senior Software Engineer',
      'company': 'Google',
      'location': 'Mountain View, CA',
      'graduationYear': '2018',
      'department': 'Computer Science',
      'skills': ['Flutter', 'Dart', 'Mobile Development', 'Leadership'],
      'experience': '5+ years in software development',
      'connections': 150,
      'isConnected': false,
      'hasPendingRequest': false,
      'profileImage': null,
      'bio':
          'Passionate about mentoring and helping students grow in their tech careers.',
      'availability': 'Available for coffee chats and career advice',
    },
    {
      'id': '2',
      'name': 'Michael Chen',
      'position': 'Product Manager',
      'company': 'Microsoft',
      'location': 'Seattle, WA',
      'graduationYear': '2017',
      'department': 'Information Technology',
      'skills': [
        'Product Strategy',
        'Agile',
        'Data Analysis',
        'Team Leadership',
      ],
      'experience': '6+ years in product management',
      'connections': 200,
      'isConnected': true,
      'hasPendingRequest': false,
      'profileImage': null,
      'bio':
          'Love connecting students with opportunities and sharing product insights.',
      'availability': 'Open to networking and referrals',
    },
    {
      'id': '3',
      'name': 'Emily Rodriguez',
      'position': 'UX Designer',
      'company': 'Adobe',
      'location': 'San Francisco, CA',
      'graduationYear': '2019',
      'department': 'Design',
      'skills': ['UI/UX Design', 'Figma', 'User Research', 'Prototyping'],
      'experience': '4+ years in design',
      'connections': 120,
      'isConnected': false,
      'hasPendingRequest': true,
      'profileImage': null,
      'bio': 'Design enthusiast who enjoys mentoring aspiring designers.',
      'availability': 'Available for design reviews and career guidance',
    },
    {
      'id': '4',
      'name': 'David Kim',
      'position': 'Data Scientist',
      'company': 'Amazon',
      'location': 'Seattle, WA',
      'graduationYear': '2016',
      'department': 'Mathematics',
      'skills': ['Python', 'Machine Learning', 'SQL', 'Statistics'],
      'experience': '7+ years in data science',
      'connections': 180,
      'isConnected': false,
      'hasPendingRequest': false,
      'profileImage': null,
      'bio':
          'Data science mentor passionate about AI and machine learning education.',
      'availability': 'Happy to discuss data science career paths',
    },
  ];

  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _referrals = [];

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Connected', 'Pending', 'Available'];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();

  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  String? _currentUserRole;
  bool _isLoadingData = true;
  final bool _isSendingConnectionRequest = false;
  final bool _isSendingMessage = false;
  final bool _isSendingReferral = false;
  final bool _isLoadingImage = false;

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
    _loadUserRole();
    _loadNetworkingData();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserRole = prefs.getString('role') ?? 'student';
    });
  }

  List<Map<String, dynamic>> get _filteredAlumni {
    List<Map<String, dynamic>> filtered = _alumniProfiles;

    // Apply filter
    if (_selectedFilter == 'Connected') {
      filtered = _alumniProfiles
          .where((alumni) => alumni['isConnected'])
          .toList();
    } else if (_selectedFilter == 'Pending') {
      filtered = _alumniProfiles
          .where((alumni) => alumni['hasPendingRequest'])
          .toList();
    } else if (_selectedFilter == 'Available') {
      filtered = _alumniProfiles
          .where(
            (alumni) => !alumni['isConnected'] && !alumni['hasPendingRequest'],
          )
          .toList();
    }

    // Apply search
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered.where((alumni) {
        return alumni['name'].toLowerCase().contains(searchText) ||
            alumni['position'].toLowerCase().contains(searchText) ||
            alumni['company'].toLowerCase().contains(searchText) ||
            alumni['department'].toLowerCase().contains(searchText) ||
            (alumni['skills'] as List<String>).any(
              (skill) => skill.toLowerCase().contains(searchText),
            );
      }).toList();
    }

    return filtered;
  }

  Future<void> _sendConnectionRequest(String alumniId) async {
    try {
      setState(() {
        final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
        alumni['hasPendingRequest'] = true;
      });

      await _saveNetworkingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connection request sent!'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Revert the state change on error
      setState(() {
        final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
        alumni['hasPendingRequest'] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send connection request: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _acceptConnectionRequest(String alumniId) async {
    try {
      setState(() {
        final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
        alumni['hasPendingRequest'] = false;
        alumni['isConnected'] = true;
        alumni['connections'] = (alumni['connections'] as int) + 1;
      });

      await _saveNetworkingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connection request accepted!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Revert the state change on error
      setState(() {
        final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
        alumni['hasPendingRequest'] = true;
        alumni['isConnected'] = false;
        alumni['connections'] = (alumni['connections'] as int) - 1;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to accept connection request: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(String alumniId, String message) async {
    final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'alumniId': alumniId,
      'alumniName': alumni['name'],
      'message': message,
      'timestamp': DateTime.now().toString(),
      'isFromStudent': true,
      'type': 'message',
    };

    setState(() {
      _messages.add(newMessage);
    });

    try {
      await _saveNetworkingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message sent!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Remove the message from the list if saving failed
      setState(() {
        _messages.removeWhere((m) => m['id'] == newMessage['id']);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _requestReferral(
    String alumniId,
    String position,
    String company,
  ) async {
    final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
    final newReferral = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'alumniId': alumniId,
      'alumniName': alumni['name'],
      'position': position,
      'company': company,
      'status': 'pending', // pending, approved, sent, rejected
      'timestamp': DateTime.now().toString(),
      'notes': '',
    };

    setState(() {
      _referrals.add(newReferral);
    });

    try {
      await _saveNetworkingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Referral request sent!'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Remove the referral from the list if saving failed
      setState(() {
        _referrals.removeWhere((r) => r['id'] == newReferral['id']);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send referral request: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _sendReferral(String referralId, String referralMessage) async {
    final originalReferral = Map<String, dynamic>.from(
      _referrals.firstWhere((r) => r['id'] == referralId),
    );

    setState(() {
      final referral = _referrals.firstWhere((r) => r['id'] == referralId);
      referral['status'] = 'sent';
      referral['referralMessage'] = referralMessage;
      referral['sentDate'] = DateTime.now().toString();
    });

    try {
      await _saveNetworkingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Referral sent successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Revert the state change on error
      setState(() {
        final referral = _referrals.firstWhere((r) => r['id'] == referralId);
        referral['status'] = originalReferral['status'];
        referral['referralMessage'] = originalReferral['referralMessage'];
        referral['sentDate'] = originalReferral['sentDate'];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send referral: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadNetworkingData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? networkingData = prefs.getString('networkingData');

      if (networkingData != null) {
        final data = json.decode(networkingData) as Map<String, dynamic>;

        setState(() {
          // Load alumni profiles with updated connection status
          final savedProfiles = data['alumniProfiles'] as List<dynamic>? ?? [];
          for (var savedProfile in savedProfiles) {
            final index = _alumniProfiles.indexWhere(
              (a) => a['id'] == savedProfile['id'],
            );
            if (index != -1) {
              _alumniProfiles[index] = Map<String, dynamic>.from(savedProfile);
            }
          }

          // Load messages and referrals
          _messages.clear();
          _messages.addAll(
            (data['messages'] as List<dynamic>? ?? []).map(
              (m) => Map<String, dynamic>.from(m),
            ),
          );

          _referrals.clear();
          _referrals.addAll(
            (data['referrals'] as List<dynamic>? ?? []).map(
              (r) => Map<String, dynamic>.from(r),
            ),
          );
        });
      }
    } catch (e) {
      print('Error loading networking data: $e');
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to load saved data. Using default data.',
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _saveNetworkingData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final networkingData = {
        'alumniProfiles': _alumniProfiles,
        'messages': _messages,
        'referrals': _referrals,
      };
      await prefs.setString('networkingData', json.encode(networkingData));
    } catch (e) {
      print('Error saving networking data: $e');
      // Show user-friendly error message for critical save failures
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save data. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      // Re-throw the error so calling methods can handle it
      rethrow;
    }
  }

  Future<void> _pickProfileImage(String alumniId) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
          alumni['profileImage'] = image.path;
        });
        _saveNetworkingData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Update Profile Image',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select an alumni to update their profile image:',
                style: GoogleFonts.inter(fontSize: 14),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _alumniProfiles.length,
                  itemBuilder: (context, index) {
                    final alumni = _alumniProfiles[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                        child:
                            alumni['profileImage'] != null &&
                                alumni['profileImage'].toString().isNotEmpty
                            ? ClipOval(
                                child: Image.file(
                                  File(alumni['profileImage']),
                                  fit: BoxFit.cover,
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      alumni['name']
                                          .toString()
                                          .split(' ')
                                          .map((n) => n[0])
                                          .join(''),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                alumni['name']
                                    .toString()
                                    .split(' ')
                                    .map((n) => n[0])
                                    .join(''),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      title: Text(
                        alumni['name'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        '${alumni['position']} at ${alumni['company']}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickProfileImage(alumni['id']);
                      },
                    );
                  },
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

  void _showMessageDialog(String alumniId) {
    final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
    _messageController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Message ${alumni['name']}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  _sendMessage(alumniId, _messageController.text.trim());
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showReferralDialog(String alumniId) {
    final alumni = _alumniProfiles.firstWhere((a) => a['id'] == alumniId);
    _referralController.clear();
    String companyName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Request Referral from ${alumni['name']}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _referralController,
                decoration: InputDecoration(
                  hintText: 'Position you\'re applying for',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Company name (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  companyName = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_referralController.text.trim().isNotEmpty) {
                  _requestReferral(
                    alumniId,
                    _referralController.text.trim(),
                    companyName.isNotEmpty ? companyName : 'Company Name',
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Request'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonScreen() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3, // Show 3 skeleton items
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 18,
                            width: 150,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 14,
                            width: 120,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 100,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bio skeleton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Skills skeleton
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 60,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats skeleton
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),

                // Button skeleton
                Container(
                  height: 36,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
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
          'Networking',
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
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MessagesPage(
                    messages: _messages,
                    alumniProfiles: _alumniProfiles,
                    onMessageSent: _sendMessage,
                  ),
                ),
              );
            },
            tooltip: 'Messages',
          ),
          IconButton(
            icon: const Icon(Icons.card_giftcard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReferralsPage(
                    referrals: _referrals,
                    alumniProfiles: _alumniProfiles,
                    onReferralSent: _sendReferral,
                    userRole: _currentUserRole ?? 'student',
                  ),
                ),
              );
            },
            tooltip: 'Referrals',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search alumni by name, position, or skills...',
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
      body: _isLoadingData
          ? _buildSkeletonScreen()
          : _filteredAlumni.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No alumni found",
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
                    "Try adjusting your search or filters",
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
              itemCount: _filteredAlumni.length,
              itemBuilder: (context, index) {
                final alumni = _filteredAlumni[index];
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 16,
                    left: 24,
                    right: 24,
                  ),
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.08),
                        spreadRadius: 2,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[700]!.withValues(alpha: 0.5)
                          : Colors.grey[200]!.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with profile image and basic info
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.secondary
                                        .withValues(alpha: 0.25),
                                    Theme.of(context).colorScheme.secondary
                                        .withValues(alpha: 0.15),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withValues(alpha: 0.3),
                                    spreadRadius: 1,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child:
                                  alumni['profileImage'] != null &&
                                      alumni['profileImage']
                                          .toString()
                                          .isNotEmpty
                                  ? ClipOval(
                                      child: Image.file(
                                        File(alumni['profileImage']),
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Text(
                                                  alumni['name']
                                                      .toString()
                                                      .split(' ')
                                                      .map((n) => n[0])
                                                      .join(''),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        alumni['name']
                                            .toString()
                                            .split(' ')
                                            .map((n) => n[0])
                                            .join(''),
                                        style: GoogleFonts.inter(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
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
                                    alumni['name'],
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${alumni['position']} at ${alumni['company']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${alumni['location']} • Class of ${alumni['graduationYear']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
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
                        const SizedBox(height: 20),

                        // Bio
                        Text(
                          alumni['bio'],
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Skills
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: (alumni['skills'] as List<String>).map((
                            skill,
                          ) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
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
                                  color: Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                skill,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Stats and availability
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]!.withValues(alpha: 0.5)
                                : Colors.grey[100]!.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 18,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${alumni['connections']} connections',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                alumni['availability'],
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action buttons
                        Row(
                          children: [
                            if (!alumni['isConnected'] &&
                                !alumni['hasPendingRequest'])
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.secondary
                                            .withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withValues(alpha: 0.3),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _sendConnectionRequest(alumni['id']),
                                    icon: const Icon(
                                      Icons.person_add,
                                      size: 18,
                                    ),
                                    label: const Text('Connect'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else if (alumni['hasPendingRequest'])
                              Expanded(
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.withValues(alpha: 0.15),
                                        Colors.orange.withValues(alpha: 0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Request Pending',
                                      style: GoogleFonts.inter(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else if (alumni['isConnected'])
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 48,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _showMessageDialog(alumni['id']),
                                          icon: const Icon(
                                            Icons.message,
                                            size: 18,
                                          ),
                                          label: const Text('Message'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 48,
                                        margin: const EdgeInsets.only(left: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.blue.withValues(
                                                alpha: 0.15,
                                              ),
                                              Colors.blue.withValues(
                                                alpha: 0.08,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue.withValues(
                                              alpha: 0.3,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _showReferralDialog(alumni['id']),
                                          icon: const Icon(
                                            Icons.card_giftcard,
                                            size: 18,
                                          ),
                                          label: const Text('Referral'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.blue,
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
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
                );
              },
            ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          heroTag: "networking_fab",
          onPressed: _showImagePickerDialog,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          tooltip: 'Update Profile Images',
          child: const Icon(Icons.photo_camera),
        ),
      ),
    );
  }
}

// Messages Page
class MessagesPage extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final List<Map<String, dynamic>> alumniProfiles;
  final Function(String, String) onMessageSent;

  const MessagesPage({
    super.key,
    required this.messages,
    required this.alumniProfiles,
    required this.onMessageSent,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Messages',
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
      body: widget.messages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No messages yet",
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
                    "Start a conversation with alumni",
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
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                final alumni = widget.alumniProfiles.firstWhere(
                  (a) => a['id'] == message['alumniId'],
                  orElse: () => {'name': 'Unknown Alumni'},
                );

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      child:
                          alumni['profileImage'] != null &&
                              alumni['profileImage'].toString().isNotEmpty
                          ? ClipOval(
                              child: Image.file(
                                File(alumni['profileImage']),
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    alumni['name']
                                        .toString()
                                        .split(' ')
                                        .map((n) => n[0])
                                        .join(''),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(
                              alumni['name']
                                  .toString()
                                  .split(' ')
                                  .map((n) => n[0])
                                  .join(''),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    title: Text(
                      alumni['name'],
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.reply),
                      onPressed: () {
                        _showReplyDialog(message['alumniId']);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open compose new message
          _showComposeDialog();
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  void _showReplyDialog(String alumniId) {
    final alumni = widget.alumniProfiles.firstWhere((a) => a['id'] == alumniId);
    _messageController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reply to ${alumni['name']}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Type your reply...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  widget.onMessageSent(
                    alumniId,
                    _messageController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _showComposeDialog() {
    _messageController.clear();
    String? selectedAlumniId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Compose New Message',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Alumni',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.alumniProfiles
                    .where((alumni) => alumni['isConnected'])
                    .map<DropdownMenuItem<String>>((alumni) {
                      return DropdownMenuItem<String>(
                        value: alumni['id'] as String,
                        child: Text(alumni['name'] as String),
                      );
                    })
                    .toList(),
                onChanged: (String? value) {
                  selectedAlumniId = value;
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedAlumniId != null &&
                    _messageController.text.trim().isNotEmpty) {
                  widget.onMessageSent(
                    selectedAlumniId!,
                    _messageController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

// Referrals Page
class ReferralsPage extends StatefulWidget {
  final List<Map<String, dynamic>> referrals;
  final List<Map<String, dynamic>> alumniProfiles;
  final Function(String, String) onReferralSent;
  final String userRole;

  const ReferralsPage({
    super.key,
    required this.referrals,
    required this.alumniProfiles,
    required this.onReferralSent,
    required this.userRole,
  });

  @override
  State<ReferralsPage> createState() => _ReferralsPageState();
}

class _ReferralsPageState extends State<ReferralsPage> {
  final TextEditingController _referralMessageController =
      TextEditingController();

  @override
  void dispose() {
    _referralMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userReferrals = widget.userRole == 'alumni'
        ? widget.referrals.where((r) => r['alumniId'] != null).toList()
        : widget.referrals.where((r) => r['alumniId'] != null).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.userRole == 'alumni' ? 'Referral Requests' : 'My Referrals',
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
      body: userReferrals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_giftcard_outlined,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.userRole == 'alumni'
                        ? "No referral requests"
                        : "No referrals requested",
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
                    widget.userRole == 'alumni'
                        ? "Students will request referrals here"
                        : "Request referrals from your connections",
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
              itemCount: userReferrals.length,
              itemBuilder: (context, index) {
                final referral = userReferrals[index];
                final alumni = widget.alumniProfiles.firstWhere(
                  (a) => a['id'] == referral['alumniId'],
                  orElse: () => {'name': 'Unknown Alumni'},
                );

                return Card(
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
                            CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1),
                              child:
                                  alumni['profileImage'] != null &&
                                      alumni['profileImage']
                                          .toString()
                                          .isNotEmpty
                                  ? ClipOval(
                                      child: Image.file(
                                        File(alumni['profileImage']),
                                        fit: BoxFit.cover,
                                        width: 40,
                                        height: 40,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Text(
                                                alumni['name']
                                                    .toString()
                                                    .split(' ')
                                                    .map((n) => n[0])
                                                    .join(''),
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                      ),
                                    )
                                  : Text(
                                      alumni['name']
                                          .toString()
                                          .split(' ')
                                          .map((n) => n[0])
                                          .join(''),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alumni['name'],
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  Text(
                                    '${referral['position']} at ${referral['company']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
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
                            _buildStatusChip(referral['status']),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Requested: ${_formatTimestamp(referral['timestamp'])}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                        ),
                        if (referral['status'] == 'sent' &&
                            referral['referralMessage'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Referral Sent:',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    referral['referralMessage'],
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[300]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (widget.userRole == 'alumni' &&
                            referral['status'] == 'pending')
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _showSendReferralDialog(referral['id']),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.green),
                                      foregroundColor: Colors.green,
                                    ),
                                    child: const Text('Send Referral'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _rejectReferral(referral['id']),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.red),
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'sent':
        color = Colors.green;
        text = 'Sent';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Declined';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showSendReferralDialog(String referralId) {
    _referralMessageController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Send Referral',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: _referralMessageController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write your referral message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_referralMessageController.text.trim().isNotEmpty) {
                  widget.onReferralSent(
                    referralId,
                    _referralMessageController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Send Referral'),
            ),
          ],
        );
      },
    );
  }

  void _rejectReferral(String referralId) {
    setState(() {
      final referral = widget.referrals.firstWhere(
        (r) => r['id'] == referralId,
      );
      referral['status'] = 'rejected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral request declined'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
