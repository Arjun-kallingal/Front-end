import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/services/mock_auth.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool initialIsExpense;

  const AddTransactionScreen({super.key, this.initialIsExpense = false});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String? _currentUserId;
  String amount = "";
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isFetchingAccounts = true;
  late bool _isExpense;

  List<AccountModel> _accounts = [];
  String? _selectedAccountId;
  String? _selectedAccountName; // Added to display the selected name in your custom box
  String? _selectedCategory;
  bool _showAccountOptions = false; // Controls your custom dropdown visibility

  final TextEditingController descriptionController = TextEditingController();

  // Colorful icons for Income
  final List<Map<String, dynamic>> _incomeCategories = [
    {"name": "Salary", "icon": Icons.payments, "color": Colors.green.shade800},
    {"name": "Freelance", "icon": Icons.laptop_mac, "color": Colors.teal.shade800},
    {"name": "Invest", "icon": Icons.trending_up, "color": Colors.blue.shade800},
    {"name": "Business", "icon": Icons.storefront, "color": Colors.orange.shade800},
    {"name": "Rental", "icon": Icons.home, "color": Colors.indigo.shade800},
    {"name": "Grants", "icon": Icons.card_giftcard, "color": Colors.amber.shade900},
    {"name": "Refunds", "icon": Icons.assignment_return, "color": Colors.cyan.shade900},
    {"name": "Other", "icon": Icons.more_horiz, "color": Colors.grey.shade800},
  ];

  // Colorful icons for Expense
  final List<Map<String, dynamic>> _expenseCategories = [
    {"name": "Food", "icon": Icons.restaurant, "color": Colors.orange.shade900},
    {"name": "Transport", "icon": Icons.directions_bus, "color": Colors.blue.shade900},
    {"name": "Shopping", "icon": Icons.shopping_bag, "color": Colors.pink.shade900},
    {"name": "Bills", "icon": Icons.bolt, "color": Colors.yellow.shade900},
    {"name": "Health", "icon": Icons.medical_services, "color": Colors.red.shade900},
    {"name": "Travel", "icon": Icons.flight, "color": Colors.cyan.shade800},
    {"name": "Edu", "icon": Icons.school, "color": Colors.purple.shade800},
    {"name": "Fun", "icon": Icons.movie, "color": Colors.deepPurple.shade800},
    {"name": "Groceries", "icon": Icons.local_grocery_store, "color": Colors.green.shade900},
    {"name": "Gifts", "icon": Icons.card_giftcard, "color": Colors.deepOrange.shade800},
    {"name": "Rent", "icon": Icons.home_work, "color": Colors.brown.shade800},
    {"name": "Other", "icon": Icons.more_horiz, "color": Colors.grey.shade800},
  ];

  // Colors for borders
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _darkRed = const Color(0xFFB71C1C);

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _initializeUser();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final userid = MockAuthService.currentUserId;

    if (userid.isNotEmpty && mounted) {
      setState(() {
        _currentUserId = userid;
      });
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
        if (_accounts.isNotEmpty) {
          _selectedAccountId = _accounts.first.id;
          _selectedAccountName = _accounts.first.name; // Automatically select the first account
        }
        _isFetchingAccounts = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isFetchingAccounts = false);
    }
  }

  Future<void> _handleSave() async {
    if (_selectedAccountId == null || amount.isEmpty || double.tryParse(amount) == 0 || _selectedCategory == null) {
      _showSnackBar("Please fill all required fields properly", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await TransactionService.processTransaction(
        userId: _currentUserId!,
        accountId: _selectedAccountId!,
        amount: amount,
        type: _isExpense ? "EXPENSE" : "INCOME",
        category: _selectedCategory!,
        description: descriptionController.text,
      );

      if (mounted && result['success']) {
        _showSnackBar("${_isExpense ? 'Expense' : 'Income'} saved successfully!", isError: false);
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleType(bool isExpense) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isExpense = isExpense;
      _selectedCategory = null;
      _showAccountOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTopToggle(),
            
            _isFetchingAccounts
                ? const Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Amount"),
                          _buildDefaultField(hint: "0.00", isAmount: true),
                          const SizedBox(height: 16),
                          _buildLabel("Description (Optional)"),
                          _buildDefaultField(controller: descriptionController, hint: "What was this for?"),
                          const SizedBox(height: 16),
                          _buildLabel("Date"),
                          _datePicker(),
                          const SizedBox(height: 24),
                          
                          // Restored your custom UI here
                          _buildLabel("Account Type"),
                          _buildAccountSelectorBox(),
                          if (_showAccountOptions) _buildAccountList(),
                          
                          const SizedBox(height: 24),
                          _buildLabel("Category"),
                          _buildTwoLineCategories(),
                        ],
                      ),
                    ),
                  ),
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          const Text("Add Transaction", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildTopToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 42,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _toggleBtn("Income", !_isExpense, _darkGreen),
            _toggleBtn("Expense", _isExpense, _darkRed),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, Color borderColor) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _toggleType(label == "Expense"),
        child: Container(
          margin: const EdgeInsets.all(4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active ? Border.all(color: borderColor, width: 2.5) : null,
          ),
          child: Text(
            label, 
            style: TextStyle(
              color: active ? borderColor : Colors.grey, 
              fontWeight: FontWeight.bold
            )
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultField({TextEditingController? controller, required String hint, bool isAmount = false}) {
    return TextField(
      controller: controller,
      keyboardType: isAmount ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      inputFormatters: isAmount ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))] : [],
      style: TextStyle(fontSize: isAmount ? 22 : 16, fontWeight: isAmount ? FontWeight.bold : FontWeight.normal),
      decoration: InputDecoration(
        prefixText: isAmount ? "₹ " : null,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onChanged: isAmount ? (val) => amount = val : null,
    );
  }

  Widget _datePicker() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
        if (d != null) setState(() => selectedDate = d);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMM, yyyy').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
            const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Your custom selector box, now using _selectedAccountName
  Widget _buildAccountSelectorBox() {
    return InkWell(
      onTap: () => setState(() => _showAccountOptions = !_showAccountOptions),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedAccountName ?? "Select Account", style: const TextStyle(fontWeight: FontWeight.w600)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Your custom list, now mapping through live API _accounts instead of hardcoded strings
  Widget _buildAccountList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: _accounts.map((acc) => ListTile(
          dense: true,
          title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: () => setState(() {
            _selectedAccountId = acc.id; // Save the ID for the API
            _selectedAccountName = acc.name; // Save the name for the UI
            _showAccountOptions = false; // Close the dropdown
          }),
        )).toList(),
      ),
    );
  }

  Widget _buildTwoLineCategories() {
    final cats = _isExpense ? _expenseCategories : _incomeCategories;
    return SizedBox(
      height: 180,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final item = cats[index];
          bool isSel = _selectedCategory == item['name'];

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = item['name']),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? Colors.black87 : Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], color: item['color'], size: 28),
                  const SizedBox(height: 4),
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickySaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade100)),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text("Save ${_isExpense ? 'Expense' : 'Income'}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)));
}