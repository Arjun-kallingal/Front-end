import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {

  static const _storage = FlutterSecureStorage();

  static const tokenKey = "auth_token";
  static const nameKey = "user_name";
  static const emailKey = "user_email";
  static const phoneKey = "user_phone";

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
    await _storage.write(key: phoneKey, value: phone);
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

  /// GET PHONE
  static Future<String?> getPhone() async {
    return await _storage.read(key: phoneKey);
  }

  /// UPDATE ONLY NAME
  static Future<void> updateName(String name) async {
    await _storage.write(key: nameKey, value: name);
  }

  /// UPDATE ONLY PHONE
  static Future<void> updatePhone(String phone) async {
    await _storage.write(key: phoneKey, value: phone);
  }

  /// CLEAR STORAGE (LOGOUT)
  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}