import '../../../core/services/local_storage_service.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _authApi = AuthApi();

  Future<bool> login(String email, String password) async {
    final token = await _authApi.login(email, password);

    if (token != null) {
      await LocalStorageService.saveToken(token); // ✅ SAVE JWT HERE
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await LocalStorageService.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    return await LocalStorageService.isLoggedIn();
  }
}