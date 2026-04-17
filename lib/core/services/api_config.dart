import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // 1. Production URL
  static const String _prodUrl = "https://walletcare-backend.onrender.com";

  // 2. Localhost Logic
  // Android Emulator uses 10.0.2.2 to access your computer's localhost
  // iOS Simulator and Web use localhost or 127.0.0.1
  static String get _localUrl {
    if (kIsWeb) return "http://localhost:5000"; // Or your specific port
    return Platform.isAndroid ? "http://10.0.2.2:5000" : "http://localhost:5000";
  }

  // 3. Environment Switch
  // kDebugMode is true when you're developing, false for signed APKs/IPAs
  static String get baseUrl => kDebugMode ? _localUrl : _prodUrl;

  static String get socketUrl => kDebugMode ? _localUrl : _prodUrl;
}