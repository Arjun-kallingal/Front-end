// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';

// class StatCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String amount;
//   final Color amountColor;
//   final Color iconBg;
//   final String subtitle;

//   const StatCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.amount,
//     required this.amountColor,
//     required this.iconBg,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final textTheme = theme.textTheme;

//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: theme.colorScheme.surface,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: AppColors.cardBorder),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔹 Icon + Title
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundColor: iconBg,
//                   child: Icon(
//                     icon,
//                     color: amountColor,
//                     size: 18,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 15),

//             /// 🔹 Amount
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 double fontSize;

//                 if (constraints.maxWidth < 150) {
//                   fontSize = 16;
//                 } else if (constraints.maxWidth < 180) {
//                   fontSize = 18;
//                 } else {
//                   fontSize = 22;
//                 }

//                 return Text(
//                   amount,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: textTheme.titleLarge?.copyWith(
//                     color: amountColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: fontSize,
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 8),

//             /// 🔹 Subtitle
//             Text(
//               subtitle,
//               style: textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
