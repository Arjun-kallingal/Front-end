// import 'package:flutter/material.dart';

// // ✅ Use absolute package paths:
// import 'package:front_end/features/home/ui/home_screen.dart';
// import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
// import 'package:front_end/features/analytics/ui/analytics_dashboardscreen.dart';
// import 'package:front_end/features/profile/ui/profile_screen.dart';

// // ✅ Import your new unified Add Transaction screen
// // import 'package:front_end/features/transactions/ui/add_transaction_screen.dart'; 

// /// 🌐 GLOBAL NAV SERVICE
// class NavigationService {
//   static final ValueNotifier<int> bottomIndex = ValueNotifier(0);

//   static void changeTab(int index) {
//     bottomIndex.value = index;
//   }
// }

// class MainNavigation extends StatelessWidget {
//   final String? userId;

//   const MainNavigation({super.key, this.userId});

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> _screens = [
//       const HomeScreen(), 
//       AnalyticsDashboardScreen(),
//       TransactionListScreen(),
//       ProfileSettingsScreen(),
//     ];
//     final theme = Theme.of(context);

//     return ValueListenableBuilder<int>(
//       valueListenable: NavigationService.bottomIndex,
//       builder: (context, index, _) {
//         return Scaffold(
//           body: IndexedStack(
//             index: index,
//             children: _screens,
//           ),
          
//           /// 🟢 NEW: CENTRAL ADD BUTTON
//           /// This puts the button on top of all your tabs!
//           floatingActionButton: FloatingActionButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const TransactionListScreen()),
//               );
//             },
//             backgroundColor: Colors.black87, // Matches your premium dark theme
//             elevation: 4,
//             shape: const CircleBorder(),
//             child: const Icon(Icons.add, color: Colors.white, size: 28),
//           ),
//           // Optional: This docks the button neatly in the center of the nav bar
//           floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

//           bottomNavigationBar: Container(
//             decoration: BoxDecoration(
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: BottomNavigationBar(
//               currentIndex: index,
//               onTap: (i) => NavigationService.bottomIndex.value = i,
//               backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
              
//               /// Changed to black87 to match the new clean UI style
//               selectedItemColor: Colors.black87, 
//               unselectedItemColor: theme.brightness == Brightness.light
//                   ? Colors.black54
//                   : Colors.grey.shade400,
//               type: BottomNavigationBarType.fixed,
//               elevation: 0, 
//               selectedFontSize: 12,
//               unselectedFontSize: 12,
//               items: const [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.home_outlined),
//                   activeIcon: Icon(Icons.home_rounded),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.pie_chart_outline_rounded),
//                   activeIcon: Icon(Icons.pie_chart_rounded),
//                   label: 'Analytics',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.history_rounded),
//                   activeIcon: Icon(Icons.manage_search_rounded),
//                   label: 'History',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.person_outline_rounded),
//                   activeIcon: Icon(Icons.person_rounded),
//                   label: 'Profile',
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }