// import 'dart:io';
// import 'package:flutter/foundation.dart';

// class ApiConfig {
//   static String get baseUrl {
//     if (kIsWeb) {
//       return "http://127.0.0.1:5000";
//     } else if (Platform.isAndroid) {
//       return "http://192.168.0.182:5000"; // your laptop IP
//     } else {
//       return "http://192.168.0.182:5000";
//     }
//   }
// }
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5000";
    } else if (Platform.isAndroid) {
      return "http://192.168.0.173:5000";
    } else {
      return "http://192.168.0.173:5000";
    }
  }
}
