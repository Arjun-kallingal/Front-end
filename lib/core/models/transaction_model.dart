// 1. THE INDIVIDUAL TRANSACTION OBJECT
class TransactionModel {
  final String id;
  final String accountId; // Needed for Reversal API
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String type;
  final String category;
  final String direction;
  final String accountName;
  final String? idempotencyKey;
  final String status; // Needed to check if already voided/reversed

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.direction,
    required this.accountName,
    this.idempotencyKey,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id']?.toString() ?? '',
      // Safely extract accountId whether it's populated or just a string
      accountId: (json['accountId'] is Map)
          ? json['accountId']['_id']?.toString() ?? ''
          : json['accountId']?.toString() ?? '',
      title: json['category'] ?? 'General',
      subtitle: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: () {
        if (json['transactedAt'] != null) {
          return DateTime.parse(json['transactedAt'].toString()).toLocal();
        }
        if (json['createdAt'] != null) {
          return DateTime.parse(json['createdAt'].toString()).toLocal();
        }
        return DateTime.now();
      }(),
      type: (json['transactionType'] ?? 'EXPENSE').toString().toUpperCase(),
      category: json['category'] ?? 'General',
      direction: (json['direction'] ?? 'STANDARD').toString().toUpperCase(),
      accountName: (json['accountName'] ?? 'Unknown Account').toString(),
      idempotencyKey: json['idempotencyKey']?.toString(),
      status: (json['status'] ?? 'COMPLETED').toString().toUpperCase(),
    );
  }
}

// 2. THE WRAPPER FOR THE FULL BACKEND RESPONSE
class TransactionHistoryResponse {
  final int count;
  final String? nextCursor;
  final List<TransactionModel> transactions;

  TransactionHistoryResponse({
    required this.count,
    required this.nextCursor,
    required this.transactions,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List dataList = json['data'] ?? [];

    return TransactionHistoryResponse(
      count: json['count'] ?? 0,
      nextCursor: json['nextCursor']?.toString(),
      transactions:
          dataList.map((item) => TransactionModel.fromJson(item)).toList(),
    );
  }
}
