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
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/features/profile/ui/notifications/notification.dart';
import 'package:front_end/core/services/auth_storage.dart';

// import 'package:front_end/core/constants/app_colors.dart';

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
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProfileProvider>().loadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final user = context.watch<UserProfileProvider>();
    final isLight = Theme.of(context).brightness == Brightness.light;

    String userName = user.name;
    String email = user.email;
    String mobileNumber = user.mobile;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : Colors.black,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isLight ? Colors.black : Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Profile & Settings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isLight ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= PROFILE CARD =================
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Builder(
                  builder: (context) {
                    final color = Theme.of(context).colorScheme;
                    final textTheme = Theme.of(context).textTheme;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.surface,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// PROFILE INFO
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    const Color.fromARGB(255, 98, 14, 14),
                                child: Text(
                                  getInitials(userName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              /// Name + Email
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// NAME + EDIT
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            userName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: textTheme.bodyLarge!.color,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    EditProfileScreen(
                                                  currentName: userName,
                                                  currentMobile: mobileNumber,
                                                ),
                                              ),
                                            );
                                            if (result != null) {
                                              context
                                                  .read<UserProfileProvider>()
                                                  .updateProfile(
                                                    newName: result["name"],
                                                    newMobile: result["mobile"],
                                                  );
                                            }
                                          },
                                          child: Text(
                                            "Edit",
                                            style: TextStyle(
                                              color: color.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    /// EMAIL
                                    Text(
                                      email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          Divider(
                            color: Theme.of(context).colorScheme.onBackground,
                            thickness: 0.6,
                            height: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                          const SizedBox(height: 12),

                          /// PREMIUM BUTTON

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
                    );
                  },
                ),
              ),

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
                const SizedBox(height: 8),
                _navigationTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: "Notification Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                ),
              ]),
              //  const SizedBox(height: 24),

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

              const SizedBox(height: 18),

              /// ================= DATA =================
              _sectionWrapper(context, "Data Management", [
                const SizedBox(height: 8),
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

              const SizedBox(height: 18),

              /// ================= SUPPORT =================
              _sectionWrapper(context, "Support & Legal", [
                const SizedBox(height: 8),
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

              const SizedBox(height: 18),

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    await AuthStorage.logout();

                    context.read<UserProfileProvider>().clearUser();

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
    );
  }

  Widget _sectionWrapper(
      BuildContext context, String title, List<Widget> children) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ),
          ...children.map((e) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 0,
                ),
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLight ? Colors.black : Colors.white;

    final color = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 25, top: 14, bottom: 14),
        decoration: BoxDecoration(
          color: color.background,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),

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
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall!.color,
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
  final isLight = Theme.of(context).brightness == Brightness.light;
  final iconColor = isLight ? Colors.black : Colors.white;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
    decoration: BoxDecoration(
      color: color.background,
      borderRadius: BorderRadius.circular(0),
    ),
    child: Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: 14.5,
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
