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

// class _HistoryScreenState extends State<HistoryScreen>
class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  String selectedFilter = "All";
  String searchQuery = "";
  DateTime? selectedDate;

  String selectedAccountType = "All";

  final List<String> accountTypes = [
    "All",
    "Cash",
    "Bank",
  ];

  final List<TransactionModel> transactionList = [
    TransactionModel(
      title: "Salary",
      subtitle: "Company Payment",
      amount: 3000,
      date: DateTime(2026, 2, 10),
      type: "income",
      accountType: "bank",
    ),
    TransactionModel(
      title: "Shopping",
      subtitle: "Clothing",
      amount: -200,
      date: DateTime(2026, 2, 9),
      type: "expense",
      accountType: "cash",
    ),
    TransactionModel(
      title: "Entertainment",
      subtitle: "Concert tickets",
      amount: -120,
      date: DateTime(2026, 2, 9),
      type: "expense",
      accountType: "bank",
    ),
    TransactionModel(
      title: "Rent",
      subtitle: "Rooms Rent",
      amount: 10000,
      date: DateTime(2026, 1, 10),
      type: "income",
      accountType: "cash",
    ),
    TransactionModel(
      title: "Bank Transfer",
      subtitle: "To Savings",
      amount: 800,
      date: DateTime(2026, 2, 8),
      type: "reserved",
      accountType: "bank",
    ),
    TransactionModel(
      title: "Bank Transfer",
      subtitle: "To Savings",
      amount: 800,
      date: DateTime(2026, 2, 8),
      type: "transfer",
      accountType: "bank",
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

      final matchesAccountType = selectedAccountType == "All"
          ? true
          : tx.accountType.toLowerCase() == selectedAccountType.toLowerCase();

      return matchesSearch &&
          matchesFilter &&
          matchesDate &&
          matchesAccountType;
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
  double get totalTransfer => filteredTransactions
      .where((tx) => tx.type == "transfer")
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

          /// 🔴 FIXED HEADER (NOT SCROLLING)

          /// 🔹 SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                            _buildHeader(context, isDark),

                  const SizedBox(height: 15),
                  _buildSearch(context),
                  const SizedBox(height: 15),
                  _buildDatePicker(context),
                  const SizedBox(height: 15),
                  _buildFilters(context),
                  const SizedBox(height: 15),
                  _buildTransactionList(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
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
              padding: const EdgeInsets.only(
                top: 15,
                bottom: 20,
                left: 20,
                right: 20,
              ),
      // padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 98, 14, 14),
            Color.fromARGB(255, 184, 20, 20),
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
             IconButton(
                  onPressed: () {
        NavigationService.bottomIndex.value = 0;
      },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 10),
              const Text(
                "Transaction History",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25), 
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem("Total", totalCount.toDouble(),
                    theme.textTheme.bodyLarge!.color!),
                _summaryItem("Income", totalIncome, AppColors.incomeAmount),
                _summaryItem("Expense", totalExpense,
                    const Color.fromARGB(233, 244, 9, 5)),
                _summaryItem("Reserved", totalReserved, AppColors.chartBarBlue),
                _summaryItem("Transfer", totalTransfer, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "",
          style: TextStyle(fontSize: 13, color: Colors.white70),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 5),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 600),
          builder: (context, val, child) {
            return Text(
              title == "Total"
                  ? val.toInt().toString()
                  : "₹${val.toStringAsFixed(0)}",
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
      ],
    );
  }

 Widget _buildSearch(BuildContext context) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      style: theme.textTheme.bodyMedium,
      onChanged: (value) {
        setState(() => searchQuery = value.trim());
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

    const double chipHeight = 42;
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(20));

    Widget buildChip(String filter) {
      final isSelected = selectedFilter == filter;

      return Expanded(
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: chipHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      )
                    : null,
                color: isSelected ? null : theme.cardColor,
                borderRadius: borderRadius,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildDropdown() {
      return Expanded(
        child: Container(
          height: chipHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
                            borderRadius: BorderRadius.circular(15),

              value: selectedAccountType,
              isExpanded: true,
              dropdownColor: theme.cardColor,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: theme.textTheme.bodyMedium?.color,
              ),
              style: theme.textTheme.bodyMedium,
              items: accountTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAccountType = value!;
                });
              },
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          /// ROW 1
          Row(
            children: [
              buildChip("All"),
              const SizedBox(width: 12),
              buildChip("Income"),
              const SizedBox(width: 12),
              buildChip("Expense"),
            ],
          ),

          const SizedBox(height: 12),

          /// ROW 2
          Row(
            children: [
              buildChip("Reserved"),
              const SizedBox(width: 12),
              buildChip("Transfer"),
              const SizedBox(width: 12),
              buildDropdown(),
            ],
          ),
        ],
      ),
    );
  }
Widget _buildTransactionList(BuildContext context) {
  final theme = Theme.of(context);

  if (groupedTransactions.isEmpty) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Text(
          "No Transactions Found",
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedTransactions.entries.map((entry) {
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
            const SizedBox(height: 10),
          ],
        );
      }).toList(),
    ),
  );
}
}
