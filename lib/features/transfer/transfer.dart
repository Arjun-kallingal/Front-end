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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<TransferProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer Money"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// FROM ACCOUNT
            DropdownButtonFormField<AccountModel>(
              value: provider.fromAccount,
              hint: const Text("From Account"),
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
            DropdownButtonFormField<AccountModel>(
              value: provider.toAccount,
              hint: const Text("To Account"),
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
            TextField(
              controller: provider.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// DESCRIPTION
            TextField(
              controller: provider.descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            /// TRANSFER BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(

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
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Transfer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}