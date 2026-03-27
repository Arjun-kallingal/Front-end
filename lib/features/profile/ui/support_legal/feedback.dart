import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _transactionController =
      TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  String? _selectedCategory;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    "Bug Report",
    "Feature Request",
    "UI/UX Issue",
    "Transaction Issue",
    "Security Concern",
    "Other",
  ];

  /// ================= PICK IMAGE =================
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// ================= SUBMIT FUNCTION =================
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating ⭐")),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final feedbackData = {
        "rating": _rating,
        "category": _selectedCategory,
        "feedback": _feedbackController.text.trim(),
        "transaction_id": _transactionController.text.trim(),
        "image_path": _selectedImage?.path,
      };

      debugPrint("Feedback Sent: $feedbackData");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback Submitted Successfully ✅"),
        ),
      );

      /// Reset form
      _feedbackController.clear();
      _transactionController.clear();

      setState(() {
        _rating = 0;
        _selectedCategory = null;
        _selectedImage = null;
      });
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
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.3),
      ),
    );
  }

  /// ================= IMAGE PICK UI =================
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _transactionController.dispose();
    super.dispose();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,

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

              /// Intro
              Text(
                "Help us improve your experience.",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              /// Rating
              Text(
                "Rate Your Experience",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Wrap(
                  children: List.generate(
                    5,
                    (index) => _buildStar(index + 1, context),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              /// Category
              Text(
                "Category",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Select category",
                ),
                validator: (value) =>
                    value == null ? "Please select a category" : null,
              ),

              /// Transaction ID
              if (_selectedCategory == "Transaction Issue") ...[
                const SizedBox(height: 20),
                Text(
                  "Transaction ID (optional)",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _transactionController,
                  decoration: const InputDecoration(
                    hintText: "Enter transaction ID",
                  ),
                ),
              ],

              const SizedBox(height: 25),

              /// Feedback
              Text(
                "Your Feedback",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      "Tell us what went wrong or how we can improve...",
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Feedback cannot be empty";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              /// IMAGE PICKER
              Text(
                "Attach Screenshot (optional)",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: color.outline),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage == null
                      ? const Center(child: Text("Tap to upload image"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              /// Security Note
              Text(
                "⚠️ Never share your OTP, PIN, or passwords.",
                style: TextStyle(
                  fontSize: 12,
                  color: color.error,
                ),
              ),

              const SizedBox(height: 30),

              /// Submit
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