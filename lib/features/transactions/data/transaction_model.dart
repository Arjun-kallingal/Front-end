//  enum TransactionType { income, expense, transfer }

// // class TransactionModel {
// //   final String title;
// //   final String subtitle;
// //   final double amount;
// //   final DateTime date;
// //   final TransactionType type;

// //   TransactionModel({
// //     required this.title,
// //     required this.subtitle,
// //     required this.amount,
// //     required this.date,
// //     required this.type,
// //   });
// // }




// class TransactionModel {
//   final String title;
//   final String date;
//   final String amount;

//   TransactionModel({
//     required this.title,
//     required this.date,
//     required this.amount,
//   });
// }




class TransactionModel {
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String type; // income / expense / transfer

  TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });
}
