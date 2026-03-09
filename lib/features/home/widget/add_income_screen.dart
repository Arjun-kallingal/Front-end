// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:front_end/core/models/account_model.dart';
// import 'package:front_end/core/services/account_service.dart';
// import 'package:front_end/core/services/transaction_service.dart';
// import 'package:front_end/core/services/mock_auth.dart';

// class AddTransactionScreen extends StatefulWidget {
//   final bool initialIsExpense;

//   const AddTransactionScreen({
//     super.key,
//     this.initialIsExpense = false,
//   });

//   @override
//   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
// }

// class _AddTransactionScreenState extends State<AddTransactionScreen> {
//   String? _currentUserId;
//   String amount = "";
//   DateTime selectedDate = DateTime.now();
//   bool _isLoading = false;
//   bool _isFetchingAccounts = true;
//   late bool _isExpense;

//   List<AccountModel> _accounts = [];
//   String? _selectedAccountId;
//   String selectedCategory = "";

//   final TextEditingController descriptionController = TextEditingController();

//   final List<Map<String, dynamic>> _incomeCategories = [
//     {"name": "Salary", "icon": Icons.payments},
//     {"name": "Freelance", "icon": Icons.laptop_mac},
//     {"name": "Investment", "icon": Icons.trending_up},
//     {"name": "Business", "icon": Icons.storefront},
//     {"name": "Other", "icon": Icons.add_circle_outline},
//   ];

//   final List<Map<String, dynamic>> _expenseCategories = [
//     {"name": "Food", "icon": Icons.restaurant},
//     {"name": "Transport", "icon": Icons.directions_bus},
//     {"name": "Rent", "icon": Icons.home},
//     {"name": "Shopping", "icon": Icons.shopping_bag},
//     {"name": "Bills", "icon": Icons.bolt},
//     {"name": "Other", "icon": Icons.more_horiz},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _isExpense = widget.initialIsExpense;
//     selectedCategory = _isExpense ? "Food" : "Salary";
//     _initializeUser();
//   }

//   @override
//   void dispose() {
//     descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeUser() async {
//     final userid = MockAuthService.currentUserId;
//     if (userid.isNotEmpty && mounted) {
//       setState(() => _currentUserId = userid);
//       _loadWallets();
//     }
//   }

//   Future<void> _loadWallets() async {
//     if (_currentUserId == null) return;
//     try {
//       final result = await AccountService.getAccountDashboard(_currentUserId!);
//       if (!mounted) return;
//       setState(() {
//         _accounts = result['accounts'];
//         if (_accounts.isNotEmpty) _selectedAccountId = _accounts.first.id;
//         _isFetchingAccounts = false;
//       });
//     } catch (e) {
//       if (mounted) setState(() => _isFetchingAccounts = false);
//     }
//   }

//   void _toggleType(bool isExpense) {
//     if (_isExpense == isExpense) return;
//     HapticFeedback.lightImpact();
//     setState(() {
//       _isExpense = isExpense;
//       selectedCategory = isExpense ? "Food" : "Salary";
//     });
//   }

//   Future<void> _handleSave() async {
//     if (_selectedAccountId == null || amount.isEmpty || double.tryParse(amount) == 0) {
//       _showSnackBar("Please enter a valid amount", isError: true);
//       return;
//     }
//     setState(() => _isLoading = true);
//     try {
//       final result = await TransactionService.processTransaction(
//         userId: _currentUserId!,
//         accountId: _selectedAccountId!,
//         amount: amount,
//         type: _isExpense ? "EXPENSE" : "INCOME",
//         category: selectedCategory,
//         description: descriptionController.text,
//       );
//       if (mounted && result['success']) {
//         Navigator.pop(context, true);
//       } else {
//         _showSnackBar(result['message'] ?? "Failed to save");
//       }
//     } catch (e) {
//       _showSnackBar("Error: $e");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _showSnackBar(String message, {bool isError = true}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: isError ? Colors.black87 : Colors.green, behavior: SnackBarBehavior.floating),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// HEADER
//             Padding(
//               padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
//                   ),
//                   const Text(
//                     "Add Transaction",
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
//                   ),
//                 ],
//               ),
//             ),

//             /// BORDER TOGGLE
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.grey.shade100),
//                 ),
//                 padding: const EdgeInsets.all(4),
//                 child: Row(
//                   children: [
//                     Expanded(child: _buildTab("Income", !_isExpense, () => _toggleType(false))),
//                     const SizedBox(width: 4),
//                     Expanded(child: _buildTab("Expense", _isExpense, () => _toggleType(true))),
//                   ],
//                 ),
//               ),
//             ),

//             Expanded(
//               child: _isFetchingAccounts
//                   ? const Center(child: CircularProgressIndicator(color: Colors.black87))
//                   : SingleChildScrollView(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           /// 1. AMOUNT FIELD FIRST
//                           _amountField(),
//                           const SizedBox(height: 24),

//                           /// 2. DESCRIPTION NEXT
//                           _descriptionField(),
//                           const SizedBox(height: 24),
                          
//                           /// 3. SELECT WALLET
//                           _walletDropdown(),
//                           const SizedBox(height: 24),

//                           /// 4. CATEGORY NEXT
//                           const Text("Category", style: TextStyle(color: Colors.grey, fontSize: 14)),
//                           const SizedBox(height: 12),
//                           _categoryGrid(),
//                           const SizedBox(height: 24),

//                           /// 5. DATE LAST
//                           _datePicker(),
//                           const SizedBox(height: 40),

//                           _saveButton(),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(String title, bool isActive, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: isActive ? Colors.black87 : Colors.transparent, width: 1.5),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? Colors.black87 : Colors.grey.shade400),
//         ),
//       ),
//     );
//   }

//   Widget _amountField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Amount", style: TextStyle(color: Colors.grey, fontSize: 15)),
//         const SizedBox(height: 8),
//         TextField(
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
//           style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 24),
//           decoration: InputDecoration(
//             prefixText: "₹ ",
//             hintText: "0.00",
//             contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black87)),
//           ),
//           onChanged: (val) => amount = val,
//         ),
//       ],
//     );
//   }

//   Widget _descriptionField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Description", style: TextStyle(color: Colors.grey)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: descriptionController,
//           decoration: InputDecoration(
//             hintText: "Add a note...",
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black87)),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _walletDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Select Wallet", style: TextStyle(color: Colors.grey)),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: _selectedAccountId,
//           isExpanded: true,
//           decoration: InputDecoration(
//             prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
//             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black87)),
//           ),
//           items: _accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name))).toList(),
//           onChanged: (val) => setState(() => _selectedAccountId = val),
//         ),
//       ],
//     );
//   }

//   Widget _categoryGrid() {
//     List<Map<String, dynamic>> cats = _isExpense ? _expenseCategories : _incomeCategories;
//     return Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       children: cats.map((cat) {
//         bool isSel = selectedCategory == cat['name'];
//         return GestureDetector(
//           onTap: () => setState(() => selectedCategory = cat['name']),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color: isSel ? Colors.black87 : Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(cat['icon'], color: isSel ? Colors.white : Colors.grey.shade600, size: 18),
//                 const SizedBox(width: 8),
//                 Text(
//                   cat['name'],
//                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? Colors.white : Colors.black87),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _datePicker() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Date", style: TextStyle(color: Colors.grey)),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () async {
//             final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
//             if (d != null) setState(() => selectedDate = d);
//           },
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(DateFormat('dd MMM, yyyy').format(selectedDate)),
//                 const Icon(Icons.calendar_month, color: Colors.grey),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _saveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.black87,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         onPressed: _isLoading ? null : _handleSave,
//         child: _isLoading
//             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//             : Text("Save ${_isExpense ? 'Expense' : 'Income'}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//       ),
//     );
//   }
// }