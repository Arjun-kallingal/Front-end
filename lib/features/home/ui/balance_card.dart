import 'package:flutter/material.dart';
import '../../../core/models/account_model.dart';
import '../../../core/services/account_service.dart';
import 'package:front_end/navigation/navigation_service.dart';

class BalanceCard extends StatefulWidget {
  final String userId;
  const BalanceCard({super.key, required this.userId});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isLoading = true;
  AccountModel? _primaryAccount;

  @override
  void initState() {
    super.initState();
    _loadPrimaryAccount();
  }

  Future<void> _loadPrimaryAccount() async {
    if (widget.userId.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> dashboardData =
          await AccountService.getAccountDashboard(widget.userId);
      // Safely casting the list to prevent type errors
      final List<AccountModel> accounts =
          (dashboardData['accounts'] as List<dynamic>?)?.cast<AccountModel>() ??
              [];

      if (mounted) {
        setState(() {
          if (accounts.isNotEmpty) {
            _primaryAccount = accounts.firstWhere(
              (acc) => acc.isDefault == true,
              orElse: () => accounts.firstWhere((acc) => acc.type == "CASH",
                  orElse: () => accounts.first),
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("BalanceCard Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 180,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.black87, borderRadius: BorderRadius.circular(24)),
        child:
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_primaryAccount == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_primaryAccount!.name.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1)),
              const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text("₹ ${_primaryAccount!.availableBalance}",
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const Text("Available Balance",
              style: TextStyle(color: Colors.white54, fontSize: 12)),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 15),

          // NEW: Reserved and Total Balances Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallStat("Reserved", _primaryAccount!.reservedBalance,
                  Colors.orangeAccent),
              _buildSmallStat("Total Worth", _primaryAccount!.totalBalance,
                  Colors.greenAccent),
            ],
          ),

          const SizedBox(height: 10),
         Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      NavigationService.bottomIndex.value = 2;
      _loadPrimaryAccount();
    },
    child: const Text(
      "Manage Wallets →",
      style: TextStyle(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
        ],
      ),
    );
  }

  // Helper widget to keep the code clean and consistent
  Widget _buildSmallStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text("₹ $value",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
