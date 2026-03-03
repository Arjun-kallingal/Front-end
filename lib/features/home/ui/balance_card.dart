import 'package:flutter/material.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/models/global_summary.dart';
import 'package:front_end/core/services/account_service.dart';

class BalanceCard extends StatefulWidget {
  final Function(String accountId)? onAccountSelected;

  const BalanceCard({super.key, this.onAccountSelected});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  final String userId = "699e8fea9a6c85ac1f0970eb";

  bool _isBalanceVisible = true;
  bool _isLoading = true;

  String _selectedAccountId = "all";
  String _activeCategory = "ALL";

  List<AccountModel> _accounts = [];
  GlobalSummary? _summary;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ================= LOAD DASHBOARD =================

  Future<void> _loadDashboard({String type = ""}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _activeCategory = type.isEmpty ? "ALL" : type.toUpperCase();
    });

    try {
      final result =
          await AccountService.getAccountDashboard(userId, type: type);

      if (!mounted) return;

      setState(() {
        _accounts = result['accounts'];
        _summary = result['summary'];

        // Reset to "all" if the specific selected account is no longer in the filtered list
        if (_selectedAccountId != "all" &&
            !_accounts.any((a) => a.id == _selectedAccountId)) {
          _selectedAccountId = "all";
        }
      });
    } catch (e) {
      debugPrint("Dashboard Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================= BALANCE GETTERS =================

  String get currentAvailable {
    if (_selectedAccountId == "all") {
      return _summary?.totalAvailable ?? "0.00";
    }
    try {
      final acc =
          _accounts.firstWhere((a) => a.id == _selectedAccountId);
      return acc.availableBalance;
    } catch (_) {
      return "0.00";
    }
  }

  String get currentReserved {
    if (_selectedAccountId == "all") {
      return _summary?.totalReserved ?? "0.00";
    }
    try {
      final acc =
          _accounts.firstWhere((a) => a.id == _selectedAccountId);
      return acc.reservedBalance;
    } catch (_) {
      return "0.00";
    }
  }

  String get currentTotal {
    if (_selectedAccountId == "all") {
      return _summary?.netWorth ?? "0.00";
    }
    try {
      final acc =
          _accounts.firstWhere((a) => a.id == _selectedAccountId);
      return acc.totalBalance;
    } catch (_) {
      return "0.00";
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10)
        ],
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAccountSelector(),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _loadDashboard(
                        type: _activeCategory == "ALL"
                            ? ""
                            : _activeCategory),
                  ),
                  IconButton(
                    icon: Icon(_isBalanceVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() =>
                        _isBalanceVisible =
                            !_isBalanceVisible),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildBalanceSection(
            "Available Balance",
            currentAvailable,
            24,
            theme.colorScheme.onSurface,
            true,
          ),

          const Divider(height: 30),

          _buildBalanceSection(
            "Reserved Amount",
            currentReserved,
            18,
            Colors.orange,
            false,
          ),

          const Divider(height: 30),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Balance",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                _isBalanceVisible
                    ? "₹ $currentTotal"
                    : "••••••",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BALANCE SECTION =================

  Widget _buildBalanceSection(
    String title,
    String value,
    double size,
    Color color,
    bool isBold,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isBalanceVisible ? "₹ $value" : "••••••",
          style: TextStyle(
            fontSize: size,
            fontWeight:
                isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ================= ACCOUNT SELECTOR =================

  Widget _buildAccountSelector() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == "create") {
          _showCreateAccountDialog();
        } else if (["ALL", "CASH", "BANK"].contains(value)) {
          setState(() {
            _selectedAccountId = "all";
            // _activeCategory is updated inside _loadDashboard via the type parameter
          });

          await _loadDashboard(type: value == "ALL" ? "" : value);
          widget.onAccountSelected?.call("all");
        } else {
          setState(() {
            _selectedAccountId = value;
          });
          widget.onAccountSelected?.call(value);
        }
      },
      itemBuilder: (context) {
        return [
          _buildPopupItem("ALL", "All Wallets", Icons.wallet),
          _buildPopupItem("CASH", "Cash Only", Icons.money),
          _buildPopupItem("BANK", "Bank Only", Icons.account_balance),
          
          // Logic: Hide individual accounts if "ALL" is selected
          if (_activeCategory != "ALL" && _accounts.isNotEmpty) ...[
            const PopupMenuDivider(),
            ..._accounts.map(
              (a) => PopupMenuItem(
                value: a.id,
                child: Row(
                  children: [
                    Icon(
                      a.type == "CASH" ? Icons.money : Icons.account_balance,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(a.name),
                  ],
                ),
              ),
            ),
          ],

          const PopupMenuDivider(),
          const PopupMenuItem(
            value: "create",
            child: Text(
              "+ Create New",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ];
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wallet, size: 18),
          const SizedBox(width: 8),
          Text(
            _selectedAccountId == "all"
                ? "$_activeCategory View"
                : _accounts.firstWhere(
                    (a) => a.id == _selectedAccountId,
                    orElse: () => _accounts.first,
                  ).name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  // Helper method for generating rows inside the Popup Menu
  PopupMenuItem<String> _buildPopupItem(
      String value, String label, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }

  // ================= CREATE ACCOUNT =================

  void _showCreateAccountDialog() {
    final controller = TextEditingController();
    String type = "CASH";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Account"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                  labelText: "Account Name"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(
                    value: "CASH", child: Text("Cash")),
                DropdownMenuItem(
                    value: "BANK", child: Text("Bank")),
              ],
              onChanged: (v) => type = v!,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await AccountService.createAccount(
                userId: userId,
                name: controller.text.trim().isEmpty
                    ? "New Account"
                    : controller.text.trim(),
                type: type,
              );

              if (!mounted) return;

              Navigator.pop(ctx);
              _loadDashboard();
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }
}