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

  // ─── FETCH DASHBOARD ─────────────────────────────────────────────

  Future<void> fetchDashboard({
    String? accountId,
    String? timeframe,
  }) async {
    final int requestId = ++_activeRequestId;

    isLoading = true;
    error = null;

    // ✅ Update state BEFORE API call
    if (accountId != null) currentAccountId = accountId;
    if (timeframe != null) currentTimeframe = timeframe;

    debugPrint("Fetching Analytics → "
        "Account: $currentAccountId | Timeframe: $currentTimeframe");

    notifyListeners();

    try {
      final result = await AnalyticsService.getDashboardData(
        accountId: currentAccountId,
        timeframe: currentTimeframe,
      );

      // ✅ Prevent stale response overwrite
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

  // ─── TIMEFRAME LABEL ─────────────────────────────────────────────

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

  // ─── CHANGE TIMEFRAME ────────────────────────────────────────────

  Future<void> changeTimeframe(String timeframe) async {
    const valid = ['Day', 'Week', 'Month', 'Year'];
    if (!valid.contains(timeframe)) return;

    // ✅ Prevent unnecessary reload
    if (timeframe == currentTimeframe) return;

    await fetchDashboard(timeframe: timeframe);
  }

  // ─── CHANGE ACCOUNT ──────────────────────────────────────────────

  Future<void> changeAccount(String accountId) async {
    if (accountId == currentAccountId) return;

    await fetchDashboard(accountId: accountId);
  }

  // ─── RETRY ───────────────────────────────────────────────────────

  Future<void> retry() async {
    await fetchDashboard();
  }
}