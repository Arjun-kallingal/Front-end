import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/account_model.dart';
import '../../../core/providers/account_provider.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  String _fmt(String value) {
    final n = double.tryParse(value) ?? 0;
    return NumberFormat('#,##,###').format(n);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    final AccountModel? account = provider.defaultAccount;

    if (provider.isLoading) {
      return _shell(
        child: const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.darkTextPrimary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (account == null) return const SizedBox.shrink();

    return _shell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Row 1: account label + wallet icon ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.darkTextPrimary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.darkTextPrimary.withOpacity(0.20),
                        width: 0.8),
                  ),
                  child: Text(
                    account.name.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.darkTextPrimary.withOpacity(0.70),
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkTextPrimary.withOpacity(0.10),
                    border: Border.all(
                        color: AppColors.darkTextPrimary.withOpacity(0.20),
                        width: 0.8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.darkTextPrimary.withOpacity(0.70),
                    size: 17,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Row 2: Balance ─────────────────────────────────────────
            Text(
              "₹ ${_fmt(account.availableBalance)}",
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.darkTextPrimary,
                letterSpacing: -1.2,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Available Balance",
              style: TextStyle(
                color: AppColors.darkTextPrimary.withOpacity(0.50),
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 16),

            // ── Sparkline chart ────────────────────────────────────────
            SizedBox(
              height: 56,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      curveSmoothness: 0.4,
                      barWidth: 2.5,
                      color: AppColors.incomeAmount,
                      dotData: const FlDotData(show: false),
                      spots: const [
                        FlSpot(0, 1.0),
                        FlSpot(1, 1.4),
                        FlSpot(2, 1.2),
                        FlSpot(3, 1.9),
                        FlSpot(4, 1.5),
                        FlSpot(5, 2.2),
                        FlSpot(6, 2.0),
                      ],
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.incomeAmount.withOpacity(0.28),
                            AppColors.incomeAmount.withOpacity(0.00),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Divider ────────────────────────────────────────────────
            Container(
                height: 0.6,
                color: AppColors.darkTextPrimary.withOpacity(0.20)),

            const SizedBox(height: 16),

            // ── Stats row ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _stat(
                    icon: Icons.lock_outline_rounded,
                    label: "Reserved",
                    value: account.reservedBalance,
                    color: AppColors.warning,
                  ),
                ),
                Container(
                  width: 0.6,
                  height: 36,
                  color: AppColors.darkTextPrimary.withOpacity(0.20),
                ),
                Expanded(
                  child: _stat(
                    icon: Icons.trending_up_rounded,
                    label: "Total Worth",
                    value: account.totalBalance,
                    color: AppColors.incomeAmount,
                    alignRight: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ── Manage Wallets button ──────────────────────────────────
            GestureDetector(
              onTap: () {
                NavigationService.bottomIndex.value = 2;
                context.read<AccountProvider>().loadAccounts();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.darkTextPrimary.withOpacity(0.10),
                  border: Border.all(
                      color: AppColors.darkTextPrimary.withOpacity(0.20),
                      width: 0.8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Manage Wallets",
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.darkTextPrimary.withOpacity(0.70),
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            AppColors.balanceCardStart,
            AppColors.balanceCardMid,
            AppColors.balanceCardEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.balanceCardMid.withOpacity(0.50),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -32,
              right: -32,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkTextPrimary.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkTextPrimary.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              right: -10,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkTextPrimary.withOpacity(0.04),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _stat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool alignRight = false,
  }) {
    final formatted =
        NumberFormat('#,##,###').format(double.tryParse(value) ?? 2);

    return Padding(
      padding: EdgeInsets.only(
        left: alignRight ? 16 : 0,
        right: alignRight ? 0 : 16,
      ),
      child: Row(
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!alignRight) ...[
            _iconPill(icon, color),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: alignRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.darkTextPrimary.withOpacity(0.50),
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "₹ $formatted",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (alignRight) ...[
            const SizedBox(width: 10),
            _iconPill(icon, color),
          ],
        ],
      ),
    );
  }

  Widget _iconPill(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: Icon(icon, color: color, size: 15),
    );
  }
}