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
  static String get baseUrl =>"http://192.168.1.193:5000";
  static String get socketUrl =>"http://192.168.1.193:5000";

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
//------------------------



static String buildMediaUrl(String path) {
  if (path.startsWith("http")) return path; // already full URL

  // Ensure exactly one slash between baseUrl and path
  return baseUrl.endsWith('/')
      ? "$baseUrl${path.startsWith('/') ? path.substring(1) : path}"
      : "$baseUrl${path.startsWith('/') ? path : '/$path'}";
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


class NotificationsApi {
  static Future<void> sendNotification({
    required int userId,
    required String title,
    required String body,
    required int senderId,
  }) async {
    final uri = Uri.parse("${Backend.baseUrl}/notifications/send");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "title": title,
        "body": body,
        "sender_id": senderId,
      }),
    );

    if (response.statusCode != 200) {
      print("❌ Notification failed: ${response.body}");
    }
  }
}

