import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/api_config.dart'; // ✅ replaces hardcoded URL

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

  // ✅ Use ApiConfig.baseUrl instead of hardcoded localhost
  late final GoalService _goalService = GoalService(
    baseUrl: "${ApiConfig.baseUrl}/api",
  );

  bool _isFetchingAccounts = true;
  bool _isSaving = false;
  List<AccountModel> _accounts = [];

  DateTime? selectedDate;
  String selectedCategory = "Savings";
  String? selectedAccountId;
  bool _showAccountOptions = false;
  String? _selectedAccountName;

  IconData selectedIcon = Icons.trending_up_rounded;

  final List<Map<String, dynamic>> categories = [
    {"name": "Savings",   "icon": Icons.trending_up_rounded,    "color": Colors.green.shade800},
    {"name": "Emergency", "icon": Icons.error_outline_rounded,   "color": Colors.red.shade800},
    {"name": "Bills",     "icon": Icons.receipt_long_rounded,    "color": Colors.orange.shade800},
    {"name": "Business",  "icon": Icons.work_outline_rounded,    "color": Colors.blue.shade800},
    {"name": "Travel",    "icon": Icons.flight_takeoff_rounded,  "color": Colors.purple.shade800},
    {"name": "Other",     "icon": Icons.category_rounded,        "color": Colors.grey.shade800},
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.existingGoal?.title ?? "");

    targetController = TextEditingController(
      text: (widget.existingGoal?.targetAmount ?? 0) > 0
          ? widget.existingGoal!.targetAmount.toString()
          : "",
    );

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

    // ✅ No user ID needed — just load accounts directly
    _loadAccounts();
  }

  @override
  void dispose() {
    titleController.dispose();
    targetController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      // ✅ No userId param — backend reads user from JWT
      final result = await AccountService.getAccountDashboard();

      if (!mounted) return;

      final accountsData = result['accounts'];
      _accounts = accountsData is List<AccountModel> ? accountsData : [];

      if (_accounts.isNotEmpty) {
        final primary = _accounts.firstWhere(
          (acc) => acc.isDefault == true,
          orElse: () => _accounts.firstWhere(
            (acc) => acc.type == "CASH",
            orElse: () => _accounts.first,
          ),
        );

        selectedAccountId = primary.id;
        _selectedAccountName = primary.name;
      }
    } catch (e) {
      debugPrint("Error loading accounts: $e");
    } finally {
      if (mounted) setState(() => _isFetchingAccounts = false);
    }
  }

  void _saveGoal() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        selectedAccountId == null) {
      _showSnackBar(
        selectedDate == null ? "Please select a deadline" : "Please fill all fields",
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    // ✅ No userId in GoalModel — backend extracts it from JWT
    final goalToSave = GoalModel(
      id: widget.existingGoal?.id ?? '',
      accountId: selectedAccountId!,
      title: titleController.text.trim(),
      category: selectedCategory,
      targetAmount: double.parse(targetController.text),
      currentAmount: widget.existingGoal?.currentAmount ?? 0.0,
      targetDate: selectedDate!,
      status: widget.existingGoal?.status ?? 'active',
      createdAt: widget.existingGoal?.createdAt ?? DateTime.now(),
    );

    try {
      bool success;

      if (widget.existingGoal != null) {
        success = await _goalService.updateGoal(goalToSave);
      } else {
        success = await _goalService.createGoal(goalToSave);
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
        } else {
          _showSnackBar("Failed to save goal", isError: true);
        }
      }
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

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          Text(
            widget.existingGoal == null ? "Create New Goal" : "Edit Goal",
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildStickySaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _isSaving ? null : _saveGoal,
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  widget.existingGoal == null ? "Save Goal" : "Update Goal",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
        ),
      ),
    );
  }

  Widget _buildAccountSelectorBox() {
    return InkWell(
      onTap: () => setState(() => _showAccountOptions = !_showAccountOptions),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedAccountName ?? "Select Account",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView(
        shrinkWrap: true,
        children: _accounts.map((acc) {
          return ListTile(
            dense: true,
            title: Text(acc.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              setState(() {
                selectedAccountId = acc.id;
                _selectedAccountName = acc.name;
                _showAccountOptions = false;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _isFetchingAccounts
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Goal Title"),
                            TextFormField(
                              controller: titleController,
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel("Target Amount"),
                            TextFormField(
                              controller: targetController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'))
                              ],
                              validator: (v) =>
                                  v == null || v.isEmpty ? "Required" : null,
                            ),
                            const SizedBox(height: 16),
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
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(selectedDate == null
                                        ? "Select Deadline"
                                        : DateFormat('dd MMM, yyyy').format(selectedDate!)),
                                    const Icon(Icons.calendar_month),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildLabel("Funding Account"),
                            _buildAccountSelectorBox(),
                            if (_showAccountOptions) _buildAccountList(),
                            const SizedBox(height: 24),
                            _buildLabel("Category"),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.2,
                              ),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected = selectedCategory == category["name"];

                                return GestureDetector(
                                  onTap: () => setState(
                                      () => selectedCategory = category["name"]),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey.shade200,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(category["icon"]),
                                        const SizedBox(height: 6),
                                        Text(category["name"]),
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
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }
}