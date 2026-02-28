import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  final bool initialValue;

  const TwoFactorAuthScreen({
    super.key,
    required this.initialValue,
  });

  @override
  State<TwoFactorAuthScreen> createState() =>
      _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState
    extends State<TwoFactorAuthScreen> {

  late bool isEnabled;
  bool hasChanged = false;

  @override
  void initState() {
    super.initState();
    isEnabled = widget.initialValue;
  }

  void _handleToggle(bool value) {
    setState(() {
      isEnabled = value;
      hasChanged = true;
    });
  }

  void _handleSave() {
    Navigator.pop(context, isEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: Column(
        children: [

          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 30,
              left: 0,
              right: 0,
            ),
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
                    const Text(
                      "Two-Factor Authentication",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ================= CONTENT =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [

                  /// SWITCH CARD
                Container(
  padding: const EdgeInsets.symmetric(
      horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(16),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enable Two-Factor Authentication",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEnabled ? "Enabled" : "Disabled",
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      ///  Smaller Switch
      Transform.scale(
        scale: 0.80, //  reduce btn size 
        child: Switch(
          value: isEnabled,
          onChanged: _handleToggle,
          activeColor: AppColors.switchActive,
        ),
      ),
    ],
  ),
),

                  const SizedBox(height: 30),

                  /// INFO CARD
                  if (isEnabled)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Two-factor authentication adds an extra layer "
                        "of security to your account by requiring a second "
                        "verification step during login.",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),

      /// ================= SAVE BUTTON =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: hasChanged
                ? AppColors.primaryRedDark
                : Colors.grey,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: hasChanged ? _handleSave : null,
          child: const Text(
            "Save",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}