import 'package:flutter/material.dart';

import '../features/home/ui/home_screen.dart';
import '../features/transactions/ui/transactionlist_screen.dart';
import '../features/analytics/ui/analytics_dashboardscreen.dart';
import '../features/accounts/ui/account.dart';

class NavigationService {
  static final ValueNotifier<int> bottomIndex = ValueNotifier(0);
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  late PageController _pageController;

  final List<Widget> _screens = [
    HomeScreen(),
    AnalyticsDashboardScreen(),
    AccountsOverviewScreen(),
    TransactionListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: NavigationService.bottomIndex,
      builder: (context, index, _) {

        return Scaffold(

          body: PageView(
            controller: _pageController,

            onPageChanged: (i) {
              NavigationService.bottomIndex.value = i;
            },

            children: _screens,
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,

            onTap: (i) {
              NavigationService.bottomIndex.value = i;

              _pageController.animateToPage(
                i,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },

            backgroundColor: theme.scaffoldBackgroundColor,
            selectedItemColor: theme.colorScheme.primary,
            unselectedItemColor: Colors.grey,

            type: BottomNavigationBarType.fixed,

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
                label: 'Accounts',
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