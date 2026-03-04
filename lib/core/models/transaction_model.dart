

/// 1. THE INDIVIDUAL TRANSACTION OBJECT
class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String type;
  final String category; // 👈 Now properly mapped
  final String direction; 
  final String accountType;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    required this.direction,
    required this.accountType,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      
      // We use 'category' as the main title (e.g., Food, Salary)
      title: json['category'] ?? 'General',
      
      // We use 'description' as the subtitle
      subtitle: json['description'] ?? '',
      
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      
      date: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
          
      type: (json['transactionType'] ?? 'expense').toString().toLowerCase(),

      // 🎯 FIXED: Mapping the category field so the getter works in your UI
      category: json['category'] ?? 'General', 

      direction: (json['direction'] ?? 'NORMAL').toString().toUpperCase(),
      
      accountType: (json['accountType'] ?? 'cash').toString().toLowerCase(),
    );
  }
}

/// 2. THE WRAPPER FOR THE FULL BACKEND RESPONSE
class TransactionHistoryResponse {
  final double income;
  final double expense;
  final double reserved;
  final double balance;
  final List<TransactionModel> transactions;

  TransactionHistoryResponse({
    required this.income,
    required this.expense,
    required this.reserved,
    required this.balance,
    required this.transactions,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] ?? {};
    final List dataList = json['data'] ?? [];

    return TransactionHistoryResponse(
      income: (summary['income'] ?? 0.0).toDouble(),
      expense: (summary['expense'] ?? 0.0).toDouble(),
      reserved: (summary['reserved'] ?? 0.0).toDouble(),
      balance: (summary['balance'] ?? 0.0).toDouble(),
      transactions: dataList
          .map((item) => TransactionModel.fromJson(item))
          .toList(),
    );
  }
}