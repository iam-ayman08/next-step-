class ProfileModel {
  final String id;
  final String? bio;
  final List<String>? skills;
  final List<String>? interests;
  final String? location;
  final String? phone;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    this.bio,
    this.skills,
    this.interests,
    this.location,
    this.phone,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      bio: json['bio'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      interests: json['interests'] != null ? List<String>.from(json['interests']) : null,
      location: json['location'],
      phone: json['phone'],
      linkedinUrl: json['linkedin_url'],
      githubUrl: json['github_url'],
      portfolioUrl: json['portfolio_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bio': bio,
      'skills': skills,
      'interests': interests,
      'location': location,
      'phone': phone,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'portfolio_url': portfolioUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
