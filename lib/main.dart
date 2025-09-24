

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// //import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';

// // Import your signup page here
// import 'screens/signup.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: FirebaseOptions(
//         apiKey: "AIzaSyAfB6rM7DsbiiwoWP0HsKp7rqjvo9dJQQM",
//         authDomain: "serviceproviderapp-63814.firebaseapp.com",
//         projectId: "serviceproviderapp-63814",
//         storageBucket: "serviceproviderapp-63814.firebasestorage.app",
//         messagingSenderId: "581489219756",
//         appId: "1:581489219756:web:d1ca68b15ebecc73abe709",
//         measurementId: "G-4K5N8PMP8D",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }

//   // FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // // Get device FCM token
//   // String? token = await messaging.getToken();
//   // print("FCM Token: $token"); // Send this to backend

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Service Provider App',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       // Change home from MyHomePage to SignupPage
//       home:  SignupScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Import your signup page here
import 'screens/signup.dart';
import 'helpers/backend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAfB6rM7DsbiiwoWP0HsKp7rqjvo9dJQQM",
        authDomain: "serviceproviderapp-63814.firebaseapp.com",
        projectId: "serviceproviderapp-63814",
        storageBucket: "serviceproviderapp-63814.firebasestorage.app",
        messagingSenderId: "581489219756",
        appId: "1:581489219756:web:d1ca68b15ebecc73abe709",
        measurementId: "G-4K5N8PMP8D",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Get device FCM token
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission (iOS ke liye)
  await messaging.requestPermission();

  String? token = await messaging.getToken();
  print("FCM Token: $token");

  if (token != null) {
    // Example: call backend to update token
    await http.post(
      Uri.parse("${Backend.baseUrl}/users/update-token"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": 123, // <-- yaha actual user ka ID dalna hoga
        "fcm_token": token,
      }),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Provider App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SignupScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
