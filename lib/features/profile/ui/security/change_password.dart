import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password Changed Successfully"),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// CURRENT PASSWORD
             TextFormField(
  controller: currentPasswordController,
  obscureText: obscureCurrent,
  enableSuggestions: false,
  autocorrect: false,
  autofillHints: const [],
  keyboardType: TextInputType.visiblePassword,
  decoration: InputDecoration(
    labelText: "Current Password",
    suffixIcon: IconButton(
      icon: Icon(
        obscureCurrent ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          obscureCurrent = !obscureCurrent;
        });
      },
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Enter current password";
    }
    return null;
  },
),

              /// NEW PASSWORD
             TextFormField(
  controller: newPasswordController,
  obscureText: obscureNew,
  enableSuggestions: false,
  autocorrect: false,
  autofillHints: const [],
  keyboardType: TextInputType.visiblePassword,
  decoration: InputDecoration(
    labelText: "New Password",
    suffixIcon: IconButton(
      icon: Icon(
        obscureNew ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          obscureNew = !obscureNew;
        });
      },
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Enter new password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  },
),

              const SizedBox(height: 20),

              /// CONFIRM PASSWORD
             TextFormField(
  controller: confirmPasswordController,
  obscureText: obscureConfirm,
  enableSuggestions: false,
  autocorrect: false,
  autofillHints: const [],
  keyboardType: TextInputType.visiblePassword,
  decoration: InputDecoration(
    labelText: "Confirm Password",
    suffixIcon: IconButton(
      icon: Icon(
        obscureConfirm ? Icons.visibility_off : Icons.visibility,
      ),
      onPressed: () {
        setState(() {
          obscureConfirm = !obscureConfirm;
        });
      },
    ),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Confirm your password";
    }
    if (value != newPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  },
),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text(
                    "Update Password",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
