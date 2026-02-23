import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/features/transactions/data/transaction_model.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';
import 'package:front_end/core/constants/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = "All";
  String searchQuery = "";
  DateTime? selectedDate;

  final List<TransactionModel> transactionList = [
    TransactionModel(
      title: "Salary",
      subtitle: "Company Payment",
      amount: 3000,
      date: DateTime(2026, 2, 10),
      type: "income",
    ),
    TransactionModel(
      title: "Shopping",
      subtitle: "Clothing",
      amount: -200,
      date: DateTime(2026, 2, 9),
      type: "expense",
    ),
    TransactionModel(
      title: "Entertainment",
      subtitle: "Concert tickets",
      amount: -120,
      date: DateTime(2026, 2, 9),
      type: "expense",
    ),
    TransactionModel(
      title: "Rent",
      subtitle: "Rooms Rent",
      amount: 10000,
      date: DateTime(2026, 1, 10),
      type: "income",
    ),
    TransactionModel(
      title: "Bank Transfer",
      subtitle: "To Savings",
      amount: 800,
      date: DateTime(2026, 2, 8),
      type: "reserved",
    ),
  ];

  List<TransactionModel> get filteredTransactions {
    return transactionList.where((tx) {
      final matchesSearch =
          tx.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              tx.subtitle.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesFilter = selectedFilter == "All"
          ? true
          : tx.type == selectedFilter.toLowerCase();

      final matchesDate = selectedDate == null
          ? true
          : tx.date.year == selectedDate!.year &&
              tx.date.month == selectedDate!.month &&
              tx.date.day == selectedDate!.day;

      return matchesSearch && matchesFilter && matchesDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, List<TransactionModel>> get groupedTransactions {
    final Map<String, List<TransactionModel>> grouped = {};
    for (var tx in filteredTransactions) {
      final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(tx.date);
      grouped.putIfAbsent(formattedDate, () => []);
      grouped[formattedDate]!.add(tx);
    }
    return grouped;
  }

  int get totalCount => filteredTransactions.length;

  double get totalIncome => filteredTransactions
      .where((tx) => tx.type == "income")
      .fold(0, (sum, tx) => sum + tx.amount);

  double get totalExpense => filteredTransactions
      .where((tx) => tx.type == "expense")
      .fold(0, (sum, tx) => sum + tx.amount.abs());

  double get totalReserved => filteredTransactions
      .where((tx) => tx.type == "reserved")
      .fold(0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: 20),
            _buildSearch(context),
            const SizedBox(height: 15),
            _buildDatePicker(context),
            const SizedBox(height: 15),
            _buildFilters(context),
            const SizedBox(height: 20),
            _buildTransactionList(context),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  NavigationService.bottomIndex.value = 0;
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                "Transaction History",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem(
                    "Total", "$totalCount", theme.textTheme.bodyLarge!.color!),
                _summaryItem("Income", "₹${totalIncome.toStringAsFixed(0)}",
                    AppColors.incomeAmount),
                _summaryItem("Expense", "₹${totalExpense.toStringAsFixed(0)}",
                    const Color.fromARGB(233, 244, 9, 5)),
                _summaryItem("Reserved", "₹${totalReserved.toStringAsFixed(0)}",
                    AppColors.chartBarBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        style: theme.textTheme.bodyMedium,
        onChanged: (value) {
          setState(() => searchQuery = value);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.cardColor,
          hintText: "Search transactions...",
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: GestureDetector(
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (picked != null) {
            setState(() => selectedDate = picked);
          }
        },
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 10),
              Text(
                selectedDate == null
                    ? "Select Date"
                    : DateFormat('dd-MM-yyyy').format(selectedDate!),
              ),
              const Spacer(),
              if (selectedDate != null)
                GestureDetector(
                  onTap: () {
                    setState(() => selectedDate = null);
                  },
                  child: const Icon(Icons.close, color: Colors.red),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final theme = Theme.of(context);

    final filters = ["All", "Income", "Expense", "Reserved"];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
            selected: isSelected,
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: groupedTransactions.isEmpty
          ? Center(
              child: Text(
                "No Transactions Found",
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              itemCount: groupedTransactions.length,
              itemBuilder: (context, index) {
                final entry = groupedTransactions.entries.elementAt(index);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...entry.value.map(
                      (tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: TransactionCard(
                          title: tx.title,
                          subtitle: tx.subtitle,
                          amount: "₹${tx.amount.abs().toStringAsFixed(0)}",
                          type: tx.type == "reserved"
                              ? TransactionType.reserved
                              : tx.amount < 0
                                  ? TransactionType.expense
                                  : TransactionType.income,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
