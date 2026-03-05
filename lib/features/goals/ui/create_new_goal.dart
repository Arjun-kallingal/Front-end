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
  State<CreateNewGoalScreen> createState() =>
      _CreateNewGoalScreenState();
}

class _CreateNewGoalScreenState
    extends State<CreateNewGoalScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController targetController;
  late TextEditingController savedController;

  DateTime? selectedDate;
  bool dateError = false;

  String selectedCategory = "Savings";
  String? selectedAccountType;

  IconData selectedIcon = Icons.trending_up_rounded;
  Color selectedColor = Colors.green;

  final List<String> accountTypes = ["Cash", "Account"];

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

    savedController =
        TextEditingController(text: widget.existingGoal?["saved"]?.toString() ?? "0");

    selectedDate = widget.existingGoal?["deadline"];

    if (widget.existingGoal != null) {
      selectedIcon = widget.existingGoal!["icon"];
      selectedColor = widget.existingGoal!["color"];
      selectedCategory = widget.existingGoal!["category"];
      selectedAccountType = widget.existingGoal!["accountType"];
    }
  }

  void _selectCategory(Map<String, dynamic> category) {
    setState(() {
      selectedCategory = category["name"];
      selectedIcon = category["icon"];
      selectedColor = category["color"];
    });
  }

  void _saveGoal() {
    setState(() {
      dateError = selectedDate == null;
    });

    if (!_formKey.currentState!.validate() || selectedDate == null) {
      return;
    }

    final goal = {
      "title": titleController.text,
      "saved": double.tryParse(savedController.text) ?? 0.0,
      "target": double.tryParse(targetController.text) ?? 0.0,
      "deadline": selectedDate,
      "icon": selectedIcon,
      "color": selectedColor,
      "category": selectedCategory,
      "accountType": selectedAccountType,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

                      /// GOAL TITLE
                      TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          "Goal Title",
                          Icons.flag_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter goal title";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      /// TARGET AMOUNT
                      TextFormField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          "Target Amount",
                          Icons.attach_money_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter target amount";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

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
                              dateError = false;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dateError ? Colors.red : Colors.transparent,
                            ),
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

                      if (dateError)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            "Please select a deadline",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),

                      const SizedBox(height: 18),

                      /// ACCOUNT TYPE (FIXED)
                      DropdownButtonFormField<String>(
                        value: selectedAccountType,
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          "Account Type",
                          Icons.account_balance_wallet_rounded,
                        ),
                        hint: const Text(
                          "Account Type",
                          style: TextStyle(color: Colors.grey),
                        ),
                        items: accountTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAccountType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please select account type";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      /// CATEGORY GRID
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.9,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final bool isSelected =
                              selectedCategory == category["name"];

                          return GestureDetector(
                            onTap: () => _selectCategory(category),
                            child: Container(
                              padding: const EdgeInsets.all(6),
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
                                      size: 18,
                                      color: category["color"]),
                                  const SizedBox(height: 4),
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

                      const SizedBox(height: 20),

                      /// SAVED AMOUNT
                      TextFormField(
                        controller: savedController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          "Saved Amount",
                          Icons.savings_rounded,
                        ),
                      ),

                      const SizedBox(height: 35),

                      /// SAVE BUTTON
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveGoal,
                          child: const Text(
                            "Save Goal",
                            style: TextStyle(color: Colors.white),
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
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}