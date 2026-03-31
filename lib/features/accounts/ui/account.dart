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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AccountProvider>().loadAccounts();       // ✅ no userId
    });
  }

  Future<void> _handleSetPrimary(String accountId) async {
    await context.read<AccountProvider>().setPrimary(accountId); // ✅ no userId
  }

  // ================= POPUP =================

  void _showCreateAccountDialog() {
    final provider = context.read<AccountProvider>();

    final controller = TextEditingController();
    String selectedType = "CASH";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final colorScheme = Theme.of(context).colorScheme;

          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              "Create New Account",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: "Account Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedType = "CASH"),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedType == "CASH"
                                ? colorScheme.primary
                                : colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "CASH",
                              style: TextStyle(
                                  color: selectedType == "CASH"
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedType = "BANK"),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedType == "BANK"
                                ? AppColors.savingsPrimary        // blueAccent → savingsPrimary
                                : colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "BANK",
                              style: TextStyle(
                                  color: selectedType == "BANK"
                                      ? AppColors.textPrimary     // white on blue
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary),
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) return;

                  Navigator.pop(ctx);

                  await AccountService.createAccount(  // ✅ no userId param
                    name: name,
                    type: selectedType,
                  );

                  provider.loadAccounts();              // ✅ no userId
                },
                child: const Text("Create"),
              )
            ],
          );
        },
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<AccountProvider>();

    final cashAccounts = provider.cashAccounts;
    final bankAccounts = provider.bankAccounts;
    final defaultAccount = provider.defaultAccount;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: colorScheme.onSurface, size: 20),
          onPressed: () {
            NavigationService.bottomIndex.value = 0;
          },
        ),
        title: Text("My Accounts",
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      
      body: provider.isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (defaultAccount != null)
                    _buildPrimaryHeroCard(defaultAccount),
                  const SizedBox(height: 20),
                  _buildNetWorthSection(),
                  const SizedBox(height: 25),
                  _buildCreateAccountSection(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("CASH ACCOUNTS"),
                  ...cashAccounts.map((acc) => _buildDataCard(acc)),
                  const SizedBox(height: 25),
                  _buildSectionHeader("BANK ACCOUNTS"),
                  ...bankAccounts.map((acc) => _buildDataCard(acc)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildNetWorthSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<AccountProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: colorScheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("NET WORTH",
              style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("₹ ${provider.totalAll.toStringAsFixed(2)}",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Divider(height: 30, color: theme.dividerColor),
          Row(
            children: [
              _buildSimpleStat(
                  "Cash", provider.totalCash, Icons.wallet, AppColors.incomeAmount),        // green → incomeAmount
              const SizedBox(width: 30),
              _buildSimpleStat("Bank", provider.totalBank,
                  Icons.account_balance, AppColors.savingsPrimary),                        // blueAccent → savingsPrimary
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
      String label, double amount, IconData icon, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5), fontSize: 10))
          ]),
          Text("₹ ${amount.toStringAsFixed(0)}",
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPrimaryHeroCard(AccountModel acc) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardBg = colorScheme.inverseSurface;
    final onCard = colorScheme.onInverseSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${acc.type} | ${acc.name.toUpperCase()}",
                  style: TextStyle(color: onCard.withOpacity(0.6), fontSize: 10)),
              Icon(Icons.verified, color: AppColors.savingsPrimary, size: 20),  // blueAccent → savingsPrimary
            ],
          ),
          const SizedBox(height: 12),
          Text("₹ ${acc.availableBalance}",
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: onCard)),
          Text("Available Balance",
              style: TextStyle(color: onCard.withOpacity(0.5), fontSize: 12)),
          Divider(height: 40, color: onCard.withOpacity(0.1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardStat(
                  "Reserved", acc.reservedBalance, AppColors.warning),          // orangeAccent → warning
              _buildCardStat(
                  "Total Worth", acc.totalBalance, AppColors.incomeAmount),     // greenAccent → incomeAmount
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value, Color color) {
    final onCard = Theme.of(context).colorScheme.onInverseSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: onCard.withOpacity(0.4), fontSize: 10)),   // white38 → onCard.withOpacity(0.4)
        Text("₹ $value",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface.withOpacity(0.45))),               // blueGrey → onSurface muted
    );
  }

  Widget _buildCreateAccountSection() {
    return GestureDetector(
      onTap: _showCreateAccountDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.savingsPrimary.withValues(alpha: 0.05),            // blueAccent → savingsPrimary
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.savingsPrimary.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, color: AppColors.savingsPrimary, size: 24),
            const SizedBox(width: 10),
            Text("Create New Account",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.savingsPrimary,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(AccountModel acc) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,                                            // white → surface
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    acc.type == "CASH" ? Icons.wallet : Icons.account_balance,
                    color: colorScheme.onSurface,                             // black87 → onSurface
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(acc.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              acc.isDefault
                  ? Icon(Icons.verified, color: AppColors.savingsPrimary)    // blueAccent → savingsPrimary
                  : PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (val) {
                        if (val == 'primary') {
                          _handleSetPrimary(acc.id);
                        }

                        if (val == 'history') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionListScreen(
                                initialAccountName: acc.name,
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder: (ctx) => const [
                        PopupMenuItem(
                          value: 'primary',
                          child: Text("Set as Primary"),
                        ),
                        PopupMenuItem(
                          value: 'history',
                          child: Text("View History"),
                        ),
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniData("Available", acc.availableBalance, colorScheme.onSurface),  // black87 → onSurface
              _buildMiniData("Reserved", acc.reservedBalance, AppColors.warning),        // orange → warning
              _buildMiniData("Total", acc.totalBalance, colorScheme.onSurface),          // black87 → onSurface
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniData(String label, String value, Color color) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.5),               // grey → onSurface muted
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text("₹ $value",
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}