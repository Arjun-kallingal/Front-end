import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {

  static const String _localIp = "192.168.137.1";  // Use "localhost" for both Android and iOS emulators
  static const String _port = "5000";

  static String get baseUrl {

    if (kIsWeb) {
      return "http://$_localIp:$_port";   // FIXED
    }

    if (Platform.isAndroid) {
      return "http://$_localIp:$_port";
    }

    return "http://$_localIp:$_port";
  }
}