import 'package:flutter/material.dart';
import '../features/home/ui/home_screen.dart';
import '../features/transactions/ui/transactionlist_screen.dart';
import '../features/analytics/ui/analytics_dashboardscreen.dart';
import '../features/accounts/ui/account.dart';

/// GLOBAL NAVIGATION SERVICE
class NavigationService {

  /// Bottom Navigation Controller
  static final ValueNotifier<int> bottomIndex = ValueNotifier(0);

  /// Navigate to Home
  static void goToHome() {
    bottomIndex.value = 0;
  }

  /// Navigate to Analytics
  static void goToAnalytics() {
    bottomIndex.value = 1;
  }

  /// Navigate to Account
  static void goToAccount() {
    bottomIndex.value = 2;
  }

  /// Navigate to Transaction History
  static void goToHistory() {
    bottomIndex.value = 3;
  }
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  /// App Screens
  static const List<Widget> _screens = [
    HomeScreen(),
    AnalyticsDashboardScreen(),
    AccountScreen(),
    TransactionListScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.bottomIndex,
      builder: (context, index, _) {

        return Scaffold(

          /// Keeps each screen state alive
          body: IndexedStack(
            index: index,
            children: _screens,
          ),

          /// Bottom Navigation
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,

            onTap: (i) {
              NavigationService.bottomIndex.value = i;
            },

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
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                activeIcon: Icon(Icons.history_toggle_off),
                label: 'History',
              ),

            ],
          ),
        );
      },
    );
  }
}