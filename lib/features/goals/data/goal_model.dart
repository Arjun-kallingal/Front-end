class GoalModel {
  final String id;
  final String userId;
  final String accountId;
  String title;
  String category;
  double targetAmount;
  double currentAmount;
  DateTime targetDate;
  DateTime createdAt;
  String status;
  String? description;
  String reminderFrequency;
  String transactionType;

  // Calculated fields from backend
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
    required this.createdAt,
    this.description,
    this.reminderFrequency = 'weekly',
    this.transactionType = 'expense',
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
      targetAmount: (json['targetAmount'] as num? ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] as num? ?? 0).toDouble(),
      targetDate: DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      description: json['description'],
      reminderFrequency: json['reminderFrequency'] ?? 'weekly',
      transactionType: json['transactionType'] ?? 'expense',

      // ✅ Safe null-aware casting for calculated fields
      daysLeft: json['daysLeft'] != null
          ? (json['daysLeft'] as num).toInt()
          : null,
      requiredDailySaving: json['requiredDailySaving'] != null
          ? (json['requiredDailySaving'] as num).toDouble()
          : null,
      progressPercentage: json['progressPercentage'] != null
          ? (json['progressPercentage'] as num).toDouble()
          : null,
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      if (!isCreate && id.isNotEmpty) "_id": id,
      "userId": userId,
      "accountId": accountId,
      "title": title,
      "category": category,
      "targetAmount": targetAmount,
      "currentAmount": currentAmount,
      "status": status,
      "targetDate": targetDate.toIso8601String(),
      if (description != null && description!.isNotEmpty)
        "description": description,
      "reminderFrequency": reminderFrequency,
      "transactionType": transactionType,
    };
  }

  double get progress => progressPercentage != null && progressPercentage! > 0
      ? (progressPercentage! / 100).clamp(0.0, 1.0)
      : (targetAmount == 0
          ? 0
          : (currentAmount / targetAmount).clamp(0.0, 1.0));
}