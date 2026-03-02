import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import 'add_income_screen.dart';
import 'package:flutter/services.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  String selectedCategory = "Rent";
  String amount = "";
  DateTime? selectedDate;

  final TextEditingController descriptionController =
      TextEditingController();

  String selectedWallet = "Cash";

  final List<String> walletTypes = [
    "Cash",
    "Bank",
    "Credit Card",
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            TransactionHeader(
              isExpense: true,
              onIncomeTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddIncomeScreen(),
                  ),
                );
              },
              onExpenseTap: () {},
            ),

            /// FORM
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _amountCard(theme),
                    const SizedBox(height: 15),

                    Text(
                      "Category",
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 15),

                    _categoryGrid(theme),
                    const SizedBox(height: 15),

                    _walletDropdown(theme),
                    const SizedBox(height: 15),

                    _textField(theme, "Description", "Add a note..."),
                    const SizedBox(height: 15),

                    _dateField(theme),
                    const SizedBox(height: 25),

                    _saveButton(theme),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= AMOUNT =================
   Widget _amountCard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount",
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 5),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          decoration: InputDecoration(
            prefixText: "₹ ",
            prefixStyle: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            hintText: "0.00",
            hintStyle: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: theme.hintColor,
            ),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              amount = value;
            });
          },
        ),
      ],
    );
  }


  /// ================= CATEGORY =================
  Widget _categoryGrid(ThemeData theme) {
    final categories = [
      {"name": "Rent", "icon": Icons.home},
      {"name": "Food", "icon": Icons.restaurant},
      {"name": "Transport", "icon": Icons.directions_car},
      {"name": "Shopping", "icon": Icons.shopping_bag},
      {"name": "Entertainment", "icon": Icons.movie},
      {"name": "Bills", "icon": Icons.receipt_long},
      {"name": "Healthcare", "icon": Icons.favorite},
      {"name": "Education", "icon": Icons.school},
      {"name": "Other", "icon": Icons.more_horiz},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isSelected = selectedCategory == cat["name"];

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = cat["name"] as String;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(
                      color: theme.colorScheme.error,
                      width: 1,
                    )
                  : Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat["icon"] as IconData,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.error
                      : theme.iconTheme.color,
                ),
                const SizedBox(height: 5),
                Text(
                  cat["name"] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= WALLET =================
  Widget _walletDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Wallet Type", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: selectedWallet,
           borderRadius: BorderRadius.circular(15),

          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            
          ),
          items: walletTypes.map((wallet) {
            return DropdownMenuItem(
              value: wallet,
              child: Text(wallet),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedWallet = value!;
            });
          },
        ),
      ],
    );
  }

  /// ================= DESCRIPTION =================
  Widget _textField(
      ThemeData theme, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),

        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  /// ================= DATE =================
  Widget _dateField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
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
                horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? "Select Date"
                      : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ================= SAVE =================
  Widget _saveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          /// ✅ 1️⃣ EMPTY CHECK
          if (amount.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please enter amount"),
              ),
            );
            return;
          }

          /// ✅ 2️⃣ INTEGER VALIDATION
          final intAmount = int.tryParse(amount);
          if (intAmount == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid amount"),
              ),
            );
            return;
          }

          /// ✅ 3️⃣ DATE VALIDATION (Optional but Recommended)
          if (selectedDate == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please select date"),
              ),
            );
            return;
          }

          /// ✅ If All Valid → Continue Saving
          debugPrint("Amount: $intAmount");
          debugPrint("Category: $selectedCategory");
          debugPrint("WalletType: $selectedWallet");
          debugPrint("Description: ${descriptionController.text}");
          debugPrint("Date: $selectedDate");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Transaction Saved Successfully"),
            ),
          );
        },
        child: const Text(
          "Save Transaction",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}