import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/account_model.dart';
import '../../core/providers/transfer_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<TransferProvider>().loadAccounts());
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
                        size: 18,
                        color: theme.colorScheme.primary),
                    onPressed: () => Navigator.pop(context),
                  ),

                  Text(
                    "Transfer Money",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
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
                    _buildLabel("From Account"),

                    DropdownButtonFormField<AccountModel>(
                      value: provider.fromAccount,
                      hint: const Text("Select account"),
                      decoration: _inputDecoration(),
                      items: provider.accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setFromAccount(value);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    /// TO ACCOUNT
                    _buildLabel("To Account"),

                    DropdownButtonFormField<AccountModel>(
                      value: provider.toAccount,
                      hint: const Text("Select account"),
                      decoration: _inputDecoration(),
                      items: provider.accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          provider.setToAccount(value);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    /// AMOUNT
                    _buildLabel("Amount"),

                    TextField(
                      controller: provider.amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration().copyWith(
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
                    _buildLabel("Description (Optional)"),

                    TextField(
                      controller: provider.descriptionController,
                      decoration: _inputDecoration().copyWith(
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
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade100),
              ),

              child: SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  onPressed: provider.loading
                      ? null
                      : () async {

                          final error =
                              await provider.submitTransfer(context);

                          if (error != null) {
                            showSnackBar(error);
                          } else {

                            showSnackBar(
                              "Transfer Successful",
                              error: false,
                            );

                            Navigator.pop(context);
                          }
                        },

                  child: provider.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Transfer Money",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT STYLE (same as AddTransactionScreen)
  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// LABEL STYLE
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}