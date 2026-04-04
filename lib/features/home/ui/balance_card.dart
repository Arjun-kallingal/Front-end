import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/account_model.dart';
import '../../../core/providers/account_provider.dart';
import 'package:front_end/navigation/navigation_service.dart';
// ── Shared dark-luxury palette (mirrors _P in home_screen.dart) ───────────────
class _C {
  static const Color bg         = Color(0xFF0F1117);
  static const Color surface    = Color(0xFF1A1D27);
  static const Color surfaceAlt = Color(0xFF21253A);

  // Hero gradient
  static const Color g1 = Color(0xFF1CB5E0); // teal
  static const Color g2 = Color(0xFF4F46E5); // indigo
  static const Color g3 = Color(0xFF7C3AED); // violet

  static const Color white     = Colors.white;
  static const Color white70   = Color(0xB3FFFFFF);
  static const Color white50   = Color(0x80FFFFFF);
  static const Color white20   = Color(0x33FFFFFF);
  static const Color white10   = Color(0x1AFFFFFF);
  static const Color white06   = Color(0x0FFFFFFF);

  static const Color income    = Color(0xFF22C55E);
  static const Color reserved  = Color(0xFFF59E0B);
  static const Color accent    = Color(0xFF1CB5E0);

  static const Color divider   = Color(0x33FFFFFF);
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  String _fmt(String value) {
    final n = double.tryParse(value) ?? 0;
    return NumberFormat('#,##,###').format(n);
  }

  @override
  Widget build(BuildContext context) {
    final provider       = context.watch<AccountProvider>();
    final AccountModel?  account = provider.defaultAccount;

    // ── Loading ───────────────────────────────────────────────────────────
    if (provider.isLoading) {
      return _shell(
        child: const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              color: _C.white,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    // ── Empty ─────────────────────────────────────────────────────────────
    if (account == null) return const SizedBox.shrink();

    // ── Content ───────────────────────────────────────────────────────────
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
                // Pill label
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _C.white20, width: 0.8),
                  ),
                  child: Text(
                    account.name.toUpperCase(),
                    style: const TextStyle(
                      color: _C.white70,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // Wallet icon ring
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.white10,
                    border:
                        Border.all(color: _C.white20, width: 0.8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _C.white70,
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
                color: _C.white,
                letterSpacing: -1.2,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Available Balance",
              style: TextStyle(
                color: _C.white50,
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
                      color: _C.income,
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
                            _C.income.withOpacity(0.28),
                            _C.income.withOpacity(0.00),
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
            Container(height: 0.6, color: _C.divider),

            const SizedBox(height: 16),

            // ── Stats row ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _stat(
                    icon: Icons.lock_outline_rounded,
                    label: "Reserved",
                    value: account.reservedBalance,
                    color: _C.reserved,
                  ),
                ),
                Container(
                  width: 0.6,
                  height: 36,
                  color: _C.divider,
                ),
                Expanded(
                  child: _stat(
                    icon: Icons.trending_up_rounded,
                    label: "Total Worth",
                    value: account.totalBalance,
                    color: _C.income,
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
                  color: _C.white10,
                  border: Border.all(color: _C.white20, width: 0.8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Manage Wallets",
                      style: TextStyle(
                        color: _C.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _C.white70,
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

  // ── Hero shell: gradient + decorative circles + shadow ─────────────────────
  Widget _shell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [_C.g1, _C.g2, _C.g3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.g2.withOpacity(0.50),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Top-right circle
            Positioned(
              top: -32,
              right: -32,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            // Bottom-left circle
            Positioned(
              bottom: -20,
              left: 20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Bottom-right small circle
            Positioned(
              bottom: 30,
              right: -10,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            // Actual content
            child,
          ],
        ),
      ),
    );
  }

  // ── Inline stat widget ──────────────────────────────────────────────────────
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
                style: const TextStyle(
                  color: _C.white50,
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