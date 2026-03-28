class GoalModel {
  final String id;

  /// Account
  final String accountId;
  final String? accountName;

  /// Basic Info
  String title;
  String category;

  /// Money
  double targetAmount;
  double currentAmount;

  /// Dates
  DateTime targetDate;
  DateTime createdAt;

  /// Status
  String status;

  /// Optional
  String? description;
  String reminderFrequency;
  String transactionType;

  /// Backend calculated fields
  final int? daysLeft;
  final double? requiredDailySaving;
  final double? progressPercentage;
  final bool isOverdue;

  GoalModel({
    required this.id,
    required this.accountId,
    this.accountName,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.status,
    this.description,
    this.reminderFrequency = 'weekly',
    this.transactionType = 'expense',
    this.daysLeft,
    this.requiredDailySaving,
    this.progressPercentage,
    this.isOverdue = false,
  });

  /// ✅ FIXED FROM JSON (IMPORTANT 🔥)
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    String parsedAccountId = '';
    String parsedAccountName = 'Unknown';

    /// 🔥 HANDLE accountId (String OR Object)
    final acc = json['accountId'];

    if (acc is String) {
      parsedAccountId = acc;
    } else if (acc is Map<String, dynamic>) {
      parsedAccountId = acc['_id'] ?? acc['id'] ?? '';
      parsedAccountName = acc['name'] ?? 'Account';
    }

    return GoalModel(
      id: json['_id'] ?? '',

      accountId: parsedAccountId,
      accountName: parsedAccountName,

      title: json['title'] ?? '',
      category: json['category'] ?? '',

      targetAmount: (json['targetAmount'] as num? ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] as num? ?? 0).toDouble(),

      targetDate:
          DateTime.tryParse(json['targetDate'] ?? '') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),

      status: json['status'] ?? 'active',

      description: json['description'],
      reminderFrequency: json['reminderFrequency'] ?? 'weekly',
      transactionType: json['transactionType'] ?? 'expense',

      /// ✅ Backend fields
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

  /// ✅ TO JSON (for create/update)
  Map<String, dynamic> toJson({bool isCreate = false}) {
    return {
      if (!isCreate && id.isNotEmpty) "_id": id,

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

  /// ✅ SAFE PROGRESS CALCULATION
  double get progress {
    if (progressPercentage != null && progressPercentage! > 0) {
      return (progressPercentage! / 100).clamp(0.0, 1.0);
    }

    if (targetAmount == 0) return 0;

    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }
}