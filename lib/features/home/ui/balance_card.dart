import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/account_model.dart';
import '../../../core/providers/account_provider.dart';
import 'package:front_end/navigation/navigation_service.dart';

class BalanceCard extends StatelessWidget {
  final String userId;

  const BalanceCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final AccountModel? primaryAccount = provider.defaultAccount;

    if (provider.isLoading) {
      return Container(
        height: 180,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (primaryAccount == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        
          gradient: const LinearGradient(
          colors: [Color(0xFF0052D4), Color(0xFF1A1A1A)],
        ), // teal color// Blue to Black Gradient
        
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ACCOUNT NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                primaryAccount.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const Icon(Icons.verified,
                  color: Color.fromARGB(255, 255, 255, 255), size: 16),
            ],
          ),

          const SizedBox(height: 12),

          /// BALANCE
          Text(
            "₹ ${primaryAccount.availableBalance}",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const Text(
            "Available Balance",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),

          const SizedBox(height: 20),

          const Divider(color: Colors.white24, thickness: 1),

          const SizedBox(height: 15),

          /// STATS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallStat(
                "Reserved",
                primaryAccount.reservedBalance,
                Colors.orangeAccent,
              ),
              _buildSmallStat(
                "Total Worth",
                primaryAccount.totalBalance,
                Colors.greenAccent,
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// MANAGE WALLET BUTTON
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                NavigationService.bottomIndex.value = 2;

                /// refresh accounts
                context.read<AccountProvider>().loadAccounts(userId);
              },
              child: const Text(
                "Manage Wallets →",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// SMALL STAT WIDGET
  Widget _buildSmallStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "₹ $value",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
