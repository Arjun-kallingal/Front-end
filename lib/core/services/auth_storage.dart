import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {

  static const _storage = FlutterSecureStorage();

  static const tokenKey = "auth_token";
  static const nameKey = "user_name";
  static const emailKey = "user_email";

  /// SAVE USER DATA
  static Future<void> saveUser({
    required String token,
    required String name,
    required String email,
    required String phone,
  }) async {

    await _storage.write(key: tokenKey, value: token);
    await _storage.write(key: nameKey, value: name);
    await _storage.write(key: emailKey, value: email);
  }

  /// GET TOKEN
  static Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  /// GET NAME
  static Future<String?> getName() async {
    return await _storage.read(key: nameKey);
  }

  /// GET EMAIL
  static Future<String?> getEmail() async {
    return await _storage.read(key: emailKey);
  }

  
  /// UPDATE ONLY NAME
  static Future<void> updateName(String name) async {
    await _storage.write(key: nameKey, value: name);
  }

  /// CLEAR STORAGE (LOGOUT)
  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}