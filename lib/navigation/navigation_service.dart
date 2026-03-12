import 'package:flutter/material.dart';
import '../features/home/ui/home_screen.dart';
import '../features/analytics/ui/analytics_dashboardscreen.dart';
import '../features/accounts/ui/account.dart';
import '../features/goals/ui/financial_goals_screen.dart';

/// GLOBAL NAV SERVICE
class NavigationService {
  static final ValueNotifier<int> bottomIndex = ValueNotifier(0);

  static String? selectedAccountName;
}

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    FinancialGoalsScreen(),
    AccountsOverviewScreen(),
    AnalyticsDashboardScreen(),
  ];

  void _handleSwipe(DragEndDetails details) {
    int index = NavigationService.bottomIndex.value;

    /// Swipe Left → Next Page
    if (details.primaryVelocity! < 0) {
      if (index < _screens.length - 1) {
        NavigationService.bottomIndex.value = index + 1;
      }
    }

    /// Swipe Right → Previous Page
    if (details.primaryVelocity! > 0) {
      if (index > 0) {
        NavigationService.bottomIndex.value = index - 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.bottomIndex,
      builder: (context, index, _) {
        return Scaffold(

          /// SWIPE DETECTOR
          body: GestureDetector(
            onHorizontalDragEnd: _handleSwipe,

            child: IndexedStack(
              index: index,
              children: _screens,
            ),
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
                icon: Icon(Icons.ads_click),
                activeIcon: Icon(Icons.ads_click),
                label: 'Goals',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_outlined),
                activeIcon: Icon(Icons.account_balance),
                label: 'Accounts',
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: 'Analytics',
              ),
            ],
          ),
        );
      },
    );
  }
}