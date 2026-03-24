import 'package:flutter/material.dart';
import 'package:front_end/features/profile/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;

  const EditProfileScreen({
    super.key,
    required this.currentName,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
  }

  Future<void> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a username")),
      );
      return;
    }

    setState(() => isLoading = true);

    final name = nameController.text.trim();
    final success = await ProfileService.updateProfile(name);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully")),
      );

      Navigator.pop(context, {"name": name});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isLight ? Colors.black : Colors.white,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isLight ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLight ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              /// CARD
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        isLight ? Colors.grey[100] : Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [

                      /// USER NAME
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "User Name",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isLight
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: nameController,
                            style: TextStyle(
                              color: isLight
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter your name",
                              hintStyle: TextStyle(
                                color: isLight
                                    ? Colors.black54
                                    : Colors.white54,
                              ),

                              filled: true,
                              fillColor: isLight
                                  ? Colors.white
                                  : Colors.black,

                              /// NORMAL BORDER
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isLight
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),

                              /// FOCUS BORDER
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isLight
                                      ? Colors.black
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      /// SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLight
                                ? Colors.black
                                : Colors.white,
                            foregroundColor: isLight
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed:
                              isLoading ? null : saveProfile,
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isLight
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                )
                              : const Text(
                                  "Save Changes",
                                  style:
                                      TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}