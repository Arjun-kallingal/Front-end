import 'package:flutter/material.dart';

import '../features/home/ui/home_screen.dart';
// 🎯 Ensure this filename matches your actual file in the folder
import '../features/transactions/ui/transactionlist_screen.dart'; 
import '../features/analytics/ui/analytics_dashboardscreen.dart';
import '../features/profile/ui/profile_screen.dart';

/// GLOBAL NAV SERVICE
class NavigationService {
  static final ValueNotifier<int> bottomIndex = ValueNotifier(0);
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

 @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const HomeScreen(), 
      AnalyticsDashboardScreen(),
      TransactionListScreen(), 
      ProfileSettingsScreen(),
    ];
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.bottomIndex,
      builder: (context, index, _) {
        return Scaffold(
          // IndexedStack preserves the state (scroll position/filters) of each tab
          body: IndexedStack(
            index: index,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => NavigationService.bottomIndex.value = i,
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor 
                ?? theme.scaffoldBackgroundColor,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: theme.brightness == Brightness.light
                ? Colors.black54
                : Colors.grey.shade400,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_outline),
                activeIcon: Icon(Icons.pie_chart),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history_toggle_off),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}