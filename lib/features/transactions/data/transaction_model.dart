class TransactionModel {
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String type; // income / expense / transfer

  // TransactionModel({
  //   required this.title,
  //   required this.subtitle,
  //   required this.amount,
  //   required this.date,
  //   required this.type,
  // });

final String accountType; // cash, bank

TransactionModel({
  required this.title,
  required this.subtitle,
  required this.amount,
  required this.date,
  required this.type,
  required this.accountType,
});
}