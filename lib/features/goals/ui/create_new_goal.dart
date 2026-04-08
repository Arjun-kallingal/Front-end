import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/api_config.dart';

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
    {"name": "Savings", "icon": Icons.trending_up_rounded},
    {"name": "Emergency", "icon": Icons.error_outline_rounded},
    {"name": "Bills", "icon": Icons.receipt_long_rounded},
    {"name": "Business", "icon": Icons.work_outline_rounded},
    {"name": "Travel", "icon": Icons.flight_takeoff_rounded},
    {"name": "Other", "icon": Icons.category_rounded},
  ];

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.existingGoal?.title ?? "");

    targetController = TextEditingController(
      text: (widget.existingGoal?.targetAmount ?? 0) > 0
          ? widget.existingGoal!.targetAmount.toString()
          : "",
    );

    selectedDate = widget.existingGoal?.targetDate;

    if (widget.existingGoal != null) {
      selectedCategory = widget.existingGoal!.category;
      selectedAccountId = widget.existingGoal!.accountId;
    }

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
      final result = await AccountService.getAccountDashboard();

      final accountsData = result['accounts'];

      if (accountsData is List<AccountModel>) {
        _accounts = accountsData;
      } else if (accountsData is List) {
        _accounts = accountsData.map((e) => AccountModel.fromJson(e)).toList();
      }

      if (_accounts.isNotEmpty) {
        final primary = _accounts.firstWhere(
          (acc) => acc.isDefault == true,
          orElse: () => _accounts.first,
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

      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        _showSnackBar("Failed to save goal", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error saving goal: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLabel(String text) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, size: 18, color: colors.onSurface),
          ),
          Text(
            widget.existingGoal == null ? "Create New Goal" : "Edit Goal",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickySaveButton() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _isSaving ? null : _saveGoal,
          child: _isSaving
              ? CircularProgressIndicator(color: colors.onPrimary)
              : Text(
                  widget.existingGoal == null ? "Save Goal" : "Update Goal",
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAccountSelectorBox() {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => setState(() => _showAccountOptions = !_showAccountOptions),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedAccountName ?? "Select Account",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountList() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListView(
        shrinkWrap: true,
        children: _accounts.map((acc) {
          return ListTile(
            dense: true,
            title: Text(
              acc.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _isFetchingAccounts
                ? const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                )
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

                                if (d != null) {
                                  setState(() => selectedDate = d);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      selectedDate == null
                                          ? "Select Deadline"
                                          : DateFormat('dd MMM, yyyy')
                                              .format(selectedDate!),
                                      style: TextStyle(color: colors.onSurface),
                                    ),
                                    Icon(Icons.calendar_month,
                                        color: colors.onSurfaceVariant),
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
                                final isSelected =
                                    selectedCategory == category["name"];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category["name"];
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primary
                                            : Theme.of(context).dividerColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(category["icon"],
                                            color: colors.primary),
                                        const SizedBox(height: 6),
                                        Text(
                                          category["name"],
                                          style: TextStyle(
                                              color: colors.onSurface),
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
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }
}