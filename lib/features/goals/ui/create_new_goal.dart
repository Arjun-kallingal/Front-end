import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// --- SERVICE & MODEL IMPORTS ---
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/mock_auth.dart';

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

  // --- Backend State ---
  late final GoalService _goalService = GoalService(
    baseUrl: "http://localhost:5000/api", // Use 10.0.2.2 for Android Emulator
    getToken: () async => null,
  );

  String? _currentUserId;
  bool _isFetchingAccounts = true;
  bool _isSaving = false;
  List<AccountModel> _accounts = [];

  // --- UI State ---
  DateTime? selectedDate;
  String selectedCategory = "Savings";
  String? selectedAccountId;
  bool _showAccountOptions = false;
  String? _selectedAccountName;
  
  IconData selectedIcon = Icons.trending_up_rounded;

  final List<Map<String, dynamic>> categories = [
    {"name": "Savings", "icon": Icons.trending_up_rounded, "color": Colors.green.shade800},
    {"name": "Emergency", "icon": Icons.error_outline_rounded, "color": Colors.red.shade800},
    {"name": "Bills", "icon": Icons.receipt_long_rounded, "color": Colors.orange.shade800},
    {"name": "Business", "icon": Icons.work_outline_rounded, "color": Colors.blue.shade800},
    {"name": "Travel", "icon": Icons.flight_takeoff_rounded, "color": Colors.purple.shade800},
    {"name": "Other", "icon": Icons.category_rounded, "color": Colors.grey.shade800},
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.existingGoal?.title ?? "");
    targetController = TextEditingController(
        text: (widget.existingGoal?.targetAmount ?? 0) > 0
            ? widget.existingGoal!.targetAmount.toString()
            : "");
    selectedDate = widget.existingGoal?.targetDate;

    if (widget.existingGoal != null) {
      selectedCategory = widget.existingGoal!.category;
      selectedAccountId = widget.existingGoal!.accountId;

      final matchedCategory = categories.firstWhere(
        (cat) => cat["name"] == selectedCategory,
        orElse: () => categories.first,
      );
      selectedIcon = matchedCategory["icon"];
    }

    _initializeUser();
  }

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    super.dispose();
  }

  // --- API LOGIC ---

  Future<void> _initializeUser() async {
    final userid = MockAuthService.currentUserId;
    if (userid.isNotEmpty && mounted) {
      setState(() => _currentUserId = userid);
      _loadAccounts();
    }
  }

  Future<void> _loadAccounts() async {
    try {
      final result = await AccountService.getAccountDashboard(_currentUserId!);
      if (!mounted) return;
      
      setState(() {
        _accounts = result['accounts'];
        
        if (selectedAccountId == null && _accounts.isNotEmpty) {
          selectedAccountId = _accounts.first.id;
          _selectedAccountName = _accounts.first.name;
        } else if (selectedAccountId != null && _accounts.isNotEmpty) {
          final acc = _accounts.firstWhere((a) => a.id == selectedAccountId, orElse: () => _accounts.first);
          _selectedAccountName = acc.name;
        }
        _isFetchingAccounts = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isFetchingAccounts = false);
    }
  }

  void _saveGoal() async {
    if (!_formKey.currentState!.validate() || selectedDate == null || selectedAccountId == null) {
      _showSnackBar(selectedDate == null ? "Please select a deadline" : "Please fill all fields", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final goalToSave = GoalModel(
      id: widget.existingGoal?.id ?? '',
      userId: _currentUserId!,
      accountId: selectedAccountId!,
      title: titleController.text.trim(),
      category: selectedCategory,
      targetAmount: double.parse(targetController.text),
      currentAmount: widget.existingGoal?.currentAmount ?? 0.0,
      targetDate: selectedDate!,
      status: widget.existingGoal?.status ?? 'active',
    );

    try {
      await _goalService.createGoal(goalToSave);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("Error saving goal: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
      );

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          ),
          Text(
            widget.existingGoal == null ? "Create New Goal" : "Edit Goal",
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
        ],
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
            backgroundColor: Colors.blue, // Changed from black to blue
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _isSaving ? null : _saveGoal,
          child: _isSaving 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(widget.existingGoal == null ? "Save Goal" : "Update Goal", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildAccountSelectorBox() {
    return InkWell(
      onTap: () => setState(() => _showAccountOptions = !_showAccountOptions),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_selectedAccountName ?? "Select Account", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

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
          title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          onTap: () => setState(() {
            selectedAccountId = acc.id; 
            _selectedAccountName = acc.name; 
            _showAccountOptions = false; 
          }),
        )).toList(),
      ),
    );
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
            
            _isFetchingAccounts
                ? const Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// GOAL TITLE
                            _buildLabel("Goal Title"),
                            TextFormField(
                              controller: titleController,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: "e.g., Dream Car, Vacation",
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),

                            /// TARGET AMOUNT
                            _buildLabel("Target Amount"),
                            TextFormField(
                              controller: targetController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                              decoration: InputDecoration(
                                prefixText: "₹ ",
                                hintText: "0.00",
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              ),
                              validator: (v) => v == null || v.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),

                            /// DEADLINE
                            _buildLabel("Target Date"),
                            InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (d != null) setState(() => selectedDate = d);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedDate == null ? "Select Deadline" : DateFormat('dd MMM, yyyy').format(selectedDate!),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: selectedDate == null ? Colors.grey : Colors.blue, // Changed active text to blue
                                      ),
                                    ),
                                    const Icon(Icons.calendar_month, size: 20, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            /// ACCOUNT SELECTION
                            _buildLabel("Funding Account"),
                            _buildAccountSelectorBox(),
                            if (_showAccountOptions) _buildAccountList(),
                            const SizedBox(height: 24),

                            /// CATEGORY
                            _buildLabel("Category"),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.2,
                              ),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected = selectedCategory == category["name"];
                                return GestureDetector(
                                  onTap: () => setState(() => selectedCategory = category["name"]),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.grey.shade200, // Changed active border to blue
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(category["icon"], size: 28, color: category["color"]),
                                        const SizedBox(height: 6),
                                        Text(
                                          category["name"], 
                                          style: TextStyle(
                                            fontSize: 11, 
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.blue : Colors.black54, // Changed active text to blue
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            
            /// BOTTOM STICKY BUTTON
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }
}