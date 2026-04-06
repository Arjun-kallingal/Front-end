import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  NotificationProvider() {
    // Kick off socket init immediately when the provider is created (main.dart
    // MultiProvider creates it before any screen mounts).
    // Using Future.microtask so the constructor finishes before async work begins.
    Future.microtask(() => initializeSocketListeners());
  }

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((n) => n["isRead"] == false).length;

  // ── 🔴 WEB-SOCKET SYNC ──────────────────────────────────────────────────
  /// Awaiting connectAndListen ensures _socket is non-null before the callback
  /// is registered — this eliminates the race condition that caused missed events.
  Future<void> initializeSocketListeners() async {
    await SocketService.connectAndListen((data) {
      if (data != null) {
        addRealTimeNotification(data);
      }
    });
  }

  // 🔥 Handles the live injection and triggers the Red Dot instantly.
  // Uses JSON round-trip to safely flatten nested Map<dynamic,dynamic> and
  // ObjectId values that the socket_io_client sometimes delivers.
  void addRealTimeNotification(dynamic data) {
    try {
      debugPrint("🎯 DATA ARRIVED AT PHONE: $data");

      // JSON round-trip: handles Map<dynamic,dynamic>, ObjectId, and any
      // nested types that Map<String,dynamic>.from() would choke on.
      final String jsonStr = jsonEncode(data);
      final Map<String, dynamic> newNotif =
          Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);

      // Ensure isRead is present and set to false for unread-count accuracy
      newNotif.putIfAbsent('isRead', () => false);

      _notifications.insert(0, newNotif);
      notifyListeners();

      debugPrint(
          "✅ UI notified. Unread: $unreadCount, Total: ${notifications.length}");

      // Trigger Toastification
      final category = newNotif['category']?.toString() ?? '';
      final title = newNotif['title']?.toString() ?? 'New Notification';
      final message = newNotif['message']?.toString() ?? '';

      Color themeColor = Colors.blue;
      IconData iconData = Icons.notifications;

      if (category == 'INCOME') {
        themeColor = Colors.green;
        iconData = Icons.arrow_downward;
      } else if (category == 'EXPENSE') {
        themeColor = Colors.red;
        iconData = Icons.arrow_upward;
      } else if (category == 'WALLET_TRANSACTION') {
        themeColor = Colors.blue;
        iconData = Icons.account_balance_wallet;
      } else if (category == 'AUTH_SECURITY') {
        themeColor = Colors.orange;
        iconData = Icons.security;
      }

      toastification.show(
        type: ToastificationType.info,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        description: message.isNotEmpty ? Text(message) : null,
        autoCloseDuration: const Duration(seconds: 4),
        style: ToastificationStyle.flat,
        alignment: Alignment.topCenter,
        primaryColor: themeColor,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: themeColor),
        ),
      );
    } catch (e, st) {
      debugPrint("❌ Error adding live notification: $e\n$st");
    }
  }

  // ── 🔵 REST API FETCH ───────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    _isLoading = true;
    _notifications = await NotificationService.fetchNotifications();
    _isLoading = false;
    notifyListeners();
  }

  // ── 🟢 ACTION: MARK AS READ ─────────────────────────────────────────────
  Future<void> markSingleAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n["_id"] == id);

    if (index != -1 && _notifications[index]["isRead"] == false) {
      _notifications[index]["isRead"] = true;
      notifyListeners();

      try {
        await NotificationService.markAsRead(id);
      } catch (e) {
        debugPrint("Error syncing read status: $e");
      }
    }
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i]["isRead"] = true;
    }
    notifyListeners();
    await NotificationService.markAllAsRead();
  }

  // ── 🟠 ACTION: DELETE ───────────────────────────────────────────────────
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n["_id"] == id);
    notifyListeners();

    bool success = await NotificationService.deleteNotification(id);
    if (!success) {
      loadNotifications();
    }
  }

  Future<void> clearAllHistory() async {
    _notifications.clear();
    notifyListeners();
    await NotificationService.deleteAllNotifications();
  }
}
