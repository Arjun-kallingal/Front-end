import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String fromAccount = "Cash";
  String toAccount = "Bank";

  DateTime selectedDate = DateTime.now();

  final List<String> accounts = ["Cash", "Bank", "Savings", "Credit Card"];

  /// PICK DATE
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// SAVE TRANSFER
  void _saveTransfer() {
    String amount = amountController.text;
    String description = descriptionController.text;

    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter amount")),
      );
      return;
    }

    /// Here you will call API later
    print("Amount: $amount");
    print("From: $fromAccount");
    print("To: $toAccount");
    print("Description: $description");
    print("Date: $selectedDate");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transfer saved successfully")),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Transfer"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            /// AMOUNT
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("Amount"),
            ),

            const SizedBox(height: 20),

            /// FROM ACCOUNT
            DropdownButtonFormField(
              value: fromAccount,
              decoration: _inputDecoration("From Account"),
              items: accounts.map((acc) {
                return DropdownMenuItem(
                  value: acc,
                  child: Text(acc),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  fromAccount = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            /// TO ACCOUNT
            DropdownButtonFormField(
              value: toAccount,
              decoration: _inputDecoration("To Account"),
              items: accounts.map((acc) {
                return DropdownMenuItem(
                  value: acc,
                  child: Text(acc),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  toAccount = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            TextField(
              controller: descriptionController,
              decoration: _inputDecoration("Description"),
            ),

            const SizedBox(height: 20),

            /// DATE
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            /// SAVE BUTTON
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
