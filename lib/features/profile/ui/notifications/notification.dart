import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  bool pushNotifications = true;
  bool paymentReminders = true;
  bool goalMilestones = true;
  bool weeklyReports = false;
  bool promotions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,

      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 14, 14),
                    Color.fromARGB(255, 184, 20, 20),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [

                    _notificationTile(
                      "Push Notifications",
                      "Receive general app notifications",
                      pushNotifications,
                      (v) => setState(() => pushNotifications = v),
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Payment Reminders",
                      "Get reminders for upcoming payments",
                      paymentReminders,
                      (v) => setState(() => paymentReminders = v),
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Goal Milestones",
                      "Notifications when you reach savings goals",
                      goalMilestones,
                      (v) => setState(() => goalMilestones = v),
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Weekly Reports",
                      "Receive weekly spending summaries",
                      weeklyReports,
                      (v) => setState(() => weeklyReports = v),
                    ),

                    const SizedBox(height: 15),

                    _notificationTile(
                      "Promotions & Offers",
                      "Get notified about special offers",
                      promotions,
                      (v) => setState(() => promotions = v),
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

  /// Notification Tile Widget
  Widget _notificationTile(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
              activeColor: AppColors.switchActive,
            ),
          ),
        ],
      ),
    );
  }
}