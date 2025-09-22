class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // 'student' or 'alumni'
  final String? profileImageUrl;
  final String? bio;
  final String? location;
  final String? phone;
  final String? linkedinUrl;
  final String? website;
  final List<String>? skills;
  final String? currentPosition;
  final String? company;
  final String? education;
  final String? graduationYear;
  final String? rollNumber;
  final DateTime? createdAt;
  final bool? isVerified;
  final String? provider; // 'email', 'google', 'github', 'linkedin'
  final Map<String, dynamic>? providerData;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    this.bio,
    this.location,
    this.phone,
    this.linkedinUrl,
    this.website,
    this.skills,
    this.currentPosition,
    this.company,
    this.education,
    this.graduationYear,
    this.rollNumber,
    this.createdAt,
    this.isVerified = false,
    this.provider = 'email',
    this.providerData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? json['name'] ?? '',
      role: json['role'] ?? 'student',
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      location: json['location'],
      phone: json['phone'],
      linkedinUrl: json['linkedinUrl'] ?? json['linkedin'],
      website: json['website'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      currentPosition: json['currentPosition'] ?? json['position'],
      company: json['company'],
      education: json['education'],
      graduationYear: json['graduationYear'],
      rollNumber: json['rollNumber'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      isVerified: json['isVerified'] ?? false,
      provider: json['provider'] ?? 'email',
      providerData: json['providerData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'location': location,
      'phone': phone,
      'linkedinUrl': linkedinUrl,
      'website': website,
      'skills': skills,
      'currentPosition': currentPosition,
      'company': company,
      'education': education,
      'graduationYear': graduationYear,
      'rollNumber': rollNumber,
      'createdAt': createdAt?.toIso8601String(),
      'isVerified': isVerified,
      'provider': provider,
      'providerData': providerData,
    };
  }

  // Map methods for database operations
  Map<String, dynamic> toMap() {
    return {
      'server_id': uid,
      'email': email,
      'name': fullName,
      'role': role,
      'avatar_url': profileImageUrl,
      'bio': bio,
      'location': location,
      'phone': phone,
      'linkedin_url': linkedinUrl,
      'website_url': website,
      'graduation_year': graduationYear,
      'roll_number': rollNumber,
      'company': company,
      'current_position': currentPosition,
      'education': education,
      'skills': skills != null ? skills!.join(',') : null,
      'interests': null, // Not in current UserModel
      'achievements': null, // Not in current UserModel
      'is_google_login': provider == 'google' ? 1 : 0,
      'google_id': providerData?['googleId'] ?? providerData?['id'],
      'created_at': createdAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['server_id'] ?? map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['name'] ?? map['fullName'] ?? '',
      role: map['role'] ?? 'student',
      profileImageUrl: map['avatar_url'] ?? map['profileImageUrl'],
      bio: map['bio'],
      location: map['location'],
      phone: map['phone'],
      linkedinUrl: map['linkedin_url'] ?? map['linkedinUrl'],
      website: map['website_url'] ?? map['website'],
      skills: map['skills'] != null ? (map['skills'] as String).split(',') : null,
      currentPosition: map['current_position'] ?? map['currentPosition'],
      company: map['company'],
      education: map['education'],
      graduationYear: map['graduation_year'] ?? map['graduationYear'],
      rollNumber: map['roll_number'] ?? map['rollNumber'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      isVerified: map['is_verified'] ?? false,
      provider: map['is_google_login'] == 1 || map['google_id'] != null
          ? 'google'
          : 'email',
      providerData: map['google_id'] != null ? {'googleId': map['google_id']} : null,
    );
  }

  // Helper methods
  String get displayName =>
      fullName.isNotEmpty ? fullName : email.split('@')[0];
  String get initials => fullName.isNotEmpty
      ? fullName.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
      : email[0].toUpperCase();

  bool get isAlumni => role.toLowerCase() == 'alumni';
  bool get isStudent => role.toLowerCase() == 'student';

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    String? profileImageUrl,
    String? bio,
    String? location,
    String? phone,
    String? linkedinUrl,
    String? website,
    List<String>? skills,
    String? currentPosition,
    String? company,
    String? education,
    String? graduationYear,
    String? rollNumber,
    DateTime? createdAt,
    bool? isVerified,
    String? provider,
    Map<String, dynamic>? providerData,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      website: website ?? this.website,
      skills: skills ?? this.skills,
      currentPosition: currentPosition ?? this.currentPosition,
      company: company ?? this.company,
      education: education ?? this.education,
      graduationYear: graduationYear ?? this.graduationYear,
      rollNumber: rollNumber ?? this.rollNumber,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      provider: provider ?? this.provider,
      providerData: providerData ?? this.providerData,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
