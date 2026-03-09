// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:front_end/core/models/account_model.dart';
// import 'package:front_end/core/services/account_service.dart';
// import 'package:front_end/core/services/transaction_service.dart';
// import 'package:front_end/core/services/mock_auth.dart';

// class AddExpenseScreen extends StatefulWidget {
//   const AddExpenseScreen({super.key});

//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }

// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   String? _currentUserId;
//   String amount = "";
//   String selectedCategory = "Food";
//   DateTime selectedDate = DateTime.now();
//   bool _isLoading = false;
//   bool _isFetchingAccounts = true;

//   List<AccountModel> _accounts = [];
//   String? _selectedAccountId;

//   final TextEditingController descriptionController = TextEditingController();

//   final List<Map<String, dynamic>> _categories = [
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
//     } else {
//       _showSnackBar("Session expired. Please log in again.");
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
//         type: "EXPENSE",
//         category: selectedCategory,
//         description: descriptionController.text,
//       );
//       if (mounted && result['success']) {
//         _showSnackBar("Expense saved!", isError: false);
//         Navigator.pop(context, true); // This closes the parent screen
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
//     if (_isFetchingAccounts) {
//       return const Center(child: CircularProgressIndicator(color: Colors.black87));
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSectionLabel("Amount"),
//           _amountField(),
//           const SizedBox(height: 24),
          
//           _buildSectionLabel("Select Wallet"),
//           _walletDropdown(),
//           const SizedBox(height: 24),

//           _buildSectionLabel("Category"),
//           const SizedBox(height: 12),
//           _categoryGrid(),
//           const SizedBox(height: 24),

//           _buildSectionLabel("Description"),
//           _descriptionField(),
//           const SizedBox(height: 24),

//           _buildSectionLabel("Date"),
//           _datePicker(),
//           const SizedBox(height: 40),

//           _saveButton(),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionLabel(String label) => Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600));

//   Widget _amountField() {
//     return TextField(
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
//       style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 32),
//       decoration: InputDecoration(
//         prefixText: "₹ ",
//         prefixStyle: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 32),
//         hintText: "0",
//         enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
//         focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2)),
//       ),
//       onChanged: (val) => amount = val,
//     );
//   }

//   Widget _walletDropdown() {
//     return DropdownButtonFormField<String>(
//       value: _selectedAccountId,
//       isExpanded: true,
//       icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.symmetric(vertical: 8),
//         enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
//         focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
//       ),
//       items: _accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.w500)))).toList(),
//       onChanged: (val) => setState(() => _selectedAccountId = val),
//     );
//   }

//   Widget _categoryGrid() {
//     return Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       children: _categories.map((cat) {
//         bool isSel = selectedCategory == cat['name'];
//         return GestureDetector(
//           onTap: () {
//             HapticFeedback.lightImpact();
//             setState(() => selectedCategory = cat['name']);
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(color: isSel ? Colors.black87 : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(cat['icon'], color: isSel ? Colors.white : Colors.grey.shade600, size: 18),
//                 const SizedBox(width: 8),
//                 Text(cat['name'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSel ? Colors.white : Colors.black87)),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _descriptionField() {
//     return TextField(
//       controller: descriptionController,
//       style: const TextStyle(fontWeight: FontWeight.w500),
//       decoration: InputDecoration(
//         hintText: "What was this for?",
//         hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
//         enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
//         focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87)),
//       ),
//     );
//   }

//   Widget _datePicker() {
//     return InkWell(
//       onTap: () async {
//         final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
//         if (d != null) setState(() => selectedDate = d);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(DateFormat('dd MMMM yyyy').format(selectedDate), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
//             Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600, size: 18)
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _saveButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 54,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
//         onPressed: _isLoading ? null : _handleSave,
//         child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Save Expense", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//       ),
//     );
//   }
// }