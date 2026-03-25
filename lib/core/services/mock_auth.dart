class MockAuthService {
  /// The exact ID from your Node.js authMiddleware.
  /// Change this string ONCE here, and it updates everywhere in the app!
  /// 
  static const String currentUserId = "69a7c2ee3b7e643684e7b2d0";
  static String get token => currentUserId; // Add this in MockAuthService
  /// A fake login method you can use later to test loading screens
  static Future<String> simulateLogin() async {
    await Future.delayed(const Duration(seconds: 1)); // Fake network delay
    return currentUserId;
  }
}