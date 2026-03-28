import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/account_provider.dart';
import '../provider/analytics_provider.dart';
import '../data/analytics_model.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFEF4444);
  static const Color _textPrimary = Color(0xFF111827);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _bgPage = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnalyticsProvider>().fetchDashboard();
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final anaP = context.watch<AnalyticsProvider>();
    final accP = context.watch<AccountProvider>();

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: _buildAppBar(anaP, accP),
      body: anaP.isLoading
          ? const Center(child: CircularProgressIndicator(color: _green))
          : anaP.error != null
              ? _buildError(anaP)
              : RefreshIndicator(
                  color: _green,
                  onRefresh: () => anaP.fetchDashboard(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _buildTimeFilter(anaP),
                      const SizedBox(height: 16),
                      if (anaP.data != null) ...[
                        _buildSummaryCards(anaP.data!),
                        const SizedBox(height: 16),
                        _buildIncomeExpenseCard(anaP.data!),
                        const SizedBox(height: 16),
                        _buildSpendGaugeCard(anaP.data!),
                        const SizedBox(height: 16),
                        _buildSpendingInsightsCard(anaP.data!),
                      ] else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: Text("No data available.",
                                style: TextStyle(color: _textSecondary)),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  // ─── APPBAR ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      AnalyticsProvider anaP, AccountProvider accP) {
    final accounts = [...accP.cashAccounts, ...accP.bankAccounts];
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      shape: const Border(bottom: BorderSide(color: _border)),
      title: const Text(
        "Financial Dashboard",
        style: TextStyle(
            color: _textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: anaP.currentAccountId,
              onChanged: (val) => anaP.changeAccount(val!),
              style: const TextStyle(fontSize: 12, color: _textPrimary),
              items: [
                const DropdownMenuItem(
                    value: "all",
                    child: Text("All Assets", style: TextStyle(fontSize: 12))),
                ...accounts.map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(a.name, style: const TextStyle(fontSize: 12)))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── TIME FILTER ───────────────────────────────────────────────────────────

  Widget _buildTimeFilter(AnalyticsProvider anaP) {
    const options = ["Day", "Week", "Month", "Year"];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: options.map((opt) {
          final isActive = anaP.currentTimeframe == opt;
          return Expanded(
            child: GestureDetector(
              onTap: () => anaP.changeTimeframe(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? _green : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: _green.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : _textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── SUMMARY CARDS ─────────────────────────────────────────────────────────

  Widget _buildSummaryCards(AnalyticsModel data) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: "Monthly Income",
            amount: data.income,
            icon: Icons.trending_up_rounded,
            color: _green,
            bgColor: const Color(0xFFD1FAE5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: "Monthly Expense",
            amount: data.expense,
            icon: Icons.trending_down_rounded,
            color: _red,
            bgColor: const Color(0xFFFEE2E2),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return _whiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: _textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${_fmt(amount)}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary),
              ),
              Container(
                width: 36,
                height: 36,
                decoration:
                    BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── INCOME VS EXPENSE DONUT ───────────────────────────────────────────────

  Widget _buildIncomeExpenseCard(AnalyticsModel data) {
    // ✅ Fix: handle zero income — show full red ring instead of crash
    final bool hasIncome = data.income > 0;
    final bool hasExpense = data.expense > 0;

    final List<PieChartSectionData> sections = [];
    if (!hasIncome && !hasExpense) {
      // Empty state — single gray ring
      sections.add(PieChartSectionData(
          value: 1, color: _border, radius: 30, showTitle: false));
    } else {
      if (hasIncome) {
        sections.add(PieChartSectionData(
            value: data.income, color: _green, radius: 30, showTitle: false));
      }
      if (hasExpense) {
        sections.add(PieChartSectionData(
            value: data.expense, color: _red, radius: 30, showTitle: false));
      }
    }

    return _whiteCard(
      child: Column(
        children: [
          // Donut with center label
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  sections: sections,
                )),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Fix: show sign + red color when deficit
                    Text(
                      data.netSavingsFormatted,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: data.isDeficit ? _red : _textPrimary,
                      ),
                    ),
                    const Text(
                      "Net Savings",
                      style: TextStyle(fontSize: 12, color: _textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Savings rate
          Column(
            children: [
              const Text("Savings Rate",
                  style: TextStyle(fontSize: 12, color: _textSecondary)),
              const SizedBox(height: 2),
              // ✅ Fix: red color when deficit
              Text(
                data.savingsRateFormatted,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: data.isDeficit ? _red : _green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _legendBox(
            dot: _green,
            label: "Income",
            amount: "₹${_fmt(data.income)}",
            bg: const Color(0xFFF0FDF4),
          ),
          const SizedBox(height: 8),
          _legendBox(
            dot: _red,
            label: "Expense",
            amount: "₹${_fmt(data.expense)}",
            bg: const Color(0xFFFEF2F2),
          ),
        ],
      ),
    );
  }

  Widget _legendBox({
    required Color dot,
    required String label,
    required String amount,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _textPrimary)),
          const Spacer(),
          Text(amount,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary)),
        ],
      ),
    );
  }

  // ─── SPEND GAUGE ───────────────────────────────────────────────────────────

  Widget _buildSpendGaugeCard(AnalyticsModel data) {
    // ✅ Fix: use clamped value from model
    final double pct = data.spendPercentageClamped;

    final Color badgeColor;
    final Color badgeBg;
    if (pct <= 40) {
      badgeColor = const Color(0xFF065F46);
      badgeBg = const Color(0xFFD1FAE5);
    } else if (pct <= 70) {
      badgeColor = const Color(0xFF92400E);
      badgeBg = const Color(0xFFFEF3C7);
    } else {
      badgeColor = const Color(0xFF991B1B);
      badgeBg = const Color(0xFFFEE2E2);
    }

    return _whiteCard(
      child: Column(
        children: [
          // ✅ Fix: OverflowBox clips bottom half → true half-circle gauge
          SizedBox(
            height: 110,
            child: OverflowBox(
              maxHeight: 220,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: 180,
                        centerSpaceRadius: 65,
                        sectionsSpace: 0,
                        sections: [
                          PieChartSectionData(
                            value: pct,
                            color: _green,
                            radius: 24,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 100 - pct,
                            color: const Color(0xFFE5E7EB),
                            radius: 24,
                            showTitle: false,
                          ),
                          // Transparent bottom half
                          PieChartSectionData(
                            value: 100,
                            color: Colors.transparent,
                            radius: 24,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 90,
                      child: Column(
                        children: [
                          Text(
                            "${pct.toStringAsFixed(1)}%",
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: _textPrimary),
                          ),
                          const Text("of income",
                              style: TextStyle(
                                  fontSize: 12, color: _textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: badgeBg, borderRadius: BorderRadius.circular(999)),
            child: Text(
              "Your spend is: ${data.healthStatus}",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: badgeColor, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SPENDING INSIGHTS ─────────────────────────────────────────────────────

  Widget _buildSpendingInsightsCard(AnalyticsModel data) {
    final totalSpend = data.categories.fold(0.0, (sum, c) => sum + c.amount);

    // ✅ Fix: empty state when no categories
    if (data.categories.isEmpty) {
      return _whiteCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text("No spending data for this period.",
                style: TextStyle(color: _textSecondary)),
          ),
        ),
      );
    }

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 60,
                    sectionsSpace: 2,
                    sections: data.categories
                        .map((c) => PieChartSectionData(
                              value: c.amount,
                              color: c.color,
                              radius: 30,
                              showTitle: false,
                            ))
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "₹${_fmt(totalSpend)}",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary),
                    ),
                    const Text("Total Spending",
                        style: TextStyle(fontSize: 12, color: _textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...data.categories.map((cat) => _categoryRow(cat)),
        ],
      ),
    );
  }

  Widget _categoryRow(CategoryData cat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(cat.name,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary)),
          ),
          Text(
            "₹${_fmt(cat.amount)}",
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: _textPrimary),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Text(
              "${cat.percentage}%",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, color: _textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ERROR STATE ───────────────────────────────────────────────────────────

  Widget _buildError(AnalyticsProvider anaP) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _red, size: 48),
            const SizedBox(height: 12),
            Text(anaP.error ?? "Something went wrong.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: anaP.retry,
              style: ElevatedButton.styleFrom(backgroundColor: _green),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SHARED ────────────────────────────────────────────────────────────────

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  String _fmt(double v) => v.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
