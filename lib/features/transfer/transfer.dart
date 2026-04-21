import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/account_model.dart';
import '../../core/providers/transfer_provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:front_end/core/services/sound_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TransferProvider>().loadAccounts());
  }

  void showSnackBar(String msg, {bool error = true}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? theme.colorScheme.error : theme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: 18, color: colorScheme.primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Transfer Money",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// FROM ACCOUNT
                    _buildLabel(isDark),

                    DropdownButtonFormField<AccountModel>(
                      initialValue: provider.fromAccount,
                      hint: Text(
                        "Select account",
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.lightTextHint,
                        ),
                      ),
                      decoration: _inputDecoration(isDark),
                      items: provider.accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) provider.setFromAccount(value);
                      },
                    ),

                    const SizedBox(height: 16),

                    /// TO ACCOUNT
                    _buildLabel(isDark, "To Account"),

                    DropdownButtonFormField<AccountModel>(
                      initialValue: provider.toAccount,
                      hint: Text(
                        "Select account",
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextHint
                              : AppColors.lightTextHint,
                        ),
                      ),
                      decoration: _inputDecoration(isDark),
                      items: provider.accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) provider.setToAccount(value);
                      },
                    ),

                    const SizedBox(height: 16),

                    /// AMOUNT
                    _buildLabel(isDark, "Amount"),

                    TextField(
                      controller: provider.amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration(isDark).copyWith(
                        prefixText: "₹ ",
                        hintText: "0.00",
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// DESCRIPTION
                    _buildLabel(isDark, "Description (Optional)"),

                    TextField(
                      controller: provider.descriptionController,
                      decoration: _inputDecoration(isDark).copyWith(
                        hintText: "Transfer note",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// STICKY TRANSFER BUTTON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBgSecondary
                    : AppColors.lightBgPrimary,
                border: Border.all(
                  color:
                      isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor:
                        colorScheme.onPrimary, // ✅ fixes text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: provider.loading
                      ? null
                      : () async {
                          final error = await provider.submitTransfer(context);

                          if (error != null) {
                            showSnackBar(error);
                          } else {
                            await SoundService.instance.playTransaction(TransactionSound.transfer);
                            showSnackBar("Transfer Successful", error: false);
                            Navigator.pop(context);
                          }
                        },
                  child: provider.loading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary, // ✅ correct color
                          ),
                        )
                      : Text(
                          "Transfer Money",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onPrimary, // ✅ correct color
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark) {
    return InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.darkBgCard : AppColors.lightBgSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildLabel(bool isDark, [String text = "From Account"]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
