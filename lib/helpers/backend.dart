// import 'package:flutter/foundation.dart';

// class Backend {
//   static String get baseUrl {
//     if (kIsWeb) {
//       return "http://192.168.1.193:5000"; // Web testing
//     } else {
//       return "http://192.168.1.193:5000"; // Android device testing
//     }
//   }

//   // 🔹 Socket.IO URL
//   static String get socketUrl {
//     if (kIsWeb) {
//       return "http://192.168.1.193:5000"; // Web testing
//     } else {
//       return "http://192.168.1.193:5000"; // Android device testing
//     }
//   }
// }


// import 'package:flutter/foundation.dart';

// class Backend {
//   static String get baseUrl {
//     return "https://15161c375307.ngrok-free.app"; // use ngrok URL
//   }

//   // 🔹 Socket.IO URL
//   static String get socketUrl {
//     return "https://15161c375307.ngrok-free.app"; // use ngrok URL
//   }
// }


import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Backend {
  static String get baseUrl => "https://4c2b0556ba0b.ngrok-free.app";
  static String get socketUrl => "https://4c2b0556ba0b.ngrok-free.app";

  // GET request
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('GET request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('GET error: $e');
      return null;
    }
  }

  // POST request with optional body
  static Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('POST request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('POST error: $e');
      return null;
    }
  }
}
