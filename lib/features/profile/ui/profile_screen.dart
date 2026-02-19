import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/features/profile/ui/details/account_info.dart';
import 'package:front_end/features/profile/ui/security/change_password.dart';
import 'package:front_end/features/profile/ui/details/account_info_email.dart';
import 'package:front_end/features/profile/ui/security/two_factor_auth.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/features/profile/ui/support_legal/help_support.dart';
import 'package:front_end/features/profile/ui/support_legal/privacy_policy.dart';
import 'package:front_end/features/profile/ui/support_legal/terms_service.dart';
import 'package:front_end/features/profile/ui/support_legal/about.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool pushNotifications = true;
  bool paymentReminders = true;
  bool goalMilestones = true;
  bool biometricLogin = false;
  String? phoneNumber;
  bool twoFactorAuth = false;
  String email = "Syamjith@walletcare.com";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: color.background, // ✅ adaptive
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 20, bottom: 100, left: 16, right: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 14, 14),
                    Color.fromARGB(255, 184, 20, 20),
                  ],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Profile & Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRedDark.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Text(
                            "SJ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Syamjith",
                                style:
                                    textTheme.titleMedium!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style:
                                    textTheme.bodySmall!.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Edit",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ================= ACCOUNT INFORMATION =================
            _sectionWrapper(context, "Account Information", [
              _navigationTile(
                context,
                icon: Icons.email_outlined,
                title: "Email",
                subtitle: email,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AccountInfoEmailScreen(currentEmail: email),
                    ),
                  );
                  if (result != null) {
                    setState(() => email = result);
                  }
                },
              ),
              _navigationTile(
                context,
                icon: Icons.phone_outlined,
                title: "Phone",
                subtitle: phoneNumber ?? "Add phone number",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AccountInfoScreen(currentNumber: phoneNumber),
                    ),
                  );
                  if (result != null) {
                    setState(() => phoneNumber = result);
                  }
                },
              ),
            ]),

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
                  onChanged: (v) =>
                      setState(() => paymentReminders = v)),
              _switchTile(context,
                  icon: Icons.flag_outlined,
                  title: "Goal Milestones",
                  value: goalMilestones,
                  onChanged: (v) =>
                      setState(() => goalMilestones = v)),
            ]),

            const SizedBox(height: 24),

            /// ================= SECURITY =================
            _sectionWrapper(context, "Security", [
              _switchTile(context,
                  icon: Icons.fingerprint,
                  title: "Biometric Login",
                  value: biometricLogin,
                  onChanged: (v) =>
                      setState(() => biometricLogin = v)),
              _navigationTile(
                context,
                icon: Icons.security_outlined,
                title: "Two-Factor Authentication",
                subtitle:
                    twoFactorAuth ? "Enabled" : "Disabled",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TwoFactorAuthScreen(
                          initialValue: twoFactorAuth),
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
                        builder: (_) =>
                            const ChangePasswordScreen()),
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
                        builder: (_) =>
                            const HelpSupportScreen()),
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
                        builder: (_) =>
                            const PrivacyPolicyScreen()),
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
                        builder: (_) =>
                            const TermsOfServiceScreen()),
                  );
                },
              ),
              _navigationTile(
                context,
                icon: Icons.info_outline,
                title: "About WalletCare",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AboutWalletCareScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 30),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Sign Out"),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionWrapper(
      BuildContext context, String title, List<Widget> children) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .color)),
              const SizedBox(height: 16),
              ...children.map((e) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),
                    child: e,
                  )),
            ]),
      ),
    );
  }

  Widget _navigationTile(BuildContext context,
      {required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap}) {
    final color = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .color)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .color)),
                    ]
                  ]),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16,
                color:
                    Theme.of(context).dividerColor),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(BuildContext context,
      {required IconData icon,
      required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color)),
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
}
