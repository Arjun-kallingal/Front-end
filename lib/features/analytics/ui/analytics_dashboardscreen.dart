import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart'; // Make sure this path is correct!
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

    // 🔥 Dynamic Theme Setup
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textSec = isDark ? const Color(0xFF8B90A7) : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(anaP, accP, theme, colorScheme, textSec, isDark),
      body: anaP.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.incomeAmount))
          : anaP.error != null
              ? _buildError(anaP, textSec)
              : RefreshIndicator(
                  color: AppColors.incomeAmount,
                  backgroundColor: colorScheme.surface,
                  onRefresh: () => anaP.fetchDashboard(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _buildTimeFilter(anaP, theme, colorScheme, textSec),
                      const SizedBox(height: 16),
                      if (anaP.data != null) ...[
                        _buildSummaryCards(anaP.data!, colorScheme, textSec, isDark),
                        const SizedBox(height: 16),
                        _buildIncomeExpenseCard(anaP.data!, colorScheme, textSec, theme, isDark),
                        const SizedBox(height: 16),
                        _buildSpendGaugeCard(anaP.data!, colorScheme, textSec, theme, isDark),
                        const SizedBox(height: 16),
                        _buildSpendingInsightsCard(anaP.data!, colorScheme, textSec, isDark),
                      ] else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: Text(
                              "No data available.",
                              style: TextStyle(color: textSec),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  // ─── APPBAR ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AnalyticsProvider anaP, AccountProvider accP,
      ThemeData theme, ColorScheme colorScheme, Color textSec, bool isDark) {
    final accounts = [...accP.cashAccounts, ...accP.bankAccounts];
    final surfaceAlt = theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,
      shape: Border(bottom: BorderSide(color: theme.dividerColor)),
      iconTheme: IconThemeData(color: colorScheme.primary),
      title: Text(
        "Analytics & Reports",
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: surfaceAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: anaP.currentAccountId,
              dropdownColor: colorScheme.surface,
              iconEnabledColor: textSec,
              onChanged: (val) => anaP.changeAccount(val!),
              style: TextStyle(fontSize: 12, color: colorScheme.primary),
              items: [
                const DropdownMenuItem(
                  value: "all",
                  child: Text("All Assets", style: TextStyle(fontSize: 12)),
                ),
                ...accounts.map(
                  (a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(a.name, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── TIME FILTER ───────────────────────────────────────────────────────────

  Widget _buildTimeFilter(AnalyticsProvider anaP, ThemeData theme,
      ColorScheme colorScheme, Color textSec) {
    const options = ["Day", "Week", "Month", "Year"];
    final surfaceAlt = theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceAlt,
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
                  color: isActive ? AppColors.incomeAmount : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.incomeAmount.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : textSec,
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

  Widget _buildSummaryCards(AnalyticsModel data, ColorScheme colorScheme,
      Color textSec, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: "Monthly Income",
            amount: data.income,
            icon: Icons.trending_up_rounded,
            color: AppColors.incomeAmount,
            bgColor: AppColors.incomeAmount.withOpacity(0.15),
            colorScheme: colorScheme,
            textSec: textSec,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: "Monthly Expense",
            amount: data.expense,
            icon: Icons.trending_down_rounded,
            color: AppColors.expenseAmount,
            bgColor: AppColors.expenseAmount.withOpacity(0.15),
            colorScheme: colorScheme,
            textSec: textSec,
            isDark: isDark,
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
    required ColorScheme colorScheme,
    required Color textSec,
    required bool isDark,
  }) {
    return _baseCard(
      colorScheme: colorScheme,
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: textSec)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "₹${_fmt(amount)}",
                  style: TextStyle(
                    fontSize: 18, // Slightly reduced to prevent overflow
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── INCOME VS EXPENSE DONUT ───────────────────────────────────────────────

  Widget _buildIncomeExpenseCard(AnalyticsModel data, ColorScheme colorScheme,
      Color textSec, ThemeData theme, bool isDark) {
    int? touchedIndex;

    final bool hasIncome = data.income > 0;
    final bool hasExpense = data.expense > 0;

    final List<PieChartSectionData> sections = [];
    if (!hasIncome && !hasExpense) {
      sections.add(PieChartSectionData(
          value: 1, color: theme.dividerColor, radius: 30, showTitle: false));
    } else {
      if (hasIncome) {
        sections.add(PieChartSectionData(
            value: data.income,
            color: AppColors.incomeAmount,
            radius: 30,
            showTitle: false));
      }
      if (hasExpense) {
        sections.add(PieChartSectionData(
            value: data.expense,
            color: AppColors.expenseAmount,
            radius: 30,
            showTitle: false));
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return _baseCard(
          colorScheme: colorScheme,
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Income Vs Expense",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        centerSpaceRadius: 60,
                        sectionsSpace: 2,
                        sections: sections,
                        pieTouchData: PieTouchData(
                          touchCallback: (event, response) {
                            setState(() {
                              touchedIndex = response
                                  ?.touchedSection?.touchedSectionIndex;
                            });
                          },
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          touchedIndex == 0
                              ? "₹${_fmt(data.income)}"
                              : touchedIndex == 1
                                  ? "₹${_fmt(data.expense)}"
                                  : data.netSavingsFormatted,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: touchedIndex == 1
                                ? AppColors.expenseAmount
                                : touchedIndex == 0
                                    ? AppColors.incomeAmount
                                    : (data.isDeficit
                                        ? AppColors.expenseAmount
                                        : colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          touchedIndex == 0
                              ? "Income"
                              : touchedIndex == 1
                                  ? "Expense"
                                  : "Net Savings",
                          style: TextStyle(fontSize: 12, color: textSec),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    Text("Savings Rate",
                        style: TextStyle(fontSize: 12, color: textSec)),
                    const SizedBox(height: 4),
                    Text(
                      data.savingsRateFormatted,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: data.isDeficit
                            ? AppColors.expenseAmount
                            : AppColors.incomeAmount,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── SPEND GAUGE ───────────────────────────────────────────────────────────

  Widget _buildSpendGaugeCard(AnalyticsModel data, ColorScheme colorScheme,
      Color textSec, ThemeData theme, bool isDark) {
    final double pct = data.spendPercentageClamped;
    final Color gaugeColor = _getGaugeColor(pct);

    return _baseCard(
      colorScheme: colorScheme,
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Spending Percentage",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
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
                            color: gaugeColor,
                            radius: 24,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 100 - pct,
                            color: theme.dividerColor,
                            radius: 24,
                            showTitle: false,
                          ),
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
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Text("of income",
                              style: TextStyle(fontSize: 12, color: textSec)),
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
              color: gaugeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "Your spend is: ${data.healthStatus}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gaugeColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SPENDING INSIGHTS ─────────────────────────────────────────────────────

  Widget _buildSpendingInsightsCard(AnalyticsModel data, ColorScheme colorScheme,
      Color textSec, bool isDark) {
    final totalSpend = data.categories.fold(0.0, (sum, c) => sum + c.amount);

    if (data.categories.isEmpty) {
      return _baseCard(
        colorScheme: colorScheme,
        isDark: isDark,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text("No spending data for this period.",
                style: TextStyle(color: textSec)),
          ),
        ),
      );
    }

    return _baseCard(
      colorScheme: colorScheme,
      isDark: isDark,
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text("Total Spending",
                        style: TextStyle(fontSize: 12, color: textSec)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...data.categories.map((cat) => _categoryRow(cat, colorScheme, textSec)),
        ],
      ),
    );
  }

  Widget _categoryRow(CategoryData cat, ColorScheme colorScheme, Color textSec) {
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
            child: Text(
              cat.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
          Text(
            "₹${_fmt(cat.amount)}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Text(
              "${cat.percentage}%",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: textSec),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ERROR STATE ───────────────────────────────────────────────────────────

  Widget _buildError(AnalyticsProvider anaP, Color textSec) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.expenseAmount, size: 48),
            const SizedBox(height: 12),
            Text(
              anaP.error ?? "Something went wrong.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textSec),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: anaP.retry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.incomeAmount),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SHARED BASE CARD ──────────────────────────────────────────────────────

  Widget _baseCard({
    required Widget child,
    required ColorScheme colorScheme,
    required bool isDark,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: colorScheme.surfaceTint.withOpacity(0.05)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────

  Color _getGaugeColor(double pct) {
    if (pct <= 40) return AppColors.incomeAmount; 
    if (pct <= 70) return AppColors.warning;      
    return AppColors.expenseAmount;               
  }

  String _fmt(double v) => v.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}