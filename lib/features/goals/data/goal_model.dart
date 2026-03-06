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

  DateTime? createdAt;
  DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  /// JSON → Model
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      accountId: json['accountId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      targetDate: DateTime.parse(json['targetDate']),
      status: json['status'] ?? "active",
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Model → JSON (Create Goal API)
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "category": category,
      "targetAmount": targetAmount,
      "targetDate": targetDate.toIso8601String(),
      "accountId": accountId,
    };
  }

  /// Update Goal JSON
  Map<String, dynamic> toUpdateJson() {
    return {
      "title": title,
      "category": category,
      "targetAmount": targetAmount,
      "targetDate": targetDate.toIso8601String(),
      "accountId": accountId,
    };
  }

  /// Deposit / Withdraw JSON
  Map<String, dynamic> amountJson(double amount) {
    return {
      "amount": amount,
    };
  }

  /// Progress for UI
  double get progress {
    if (targetAmount == 0) return 0;
    return currentAmount / targetAmount;
  }

  /// Remaining amount
  double get remainingAmount {
    return targetAmount - currentAmount;
  }

  /// Goal completed
  bool get isCompleted {
    return status == "completed";
  }
}