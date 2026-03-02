import 'package:flutter/material.dart';

import '../features/home/ui/home_screen.dart';
import '../features/transactions/ui/transactionlist_screen.dart';
import '../features/analytics/ui/analytics_dashboardscreen.dart';
import '../features/profile/ui/profile_screen.dart';

/// GLOBAL NAV SERVICE
class NavigationService {
  static final ValueNotifier<int> bottomIndex = ValueNotifier(0);
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    AnalyticsDashboardScreen(),
    HistoryScreen(),
    ProfileSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.bottomIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: _screens[index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => NavigationService.bottomIndex.value = i,

            // 🎯 THEME BASED COLORS
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor 
                ?? theme.scaffoldBackgroundColor,

            selectedItemColor: theme.colorScheme.primary,

           unselectedItemColor: theme.brightness == Brightness.light
    ? Colors.black
    : Colors.grey.shade400,
            type: BottomNavigationBarType.fixed,
            elevation: 0,

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}