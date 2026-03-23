import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  bool pushNotifications = true;
  bool paymentReminders = true;
  bool goalMilestones = true;
  bool weeklyReports = false;
  bool promotions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Column(
          children: [

            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12),
              color: isDark ? Colors.black : Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [

                    _notificationTile(
                      "Push Notifications",
                      "Receive general app notifications",
                      pushNotifications,
                      (v) =>
                          setState(() => pushNotifications = v),
                      isDark,
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Payment Reminders",
                      "Get reminders for upcoming payments",
                      paymentReminders,
                      (v) =>
                          setState(() => paymentReminders = v),
                      isDark,
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Goal Milestones",
                      "Notifications when you reach savings goals",
                      goalMilestones,
                      (v) =>
                          setState(() => goalMilestones = v),
                      isDark,
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Weekly Reports",
                      "Receive weekly spending summaries",
                      weeklyReports,
                      (v) =>
                          setState(() => weeklyReports = v),
                      isDark,
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Promotions & Offers",
                      "Get notified about special offers",
                      promotions,
                      (v) =>
                          setState(() => promotions = v),
                      isDark,
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= TILE =================
  Widget _notificationTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white24
              : Colors.black12,
        ),
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor:
                  isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}