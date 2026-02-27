import 'package:flutter/material.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/constants/app_colors.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  final String userId = "699e8fea9a6c85ac1f0970eb"; // TEMP USER

  bool _isBalanceVisible = true;
  bool _isLoading = true;

  String _selectedAccountId = "all";
  List<AccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  /// ================= LOAD ACCOUNTS =================
  Future<void> _loadAccounts({String type = ""}) async {
    setState(() => _isLoading = true);

    try {
      final accounts =
          await AccountService.getAccounts(userId, type: type);

      setState(() {
        _accounts = accounts;
        _selectedAccountId = "all";
      });
    } catch (e) {
      debugPrint("Error loading accounts: $e");

      setState(() {
        _accounts = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// ================= BALANCE CALCULATIONS =================
  double get availableBalance {
    if (_accounts.isEmpty) return 0;

    if (_selectedAccountId == "all") {
      return _accounts.fold(
          0, (sum, acc) => sum + acc.availableBalance);
    }

    final account = _accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => _accounts.first,
    );

    return account.availableBalance;
  }

  double get reservedBalance {
    if (_accounts.isEmpty) return 0;

    if (_selectedAccountId == "all") {
      return _accounts.fold(
          0, (sum, acc) => sum + acc.reservedBalance);
    }

    final account = _accounts.firstWhere(
      (a) => a.id == _selectedAccountId,
      orElse: () => _accounts.first,
    );

    return account.reservedBalance;
  }

  double get totalBalance =>
      availableBalance + reservedBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAccountSelector(),
              IconButton(
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// AVAILABLE
          const Text("Available Balance"),
          const SizedBox(height: 5),
          Text(
            _isBalanceVisible
                ? "₹ ${availableBalance.toStringAsFixed(2)}"
                : "••••••",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 15),

          /// RESERVED
          const Text("Reserved Amount"),
          const SizedBox(height: 5),
          Text(
            _isBalanceVisible
                ? "₹ ${reservedBalance.toStringAsFixed(2)}"
                : "••••••",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.savingsPrimary,
            ),
          ),

          const SizedBox(height: 15),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 15),

          /// TOTAL
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Balance"),
              Text(
                _isBalanceVisible
                    ? "₹ ${totalBalance.toStringAsFixed(2)}"
                    : "••••••",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ================= DROPDOWN =================
  Widget _buildAccountSelector() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == "create_account") {
          _showCreateAccountDialog();
          return;
        }

        if (value == "ALL") {
          await _loadAccounts();
          return;
        }

        if (value == "CASH" ||
            value == "BANK" ||
            value == "SAVINGS") {
          await _loadAccounts(type: value);
          return;
        }

        setState(() {
          _selectedAccountId = value;
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: "ALL", child: Text("All")),
        const PopupMenuItem(
            value: "CASH", child: Text("Cash")),
        const PopupMenuItem(
            value: "BANK", child: Text("Bank")),
        const PopupMenuItem(
            value: "SAVINGS",
            child: Text("Savings")),

        const PopupMenuDivider(),

        ..._accounts.map(
          (account) => PopupMenuItem(
            value: account.id,
            child: Text(account.name),
          ),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem(
          value: "create_account",
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text("Create Account"),
            ],
          ),
        ),
      ],
      child: Row(
        children: const [
          Text("Wallet Type"),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  /// ================= CREATE ACCOUNT =================
  void _showCreateAccountDialog() {
    final nameController = TextEditingController();
    String selectedType = "CASH";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: "Account Name"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(
                    value: "CASH",
                    child: Text("Cash")),
                DropdownMenuItem(
                    value: "BANK",
                    child: Text("Bank")),
                DropdownMenuItem(
                    value: "SAVINGS",
                    child: Text("Savings")),
              ],
              onChanged: (value) {
                selectedType = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await AccountService.createAccount(
                userId: userId,
                name: nameController.text,
                type: selectedType,
                initialBalance: 0,
              );

              Navigator.pop(context);
              _loadAccounts();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}