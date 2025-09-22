class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int fundingGoal;
  final int currentFunding;
  final String fundingType;
  final String timeline;
  final String expectedOutcomes;
  final String? teamMembers;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fundingGoal,
    required this.currentFunding,
    required this.fundingType,
    required this.timeline,
    required this.expectedOutcomes,
    this.teamMembers,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      fundingGoal: json['funding_goal'] as int,
      currentFunding: json['current_funding'] as int,
      fundingType: json['funding_type'] as String,
      timeline: json['timeline'] as String,
      expectedOutcomes: json['expected_outcomes'] as String,
      teamMembers: json['team_members'] as String?,
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
      'category': category,
      'funding_goal': fundingGoal,
      'current_funding': currentFunding,
      'funding_type': fundingType,
      'timeline': timeline,
      'expected_outcomes': expectedOutcomes,
      'team_members': teamMembers,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String getCategoryDisplayName() {
    switch (category) {
      case 'technology':
        return 'Technology';
      case 'research':
        return 'Research';
      case 'social-impact':
        return 'Social Impact';
      case 'healthcare':
        return 'Healthcare';
      case 'education':
        return 'Education';
      case 'environment':
        return 'Environment';
      case 'business':
        return 'Business';
      case 'arts-culture':
        return 'Arts & Culture';
      default:
        return category;
    }
  }

  String getFundingTypeDisplayName() {
    switch (fundingType) {
      case 'financial':
        return 'Financial Support';
      case 'mentorship':
        return 'Mentorship';
      case 'technical':
        return 'Technical Help';
      case 'resources':
        return 'Resources';
      case 'networking':
        return 'Networking';
      case 'all':
        return 'All Support Types';
      default:
        return fundingType;
    }
  }

  bool get isPending => status == 'pending';
  bool get isFunded => status == 'funded';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isRejected => status == 'rejected';

  bool get canAcceptSupport =>
      isPending || isInProgress;

  double get fundingProgress => fundingGoal > 0
      ? (currentFunding / fundingGoal).clamp(0.0, 1.0)
      : 0.0;

  int get remainingFunding => fundingGoal - currentFunding;

  bool get isFullyFunded => currentFunding >= fundingGoal;

  String get formattedFundingGoal => '₹${fundingGoal.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )}';

  String get formattedCurrentFunding => '₹${currentFunding.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )}';

  String get formattedRemainingFunding => '₹${remainingFunding.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )}';

  @override
  String toString() {
    return 'ProjectModel(id: $id, title: $title, fundingGoal: $fundingGoal, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
