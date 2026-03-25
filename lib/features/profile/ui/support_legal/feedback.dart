import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  /// ================= SUBMIT FUNCTION =================
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating ⭐")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final feedbackData = {
        "rating": _rating,
        "feedback": _feedbackController.text.trim(),
        "email": _emailController.text.trim(),
      };

      debugPrint("Feedback Sent: $feedbackData");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback Submitted Successfully ✅"),
        ),
      );

      _feedbackController.clear();
      _emailController.clear();

      setState(() => _rating = 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong ❌")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// ================= STAR =================
  Widget _buildStar(int index, BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: () {
        setState(() {
          _rating = index;
        });
      },
      icon: Icon(
        Icons.star,
        size: 32,
        color: index <= _rating
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,

      /// ✅ AppBar instead of manual header
      appBar: AppBar(
        title: const Text("Feedback & Rate Us"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Rating Title
              Text(
                "Rate Your Experience",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// Stars
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    5,
                    (index) => _buildStar(index + 1, context),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Feedback Title
              Text(
                "Your Feedback",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// Feedback Field (THEME CONTROLLED)
              TextFormField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Write your feedback here...",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Feedback cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              /// Email Title
              Text(
                "Email (optional)",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 8),

              /// Email Field (THEME CONTROLLED)
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Enter your email",
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return "Enter a valid email";
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              /// Submit Button (THEME CONTROLLED)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  child: _isSubmitting
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        )
                      : const Text("Submit Feedback"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}