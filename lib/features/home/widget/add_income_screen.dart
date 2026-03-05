import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'add_expense_screen.dart';
import 'add_transaction_screen.dart';
import 'package:front_end/core/services/mock_auth.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  String? _currentUserId;
  String amount = "";
  String selectedCategory = "Salary";
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isFetchingAccounts = true;

  List<AccountModel> _accounts = [];
  String? _selectedAccountId;

  final TextEditingController descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {"name": "Salary", "icon": Icons.payments},
    {"name": "Freelance", "icon": Icons.laptop_mac},
    {"name": "Investment", "icon": Icons.trending_up},
    {"name": "Business", "icon": Icons.storefront},
    {"name": "Other", "icon": Icons.add_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    // Use the static constant directly (no await/parentheses)
    final userid = MockAuthService.currentUserId;

    if (userid.isNotEmpty && mounted) {
      setState(() {
        _currentUserId = userid;
      });

      // NOW trigger the wallet fetch
      _loadWallets();
    } else {
      _showSnackBar("Session expired. Please log in again.");
    }
  }

  Future<void> _loadWallets() async {
    if (_currentUserId == null) return;
    try {
      final result = await AccountService.getAccountDashboard(_currentUserId!);
      if (!mounted) return;
      setState(() {
        _accounts = result['accounts'];
        if (_accounts.isNotEmpty) _selectedAccountId = _accounts.first.id;
        _isFetchingAccounts = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isFetchingAccounts = false);
    }
  }

  Future<void> _handleSave() async {
    if (_selectedAccountId == null ||
        amount.isEmpty ||
        double.tryParse(amount) == 0) {
      _showSnackBar("Please enter a valid amount", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await TransactionService.processTransaction(
        userId: _currentUserId!,
        accountId: _selectedAccountId!,
        amount: amount,
        type: "INCOME", // Make sure this is uppercase to match your Ledger enum
        category: selectedCategory,
        description: descriptionController.text,
      );

      if (mounted && result['success']) {
        _showSnackBar("Income saved successfully!", isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar(result['message'] ?? "Failed to save");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            TransactionHeader(
              isExpense: false,
              onIncomeTap: () {},
              onExpenseTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
            ),
            Expanded(
              child: _isFetchingAccounts
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _amountField(theme, Colors.green),
                          const SizedBox(height: 25),
                          _walletDropdown(),
                          const SizedBox(height: 25),
                          const Text("Category",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 12),
                          _categoryGrid(Colors.green),
                          const SizedBox(height: 25),
                          _descriptionField(),
                          const SizedBox(height: 25),
                          _datePicker(),
                          const SizedBox(height: 35),
                          _saveButton(Colors.green, "Save Income"),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSED WIDGETS (Slightly Green Themed) ---
  Widget _amountField(ThemeData theme, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Amount", style: TextStyle(color: Colors.grey)),
      TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
        ],
        style: theme.textTheme.headlineLarge
            ?.copyWith(fontWeight: FontWeight.bold, color: color),
        decoration: const InputDecoration(
            prefixText: "₹ ", border: InputBorder.none, hintText: "0.00"),
        onChanged: (val) => amount = val,
      ),
    ]);
  }

  Widget _walletDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Select Wallet", style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _selectedAccountId,
        isExpanded: true,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: _accounts
            .map(
                (acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name)))
            .toList(),
        onChanged: (val) => setState(() => _selectedAccountId = val),
      ),
    ]);
  }

  Widget _categoryGrid(Color activeColor) {
    return LayoutBuilder(builder: (context, constraints) {
      double itemWidth = (constraints.maxWidth - 24) / 3;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _categories.map((cat) {
          bool isSel = selectedCategory == cat['name'];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: itemWidth,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: isSel ? activeColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isSel ? activeColor : Colors.grey.shade300)),
              child: Column(children: [
                Icon(cat['icon'],
                    color: isSel ? Colors.white : Colors.grey[700], size: 22),
                const SizedBox(height: 6),
                Text(cat['name'],
                    style: TextStyle(
                        fontSize: 12,
                        color: isSel ? Colors.white : Colors.black87)),
              ]),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _descriptionField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Description", style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 8),
      TextField(
          controller: descriptionController,
          decoration: InputDecoration(
              hintText: "Add a note...",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ]);
  }

  Widget _datePicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Date", style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 8),
      InkWell(
        onTap: () async {
          final d = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100));
          if (d != null) setState(() => selectedDate = d);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(DateFormat('dd MMM, yyyy').format(selectedDate)),
            const Icon(Icons.calendar_month, color: Colors.grey)
          ]),
        ),
      ),
    ]);
  }

  Widget _saveButton(Color color, String label) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: _isLoading ? null : _handleSave,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
      ),
    );
  }
}
