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
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text("Two-Factor Authentication"),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: AppColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                value: isEnabled,
                onChanged: _handleToggle,
                activeThumbColor: AppColors.switchActive,
                title: const Text(
                  "Enable Two-Factor Authentication",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  isEnabled ? "Enabled" : "Disabled",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
          ],
        ),
      ),
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
