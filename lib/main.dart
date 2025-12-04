// import 'screens/payment_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'screens/document_upload_screen.dart';
// import 'package:app_links/app_links.dart';
// import 'dart:async';
// import 'helpers/socket_manager.dart'; // ✅ Global Socket Manager
// import 'screens/reset-password.dart';
// import 'screens/splashScreen.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'screens/provider_status_screen.dart';

// /// 🔹 Firebase background message handler
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   final notification = message.notification;
//   if (notification != null) {
//     const androidDetails = AndroidNotificationDetails(
//       'default_channel',
//       'Default Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );

//     const platformDetails = NotificationDetails(android: androidDetails);
//     await FlutterLocalNotificationsPlugin().show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       platformDetails,
//     );
//   }
//   print("💬 Background message received: ${message.notification?.title}");
// }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
//   'default_channel',
//   'Default Notifications',
//   description: 'Used for general notifications.',
//   importance: Importance.high,
// );

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // 🔹 Firebase init
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
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

//   // 🔹 Notification channel
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin
//       >()
//       ?.createNotificationChannel(defaultChannel);

//   const initializationSettings = InitializationSettings(
//     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//   );

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   await messaging.requestPermission();

//   // 🔹 Foreground notifications
//   FirebaseMessaging.onMessage.listen((message) {
//     final notification = message.notification;
//     if (notification != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'default_channel',
//             'Default Notifications',
//             importance: Importance.high,
//             priority: Priority.high,
//             icon: '@mipmap/ic_launcher',
//           ),
//         ),
//       );
//     }
//   });

//   // 🔥 Initialize Global Socket
//   await SocketManager().initSocket();

//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late AppLinks _appLinks;
//   StreamSubscription? _sub;
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   @override
//   void initState() {
//     super.initState();
//     _appLinks = AppLinks();
//     initDeepLinkListener();
//   }

//   void initDeepLinkListener() async {
//     try {
//       final initialUri = await _appLinks.getInitialLink();
//       if (initialUri != null) handleDeepLink(initialUri);
//     } catch (e) {
//       print("Error getting initial link: $e");
//     }

//     _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
//       if (uri != null) handleDeepLink(uri);
//     }, onError: (err) => print("Deep link error: $err"));
//   }

//   void handleDeepLink(Uri uri) {
//     switch (uri.host) {
//       case 'resetpassword':
//         final token = uri.queryParameters['token'];
//         if (token != null) {
//           navigatorKey.currentState?.push(
//             MaterialPageRoute(
//               builder: (_) => ResetPasswordScreen(token: token),
//             ),
//           );
//         }
//         break;

//      case 'payment':
//   final userId = int.tryParse(uri.queryParameters['userId'] ?? '');
//   final amount = double.tryParse(uri.queryParameters['amount'] ?? '100') ?? 100;

//   if (userId != null) {
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(
//         builder: (_) => PaymentScreen(
//           userId: userId,
//           amount: amount, // pass amount
//         ),
//       ),
//     );
//   }
//   break;

//       case 'documents':
//         final userId = int.tryParse(uri.queryParameters['userId'] ?? '');
//         if (userId != null) {
//           navigatorKey.currentState?.push(
//             MaterialPageRoute(
//               builder: (_) => DocumentUploadScreen(userId: userId),
//             ),
//           );
//         }
//         break;

//       case 'status':
//   final providerId = int.tryParse(uri.queryParameters['userId'] ?? '');
//   if (providerId != null) {
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(
//         builder: (_) => ProviderStatusScreen(providerId: providerId),
//       ),
//     );
//   }
//   break;

//     }
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Service Provider App',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: SplashScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

////


import 'screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'screens/document_upload_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'helpers/socket_manager.dart'; // ✅ Global Socket Manager
import 'screens/reset-password.dart';
import 'screens/splashScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/dashboard.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';


/// 🔹 Firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final notification = message.notification;
  if (notification != null) {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(android: androidDetails);
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
  'default_channel',
  'Default Notifications',
  description: 'Used for general notifications.',
  importance: Importance.high,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Firebase init
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

  // 🔹 Notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(defaultChannel);

  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  // 🔹 Foreground notifications
  FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });
  await SocketManager().initSocket();

  runApp(  
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription? _sub;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    initDeepLinkListener();
  }

  void initDeepLinkListener() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) handleDeepLink(initialUri);
    } catch (e) {
      print("Error getting initial link: $e");
    }

    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) handleDeepLink(uri);
    }, onError: (err) => print("Deep link error: $err"));
  }

  void handleDeepLink(Uri uri) {
    switch (uri.host) {
      case 'resetpassword':
        final token = uri.queryParameters['token'];
        if (token != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(token: token),
            ),
          );
        }
        break;

      case 'payment':
        final userId = int.tryParse(uri.queryParameters['userId'] ?? '');
        final amount =
            double.tryParse(uri.queryParameters['amount'] ?? '100') ?? 100;

        if (userId != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                userId: userId,
                amount: amount, // pass amount
              ),
            ),
          );
        }
        break;

      case 'documents':
        final userId = int.tryParse(uri.queryParameters['userId'] ?? '');
        if (userId != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => DocumentUploadScreen(userId: userId),
            ),
          );
        }
        break;

      case 'status':
        final providerId = int.tryParse(uri.queryParameters['userId'] ?? '');
        if (providerId != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ProviderDashboardScreen(providerId: providerId),
            ),
          );
        }
        break;
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
