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
      type: "transfer",
    ),
  ];

  List<TransactionModel> get filteredTransactions {
    List<TransactionModel> list = transactionList;

    list = list.where((tx) {
      return tx.title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    if (selectedFilter != "All") {
      list =
          list.where((tx) => tx.type == selectedFilter.toLowerCase()).toList();
    }

    if (selectedDate != null) {
      list = list
          .where((tx) =>
              tx.date.year == selectedDate!.year &&
              tx.date.month == selectedDate!.month &&
              tx.date.day == selectedDate!.day)
          .toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Map<String, List<TransactionModel>> get groupedTransactions {
    Map<String, List<TransactionModel>> grouped = {};

    for (var tx in filteredTransactions) {
      String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(tx.date);

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

  double get totalTransfer => filteredTransactions
      .where((tx) => tx.type == "transfer")
      .fold(0, (sum, tx) => sum + tx.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔴 HEADER
            Container(
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
                  /// 🔙 BACK + TITLE
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          NavigationService.bottomIndex.value = 0;
                        },
                        child: const CircleAvatar(
                          backgroundColor: AppColors.profileAvatarBg,
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        "Transaction History",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// 🔴 SUMMARY CARD (Inside Header Properly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFB00000),
                          Color(0xFF8B0000),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white24,
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem("Total", "$totalCount", Colors.white),
                        _summaryItem(
                          "Income",
                          "\$${totalIncome.toStringAsFixed(0)}",
                          const Color(0xFF00E676),
                        ),
                        _summaryItem(
                          "Expense",
                          "\$${totalExpense.toStringAsFixed(0)}",
                          const Color(0xFFFF8A80),
                        ),
                        _summaryItem(
                          "Transfers",
                          "\$${totalTransfer.toStringAsFixed(0)}",
                          const Color(0xFF64B5F6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.searchBg,
                  hintText: "Search transactions...",
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.searchIcon,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 📅 DATE PICKER
            Padding(
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
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.searchBg,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.searchIcon),
                      const SizedBox(width: 10),
                      Text(
                        selectedDate == null
                            ? "Select Date"
                            : DateFormat('dd-MM-yyyy').format(selectedDate!),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      if (selectedDate != null)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = null;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: AppColors.error,
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// 🔘 FILTER BUTTONS
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ["All", "Income", "Expense", "Transfer"]
                    .map(
                      (filter) => ChoiceChip(
                        label: Text(filter),
                        selected: selectedFilter == filter,
                        backgroundColor: AppColors.filterBg,
                        selectedColor: AppColors.filterSelectedBg,
                        labelStyle: TextStyle(
                          color: selectedFilter == filter
                              ? AppColors.filterSelectedText
                              : AppColors.filterText,
                        ),
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// 📜 GROUPED LIST
            Expanded(
              child: groupedTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        "No Transactions Found",
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      children: groupedTransactions.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: AppColors.dateLabel,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...entry.value.map(
                              (tx) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: TransactionCard(
                                  title: tx.title,
                                  subtitle: tx.subtitle,
                                  amount: tx.amount.toStringAsFixed(0),
                                  type: tx.type == "transfer"
                                      ? TransactionType.transfer
                                      : tx.amount < 0
                                          ? TransactionType.expense
                                          : TransactionType.income,
                                ),
                              ),
                            )
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
