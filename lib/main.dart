// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// // Import your signup page here
// import 'screens/signup.dart';
// import 'helpers/backend.dart';

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

//   // Get device FCM token
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Request permission (iOS ke liye)
//   await messaging.requestPermission();

//   String? token = await messaging.getToken();
//   print("FCM Token: $token");

//   if (token != null) {
//     // Example: call backend to update token
//     await http.post(
//       Uri.parse("${Backend.baseUrl}/users/update-token"),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({
//         "user_id": 123, // <-- yaha actual user ka ID dalna hoga
//         "fcm_token": token,
//       }),
//     );
//   }

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
//       home: SignupScreen(),
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
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'dart:core';
// Import your screens
//import 'screens/signup.dart';
import 'screens/reset-password.dart';
import 'helpers/backend.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/splashScreen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notification = message.notification;
  if (notification != null) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel', // same channel as in Node.js & manifest
          'Default Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // 🔹 Show notification even if app is in background/terminated
    await FlutterLocalNotificationsPlugin().show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }

  print("💬 Background message received: ${message.notification?.title}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
  'default_channel', // 👈 must match AndroidManifest & Node.js
  'Default Notifications',
  description: 'Used for general notifications.',
  importance: Importance.high,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Firebase initialization
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
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

  // 💥 CREATE Notification Channel for Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(defaultChannel);

  // 💥 Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 💥 Ask for notification permission
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  // 💥 Handle foreground messages (so they appear while app is open)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel', // same id everywhere
            'Default Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
  // FCM token handling
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  //await messaging.requestPermission();
  String? token = await messaging.getToken();
  print("FCM Token: $token");

  if (token != null) {
    try {
      await http.post(
        Uri.parse("${Backend.baseUrl}/users/update-token"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": 123, // replace with actual logged-in user ID
          "fcm_token": token,
        }),
      );
    } catch (e) {
      print("FCM token update failed: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Declaration is fine: late AppLinks _appLinks;
  late AppLinks _appLinks;
  StreamSubscription? _sub;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // FIX 1: Initialize AppLinks object here, synchronously
    _appLinks = AppLinks();
    initDeepLinkListener();
  }

  void initDeepLinkListener() async {
    // _appLinks = AppLinks(); // Initialize the AppLinks object

    // Handle app opened from terminated state
    try {
      final initialUri = await _appLinks.getInitialLink(); // returns Uri?
      if (initialUri != null) {
        handleDeepLink(initialUri);
      }
    } catch (e) {
      print("Error getting initial link: $e");
    }

    // Handle app opened while in background or foreground
    _sub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) handleDeepLink(uri);
      },
      onError: (err) {
        print("Deep link error: $err");
      },
    );
  }

  // ... rest of the class remains the same ...

  void handleDeepLink(Uri uri) {
    if (uri.host == 'resetpassword') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => ResetPasswordScreen(token: token)),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Service Provider App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}




// https://349adebab51b.ngrok-free.app/services?category_id=31