 import 'package:flutter/material.dart';

class SummaryItem extends StatelessWidget {
  final String title;
  final String value;

  const SummaryItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}




// class SummaryItem extends StatelessWidget {
//   final String title;
//   final String value;
//   final Color color;

//   const SummaryItem({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           title,
//           style: const TextStyle(color: Colors.white70, fontSize: 12),
//         ),
//         const SizedBox(height: 5),
//         Text(
//           value,
//           style: TextStyle(
//             color: color,
//             fontWeight: FontWeight.bold,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
// }
