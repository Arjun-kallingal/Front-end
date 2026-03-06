class AnalyticsModel {
  final String id;
  final String type; // 'CASH' or 'ACCOUNT'
  final String transactionType; // 'INCOME', 'EXPENSE', 'DEBT'
  final String category;
  final double amount;
  final DateTime date;

  AnalyticsModel({
    required this.id,
    required this.type,
    required this.transactionType,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['_id'] ?? '',
      type: json['accountType'] ?? 'CASH',
      transactionType: json['transactionType'] ?? 'EXPENSE',
      category: json['category'] ?? 'General',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}