import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/constants/app_colors.dart'; 
// 👇 Make sure this path is correct based on your folder structure!
import '../data/goal_model.dart'; 

class CreateNewGoalScreen extends StatefulWidget {
  final GoalModel? existingGoal; 
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
  String? selectedAccountId; // Changed to match your model
  
  IconData selectedIcon = Icons.trending_up_rounded;
  Color selectedColor = Colors.green;

  // Assuming these are the Account IDs or Types you want to send
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

    // 1. Map from your ACTUAL GoalModel properties
    titleController = TextEditingController(text: widget.existingGoal?.title ?? "");
   targetController = TextEditingController(
    text: (widget.existingGoal?.targetAmount ?? 0) > 0 
        ? widget.existingGoal!.targetAmount.toString() 
        : ""
);
    selectedDate = widget.existingGoal?.targetDate;

    if (widget.existingGoal != null) {
      selectedCategory = widget.existingGoal!.category;
      
      // Safety check for accountId dropdown
      if (accountTypes.contains(widget.existingGoal!.accountId)) {
        selectedAccountId = widget.existingGoal!.accountId;
      }

      // 2. Figure out the right color and icon based on the category string!
      final matchedCategory = categories.firstWhere(
        (cat) => cat["name"] == selectedCategory,
        orElse: () => categories.first,
      );
      selectedIcon = matchedCategory["icon"];
      selectedColor = matchedCategory["color"];
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    super.dispose();
  }

  void _selectCategory(Map<String, dynamic> category) {
    setState(() {
      selectedCategory = category["name"];
      selectedIcon = category["icon"];
      selectedColor = category["color"];
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.headerGradientStart,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      _showSnackBar("Please select a deadline");
      return;
    }

    if (selectedAccountId == null) {
      _showSnackBar("Please select an account type");
      return;
    }

    // 3. Create the GoalModel exactly as your class expects it!
    final updatedGoal = GoalModel(
      // Keep existing IDs, or pass empty strings for new creations
      id: widget.existingGoal?.id ?? '', 
      userId: widget.existingGoal?.userId ?? '', // Usually handled by backend
      accountId: selectedAccountId!, 
      title: titleController.text.trim(),
      category: selectedCategory,
      targetAmount: double.parse(targetController.text),
      currentAmount: widget.existingGoal?.currentAmount ?? 0.0,
      targetDate: selectedDate!,
      status: widget.existingGoal?.status ?? 'active',
    );

    Navigator.pop(context, updatedGoal);
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
                  colors: [AppColors.headerGradientStart, AppColors.headerGradientEnd],
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
                      child: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    widget.existingGoal == null ? "Create New Goal" : "Edit Goal",
                    style: const TextStyle(
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
                        decoration: _inputDecoration("Goal Title", Icons.flag_rounded),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                        decoration: _inputDecoration("Target Amount", Icons.attach_money_rounded),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter target amount";
                          }
                          if (double.tryParse(value) == null) {
                            return "Please enter a valid number";
                          }
                          if (double.parse(value) <= 0) {
                            return "Amount must be greater than 0";
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, size: 20, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                selectedDate == null
                                    ? "Select Deadline"
                                    : DateFormat("dd MMM yyyy").format(selectedDate!),
                                style: TextStyle(
                                  color: selectedDate == null ? Colors.grey : AppColors.textPrimary,
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

                      /// ACCOUNT TYPE / ID
                      DropdownButtonFormField<String>(
                        value: selectedAccountId,
                        hint: const Text("Select Account", style: TextStyle(color: Colors.grey)),
                        dropdownColor: AppColors.cardBg,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration("Account", Icons.account_balance_wallet_rounded),
                        items: accountTypes.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedAccountId = value;
                          });
                        },
                        validator: (value) => value == null ? "Select an account" : null,
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.4,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final bool isSelected = selectedCategory == category["name"];

                          return GestureDetector(
                            onTap: () => _selectCategory(category),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? category["color"].withOpacity(0.2) : AppColors.cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? category["color"] : Colors.white12,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(category["icon"], size: 20, color: category["color"]),
                                  const SizedBox(height: 6),
                                  Text(
                                    category["name"],
                                    style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
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
                          child: Text(
                            widget.existingGoal == null ? "Save Goal" : "Update Goal",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}