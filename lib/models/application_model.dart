class ApplicationModel {
  final String id;
  final String userId;
  final String company;
  final String position;
  final String status;
  final String? jobDescription;
  final DateTime applicationDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.company,
    required this.position,
    required this.status,
    this.jobDescription,
    required this.applicationDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      userId: json['user_id'],
      company: json['company'],
      position: json['position'],
      status: json['status'],
      jobDescription: json['job_description'],
      applicationDate: DateTime.parse(json['application_date']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company': company,
      'position': position,
      'status': status,
      'job_description': jobDescription,
      'application_date': applicationDate.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
