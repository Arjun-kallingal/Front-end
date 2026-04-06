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

  /// START DATE PICKER
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

  /// END DATE PICKER
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

    final theme = Theme.of(context);

    return Scaffold(

      appBar: AppBar(
        title: const Text("Filters"),

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: theme.colorScheme.primary,
          ),
        ),

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
            child: Text(
              "Clear",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
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

                      final isSelected = selectedMenuIndex == index;

                      return InkWell(

                        onTap: () {
                          setState(() {
                            selectedMenuIndex = index;
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade200,

                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),

                          child: Text(
                            leftMenu[index],
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,

                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.black87,
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
         SafeArea(
  top: false,
  child: Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      border: Border(
        top: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
    ),
    child: SizedBox(
      width: double.infinity,
      height: 54,
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
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "Apply",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ),
)
        ],
      ),
    );
  }

  /// RIGHT PANEL
  Widget _buildRightPanel() {

    final theme = Theme.of(context);

    switch (selectedMenuIndex) {

      /// TYPE
      case 0:
        return ListView(
          children: types.map((e) {

            return RadioListTile(

              title: Text(e),

              value: e,
              groupValue: type,

              activeColor: theme.colorScheme.primary,

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

              activeColor: theme.colorScheme.primary,

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

              secondary: const Icon(
                Icons.all_inclusive,
                color: Colors.grey,
              ),

              value: "All Accounts",
              groupValue: account,

              activeColor: theme.colorScheme.primary,

              onChanged: (v) {
                setState(() => account = v.toString());
              },
            ),

            ...widget.availableAccounts.map((a) {

              bool isCash = a.type == "CASH";

              return RadioListTile(

                title: Text(a.name),

                secondary: Icon(
                  isCash
                      ? Icons.money
                      : Icons.account_balance,

                  color: isCash
                      ? Colors.green
                      : const Color(0xFF1976D2),
                ),

                value: a.name,
                groupValue: account,

                activeColor: theme.colorScheme.primary,

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