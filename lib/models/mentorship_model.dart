class MentorshipModel {
  final String id;
  final String mentorId;
  final String menteeId;
  final String status;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;

  MentorshipModel({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MentorshipModel.fromJson(Map<String, dynamic> json) {
    return MentorshipModel(
      id: json['id'],
      mentorId: json['mentor_id'],
      menteeId: json['mentee_id'],
      status: json['status'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentor_id': mentorId,
      'mentee_id': menteeId,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
