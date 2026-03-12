import 'package:flutter/material.dart';
import '../../../core/models/account_model.dart';
import '../../../core/services/account_service.dart';
import '../../../core/services/mock_auth.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/features/transfer/transfer.dart'; // Ensure this matches your actual file name
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';

class AccountsOverviewScreen extends StatefulWidget {
  const AccountsOverviewScreen({super.key});

  @override
  State<AccountsOverviewScreen> createState() => _AccountsOverviewScreenState();
}

class _AccountsOverviewScreenState extends State<AccountsOverviewScreen> {
  bool _isLoading = true;
  List<AccountModel> _cashAccounts = [];
  List<AccountModel> _bankAccounts = [];
  AccountModel? _defaultAccount;

  double _totalCash = 0;
  double _totalBank = 0;
  double _totalAll = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  // ================= DATA LOGIC =================

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final userId = MockAuthService.currentUserId;
      final Map<String, dynamic> data =
          await AccountService.getAccountDashboard(userId);
      final List<AccountModel> all =
          (data['accounts'] as List<dynamic>?)?.cast<AccountModel>() ?? [];

      if (mounted) {
        setState(() {
          _cashAccounts = all.where((a) => a.type == "CASH").toList();
          _bankAccounts = all.where((a) => a.type == "BANK").toList();

          if (all.isNotEmpty) {
            _defaultAccount =
                all.firstWhere((acc) => acc.isDefault, orElse: () => all.first);
          }

          _totalCash = _cashAccounts.fold(
              0, (sum, item) => sum + double.parse(item.totalBalance));
          _totalBank = _bankAccounts.fold(
              0, (sum, item) => sum + double.parse(item.totalBalance));
          _totalAll = _totalCash + _totalBank;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSetPrimary(String accountId) async {
    final success = await AccountService.setPrimaryAccount(accountId);
    if (success && mounted) _loadAccounts();
  }

  // ================= POPUP LOGIC =================

  void _showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent),
            SizedBox(width: 10),
            Text("Oops!", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Got it")),
        ],
      ),
    );
  }

  void _showCreateAccountDialog() {
    final controller = TextEditingController();
    String selectedType = "CASH";

    showDialog(
      context: context,
      // StatefulBuilder allows the dialog to update its own UI when you tap the Cash/Bank buttons
      builder: (ctx) => StatefulBuilder(builder: (context, setDialogState) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Create New Account",
              style: TextStyle(fontWeight: FontWeight.bold)),
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

              // NO MORE BUGGY DROPDOWN! Premium selection buttons instead.
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => selectedType = "CASH"),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedType == "CASH"
                              ? Colors.black
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text("CASH",
                              style: TextStyle(
                                  color: selectedType == "CASH"
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => selectedType = "BANK"),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedType == "BANK"
                              ? Colors.blueAccent
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text("BANK",
                              style: TextStyle(
                                  color: selectedType == "BANK"
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold)),
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
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                bool exists = [..._cashAccounts, ..._bankAccounts]
                    .any((a) => a.name.toLowerCase() == name.toLowerCase());
                if (exists) {
                  _showErrorPopup(
                      "An account with the name '$name' already exists.");
                  return;
                }

                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                try {
                  await AccountService.createAccount(
                      userId: MockAuthService.currentUserId,
                      name: name,
                      type: selectedType);
                  _loadAccounts();
                } catch (e) {
                  _showErrorPopup("Failed: $e");
                  setState(() => _isLoading = false);
                }
              },
              child: const Text("Create"),
            )
          ],
        );
      }),
    );
  }

  // ================= UI BUILDERS =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        // FIXED: Title sits right next to the back button now
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () {
            NavigationService.bottomIndex.value = 0;
          },
        ),
        title: const Text("My Accounts",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransferScreen(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.swap_horiz, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.black87))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_defaultAccount != null)
                    _buildPrimaryHeroCard(_defaultAccount!),
                  const SizedBox(height: 20),
                  _buildNetWorthSection(),
                  const SizedBox(height: 25),
                  _buildCreateAccountSection(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("CASH ACCOUNTS"),
                  ..._cashAccounts.map((acc) => _buildDataCard(acc)),
                  const SizedBox(height: 25),
                  _buildSectionHeader("BANK ACCOUNTS"),
                  ..._bankAccounts.map((acc) => _buildDataCard(acc)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildCreateAccountSection() {
    return GestureDetector(
      onTap: _showCreateAccountDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.blueAccent.withValues(alpha: 0.2), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, color: Colors.blueAccent, size: 24),
            SizedBox(width: 10),
            Text("Create New Account",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("NET WORTH",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("₹ ${_totalAll.toStringAsFixed(2)}",
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          Row(
            children: [
              _buildSimpleStat("Cash", _totalCash, Icons.wallet, Colors.green),
              const SizedBox(width: 30),
              _buildSimpleStat(
                  "Bank", _totalBank, Icons.account_balance, Colors.blueAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
      String label, double amount, IconData icon, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 10))
          ]),
          Text("₹ ${amount.toStringAsFixed(0)}",
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPrimaryHeroCard(AccountModel acc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${acc.type} | ${acc.name.toUpperCase()}",
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
              const Icon(Icons.verified, color: Colors.blueAccent, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text("₹ ${acc.availableBalance}",
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const Text("Available Balance",
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const Divider(height: 40, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardStat(
                  "Reserved", acc.reservedBalance, Colors.orangeAccent),
              _buildCardStat(
                  "Total Worth", acc.totalBalance, Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
      Text("₹ $value",
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 14)),
    ]);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.blueGrey)),
    );
  }

  Widget _buildDataCard(AccountModel acc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: acc.isDefault
            ? Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Column(
        children: [
          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    acc.type == "CASH" ? Icons.wallet : Icons.account_balance,
                    color: Colors.black87,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    acc.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),

              /// RIGHT SIDE ICON / MENU
              acc.isDefault
                  ? const Icon(
                      Icons.verified,
                      color: Colors.blueAccent,
                      size: 22,
                    )
                  : PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onSelected: (val) {
                        if (val == 'primary') {
                          _handleSetPrimary(acc.id);
                        }
                        if (val == 'history') {
                          NavigationService.selectedAccountName = acc.name;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionListScreen(),
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

          /// BALANCE DATA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniData("Available", acc.availableBalance, Colors.black87),
              _buildMiniData("Reserved", acc.reservedBalance, Colors.orange),
              _buildMiniData("Total", acc.totalBalance, Colors.black87),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniData(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(
              color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      Text("₹ $value",
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.bold)),
    ]);
  }
}
