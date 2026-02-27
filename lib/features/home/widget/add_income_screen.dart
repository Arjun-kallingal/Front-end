import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import 'add_expense_screen.dart';
import 'package:flutter/services.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  String selectedCategory = "Business";
  String amount = "";
  DateTime? selectedDate;

  final TextEditingController descriptionController = TextEditingController();

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
              isExpense: false,
              onIncomeTap: () {},
              onExpenseTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(),
                  ),
                );
              },
            ),

            /// BODY
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _amountCard(theme),
                    const SizedBox(height: 25),
                    Text("Category", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 20),
                    _categoryGrid(theme),
                    const SizedBox(height: 25),
                    _walletDropdown(theme),
                    const SizedBox(height: 25),
                    _textField(theme, "Description", "Add a note..."),
                    const SizedBox(height: 25),
                    _dateField(theme),
                    const SizedBox(height: 35),
                    _saveButton(theme),
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

  /// ================= AMOUNT =================
  Widget _amountCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Amount",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
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
              hintText: "0",
              hintStyle: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  /// ================= CATEGORY =================
  Widget _categoryGrid(ThemeData theme) {
    final categories = [
      {"name": "Salary", "icon": Icons.card_giftcard},
      {"name": "Freelance", "icon": Icons.laptop},
      {"name": "Investment", "icon": Icons.trending_up},
      {"name": "Business", "icon": Icons.business},
      {"name": "Other", "icon": Icons.more_horiz},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
                      color: theme.colorScheme.primary,
                      width: 2,
                    )
                  : Border.all(
                      color: theme.dividerColor,
                    ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat["icon"] as IconData,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
                ),
                const SizedBox(height: 8),
                Text(
                  cat["name"] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.colorScheme.primary : null,
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
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(15),
          value: selectedWallet,
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
  Widget _textField(ThemeData theme, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
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
        const SizedBox(height: 10),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
