import 'package:flutter/material.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/constants/app_colors.dart';

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
    "Date",
  ];

  final List<String> types = [
    "All Type",
    "Income",
    "Expense",
    "Reserved",
    "Transfer",
  ];

  final List<String> categories = [
    "All",
    "Food",
    "Transport",
    "Salary",
    "Shopping",
    "Rent",
    "Bills",
    "Entertainment",
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

  Future<void> pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => startDate = date);
  }

  Future<void> pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => endDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final leftMenuBg =
        isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary;
    final leftMenuSelectedBg =
        isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary;
    final leftMenuUnselectedText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filters"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: colorScheme.primary,
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
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
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
                  color: leftMenuBg,
                  child: ListView.builder(
                    itemCount: leftMenu.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedMenuIndex == index;

                      return InkWell(
                        onTap: () =>
                            setState(() => selectedMenuIndex = index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? leftMenuSelectedBg
                                : leftMenuBg,
                            border: Border(
                              left: BorderSide(
                                color: isSelected
                                    ? colorScheme.primary
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
                                  ? colorScheme.primary
                                  : leftMenuUnselectedText,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// RIGHT PANEL
                Expanded(child: _buildRightPanel(isDark, colorScheme)),
              ],
            ),
          ),

          /// APPLY BUTTON
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkDivider
                        : AppColors.lightDivider,
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDark, ColorScheme colorScheme) {
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    switch (selectedMenuIndex) {

      /// TYPE
      case 0:
        return ListView(
          children: types.map((e) {
            return RadioListTile(
              title: Text(e, style: TextStyle(color: textColor)),
              value: e,
              groupValue: type,
              activeColor: colorScheme.primary,
              onChanged: (v) => setState(() => type = v!),
            );
          }).toList(),
        );

      /// CATEGORY
      case 1:
        return ListView(
          children: categories.map((e) {
            return RadioListTile(
              title: Text(e, style: TextStyle(color: textColor)),
              value: e,
              groupValue: category,
              activeColor: colorScheme.primary,
              onChanged: (v) => setState(() => category = v!),
            );
          }).toList(),
        );

      /// ACCOUNT
      case 2:
        return ListView(
          children: [
            RadioListTile(
              title: Text("All Accounts", style: TextStyle(color: textColor)),
              secondary: Icon(Icons.all_inclusive, color: subtitleColor),
              value: "All Accounts",
              groupValue: account,
              activeColor: colorScheme.primary,
              onChanged: (v) => setState(() => account = v.toString()),
            ),
            ...widget.availableAccounts.map((a) {
              final isCash = a.type == "CASH";
              return RadioListTile(
                title: Text(a.name, style: TextStyle(color: textColor)),
                secondary: Icon(
                  isCash ? Icons.money : Icons.account_balance,
                  color: isCash
                      ? AppColors.incomeAmount
                      : AppColors.savingsPrimary,
                ),
                value: a.name,
                groupValue: account,
                activeColor: colorScheme.primary,
                onChanged: (v) => setState(() => account = v.toString()),
              );
            }),
          ],
        );

      /// DATE
      case 3:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                title: Text("Start Date", style: TextStyle(color: textColor)),
                subtitle: Text(
                  startDate == null
                      ? "Select date"
                      : startDate.toString().split(" ")[0],
                  style: TextStyle(color: subtitleColor),
                ),
                trailing: Icon(Icons.calendar_today, color: subtitleColor),
                onTap: pickStartDate,
              ),
              ListTile(
                title: Text("End Date", style: TextStyle(color: textColor)),
                subtitle: Text(
                  endDate == null
                      ? "Select date"
                      : endDate.toString().split(" ")[0],
                  style: TextStyle(color: subtitleColor),
                ),
                trailing: Icon(Icons.calendar_today, color: subtitleColor),
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