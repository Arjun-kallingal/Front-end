import 'package:flutter/material.dart';
import 'package:front_end/features/profile/ui/security/change_password.dart';
import 'package:front_end/features/profile/ui/security/two_factor_auth.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/features/profile/ui/support_legal/help_support.dart';
import 'package:front_end/features/profile/ui/support_legal/privacy_policy.dart';
import 'package:front_end/features/profile/ui/support_legal/terms_service.dart';
import 'package:front_end/features/profile/ui/about/about.dart';
import 'package:front_end/features/profile/ui/share/export_data.dart';
import 'package:front_end/features/auth/ui/login_screen.dart';
import 'package:front_end/features/profile/ui/premium/premium_feature.dart';
import 'package:front_end/features/profile/ui/edit-profile/profile_edit.dart';
import 'package:front_end/features/profile/ui/support_legal/feedback.dart';
import 'package:front_end/navigation/navigation_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool pushNotifications = true;
  bool paymentReminders = true;
  bool goalMilestones = true;
  bool twoFactorAuth = false;

  String userName = "Syamjith";
  String email = "syamjith@email.com";
  String? profileImage;
  String mobileNumber = "";

  ///  SAFE INITIALS METHOD
  String getInitials(String name) {
    if (name.trim().isEmpty) return "U";

    final parts = name.trim().split(" ");

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
  backgroundColor: color.background,
  body: SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 30, bottom: 15),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 98, 14, 14),
                  Color.fromARGB(255, 184, 20, 20),
                ],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        NavigationService.bottomIndex.value = 0;
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Profile & Settings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(210, 99, 10, 10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ================= PROFILE INFO =================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Avatar
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white24,
                              backgroundImage: (profileImage != null &&
                                      profileImage!.isNotEmpty &&
                                      profileImage!.startsWith("http"))
                                  ? NetworkImage(profileImage!)
                                  : null,
                              child: (profileImage == null ||
                                      profileImage!.isEmpty ||
                                      !profileImage!.startsWith("http"))
                                  ? Text(
                                      getInitials(userName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),

                            const SizedBox(width: 16),

                            /// Text section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// NAME + EDIT
                                  Row(
                                    children: [
                                      /// Name safe
                                      Expanded(
                                        child: Text(
                                          userName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      TextButton(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditProfileScreen(
                                                currentName: userName,
                                                currentMobile: mobileNumber,
                                                currentImage: profileImage,
                                              ),
                                            ),
                                          );

                                          if (result != null && mounted) {
                                            setState(() {
                                              userName =
                                                  result["name"] ?? userName;
                                              mobileNumber = result["mobile"] ??
                                                  mobileNumber;
                                              profileImage = result["image"] ??
                                                  profileImage;
                                            });
                                          }
                                        },
                                        child: const Text(
                                          "Edit",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  /// EMAIL safe
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Divider
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 148, 77, 77),
                        ),

                        const SizedBox(height: 12),

                        /// ================= PREMIUM BUTTON =================
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PremiumUpgradeScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFF59E0B),
                                  Color(0xFFF97316),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.workspace_premium,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "Upgrade to Premium",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// ================= SCROLLABLE CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  /// ================= APPEARANCE =================
                  _sectionWrapper(context, "Appearance", [
                    _switchTile(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: "Dark Mode",
                      value: context.watch<ThemeProvider>().isDark,
                      onChanged: (value) {
                        context.read<ThemeProvider>().toggleTheme(value);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  /// ================= NOTIFICATIONS =================
                  _sectionWrapper(context, "Notifications", [
                    _switchTile(context,
                        icon: Icons.notifications_outlined,
                        title: "Push Notifications",
                        value: pushNotifications,
                        onChanged: (v) =>
                            setState(() => pushNotifications = v)),
                    _switchTile(context,
                        icon: Icons.payment_outlined,
                        title: "Payment Reminders",
                        value: paymentReminders,
                        onChanged: (v) => setState(() => paymentReminders = v)),
                    _switchTile(context,
                        icon: Icons.flag_outlined,
                        title: "Goal Milestones",
                        value: goalMilestones,
                        onChanged: (v) => setState(() => goalMilestones = v)),
                  ]),

                  const SizedBox(height: 24),

                  /// ================= SECURITY =================
                  _sectionWrapper(context, "Security", [
                    _navigationTile(
                      context,
                      icon: Icons.security_outlined,
                      title: "Two-Factor Authentication",
                      subtitle: twoFactorAuth ? "Enabled" : "Disabled",
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TwoFactorAuthScreen(
                              initialValue: twoFactorAuth,
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() => twoFactorAuth = result);
                        }
                      },
                    ),
                    _navigationTile(
                      context,
                      icon: Icons.lock_outline,
                      title: "Change Password",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  /// ================= DATA =================
                  _sectionWrapper(context, "Data Management", [
                    _navigationTile(
                      context,
                      icon: Icons.download_outlined,
                      title: "Export Data",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExportDataScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  /// ================= SUPPORT =================
                  _sectionWrapper(context, "Support & Legal", [
                    _navigationTile(
                      context,
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    _navigationTile(
                      context,
                      icon: Icons.feedback_outlined,
                      title: "Feedback & Rate Us",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackScreen(),
                          ),
                        );
                      },
                    ),
                    _navigationTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: "Privacy Policy",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                    ),
                    _navigationTile(
                      context,
                      icon: Icons.description_outlined,
                      title: "Terms of Service",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsOfServiceScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  /// ================= ABOUT =================
                  _sectionWrapper(context, "About", [
                    _navigationTile(
                      context,
                      icon: Icons.info_outline,
                      title: "About WalletCare",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutWalletCareScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Sign Out"),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _sectionWrapper(
      BuildContext context, String title, List<Widget> children) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium!.color)),
          const SizedBox(height: 16),
          ...children.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: e,
              )),
        ]),
      ),
    );
  }


    Widget _navigationTile(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  required VoidCallback onTap,
}) {
  final color = Theme.of(context).colorScheme;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          Icon(icon, color: color.primary),

          const SizedBox(width: 12),

          ///  prevents overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color,
                  ),
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .color,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          ///  keeps icon visible
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).dividerColor,
          ),
        ],
      ),
    ),
  );
}
  }

  Widget _switchTile(BuildContext context,
      {required IconData icon,
      required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge!.color)),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              activeColor: color.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

