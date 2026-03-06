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

  void _submitFeedback() {
    if (_formKey.currentState!.validate() && _rating > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback Submitted Successfully ✅"),
        ),
      );

      _feedbackController.clear();
      _emailController.clear();

      setState(() {
        _rating = 0;
      });
    } else if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating ⭐"),
        ),
      );
    }
  }

  Widget _buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          _rating = index;
        });
      },
      icon: Icon(
        Icons.star,
        size: 32,
        color: index <= _rating ? Colors.amber : Colors.grey,
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: color.background,

      /// prevents resize overflow when keyboard opens
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Column(
          children: [
            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                 colors: [
  Color(0xFF2E7D32), // Normal Green
  Color(0xFF4CAF50), // Material Green
],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),

                  /// prevents overflow
                  const Expanded(
                    child: Text(
                      "Feedback & Rate Us",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ================= FORM =================
            Expanded(
              child: SingleChildScrollView(
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
                      /// rating title
                      Text(
                        "Rate Your Experience",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// stars
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            5,
                            (index) => _buildStar(index + 1),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// feedback title
                      Text(
                        "Your Feedback",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// feedback field
                      TextFormField(
                        controller: _feedbackController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Write your feedback here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Feedback cannot be empty";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// email title
                      Text(
                        "Email (optional)",
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 8),

                      /// email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// submit button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 184, 20, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _submitFeedback,
                          child: const Text(
                            "Submit Feedback",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
