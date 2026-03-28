import 'package:flutter/material.dart';
import '../data/analytics_model.dart';
import '../service/service.dart';

class AnalyticsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  String currentAccountId = "all";
  String currentTimeframe = "Month";

  AnalyticsModel? data;

  int _activeRequestId = 0;

  Future<void> fetchDashboard({String? accountId, String? timeframe}) async {
    final int requestId = ++_activeRequestId;

    isLoading = true;
    error = null;

    if (accountId != null) currentAccountId = accountId;
    if (timeframe != null) currentTimeframe = timeframe;

    notifyListeners();

    try {
      final result = await AnalyticsService.getDashboardData(
        accountId: currentAccountId,
        timeframe: currentTimeframe,
      );
      if (requestId == _activeRequestId) {
        data = result;
      }
    } catch (e) {
      if (requestId == _activeRequestId) {
        error = e.toString().replaceAll("Exception: ", "");
        debugPrint("AnalyticsProvider Error: $error");
      }
    } finally {
      if (requestId == _activeRequestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  String get timeframeLabel {
    switch (currentTimeframe) {
      case 'Day':
        return "Today";
      case 'Week':
        return "This Week";
      case 'Year':
        return "This Year";
      default:
        return "This Month";
    }
  }

  void changeTimeframe(String timeframe) {
    const valid = ['Day', 'Week', 'Month', 'Year'];
    if (!valid.contains(timeframe)) return;
    fetchDashboard(timeframe: timeframe);
  }

  void changeAccount(String accountId) => fetchDashboard(accountId: accountId);

  void retry() => fetchDashboard();
}
