import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {

  String name = "";
  String email = "";
  String mobile = "";
  String? image;

  /// Set user when login/signup
  void setUser({
    required String userName,
    required String userEmail,
    String userMobile = "",
    String? userImage,
  }) {
    name = userName;
    email = userEmail;
    mobile = userMobile;
    image = userImage;

    notifyListeners();
  }

  /// Update profile from edit page
  void updateProfile({
    String? newName,
    String? newMobile,
    String? newImage,
  }) {

    if (newName != null) name = newName;
    if (newMobile != null) mobile = newMobile;
    if (newImage != null) image = newImage;

    notifyListeners();
  }
}