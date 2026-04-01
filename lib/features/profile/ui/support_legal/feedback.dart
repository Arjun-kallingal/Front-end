import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front_end/features/profile/services/feedback_service.dart';
import 'package:front_end/core/services/auth_storage.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _transactionController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  String? _selectedCategory;
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  late List<AnimationController> _starControllers;
  late List<Animation<double>> _starScales;

  final List<String> _categories = [
    "Bug Report",
    "Feature Request",
    "UI/UX Issue",
    "Transaction Issue",
    "Security Concern",
    "Other",
  ];

  final List<IconData> _categoryIcons = [
    Icons.bug_report_outlined,
    Icons.lightbulb_outline,
    Icons.palette_outlined,
    Icons.receipt_long_outlined,
    Icons.shield_outlined,
    Icons.more_horiz_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _starControllers = List.generate(
      5,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _starScales = _starControllers
        .map((c) => Tween<double>(begin: 1.0, end: 1.35).animate(
              CurvedAnimation(parent: c, curve: Curves.elasticOut),
            ))
        .toList();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

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
      final token = await AuthStorage.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again.")),
        );
        return;
      }

      await FeedbackService.updateRating(_rating, token);

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = null;
      }

      await FeedbackService.submitFeedback(
        token: token,
        category: _selectedCategory!,
        description: _feedbackController.text.trim(),
        screenshotUrl: imageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback Submitted Successfully ✅")),
      );

      _feedbackController.clear();
      _transactionController.clear();

      setState(() {
        _rating = 0;
        _selectedCategory = null;
        _selectedImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStar(int index) {
    final theme = Theme.of(context);
    final isSelected = index <= _rating;
    final animIndex = index - 1;

    return ScaleTransition(
      scale: _starScales[animIndex],
      child: GestureDetector(
        onTap: () async {
          _starControllers[animIndex].forward().then(
                (_) => _starControllers[animIndex].reverse(),
              );
          setState(() {
            _rating = index;
          });
          try {
            final token = await AuthStorage.getToken();
            if (token != null) {
              await FeedbackService.updateRating(index, token);
            }
          } catch (e) {
            debugPrint("Rating error: $e");
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 40,
            color: isSelected
                ? const Color(0xFFFFC107)
                : theme.colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "Add Screenshot",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_outlined,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_outlined,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _transactionController.dispose();
    for (final c in _starControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _ratingLabel() {
    switch (_rating) {
      case 1:
        return "Poor";
      case 2:
        return "Fair";
      case 3:
        return "Good";
      case 4:
        return "Great";
      case 5:
        return "Excellent!";
      default:
        return "Tap a star to rate";
    }
  }

  Widget _sectionLabel(String label) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: color.onSurface.withOpacity(0.45),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,
     appBar: AppBar(
  elevation: 0,
  backgroundColor: color.surface,
  surfaceTintColor: Colors.transparent,
  automaticallyImplyLeading: false,
  titleSpacing: 0,
  leading: IconButton(
    onPressed: () => Navigator.pop(context),
    padding: EdgeInsets.zero,
    icon: Icon(
      Icons.arrow_back_ios_new,
      size: 18,
      color: color.onSurface,
    ),
  ),
  title: Text(
    "Feedback & Rate Us",
    style: theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: color.onSurface,
    ),
  ),
  centerTitle: false,
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ─── Hero Banner ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.primary, color.primary.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Share Your Experience",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: color.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your feedback helps us improve",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: color.onPrimary.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.rate_review_outlined,
                        size: 44, color: color.onPrimary.withOpacity(0.8)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Rating ─────────────────────────────────────────────
              _sectionLabel("Rate Your Experience"),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => _buildStar(i + 1)),
              ),
              const SizedBox(height: 8),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _ratingLabel(),
                    key: ValueKey(_rating),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _rating > 0
                          ? const Color(0xFFFFC107)
                          : color.onSurface.withOpacity(0.45),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Divider(height: 1, thickness: 0.5, color: color.outline.withOpacity(0.2)),
              const SizedBox(height: 24),

              // ─── Category ───────────────────────────────────────────
              _sectionLabel("Category"),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text(
                  "Select a category",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color.onSurface.withOpacity(0.45),
                  ),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: color.surfaceVariant.withOpacity(0.5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: color.outline.withOpacity(0.3), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.error, width: 1.5),
                  ),
                ),
                dropdownColor: color.surface,
                borderRadius: BorderRadius.circular(12),
                items: _categories.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final val = entry.value;
                  return DropdownMenuItem(
                    value: val,
                    child: Row(
                      children: [
                        Icon(_categoryIcons[idx], size: 18, color: color.primary),
                        const SizedBox(width: 12),
                        Text(val),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (v) => v == null ? "Please select a category" : null,
              ),

              const SizedBox(height: 24),
              Divider(height: 1, thickness: 0.5, color: color.outline.withOpacity(0.2)),
              const SizedBox(height: 24),

              // ─── Feedback ───────────────────────────────────────────
              _sectionLabel("Your Feedback"),
              TextFormField(
                controller: _feedbackController,
                maxLines: 5,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: "Describe your experience in detail...",
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: color.onSurface.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: color.surfaceVariant.withOpacity(0.5),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: color.outline.withOpacity(0.3), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.primary, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: color.error, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Please enter your feedback" : null,
              ),

              const SizedBox(height: 24),
              Divider(height: 1, thickness: 0.5, color: color.outline.withOpacity(0.2)),
              const SizedBox(height: 24),

              // ─── Screenshot ─────────────────────────────────────────
              _sectionLabel("Screenshot (Optional)"),
              GestureDetector(
                onTap: _showImageOptions,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _selectedImage == null
                        ? color.surfaceVariant.withOpacity(0.5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedImage != null
                          ? color.primary
                          : color.outline.withOpacity(0.4),
                      width: _selectedImage != null ? 2 : 1.5,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 28,
                                color: color.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Tap to upload screenshot",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: color.onSurface.withOpacity(0.55),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              "Camera or Gallery",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: color.onSurface.withOpacity(0.35),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: color.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close,
                                      size: 16, color: color.onError),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // ─── Submit Button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.primary,
                    foregroundColor: color.onPrimary,
                    elevation: 2,
                    shadowColor: color.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: color.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "Submit Feedback",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: color.onPrimary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
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