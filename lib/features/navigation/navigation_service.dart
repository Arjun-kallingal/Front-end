import 'package:flutter/material.dart';

// ✅ Use absolute package paths:
import 'package:front_end/features/home/ui/home_screen.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:front_end/features/analytics/ui/analytics_dashboardscreen.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';

/// 🌐 GLOBAL NAV SERVICE
/// Allows you to change tabs from anywhere (e.g., clicking "See All" on Home)
class NavigationService {
  static final ValueNotifier<int> bottomIndex = ValueNotifier(0);

  // Helper to change tab programmatically
  static void changeTab(int index) {
    bottomIndex.value = index;
  }
}

class MainNavigation extends StatelessWidget {
  final String? userId;

  const MainNavigation({super.key, this.userId});

  // 🎯 List of screens matching the BottomNavBar order
  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const HomeScreen(), // 🎯 Removed the UserId parameter!
      AnalyticsDashboardScreen(),
      TransactionListScreen(),
      ProfileSettingsScreen(),
    ];
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.bottomIndex,
      builder: (context, index, _) {
        return Scaffold(
          // 🧱 IndexedStack keeps the "Scroll State" alive when switching tabs
          body: IndexedStack(
            index: index,
            children: _screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => NavigationService.bottomIndex.value = i,
              backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
                  theme.scaffoldBackgroundColor,
              selectedItemColor:
                  const Color(0xFFB81414), // Matches your brand red
              unselectedItemColor: theme.brightness == Brightness.light
                  ? Colors.black54
                  : Colors.grey.shade400,
              type: BottomNavigationBarType.fixed,
              elevation: 0, // Handled by Container decoration for cleaner look
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_outline_rounded),
                  activeIcon: Icon(Icons.pie_chart_rounded),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  activeIcon: Icon(Icons.manage_search_rounded),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
