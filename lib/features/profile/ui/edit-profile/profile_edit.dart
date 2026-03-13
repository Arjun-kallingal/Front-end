import 'package:flutter/material.dart';
import 'package:front_end/features/profile/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentMobile;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentMobile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  late TextEditingController nameController;
  late TextEditingController mobileController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    mobileController = TextEditingController(text: widget.currentMobile);
  }

  Future<void> saveProfile() async {

  if (nameController.text.trim().isEmpty ||
      mobileController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  final name = nameController.text.trim();
  final phone = mobileController.text.trim();

  final success = await ProfileService.updateProfile(name, phone);

  setState(() {
    isLoading = false;
  });

  if (!mounted) return;

  if (success) {

    /// RETURN UPDATED DATA TO PREVIOUS SCREEN
   ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text("Profile Updated Successfully")),
);

Navigator.pop(context, {
  "name": name,
  "mobile": phone,
});

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update profile")),
    );
  }
}

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 98, 14, 14),
                      Color.fromARGB(255, 184, 20, 20),
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
                    const SizedBox(width: 8),
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              /// CARD
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [

                      /// USER NAME
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              "User Name",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: color.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// MOBILE NUMBER
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text(
                              "Mobile Number",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          TextField(
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: color.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
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
                          onPressed: isLoading ? null : saveProfile,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(fontSize: 16),
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