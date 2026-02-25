class AnalyticsModel {
  final String id;
  final String type; // "cash" or "account"
  final double amount;
  final DateTime date;

  AnalyticsModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
  });
}