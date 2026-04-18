import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: "Clear All Notifications?",
        message: "This will permanently delete all your notifications.",
        onConfirm: () => context.read<NotificationProvider>().clearAllHistory(),
      ),
    );
  }

  void _confirmDeleteSingle(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: "Remove Notification?",
        message: "Are you sure you want to delete this notification?",
        onConfirm: () =>
            context.read<NotificationProvider>().removeNotification(id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final notifications = context.watch<NotificationProvider>().notifications;
    final isLoading = context.watch<NotificationProvider>().isLoading;
    final unreadCount = notifications.where((n) => n["isRead"] == false).length;

    final textSec = isDark ? const Color(0xFF8B90A7) : const Color(0xFF9098B1);
    // final surfaceAlt =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;
    final cardBg = isDark ? const Color(0xFF1E2235) : Colors.white;
    final scaffoldBg =
        isDark ? const Color(0xFF141728) : const Color(0xFFF4F6FB);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notifications",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            if (unreadCount > 0)
              Text(
                "$unreadCount unread",
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () =>
                  context.read<NotificationProvider>().markAllAsRead(),
              icon: Icon(Icons.done_all_rounded,
                  size: 16, color: colorScheme.secondary),
              label: Text(
                "Mark all read",
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined,
                  size: 22, color: Colors.redAccent.withOpacity(0.8)),
              onPressed: () => _confirmDeleteAll(context),
              tooltip: "Clear all",
            ),
          ],
          const SizedBox(width: 4),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.secondary))
          : notifications.isEmpty
              ? _buildEmptyState(colorScheme, textSec)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _NotificationTile(
                      notif: notif,
                      colorScheme: colorScheme,
                      cardBg: cardBg,
                      textSec: textSec,
                      isDark: isDark,
                      onTap: () {
                        if (notif["isRead"] == false) {
                          context
                              .read<NotificationProvider>()
                              .markSingleAsRead(notif["_id"]);
                        }
                      },
                      onDelete: () =>
                          _confirmDeleteSingle(context, notif["_id"]),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, Color textSec) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: textSec.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 44,
              color: textSec.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "All caught up!",
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "No new notifications to show",
            style: TextStyle(color: textSec, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable Notification Tile
// ─────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  final ColorScheme colorScheme;
  final Color cardBg;
  final Color textSec;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notif,
    required this.colorScheme,
    required this.cardBg,
    required this.textSec,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRead = notif["isRead"] ?? false;

    IconData iconData = Icons.notifications_active_rounded;
    Color iconColor = colorScheme.secondary;

    if (notif["category"] == "WALLET_TRANSACTION") {
      iconColor = AppColors.expenseAmount;
      iconData = Icons.account_balance_wallet_rounded;
    } else if (notif["category"] == "AUTH_SECURITY") {
      iconColor = Colors.orange;
      iconData = Icons.security_rounded;
    }

    String dateStr = "";
    if (notif["createdAt"] is Map && notif["createdAt"].containsKey("\$date")) {
      dateStr = notif["createdAt"]["\$date"];
    } else {
      dateStr = notif["createdAt"] ?? "";
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isRead ? cardBg.withOpacity(isDark ? 0.45 : 0.7) : cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : colorScheme.secondary.withOpacity(0.13),
            width: 1,
          ),
          boxShadow: isRead
              ? []
              : [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 21),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif["title"] ?? "",
                          style: TextStyle(
                            color: isRead ? textSec : colorScheme.primary,
                            fontSize: 14.5,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notif["message"] ?? "",
                    style: TextStyle(
                      color: textSec.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(dateStr),
                    style: TextStyle(
                      color: textSec.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // ✕ Delete button
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: textSec.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: textSec.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    if (iso.isEmpty) return "";
    try {
      final date = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 7) return "${diff.inDays}d ago";
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return "";
    }
  }
}

// ─────────────────────────────────────────────
// Reusable Confirm Dialog
// ─────────────────────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2235) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.primary.withOpacity(0.55),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.primary.withOpacity(0.07),
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Remove",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
