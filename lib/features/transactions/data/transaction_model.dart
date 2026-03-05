class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String type;
  final String accountType;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.accountType,
  });

  // This factory method is what the Service is looking for
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      // Your backend maps _id to id
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      
      // Backend 'category' -> Frontend 'title'
      title: json['category'] ?? 'General',
      
      // Backend 'description' -> Frontend 'subtitle'
      subtitle: json['description'] ?? '',
      
      // Convert Decimal128 String from Node.js to Double
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      
      // Parse ISO Date string
      date: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
          
      // Convert 'INCOME'/'EXPENSE' to lowercase for UI logic
      type: (json['transactionType'] ?? 'expense').toString().toLowerCase(),
      
      // Used for Bank/Cash filtering
      accountType: (json['accountType'] ?? 'cash').toString().toLowerCase(),
    );
  }
}