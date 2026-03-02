import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:front_end/core/services/permission_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentMobile;
  final String? currentImage;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentMobile,
    this.currentImage,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController mobileController;

  File? selectedImage;
  String? imageUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    mobileController = TextEditingController(text: widget.currentMobile);
    imageUrl = widget.currentImage;
  }

  void showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await pickFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> pickFromGallery() async {
    final hasPermission = await PermissionService.requestGalleryPermission();

    if (!hasPermission) {
      showPermissionSnackBar();
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> pickFromCamera() async {
    final hasPermission = await PermissionService.requestCameraPermission();

    if (!hasPermission) {
      showPermissionSnackBar();
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  void showPermissionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Permission required. Please enable it in settings."),
      ),
    );
  }

  Future<String?> uploadImage(File image) async {
    setState(() {
      isUploading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://yourapi.com/upload-profile/userId"),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      var response = await request.send();

      setState(() {
        isUploading = false;
      });

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = jsonDecode(res.body);
        return data["imageUrl"];
      } else {
        return null;
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      return null;
    }
  }

  Future<void> saveProfile() async {
    String? finalImageUrl = imageUrl;

    if (selectedImage != null) {
      final uploadedUrl = await uploadImage(selectedImage!);
      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      }
    }

    Navigator.pop(context, {
      "name": nameController.text,
      "mobile": mobileController.text,
      "image": finalImageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        // ✅ added SafeArea only
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      GestureDetector(
                        onTap: showImageSourceSelector,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : (imageUrl != null &&
                                          imageUrl!.startsWith("http"))
                                      ? NetworkImage(imageUrl!) as ImageProvider
                                      : null,
                              child: selectedImage == null &&
                                      (imageUrl == null ||
                                          !imageUrl!.startsWith("http"))
                                  ? const Icon(Icons.camera_alt, size: 30)
                                  : null,
                            ),
                            if (isUploading) const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LABEL OUTSIDE WITH LEFT PADDING
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              "User Name",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// TEXT FIELD
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
                     Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// MOBILE NUMBER LABEL OUTSIDE
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

    /// MOBILE NUMBER FIELD
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
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isUploading ? null : saveProfile,
                          child: const Text(
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
