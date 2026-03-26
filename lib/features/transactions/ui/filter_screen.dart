import 'package:flutter/material.dart';
import 'package:front_end/core/models/account_model.dart';

class FilterScreen extends StatefulWidget {
  final String selectedType;
  final String selectedCategory;
  final String selectedAccountName;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<AccountModel> availableAccounts;

  const FilterScreen({
    super.key,
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedAccountName,
    required this.startDate,
    required this.endDate,
    required this.availableAccounts,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  int selectedMenuIndex = 0;

  late String type;
  late String category;
  late String account;

  DateTime? startDate;
  DateTime? endDate;

  final List<String> leftMenu = [
    "Transaction Type",
    "Category",
    "Account",
    "Date"
  ];

  final List<String> types = [
    "All Type",
    "Income",
    "Expense",
    "Reserved",
    "Transfer"
  ];

  final List<String> categories = [
    "All",
    "Food",
    "Transport",
    "Salary",
    "Shopping",
    "Rent",
    "Bills",
    "Entertainment"
  ];

  @override
  void initState() {
    super.initState();
    type = widget.selectedType;
    category = widget.selectedCategory;
    account = widget.selectedAccountName;
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  /// DATE PICKER
  Future<void> pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        startDate = date;
      });
    }
  }

  Future<void> pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        endDate = date;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                type = "All Type";
                category = "All";
                account = "All Accounts";
                startDate = null;
                endDate = null;
              });
            },
            child: const Text("Clear"),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                /// LEFT MENU
                Container(
                  width: 150,
                  color: Colors.grey.shade200,
                  child: ListView.builder(
                    itemCount: leftMenu.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedMenuIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: selectedMenuIndex == index
                              ? Colors.white
                              : Colors.grey.shade200,
                          child: Text(
                            leftMenu[index],
                            style: TextStyle(
                              fontWeight: selectedMenuIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// RIGHT PANEL
                Expanded(
                  child: _buildRightPanel(),
                ),
              ],
            ),
          ),

          /// APPLY BUTTON
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "type": type,
                  "category": category,
                  "account": account,
                  "startDate": startDate,
                  "endDate": endDate,
                });
              },
              child: const Text("Apply"),
            ),
          )
        ],
      ),
    );
  }

  /// RIGHT SIDE OPTIONS
  Widget _buildRightPanel() {
    switch (selectedMenuIndex) {
      /// TYPE
      case 0:
        return ListView(
          children: types.map((e) {
            return RadioListTile(
              title: Text(e),
              value: e,
              groupValue: type,
              activeColor: const Color(0xFFB81414),
              onChanged: (v) {
                setState(() => type = v!);
              },
            );
          }).toList(),
        );

      /// CATEGORY
      case 1:
        return ListView(
          children: categories.map((e) {
            return RadioListTile(
              title: Text(e),
              value: e,
              groupValue: category,
              activeColor: const Color(0xFFB81414),
              onChanged: (v) {
                setState(() => category = v!);
              },
            );
          }).toList(),
        );

      /// ACCOUNT
      case 2:
        return ListView(
          children: [
            RadioListTile(
              title: const Text("All Accounts"),
              secondary: const Icon(Icons.all_inclusive, color: Colors.grey),
              value: "All Accounts",
              groupValue: account,
              activeColor: const Color(0xFFB81414),
              onChanged: (v) {
                setState(() => account = v.toString());
              },
            ),
            ...widget.availableAccounts.map((a) {
              bool isCash = a.type == "CASH";
              return RadioListTile(
                title: Text(a.name),
                secondary: Icon(
                  isCash ? Icons.money : Icons.account_balance,
                  color: isCash ? Colors.green : const Color(0xFF1976D2),
                ),
                value: a.name,
                groupValue: account,
                activeColor: const Color(0xFFB81414),
                onChanged: (v) {
                  setState(() => account = v.toString());
                },
              );
            }).toList(),
          ],
        );

      /// DATE
      case 3:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                title: const Text("Start Date"),
                subtitle: Text(
                  startDate == null
                      ? "Select date"
                      : startDate.toString().split(" ")[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickStartDate,
              ),
              ListTile(
                title: const Text("End Date"),
                subtitle: Text(
                  endDate == null
                      ? "Select date"
                      : endDate.toString().split(" ")[0],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickEndDate,
              ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }
}