import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/features/analytics/ui/analytics_dashboardscreen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      themeMode: themeMode,

      
      home: const AnalyticsDashboardScreen(),
    );
  }
}