import 'package:flutter/material.dart';
import '../../core/models/account_model.dart';
import '../../core/services/account_service.dart';
import '../../core/services/transfer_service.dart';
import '../../core/services/mock_auth.dart';
import 'package:uuid/uuid.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  List<AccountModel> accounts = [];

  AccountModel? fromAccount;
  AccountModel? toAccount;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
final idempotencyKey = const Uuid().v4();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
  try {
    final result = await AccountService.getAccountDashboard(MockAuthService.token);

    setState(() {
      accounts = result['accounts'] as List<AccountModel>;
    });
  } catch (e) {
    print("Failed to load accounts: $e");
  }
}

  Future<void> submitTransfer() async {
    final amount = double.tryParse(amountController.text.trim());

    if (fromAccount == null || toAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select accounts")),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid amount")),
      );
      return;
    }

    if (fromAccount!.id == toAccount!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Accounts cannot be same")),
      );
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      
await TransferService.accountTransfer(
  token: MockAuthService.token,
  fromAccountId: fromAccount!.id,
  toAccountId: toAccount!.id,
  amount: amount,
  category: "TRANSFER",
  description: descriptionController.text,
  idempotencyKey: idempotencyKey,
);

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transfer Successful")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transfer Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              value: fromAccount,
              hint: const Text("From Account"),
              items: accounts.map((acc) {
                return DropdownMenuItem(
                  value: acc,
                  child: Text(acc.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  fromAccount = value;
                });
              },
            ),

            const SizedBox(height: 16),

            /// TO ACCOUNT
            DropdownButtonFormField<AccountModel>(
              value: toAccount,
              hint: const Text("To Account"),
              items: accounts.map((acc) {
                return DropdownMenuItem(
                  value: acc,
                  child: Text(acc.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  toAccount = value;
                });
              },
            ),

            const SizedBox(height: 16),

            /// AMOUNT
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// DESCRIPTION
            TextField(
              controller: descriptionController,
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
                onPressed: loading ? null : submitTransfer,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Transfer"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
