import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/account_model.dart';
import '../../../core/services/account_service.dart';
import '../../../core/providers/account_provider.dart';
import '../../../core/constants/app_colors.dart';

import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';

class AccountsOverviewScreen extends StatefulWidget {
  const AccountsOverviewScreen({super.key});

  @override
  State<AccountsOverviewScreen> createState() => _AccountsOverviewScreenState();
}

class _AccountsOverviewScreenState extends State<AccountsOverviewScreen> {
  String _activeFilter = "ALL";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AccountProvider>().loadAccounts();
    });
  }

  Future<void> _handleSetPrimary(String accountId) async {
    await context.read<AccountProvider>().setPrimary(accountId);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: TextStyle(color: theme.colorScheme.surface)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleDeleteAccount(AccountModel acc) async {
    final double totalBalance = double.tryParse(acc.totalBalance) ?? 0.0;

    if (totalBalance > 0) {
      showDialog(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: colorScheme.surface,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.error, size: 36),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Funds Remaining",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "This account still holds ₹$totalBalance.\n\nPlease transfer or withdraw all your funds before closing it.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Okay",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: colorScheme.surface,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delete Account?",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: Icon(Icons.close_rounded,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "Are you sure you want to close '${acc.name}'?\nThis action cannot be undone.",
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.4,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkBgElevated
                          : AppColors.lightTextPrimary,
                      foregroundColor: AppColors.darkTextPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Delete Account",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      try {
        final result = await AccountService.deleteAccount(acc.id);

        if (result['success'] == true) {
          _showSnackBar("Account successfully closed.");
          context.read<AccountProvider>().loadAccounts();
        } else {
          _showSnackBar(result['message'] ?? "Failed to delete account.",
              isError: true);
        }
      } catch (e) {
        _showSnackBar("Connection error. Could not delete account.",
            isError: true);
      }
    }
  }

  void _showCreateAccountBottomSheet({String initialType = "CASH"}) {
    final provider = context.read<AccountProvider>();
    final controller = TextEditingController();
    String selectedType = initialType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;
          final textSec =
              isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
          final surfaceAlt = theme.inputDecorationTheme.fillColor ??
              (isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary);

          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textSec.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Create New Account",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                      color: surfaceAlt,
                      borderRadius: BorderRadius.circular(14)),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: "Account Name",
                      labelStyle: TextStyle(color: textSec),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildTypeOption(
                        "CASH",
                        Icons.wallet_rounded,
                        selectedType == "CASH",
                        AppColors.incomeAmount,
                        surfaceAlt,
                        textSec,
                        () => setSheetState(() => selectedType = "CASH")),
                    const SizedBox(width: 12),
                    _buildTypeOption(
                        "BANK",
                        Icons.account_balance_rounded,
                        selectedType == "BANK",
                        AppColors.savingsPrimary,
                        surfaceAlt,
                        textSec,
                        () => setSheetState(() => selectedType = "BANK")),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;

                      Navigator.pop(ctx);

                      await AccountService.createAccount(
                          name: name, type: selectedType);
                      provider.loadAccounts();
                    },
                    child: const Text("Create Account",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeOption(String label, IconData icon, bool isSel, Color col,
      Color bg, Color txt, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSel ? col.withOpacity(0.1) : bg,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: isSel ? col : Colors.transparent, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? col : txt, size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color: isSel ? col : txt,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
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
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              onRefresh: () async => provider.loadAccounts(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.only(bottom: 80),
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
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _showCreateAccountBottomSheet,
              child: Container(
                height: uniformHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.75)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: colorScheme.onPrimary, // ✅ FIX
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "Add",
                        style: TextStyle(
                          color: colorScheme.onPrimary, // ✅ FIX
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
          color:
              isSel ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSel
                  ? colorScheme.primary
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSel
                          ? colorScheme.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? baseColor.withOpacity(0.06) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? baseColor.withOpacity(0.15)
                : baseColor.withOpacity(0.1),
            width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(
                    acc.type == "CASH"
                        ? Icons.wallet_rounded
                        : Icons.account_balance_rounded,
                    color: baseColor,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                          child: Text(acc.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: colorScheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis)),
                      if (acc.isDefault) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.verified_rounded, color: baseColor, size: 16)
                      ],
                    ]),
                    Text("Available: ₹${acc.availableBalance}",
                        style: TextStyle(
                            fontSize: 12,
                            color: textSec,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz_rounded, color: textSec, size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onSelected: (val) {
                  if (val == 'primary') _handleSetPrimary(acc.id);
                  if (val == 'history') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TransactionListScreen(
                                initialAccountName: acc.name)));
                  }
                  if (val == 'delete') _handleDeleteAccount(acc);
                },
                itemBuilder: (ctx) => [
                  if (!acc.isDefault)
                    const PopupMenuItem(
                        value: 'primary',
                        child: Text("Set as Primary Account",
                            style: TextStyle(fontSize: 14))),
                  const PopupMenuItem(
                      value: 'history',
                      child: Text("View Transaction History",
                          style: TextStyle(fontSize: 14))),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text("Delete Account",
                          style: TextStyle(
                              color: AppColors.expenseAmount,
                              fontSize: 14,
                              fontWeight: FontWeight.w600))),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                height: 1,
                color: isDark
                    ? baseColor.withOpacity(0.15)
                    : baseColor.withOpacity(0.1)),
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
                  color: AppColors.darkTextPrimary.withOpacity(0.5),
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
          color: AppColors.darkTextPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.darkTextPrimary.withOpacity(0.15)),
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
                      color: AppColors.darkTextPrimary.withOpacity(0.8),
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
                color: color.withOpacity(0.6),
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
