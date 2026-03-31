import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/account_model.dart';
import '../../../core/providers/account_provider.dart';
import 'package:front_end/navigation/navigation_service.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  String formatCurrency(String value) {
    final number = double.tryParse(value) ?? 0;
    return NumberFormat('#,##,###').format(number);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final AccountModel? primaryAccount = provider.defaultAccount;

    /// LOADING STATE
    if (provider.isLoading) {
      return Container(
        height: 120,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Colors.black87,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    /// EMPTY STATE
    if (primaryAccount == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.3),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [

          
          /// CARD BODY
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(22),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF111827),
                ],
              ),
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
                        fontSize: 12,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// BALANCE
                Text(
                  "₹ ${formatCurrency(primaryAccount.availableBalance)}",
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Available Balance",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                /// SPARKLINE CHART
                SizedBox(
                  height: 60,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          barWidth: 3,
                          color: Colors.greenAccent,
                          dotData: const FlDotData(show: false),
                          spots: const [
                            FlSpot(0, 1),
                            FlSpot(1, 1.5),
                            FlSpot(2, 1.3),
                            FlSpot(3, 1.8),
                            FlSpot(4, 1.6),
                            FlSpot(5, 2),
                          ],
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.greenAccent.withOpacity(.3),
                                Colors.transparent
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(height: 1, color: Colors.white24),

                const SizedBox(height: 14),

                /// SMALL STATS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSmallStat(
                      icon: Icons.lock_outline,
                      label: "Reserved",
                      value: primaryAccount.reservedBalance,
                      color: Colors.orangeAccent,
                    ),
                    _buildSmallStat(
                      icon: Icons.trending_up,
                      label: "Total Worth",
                      value: primaryAccount.totalBalance,
                      color: Colors.greenAccent,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// MANAGE BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      NavigationService.bottomIndex.value = 2;
                      context.read<AccountProvider>().loadAccounts();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white10,
                      ),
                      child: const Text(
                        "Manage Wallets →",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SMALL STAT WIDGET
  Widget _buildSmallStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final formatted =
        NumberFormat('#,##,###').format(double.tryParse(value) ?? 0);

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
            Text(
              "₹ $formatted",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        )
      ],
    );
  }
}