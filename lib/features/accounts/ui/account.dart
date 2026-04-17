import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/account_model.dart';
import '../../../core/services/account_service.dart';
import '../../../core/providers/account_provider.dart';
import '../../../core/constants/app_colors.dart';

import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:front_end/features/transactions/ui/reserve_funds_screen.dart';

class AccountsOverviewScreen extends StatefulWidget {
  const AccountsOverviewScreen({super.key});

  @override
  State<AccountsOverviewScreen> createState() => _AccountsOverviewScreenState();
}

class _AccountsOverviewScreenState extends State<AccountsOverviewScreen>
    with SingleTickerProviderStateMixin {
  String _activeFilter = "ALL";

  // --- PREMIUM RADIAL FAB ANIMATION CONTROLLERS ---
  late AnimationController _fabController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    // Bouncy curve for movement and scaling
    _expandAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack);

    // Strict smooth curve for Opacity
    _fadeAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeOut);

    // Spin curve for the '+' icon
    _rotationAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccountProvider>().loadAccounts();
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  Future<void> _handleSetPrimary(String accountId) async {
    await context.read<AccountProvider>().setPrimary(accountId);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!context.mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(
                color: theme.colorScheme.surface, fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- PREMIUM DELETE FLOW ---
  Future<void> _handleDeleteAccount(AccountModel acc) async {
    final double totalBalance = double.tryParse(acc.totalBalance) ?? 0.0;

    if (totalBalance > 0) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (ctx) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              backgroundColor: colorScheme.surface,
              elevation: 24,
              shadowColor: Colors.black45,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: AppColors.warning, size: 40),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Funds Remaining",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "This account still holds ₹$totalBalance.\n\nPlease transfer or withdraw all your funds before closing it.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.5,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Got it",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            backgroundColor: colorScheme.surface,
            elevation: 24,
            shadowColor: Colors.black45,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 28),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        icon: Icon(Icons.close_rounded,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted),
                        style: IconButton.styleFrom(
                            backgroundColor: isDark
                                ? AppColors.darkBgSecondary
                                : AppColors.lightBgSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Delete Account?",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 12),
                  Text(
                    "Are you sure you want to permanently close '${acc.name}'? This action cannot be undone.",
                    style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.5,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              foregroundColor: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shadowColor:
                                  AppColors.error.withValues(alpha: 0.5),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("Delete",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        final result = await AccountService.deleteAccount(acc.id);

        if (!context.mounted) return;

        if (result['success'] == true) {
          _showSnackBar("Account successfully closed.");
          context.read<AccountProvider>().loadAccounts();
        } else {
          _showSnackBar(result['message'] ?? "Failed to delete account.",
              isError: true);
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar("Connection error. Could not delete account.",
              isError: true);
        }
      }
    }
  }

  // --- UPGRADED PREMIUM UI HELPER FOR TEXT FIELDS ---
  InputDecoration _getPremiumDecoration(
      ThemeData theme, ColorScheme colorScheme, Color surfaceAlt, Color textSec,
      {required String label, required IconData icon, String? prefixText}) {
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textSec, fontWeight: FontWeight.w500),
      floatingLabelStyle:
          TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w800),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : colorScheme.onSurface.withValues(alpha: 0.04),
      prefixIcon: Icon(icon,
          color: colorScheme.primary.withValues(alpha: 0.8), size: 22),
      prefixText: prefixText,
      prefixStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  // --- PREMIUM EDIT ACCOUNT BOTTOM SHEET ---
  void _showEditAccountBottomSheet(AccountModel acc) {
    final nameController = TextEditingController(text: acc.name);
    final minBalanceController = TextEditingController(text: acc.minBalance);
    String selectedType = acc.type;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;
          final textSec =
              isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
          final surfaceAlt = theme.inputDecorationTheme.fillColor ??
              (isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary);

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5)
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                            color: textSec.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    // --- PREMIUM HEADER ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.edit_note_rounded,
                              color: colorScheme.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Update Account",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.onSurface)),
                              const SizedBox(height: 2),
                              Text(
                                  "Modify your account details and preferences.",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: textSec,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    TextField(
                      controller: nameController,
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      decoration: _getPremiumDecoration(
                          theme, colorScheme, surfaceAlt, textSec,
                          label: "Account Name",
                          icon: Icons.account_balance_wallet_rounded),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 12, bottom: 24),
                      child: Text(
                          "This is how the account will appear in your lists and charts.",
                          style: TextStyle(
                              fontSize: 12,
                              color: textSec.withValues(alpha: 0.8))),
                    ),

                    TextField(
                      controller: minBalanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      decoration: _getPremiumDecoration(
                          theme, colorScheme, surfaceAlt, textSec,
                          label: "Low Balance Reminder",
                          icon: Icons.notifications_active_rounded, // REMINDER ICON
                          prefixText: "₹ "),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 12, bottom: 32),
                      child: Text(
                          "We'll visually notify you if funds drop below this limit.",
                          style: TextStyle(
                              fontSize: 12,
                              color: textSec.withValues(alpha: 0.8))),
                    ),

                    // --- ACCOUNT TYPE SECTION ---
                    Text("ACCOUNT TYPE",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: textSec)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTypeOption(
                            "CASH",
                            Icons.wallet_rounded,
                            selectedType == "CASH",
                            AppColors.incomeAmount,
                            isDark,
                            textSec,
                            () => setSheetState(() => selectedType = "CASH")),
                        const SizedBox(width: 16),
                        _buildTypeOption(
                            "BANK",
                            Icons.account_balance_rounded,
                            selectedType == "BANK",
                            AppColors.savingsPrimary,
                            isDark,
                            textSec,
                            () => setSheetState(() => selectedType = "BANK")),
                      ],
                    ),
                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shadowColor:
                              colorScheme.primary.withValues(alpha: 0.4),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final minBal = minBalanceController.text.trim();
                                if (name.isEmpty) return;

                                setSheetState(() => isProcessing = true);
                                try {
                                  await context
                                      .read<AccountProvider>()
                                      .updateAccount(acc.id,
                                          name: name,
                                          type: selectedType,
                                          minBalance:
                                              minBal.isEmpty ? "0" : minBal);
                                  if (context.mounted) Navigator.pop(ctx);
                                } catch (e) {
                                  if (context.mounted) {
                                    Navigator.pop(ctx);
                                    _showSnackBar("Failed to update account",
                                        isError: true);
                                  }
                                }
                              },
                        child: isProcessing
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2.5))
                            : const Text("Save Changes",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- PREMIUM CREATE ACCOUNT BOTTOM SHEET ---
  void _showCreateAccountBottomSheet({String initialType = "CASH"}) {
    final nameController = TextEditingController();
    final depositController = TextEditingController();
    final minBalanceController = TextEditingController();
    String selectedType = initialType;
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;
          final textSec =
              isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
          final surfaceAlt = theme.inputDecorationTheme.fillColor ??
              (isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary);

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 32,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5)
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                            color: textSec.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    // --- PREMIUM HEADER ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_card_rounded,
                              color: colorScheme.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("New Account",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: colorScheme.onSurface)),
                              const SizedBox(height: 2),
                              Text(
                                  "Add a wallet or bank to track your money.",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: textSec,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      decoration: _getPremiumDecoration(
                          theme, colorScheme, surfaceAlt, textSec,
                          label: "Account Name",
                          icon: Icons.account_balance_wallet_rounded),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 12, bottom: 20),
                      child: Text(
                          "e.g., Main Wallet, Salary Account, Travel Fund",
                          style: TextStyle(
                              fontSize: 12,
                              color: textSec.withValues(alpha: 0.8))),
                    ),

                    TextField(
                      controller: depositController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      decoration: _getPremiumDecoration(
                          theme, colorScheme, surfaceAlt, textSec,
                          label: "Opening Balance",
                          icon: Icons.payments_rounded,
                          prefixText: "₹ "),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 12, bottom: 20),
                      child: Text(
                          "The current amount of money already in this account.",
                          style: TextStyle(
                              fontSize: 12,
                              color: textSec.withValues(alpha: 0.8))),
                    ),

                    TextField(
                      controller: minBalanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      decoration: _getPremiumDecoration(
                          theme, colorScheme, surfaceAlt, textSec,
                          label: "Low Balance Reminder",
                          icon: Icons.notifications_active_rounded, // REMINDER ICON
                          prefixText: "₹ "),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, left: 12, bottom: 32),
                      child: Text(
                          "We'll visually notify you if funds drop below this limit.",
                          style: TextStyle(
                              fontSize: 12,
                              color: textSec.withValues(alpha: 0.8))),
                    ),

                    // --- ACCOUNT TYPE SECTION ---
                    Text("ACCOUNT TYPE",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: textSec)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTypeOption(
                            "CASH",
                            Icons.wallet_rounded,
                            selectedType == "CASH",
                            AppColors.incomeAmount,
                            isDark,
                            textSec,
                            () => setSheetState(() => selectedType = "CASH")),
                        const SizedBox(width: 16),
                        _buildTypeOption(
                            "BANK",
                            Icons.account_balance_rounded,
                            selectedType == "BANK",
                            AppColors.savingsPrimary,
                            isDark,
                            textSec,
                            () => setSheetState(() => selectedType = "BANK")),
                      ],
                    ),
                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shadowColor:
                              colorScheme.primary.withValues(alpha: 0.4),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final deposit = depositController.text.trim();
                                final minBal = minBalanceController.text.trim();
                                if (name.isEmpty) return;

                                setSheetState(() => isProcessing = true);

                                try {
                                  await AccountService.createAccount(
                                      name: name,
                                      type: selectedType,
                                      initialDeposit:
                                          deposit.isEmpty ? "0" : deposit,
                                      minBalance:
                                          minBal.isEmpty ? "0" : minBal);
                                  if (!context.mounted) return;

                                  context
                                      .read<AccountProvider>()
                                      .loadAccounts();
                                  Navigator.pop(ctx);
                                } catch (e) {
                                  setSheetState(() => isProcessing = false);
                                  if (context.mounted) {
                                    _showSnackBar("Failed to create account",
                                        isError: true);
                                  }
                                }
                              },
                        child: isProcessing
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2.5))
                            : const Text("Create Account",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- SMART RESERVE MANAGER ---
  void _handleManageReservesFabAction() {
    _toggleFab();

    final provider = context.read<AccountProvider>();
    final allAccounts = [...provider.cashAccounts, ...provider.bankAccounts];

    if (allAccounts.isEmpty) {
      _showSnackBar("You don't have any accounts yet.", isError: true);
      return;
    }

    if (allAccounts.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReserveFundsScreen(
            accountId: allAccounts.first.id,
            accountName: allAccounts.first.name,
          ),
        ),
      );
    } else {
      _showAccountSelectionSheet(allAccounts);
    }
  }

  void _showAccountSelectionSheet(List<AccountModel> accounts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final textSec =
            isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              24,
              20,
              MediaQuery.of(ctx).padding.bottom + 32,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                          color: textSec.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Select Account",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Which account's reserves do you want to manage?",
                    style: TextStyle(
                        fontSize: 14,
                        color: textSec,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  ...accounts.map((acc) {
                    final baseColor = acc.type == "CASH"
                        ? AppColors.incomeAmount
                        : AppColors.savingsPrimary;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                              color: baseColor.withValues(alpha: 0.2),
                              width: 1.5),
                        ),
                        tileColor: baseColor.withValues(alpha: 0.05),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: baseColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                              acc.type == 'CASH'
                                  ? Icons.wallet_rounded
                                  : Icons.account_balance_rounded,
                              color: baseColor,
                              size: 20),
                        ),
                        title: Text(
                          acc.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Available: ₹${acc.availableBalance}",
                            style: TextStyle(
                                color: textSec,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        trailing: Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: textSec),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReserveFundsScreen(
                                accountId: acc.id,
                                accountName: acc.name,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- UPGRADED TYPE SELECTOR (CASH / BANK) ---
  Widget _buildTypeOption(String label, IconData icon, bool isSel, Color col,
      bool isDark, Color txt, VoidCallback onTap) {
    final unselectedBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSel ? col.withValues(alpha: 0.15) : unselectedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSel ? col : Colors.transparent, width: isSel ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSel ? col : txt.withValues(alpha: 0.7), size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: isSel ? col : txt,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  // --- REDESIGNED GLASSY RADIAL FAB ICON ---
  Widget _buildIconFabOption({
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        verticalOffset: 30,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                // REFINED: Reduced alpha for more transparency
                color: bgColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  // Subtle border tinted with the icon color
                  color: bgColor.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              // REFINED: Increased icon size from 24 to 28 so it stands out more
              child: Icon(icon, color: bgColor, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text("My Assets",
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface, size: 20),
          onPressed: () => NavigationService.bottomIndex.value = 0,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: provider.isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary))
                : RefreshIndicator(
                    onRefresh: () async => provider.loadAccounts(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.only(bottom: 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPremiumNetWorthCard(provider, isDark),
                          _buildActionHub(colorScheme, isDark),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_activeFilter == "ALL" ||
                                    _activeFilter == "CASH") ...[
                                  _buildSectionHeader("CASH WALLETS", isDark),
                                  ...provider.cashAccounts.map((acc) =>
                                      _buildSleekDataCard(
                                          acc, theme, colorScheme, isDark)),
                                  const SizedBox(height: 20),
                                ],
                                if (_activeFilter == "ALL" ||
                                    _activeFilter == "BANK") ...[
                                  _buildSectionHeader("BANK ACCOUNTS", isDark),
                                  ...provider.bankAccounts.map((acc) =>
                                      _buildSleekDataCard(
                                          acc, theme, colorScheme, isDark)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_isFabOpen,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 8 * _fadeAnimation.value,
                        sigmaY: 8 * _fadeAnimation.value),
                    child: GestureDetector(
                      onTap: _toggleFab,
                      child: Container(
                        color: Colors.black.withValues(
                            alpha:
                                (0.5 * _fadeAnimation.value).clamp(0.0, 1.0)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. RADIAL OPTION 2: Manage Reserves
          AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Positioned(
                right: 22 + (65 * _expandAnimation.value),
                bottom: 26 + (75 * _expandAnimation.value),
                child: IgnorePointer(
                  ignoring: !_isFabOpen,
                  child: Transform.scale(
                    scale: _expandAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: _buildIconFabOption(
                        icon: Icons.lock_clock_rounded,
                        bgColor: AppColors.warning,
                        tooltip: "Manage Reserves",
                        onTap: _handleManageReservesFabAction,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 4. RADIAL OPTION 1: Add Account
          AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Positioned(
                right: 22,
                bottom: 26 + (95 * _expandAnimation.value),
                child: IgnorePointer(
                  ignoring: !_isFabOpen,
                  child: Transform.scale(
                    scale: _expandAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: _buildIconFabOption(
                        icon: Icons.add_card_rounded,
                        bgColor: AppColors.incomeAmount,
                        tooltip: "Add Account",
                        onTap: () {
                          _toggleFab();
                          _showCreateAccountBottomSheet();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 5. MAIN FAB TRIGGER (Reverted to solid style)
          Positioned(
            right: 20,
            bottom: 24,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 3.14159 * 2,
                  child: FloatingActionButton(
                    onPressed: _toggleFab,
                    backgroundColor: isDark ? const Color(0xFF2A2D3E) : colorScheme.primary,
                    foregroundColor: isDark ? Colors.white : colorScheme.onPrimary,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.add_rounded, size: 30),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHub(ColorScheme colorScheme, bool isDark) {
    const double uniformHeight = 42.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Expanded(
              child: _buildFilterChip("ALL", Icons.apps_rounded, colorScheme,
                  isDark, uniformHeight)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildFilterChip("CASH", Icons.wallet_rounded, colorScheme,
                  isDark, uniformHeight)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildFilterChip("BANK", Icons.account_balance_rounded,
                  colorScheme, isDark, uniformHeight)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, ColorScheme colorScheme,
      bool isDark, double height) {
    bool isSel = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSel
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel
                ? colorScheme.primary
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 14,
                color: isSel
                    ? colorScheme.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: isSel
                          ? colorScheme.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleekDataCard(
      AccountModel acc, ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final textSec =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final baseColor =
        acc.type == "CASH" ? AppColors.incomeAmount : AppColors.savingsPrimary;

    final double minBalDouble = double.tryParse(acc.minBalance) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? baseColor.withValues(alpha: 0.06) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? baseColor.withValues(alpha: 0.15)
                : baseColor.withValues(alpha: 0.1),
            width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(
                    acc.type == "CASH"
                        ? Icons.wallet_rounded
                        : Icons.account_balance_rounded,
                    color: baseColor,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                          child: Text(acc.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      if (acc.isDefault) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded, color: baseColor, size: 16)
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Text("Available: ₹${acc.availableBalance}",
                        style: TextStyle(
                            fontSize: 13,
                            color: textSec,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (minBalDouble > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_active_rounded,
                          size: 12, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text("₹${acc.minBalance}",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz_rounded, color: textSec, size: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'primary') _handleSetPrimary(acc.id);
                  if (val == 'history') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TransactionListScreen(accountId: acc.id)));
                  }
                  if (val == 'edit') _showEditAccountBottomSheet(acc);
                  if (val == 'delete') _handleDeleteAccount(acc);
                },
                itemBuilder: (ctx) => [
                  if (!acc.isDefault)
                    const PopupMenuItem(
                        value: 'primary',
                        child: Text("Set as Primary Account",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500))),
                  const PopupMenuItem(
                      value: 'history',
                      child: Text("View Transaction History",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))),
                  const PopupMenuItem(
                      value: 'edit',
                      child: Text("Edit Account",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500))),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text("Delete Account",
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w700))),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
                height: 1,
                color: isDark
                    ? baseColor.withValues(alpha: 0.15)
                    : baseColor.withValues(alpha: 0.1)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniData(
                  "Reserved", acc.reservedBalance, AppColors.warning),
              _buildMiniData(
                  "Total Worth", acc.totalBalance, colorScheme.onSurface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumNetWorthCard(AccountProvider provider, bool isDark) {
    final Color gradStart =
        isDark ? AppColors.accountsCardBg : const Color(0xFF1E293B);
    final Color gradEnd =
        isDark ? AppColors.darkBgSecondary : const Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [gradStart, gradEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TOTAL NET WORTH",
              style: TextStyle(
                  color: AppColors.darkTextPrimary.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text("₹${provider.totalAll.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkTextPrimary,
                  letterSpacing: -1.0)),
          const SizedBox(height: 24),
          Row(children: [
            _buildGlassStatCard(
                "Cash", provider.totalCash, AppColors.incomeAmount),
            const SizedBox(width: 12),
            _buildGlassStatCard(
                "Bank", provider.totalBank, AppColors.savingsPrimary),
          ]),
        ],
      ),
    );
  }

  Widget _buildGlassStatCard(String label, double amount, Color accCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkTextPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.darkTextPrimary.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: accCol, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: AppColors.darkTextPrimary.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            Text("₹${amount.toStringAsFixed(0)}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)),
    );
  }

  Widget _buildMiniData(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: color.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text("₹ $value",
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}