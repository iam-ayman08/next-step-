class ScholarshipModel {
  final String id;
  final String title;
  final String description;
  final int amount;
  final String category;
  final String? eligibilityCriteria;
  final DateTime applicationDeadline;
  final int maxApplications;
  final int currentApplications;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScholarshipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    this.eligibilityCriteria,
    required this.applicationDeadline,
    required this.maxApplications,
    required this.currentApplications,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: json['amount'] as int,
      category: json['category'] as String,
      eligibilityCriteria: json['eligibility_criteria'] as String?,
      applicationDeadline: DateTime.parse(json['application_deadline'] as String),
      maxApplications: json['max_applications'] as int,
      currentApplications: json['current_applications'] as int,
      status: json['status'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'eligibility_criteria': eligibilityCriteria,
      'application_deadline': applicationDeadline.toIso8601String(),
      'max_applications': maxApplications,
      'current_applications': currentApplications,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getCategoryDisplayName() {
    switch (category) {
      case 'merit-based':
        return 'Merit-Based';
      case 'need-based':
        return 'Need-Based';
      case 'research':
        return 'Research';
      case 'achievement':
        return 'Achievement';
      default:
        return category;
    }
  }

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';
  bool get isDraft => status == 'draft';

  bool get canAcceptApplications =>
      isActive &&
      currentApplications < maxApplications &&
      applicationDeadline.isAfter(DateTime.now());

  double get applicationProgress => maxApplications > 0
      ? (currentApplications / maxApplications).clamp(0.0, 1.0)
      : 0.0;

  String get formattedAmount => '₹${amount.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )}';

  String get formattedDeadline =>
      '${applicationDeadline.day}/${applicationDeadline.month}/${applicationDeadline.year}';

  @override
  String toString() {
    return 'ScholarshipModel(id: $id, title: $title, amount: $amount, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScholarshipModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
