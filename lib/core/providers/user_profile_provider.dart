import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {

  String name = "Syamjith";
  String email = "syamjith@email.com";
  String mobile = "";
  String? image;

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