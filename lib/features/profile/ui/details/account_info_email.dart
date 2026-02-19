import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

import 'package:front_end/core/widgets/custom_button.dart';
import 'package:front_end/core/widgets/custom_text_field.dart';


class AccountInfoEmailScreen extends StatefulWidget {
  final String? currentEmail;

  const AccountInfoEmailScreen({
    super.key,
    this.currentEmail,
  });

  @override
  State<AccountInfoEmailScreen> createState() =>
      _AccountInfoEmailScreenState();
}

class _AccountInfoEmailScreenState
    extends State<AccountInfoEmailScreen> {

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _saveEmail() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        _emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.currentEmail != null;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        title: Text(
          isEditing ? "Change Email" : "Add Email",
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
                  "Email Address",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(
                        color:
                            AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  hintText: "Enter your email",
                  controller: _emailController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return "Please enter email";
                    }

                    final emailRegex =
                        RegExp(r'^[^@]+@[^@]+\.[^@]+');

                    if (!emailRegex.hasMatch(value)) {
                      return "Enter valid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                CustomButton(
                  text: isEditing
                      ? "Update Email"
                      : "Save Email",
                  onPressed: _saveEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
