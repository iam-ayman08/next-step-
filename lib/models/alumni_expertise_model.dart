class AlumniExpertiseModel {
  final String id;
  final String userId;
  final String expertiseArea;
  final int yearsExperience;
  final String? currentPosition;
  final String? company;
  final String? skills;
  final String availabilityStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlumniExpertiseModel({
    required this.id,
    required this.userId,
    required this.expertiseArea,
    required this.yearsExperience,
    this.currentPosition,
    this.company,
    this.skills,
    required this.availabilityStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlumniExpertiseModel.fromJson(Map<String, dynamic> json) {
    return AlumniExpertiseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      expertiseArea: json['expertise_area'] as String,
      yearsExperience: json['years_experience'] as int,
      currentPosition: json['current_position'] as String?,
      company: json['company'] as String?,
      skills: json['skills'] as String?,
      availabilityStatus: json['availability_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'expertise_area': expertiseArea,
      'years_experience': yearsExperience,
      'current_position': currentPosition,
      'company': company,
      'skills': skills,
      'availability_status': availabilityStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getAvailabilityDisplayName() {
    switch (availabilityStatus) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'unavailable':
        return 'Unavailable';
      default:
        return availabilityStatus;
    }
  }

  bool get isAvailable => availabilityStatus == 'available';
  bool get isBusy => availabilityStatus == 'busy';
  bool get isUnavailable => availabilityStatus == 'unavailable';

  List<String> getSkillsList() {
    if (skills == null || skills!.isEmpty) {
      return [];
    }
    try {
      return List<String>.from(skills!.split(',').map((s) => s.trim()));
    } catch (e) {
      return [];
    }
  }

  String getExperienceLevel() {
    if (yearsExperience >= 10) {
      return 'Expert';
    } else if (yearsExperience >= 5) {
      return 'Senior';
    } else if (yearsExperience >= 2) {
      return 'Mid-level';
    } else {
      return 'Junior';
    }
  }

  String getDisplayTitle() {
    if (currentPosition != null && company != null) {
      return '$currentPosition at $company';
    } else if (currentPosition != null) {
      return currentPosition!;
    } else if (company != null) {
      return company!;
    } else {
      return expertiseArea;
    }
  }

  @override
  String toString() {
    return 'AlumniExpertiseModel(id: $id, expertiseArea: $expertiseArea, yearsExperience: $yearsExperience, availability: $availabilityStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlumniExpertiseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
