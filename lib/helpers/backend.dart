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


import 'package:flutter/foundation.dart';

class Backend {
  static String get baseUrl {
    return "https://263b66bcac56.ngrok-free.app"; // use ngrok URL
  }

  // 🔹 Socket.IO URL
  static String get socketUrl {
    return "https://263b66bcac56.ngrok-free.app"; // use ngrok URL
  }
}
