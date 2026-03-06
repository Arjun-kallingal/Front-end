import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class CreateNewGoalScreen extends StatefulWidget {
  final Map<String, dynamic>? existingGoal;
  final int? index;

  const CreateNewGoalScreen({
    Key? key,
    this.existingGoal,
    this.index,
  }) : super(key: key);

  @override
  State<CreateNewGoalScreen> createState() => _CreateNewGoalScreenState();
}

class _CreateNewGoalScreenState extends State<CreateNewGoalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController targetController;

  DateTime? selectedDate;

  String selectedCategory = "Savings";
  String? selectedAccountType;
  String? transactionType;

  IconData selectedIcon = Icons.trending_up_rounded;
  Color selectedColor = Colors.green;

  final List<String> accountTypes = ["Cash", "Account"];

  final List<String> transactionTypes = [
    "Reserved",
    "Expense",
    "Transaction"
  ];

  final List<Map<String, dynamic>> categories = [
    {"name": "Savings", "icon": Icons.trending_up_rounded, "color": Colors.green},
    {"name": "Emergency", "icon": Icons.error_outline_rounded, "color": Colors.red},
    {"name": "Bills", "icon": Icons.receipt_long_rounded, "color": Colors.orange},
    {"name": "Business", "icon": Icons.work_outline_rounded, "color": Colors.blue},
    {"name": "Travel", "icon": Icons.flight_takeoff_rounded, "color": Colors.purple},
    {"name": "Other", "icon": Icons.category_rounded, "color": Colors.teal},
  ];

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.existingGoal?["title"] ?? "");

    targetController =
        TextEditingController(text: widget.existingGoal?["target"]?.toString() ?? "");

    selectedDate = widget.existingGoal?["deadline"];

    if (widget.existingGoal != null) {
      selectedIcon = widget.existingGoal!["icon"];
      selectedColor = widget.existingGoal!["color"];
      selectedCategory = widget.existingGoal!["category"];
      selectedAccountType = widget.existingGoal!["accountType"];
      transactionType = widget.existingGoal!["transactionType"];
    }
  }

  void _selectCategory(Map<String, dynamic> category) {
    setState(() {
      selectedCategory = category["name"];
      selectedIcon = category["icon"];
      selectedColor = category["color"];
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Text(
            "Notification",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      _showAlert("Please select a deadline");
      return;
    }

    final goal = {
      "title": titleController.text,
      "target": double.tryParse(targetController.text) ?? 0.0,
      "deadline": selectedDate,
      "icon": selectedIcon,
      "color": selectedColor,
      "category": selectedCategory,
      "accountType": selectedAccountType,
      "transactionType": transactionType,
    };

    Navigator.pop(context, goal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.headerGradientStart,
                    AppColors.headerGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const CircleAvatar(
                      backgroundColor: AppColors.profileAvatarBg,
                      child: Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Create New Goal",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [

                      /// SECTION TITLE
                      const Text(
                        "Goal Details",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// GOAL TITLE
                      TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration:
                            _inputDecoration("Goal Title", Icons.flag_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter goal title";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// TARGET AMOUNT
                      TextFormField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                            "Target Amount", Icons.attach_money_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter target amount";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      /// DEADLINE
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  size: 20, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                selectedDate == null
                                    ? "Select Deadline"
                                    : DateFormat("dd MMM yyyy")
                                        .format(selectedDate!),
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? Colors.grey
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// ACCOUNT SECTION
                      const Text(
                        "Account Information",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// ACCOUNT TYPE
                      DropdownButtonFormField<String>(
                        value: selectedAccountType,
                        hint: const Text(
                          "Select Account Type",
                          style: TextStyle(color: Colors.grey),
                        ),
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                            "Account Type",
                            Icons.account_balance_wallet_rounded),
                        items: accountTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAccountType = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Select account type" : null,
                      ),

                      const SizedBox(height: 16),

                      /// TRANSACTION TYPE
                      DropdownButtonFormField<String>(
                        value: transactionType,
                        hint: const Text(
                          "Select Transaction Type",
                          style: TextStyle(color: Colors.grey),
                        ),
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration:
                            _inputDecoration("Transaction Type", Icons.swap_horiz),
                        items: transactionTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            transactionType = value;
                          });

                          if (value == "Expense") {
                            _showAlert("Your amount removed from the reserved amount");
                          }

                          if (value == "Reserved") {
                            _showAlert("Amount moved to reserved");
                          }
                        },
                        validator: (value) =>
                            value == null ? "Select transaction type" : null,
                      ),

                      const SizedBox(height: 25),

                      /// CATEGORY TITLE
                      const Text(
                        "Goal Category",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 14),

                      /// CATEGORY GRID
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.4,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final bool isSelected =
                              selectedCategory == category["name"];

                          return GestureDetector(
                            onTap: () => _selectCategory(category),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category["color"].withOpacity(0.2)
                                    : AppColors.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? category["color"]
                                      : Colors.white12,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(category["icon"],
                                      size: 20,
                                      color: category["color"]),
                                  const SizedBox(height: 6),
                                  Text(
                                    category["name"],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      /// SAVE BUTTON
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedColor,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _saveGoal,
                          child: const Text(
                            "Save Goal",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      filled: true,
      fillColor: AppColors.cardBg,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}