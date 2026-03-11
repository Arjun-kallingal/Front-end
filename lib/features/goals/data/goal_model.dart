class GoalModel {
  final String id;
  final String userId;
  final String accountId;
  String title;
  String category;
  double targetAmount;
  double currentAmount;
  DateTime targetDate;
  String status;

  // CALCULATED FIELDS FROM BACKEND
  final int? daysLeft;
  final double? requiredDailySaving;
  final double? progressPercentage;
  final bool isOverdue;

  GoalModel({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.status,
    this.daysLeft,
    this.requiredDailySaving,
    this.progressPercentage,
    this.isOverdue = false,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      accountId: json['accountId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'active',
      
      daysLeft: json['daysLeft'] is int ? json['daysLeft'] : null,
      requiredDailySaving: (json['requiredDailySaving'] ?? 0).toDouble(),
      progressPercentage: (json['progressPercentage'] ?? 0).toDouble(),
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) "_id": id, 
      "userId": userId,
      "accountId": accountId,
      "title": title,
      "category": category,
      "targetAmount": targetAmount,
      "currentAmount": currentAmount,
      "status": status,
      "targetDate": targetDate.toIso8601String(),
    };
  }

  double get progress => progressPercentage != null && progressPercentage! > 0
      ? (progressPercentage! / 100).clamp(0.0, 1.0)
      : (targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0));
}