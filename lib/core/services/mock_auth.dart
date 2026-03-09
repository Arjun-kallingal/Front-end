class MockAuthService {
  /// The exact ID from your Node.js authMiddleware.
  /// Change this string ONCE here, and it updates everywhere in the app!
  static const String currentUserId = "699e8fea9a6c85ac1f0970eb";

  /// A fake login method you can use later to test loading screens
  static Future<String> simulateLogin() async {
    await Future.delayed(const Duration(seconds: 1)); // Fake network delay
    return currentUserId;
  }
}