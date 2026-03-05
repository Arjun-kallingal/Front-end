import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _repository.login(email, password);

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<void> logout() async {
    await _repository.logout();
  }
}