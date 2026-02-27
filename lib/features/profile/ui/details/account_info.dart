import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/widgets/custom_button.dart';
import 'package:front_end/core/widgets/custom_text_field.dart';

class AccountInfoScreen extends StatefulWidget {
  final String? currentNumber;

  const AccountInfoScreen({
    super.key,
    this.currentNumber,
  });

  @override
  State<AccountInfoScreen> createState() =>
      _AccountInfoScreenState();
}

class _AccountInfoScreenState
    extends State<AccountInfoScreen> {

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController =
        TextEditingController(text: widget.currentNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _savePhone() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.currentNumber != null;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        title: Text(
          isEditing
              ? "Change Phone Number"
              : "Add Phone Number",
          style: const TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.cardBorder,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Mobile Number",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  hintText: "Enter phone number",
                  controller: _phoneController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Please enter phone number";
                    }
                    if (value.length < 10) {
                      return "Enter valid phone number";
                    }
                    return null;
                  },
                  suffixIcon: const Icon(
                    Icons.phone,
                    color: AppColors.textHint,
                  ),
                ),

                const SizedBox(height: 28),

                CustomButton(
                  text: isEditing
                      ? "Update Number"
                      : "Save Number",
                  onPressed: _savePhone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
