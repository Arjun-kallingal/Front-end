class GoalModel {
  final String id;
  // ✅ userId removed — backend gets it from JWT
  final String? accountName;
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
    // ✅ userId removed
    required this.accountId,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.status,
    required this.createdAt,
    this.accountName,
    this.description,
    this.reminderFrequency = 'weekly',
    this.transactionType = 'expense',
    this.daysLeft,
    this.requiredDailySaving,
    this.progressPercentage,
    this.isOverdue = false,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    // Safely extract from Mongoose populated object
    final accountData = json['accountId'];
    final parsedAccountId = accountData is Map
        ? (accountData['_id']?.toString() ?? '')
        : (accountData?.toString() ?? '');

    // Safely extract Account Name whether it is nested in accountId or at the root
    String parsedAccountName = 'Main Account'; // Default fallback
    if (json['accountId'] is Map && json['accountId']['name'] != null) {
      parsedAccountName = json['accountId']['name'].toString();
    } else if (json['accountName'] != null &&
        json['accountName'].toString().isNotEmpty) {
      parsedAccountName = json['accountName'].toString();
    }

    return GoalModel(
      id: json['_id']?.toString() ?? '',
      accountId: parsedAccountId,
      accountName: parsedAccountName,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      targetAmount: (json['targetAmount'] as num? ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] as num? ?? 0).toDouble(),

      // ✅ Enforce local timezones
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'].toString()).toLocal()
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now(),

      status: json['status'] ?? 'active',
      description: json['description'],
      reminderFrequency: json['reminderFrequency'] ?? 'weekly',
      transactionType: json['transactionType'] ?? 'expense',

      // Allow mapping from either backend naming convention
      daysLeft: (json['daysLeft'] ?? json['remainingDays']) != null
          ? ((json['daysLeft'] ?? json['remainingDays']) as num).toInt()
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
      // ✅ userId removed — never sent in body, backend reads from JWT
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
