import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // ⚠️ IMPORTANT: Use your computer's actual local IP address (NOT 'localhost').
  // 'localhost' only works on the same machine. For other devices on the same
  // WiFi, open cmd → run `ipconfig` → use the IPv4 address (e.g., 192.168.x.x)
  static const String _localIp =
      "localhost"; // 🔴 CHANGE THIS to your PC's IP
  static const String _port = "5000";

  static String get baseUrl {
    if (kIsWeb) {
      return "http://$_localIp:$_port";
    }

    if (!kIsWeb && Platform.isAndroid) {
      return "http://$_localIp:$_port";
    }

    return "http://$_localIp:$_port";
  }
}
