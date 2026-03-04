import 'package:flutter/material.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {

  final Color primaryRed = const Color(0xFFB81414);
  final Color goalBlue = const Color(0xFF1976D2);

  /// FILTER STATES
  String selectedType = "All Type";
  String selectedCategory = "All";
  String selectedAccountName = "All Accounts";

  DateTime? startDate;
  DateTime? endDate;

  String searchQuery = "";

  bool _isLoading = true;

  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];

  final List<String> _types = [
    "All Type",
    "Income",
    "Expense",
    "Reserved",
    "Transfer"
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// FETCH DATA
  Future<void> _fetchData({String? accountId}) async {

    setState(() => _isLoading = true);

    try {

      final results = await Future.wait([
        TransactionService.getHistory(
          "699e8fea9a6c85ac1f0970eb",
          accountId: accountId,
        ),
        AccountService.getAccountDashboard(
          "699e8fea9a6c85ac1f0970eb",
        )
      ]);

      final accountData = results[1] as Map<String, dynamic>;

      setState(() {
        _transactions =
            (results[0] as TransactionHistoryResponse).transactions;

        _accounts = List<AccountModel>.from(accountData['accounts']);

        _isLoading = false;
      });

    } catch (e) {

      setState(() => _isLoading = false);

    }
  }

  /// ICON UI
  Widget _getTransactionLeading(TransactionModel tx) {

    if (tx.direction == "GOAL_ALLOCATION") {

      return CircleAvatar(
        radius: 18,
        backgroundColor: goalBlue.withOpacity(0.1),
        child: Icon(Icons.flag_circle, color: goalBlue, size: 22),
      );

    }

    switch (tx.type) {

      case 'income':
        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.trending_up,
              color: Colors.green,
              size: 20),
        );

      case 'transfer':
        return CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.withOpacity(0.1),
          child: const Icon(Icons.sync_alt,
              color: Colors.grey,
              size: 20),
        );

      case 'expense':
      default:
        return CircleAvatar(
          radius: 18,
          backgroundColor: primaryRed.withOpacity(0.1),
          child: Icon(Icons.trending_down,
              color: primaryRed,
              size: 20),
        );
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        title: const Text(
          "History",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),

        actions: [

          IconButton(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh, color: Colors.white))

        ],
      ),

      body: Column(
        children: [

          /// HEADER
          Container(
            color: primaryRed,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
            child: Column(
              children: [

                /// SEARCH
                Row(
                  children: [

                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          onChanged: (v) =>
                              setState(() => searchQuery = v),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: "Search transactions...",
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey,
                                size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.date_range,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// FILTER ROW
                Row(
                  children: [

                    /// ACCOUNT
                    Expanded(
                      flex: 3,
                      child: _buildHeaderDropdown(
                        selectedAccountName,
                        [
                          "All Accounts",
                          ..._accounts.map((a) => a.name)
                        ],
                        (val) {

                          String? id = (val ==
                                  "All Accounts")
                              ? null
                              : _accounts
                                  .firstWhere(
                                      (a) => a.name == val)
                                  .id;

                          setState(() =>
                              selectedAccountName = val!);

                          _fetchData(accountId: id);
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// TYPE
                    Expanded(
                      flex: 2,
                      child: _buildHeaderDropdown(
                        selectedType,
                        _types,
                        (val) => setState(
                            () => selectedType = val!),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// CATEGORY
                    GestureDetector(
                      onTap: _showCategoryModal,
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: selectedCategory != "All"
                              ? Colors.white
                              : Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.bar_chart,
                            color: selectedCategory != "All"
                                ? primaryRed
                                : Colors.white,
                            size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: primaryRed))
                : _buildTransactionList(isDark),
          )
        ],
      ),
    );
  }

  /// DROPDOWN
  Widget _buildHeaderDropdown(
      String value,
      List<String> items,
      Function(String?) onChanged) {

    return Container(
      height: 38,
      padding:
          const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: primaryRed,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 18),
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      overflow:
                          TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// TRANSACTION LIST
  Widget _buildTransactionList(bool isDark) {

    final list = _transactions.where((tx) {

      final mSearch =
          tx.title.toLowerCase().contains(
                  searchQuery.toLowerCase()) ||
              tx.subtitle.toLowerCase().contains(
                  searchQuery.toLowerCase());

      final mCat = selectedCategory == "All" ||
          tx.category == selectedCategory;

      bool mType = true;

      if (selectedType == "Income") {
        mType = tx.type == "income";
      } else if (selectedType == "Expense") {
        mType = tx.type == "expense" &&
            tx.direction != "GOAL_ALLOCATION";
      } else if (selectedType == "Reserved") {
        mType = tx.direction == "GOAL_ALLOCATION";
      } else if (selectedType == "Transfer") {
        mType = tx.type == "transfer";
      }

      bool mDate = true;

      if (startDate != null && endDate != null) {
        mDate = tx.date.isAfter(
                startDate!.subtract(
                    const Duration(days: 1))) &&
            tx.date.isBefore(
                endDate!.add(
                    const Duration(days: 1)));
      }

      return mSearch && mCat && mType && mDate;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: list.length,
      itemBuilder: (context, i) {

        final tx = list[i];

        bool isInc = tx.type == 'income';

        bool isRes =
            tx.direction == "GOAL_ALLOCATION";

        Color moneyColor = isInc
            ? Colors.green
            : (isRes ? goalBlue : primaryRed);

        return Container(
          margin:
              const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: ListTile(
  leading: _getTransactionLeading(tx),

  /// CATEGORY
  title: Text(
    tx.title,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: isDark ? Colors.white : Colors.black87,
    ),
  ),

  /// DESCRIPTION + DATE
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      if (tx.subtitle.isNotEmpty)
        Text(
          tx.subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? Colors.white60
                : Colors.grey.shade600,
          ),
        ),

      Text(
        DateFormat('dd MMM yyyy').format(tx.date),
        style: TextStyle(
          fontSize: 10,
          color: isDark
              ? Colors.white38
              : Colors.grey.shade500,
        ),
      ),
    ],
  ),

  /// AMOUNT
  trailing: Text(
    "${isInc ? '+' : '-'}₹${tx.amount.abs().toStringAsFixed(0)}",
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: moneyColor,
      fontSize: 14,
    ),
  ),
),
          
        );
      },
    );
  }

  /// CLEAR FILTERS
  void _clearFilters() {

    setState(() {

      selectedType = "All Type";
      selectedCategory = "All";
      selectedAccountName = "All Accounts";
      startDate = null;
      endDate = null;
      searchQuery = "";

    });

  }

  /// DATE RANGE PICKER
  void _pickDateRange() async {

    final range =
        await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (range != null) {

      setState(() {

        startDate = range.start;
        endDate = range.end;

      });

    }
  }

  /// CATEGORY MODAL
  void _showCategoryModal() {

    final List<Map<String, dynamic>>
        categoryData = [

      {'name': 'All', 'icon': Icons.all_inclusive},
      {'name': 'Food', 'icon': Icons.restaurant},
      {'name': 'Transport', 'icon': Icons.directions_bus},
      {'name': 'Salary', 'icon': Icons.payments},
      {'name': 'Shopping', 'icon': Icons.shopping_bag},
      {'name': 'Rent', 'icon': Icons.home},
      {'name': 'Bills', 'icon': Icons.receipt_long},
      {'name': 'Entertainment', 'icon': Icons.movie},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {

        return Container(
          height: MediaQuery.of(context)
                  .size
                  .height *
              0.45,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius:
                const BorderRadius.vertical(
                    top: Radius.circular(20)),
          ),
          child: GridView.builder(
            padding:
                const EdgeInsets.all(15),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
            itemCount: categoryData.length,
            itemBuilder:
                (context, index) {

              final cat =
                  categoryData[index];

              final isSelected =
                  selectedCategory ==
                      cat['name'];

              return InkWell(
                onTap: () {

                  setState(() =>
                      selectedCategory =
                          cat['name']);

                  Navigator.pop(context);

                },
                child: Column(
                  children: [

                    CircleAvatar(
                      backgroundColor:
                          isSelected
                              ? primaryRed
                              : Colors.grey
                                  .withOpacity(
                                      0.1),
                      child: Icon(
                        cat['icon'],
                        color: isSelected
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(cat['name'],
                        style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? primaryRed
                                : Colors.grey)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}