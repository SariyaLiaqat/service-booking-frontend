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



///////////////////////////////////////////////////
///

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';


// class Backend {
//   static String get baseUrl =>"http://192.168.1.193:5000";
//   static String get socketUrl =>"http://192.168.1.193:5000";

//   // GET request
//   static Future<Map<String, dynamic>?> get(String endpoint) async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl$endpoint'));
//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         debugPrint('GET request failed: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('GET error: $e');
//       return null;
//     }




//   }
// //------------------------



// static String buildMediaUrl(String path) {
//   if (path.startsWith("http")) return path; // already full URL

//   // Ensure exactly one slash between baseUrl and path
//   return baseUrl.endsWith('/')
//       ? "$baseUrl${path.startsWith('/') ? path.substring(1) : path}"
//       : "$baseUrl${path.startsWith('/') ? path : '/$path'}";
// }




//   // POST request with optional body
//   static Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> body) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(body),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return json.decode(response.body);
//       } else {
//         debugPrint('POST request failed: ${response.statusCode}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('POST error: $e');
//       return null;
//     }
//   }
// }


// class NotificationsApi {
//   static Future<void> sendNotification({
//     required int userId,
//     required String title,
//     required String body,
//     required int senderId,
//   }) async {
//     final uri = Uri.parse("${Backend.baseUrl}/notifications/send");
//     final response = await http.post(
//       uri,
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({
//         "user_id": userId,
//         "title": title,
//         "body": body,
//         "sender_id": senderId,
//       }),
//     );

//     if (response.statusCode != 200) {
//       print("❌ Notification failed: ${response.body}");
//     }
//   }
// }








import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';




class Backend {
  static String get baseUrl => "http://172.24.54.177:5000";
  static String get socketUrl => "http://172.24.54.177:5000";
//http://192.168.1.193:5000
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      debugPrint("🔍 GET $endpoint → ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("✅ GET response: $data");
        return data;
      } else {
        debugPrint('❌ GET request failed: ${response.statusCode} | ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ GET error: $e');
      return null;
    }
  }
//------------------------


// 🔹 Parse payment URL from backend response
 static String? parsePaymentUrl(Map<String, dynamic>? response) {
    if (response == null) return null;
    if (response.containsKey('payment_url')) {
      debugPrint("🔗 Payment URL parsed: ${response['payment_url']}");
      return response['payment_url'] as String?;
    }
    return null;
  }

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
      debugPrint("📤 POST $endpoint → $body");
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      debugPrint("🔍 POST $endpoint → ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        debugPrint("✅ POST response: $data");
        return data;
      } else {
        debugPrint('❌ POST request failed: ${response.statusCode} | ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ POST error: $e');
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
    debugPrint("📨 Sending notification to userId $userId → $title | $body");
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
    } else {
      debugPrint("✅ Notification sent successfully");
    }
  }
}


class PaymentApi {
  static Future<Map<String, dynamic>> createPayment({
    required int taskId,
    required int userId,
    required int spId,
    required double amount,
  }) async {
    final uri = Uri.parse("${Backend.baseUrl}/user-payment/create");
    print("📤 Sending request to: $uri");

    final body = {
      "taskId": taskId,
      "userId": userId,
      "spId": spId,
      "amount": amount,
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    print("📥 Status Code: ${response.statusCode}");
    print("📥 Raw Response: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // ✅ Return full map with payment_url, txnId, ordId
      return {
        "payment_url": data['payment_url'] ?? "",
        "txnId": data['txnId']?.toString() ?? "",
        "ordId": data['ordId']?.toString() ?? "",
      };
    } else {
      throw Exception("Failed to create payment → ${response.body}");
    }
  }
}
