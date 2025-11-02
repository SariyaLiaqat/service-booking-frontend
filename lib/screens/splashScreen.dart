


// import 'package:flutter/material.dart';
// import 'dart:async';
// import '../helpers/coolors.dart'; // Assuming your color constants are here
// import 'package:servicebookingapp/screens/signup.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _logoController;
//   late Animation<double> _logoAnimation;

//   // --- Branding Text (Can be adjusted later) ---
//   final String _appName = 'ServiceBook Pro'; // Strong, professional name
//   final String _tagline = 'Your service simplified'; // Confident tagline

//   @override
//   void initState() {
//     super.initState();

//     // 1. Logo Animation (Simple fade-in and subtle scale)
//     _logoController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     // Fade-in animation
//     _logoAnimation = CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.easeOut,
//     );

//     _logoController.forward();

//     // 2. Navigation (Standard 3-second delay for initial load)
//     Timer(const Duration(seconds: 4), () { // Corrected from 6 seconds
//       Navigator.of(context).pushReplacement(PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => SignupScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           // Smooth curve for a high-quality transition
//           var curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          
//           // Subtle Slide from bottom (less aggressive than 0.2)
//           final slideTween = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero);
          
//           return FadeTransition(
//             opacity: curve,
//             child: SlideTransition(
//               position: slideTween.animate(curve),
//               child: child,
//             ),
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 700),
//       ));
//     });
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // We use a Stack to perfectly anchor the progress bar to the bottom edge.
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       body: Stack(
//         children: [
//           // --- Main Content: Logo, Name, Tagline (Centered) ---
//           Center(
//             child: FadeTransition(
//               opacity: _logoAnimation,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 mainAxisSize: MainAxisSize.min, // Keep column size minimal
//                 children: [
//                   // Logo
//                   Image.asset(
//                     'assets/images/bglogo.png', // Ensure this path is correct
//                     width: 150,
//                     height: 150,
//                   ),
//                   const SizedBox(height: 24),
//                   // App Name (Strong and Primary Colored)
//                   Text(
//                     _appName,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: kPrimaryColor,
//                       fontSize: 34,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   // Tagline (Subtle and readable)
//                   Text(
//                     _tagline,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: kTextSecondary,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
          
//           // --- Professional Bottom Progress Indicator ---
//           // Anchored to the very bottom of the screen.
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: LinearProgressIndicator(
//               backgroundColor: kPrimaryColor.withOpacity(0.1),
//               valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
//               minHeight: 4, // Slim, non-intrusive height
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



///////////////////////////////

// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../helpers/backend.dart';
// import '../helpers/coolors.dart';
// import 'signup.dart';
// import 'login.dart';
// import 'provider_next_steps_screen.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _logoController;
//   late Animation<double> _logoAnimation;

//   final String _appName = 'ServiceBook Pro';
//   final String _tagline = 'Your service simplified';

//   @override
//   void initState() {
//     super.initState();

//     _logoController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     _logoAnimation = CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.easeOut,
//     );

//     _logoController.forward();

//     // 🔥 Start navigation check after short splash delay
//     Timer(const Duration(seconds: 3), _checkUserStatus);
//   }

//   Future<void> _checkUserStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getInt('userId');
//     final role = prefs.getString('role'); // example: 'provider' or 'user'

//     // 🟠 If no user found (first time open)
//     if (userId == null || role == null) {
//       _navigateTo(SignupScreen());
//       return;
//     }

//     // 🟣 If Provider, check backend status
//     if (role == 'provider') {
//       try {
//         final response = await http.get(
//           Uri.parse('${Backend.baseUrl}/provider/status/$userId'),
//         );

//         if (response.statusCode == 200) {
//           final data = jsonDecode(response.body);
//           final provider = data['provider'];
//           final overallStatus = data['overall_status'];

//           final paymentDone = provider['payment_status'] == 'paid';
//           final docsDone = provider['documents_uploaded'] == true;
//           final approved = overallStatus == 'approved';

//           if (!paymentDone || !docsDone || !approved) {
//             // 👇 Stay in next steps screen until both done
//             _navigateTo(ProviderNextStepsScreen(userId: userId));
//           } else {
//             // ✅ Both done and approved → Go to login
//             _navigateTo(LoginScreen());
//           }
//         } else {
//           _navigateTo(SignupScreen());
//         }
//       } catch (e) {
//         print("Error checking provider status: $e");
//         _navigateTo(SignupScreen());
//       }
//     } else {
//       // 🟢 Normal user — just go to Login
//       _navigateTo(LoginScreen());
//     }
//   }

//   void _navigateTo(Widget screen) {
//     Navigator.of(context).pushReplacement(PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => screen,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         var curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
//         final slideTween = Tween<Offset>(
//           begin: const Offset(0, 0.05),
//           end: Offset.zero,
//         );
//         return FadeTransition(
//           opacity: curve,
//           child: SlideTransition(
//             position: slideTween.animate(curve),
//             child: child,
//           ),
//         );
//       },
//       transitionDuration: const Duration(milliseconds: 700),
//     ));
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       body: Stack(
//         children: [
//           Center(
//             child: FadeTransition(
//               opacity: _logoAnimation,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/images/bglogo.png',
//                     width: 150,
//                     height: 150,
//                   ),
//                   const SizedBox(height: 24),
//                   Text(
//                     _appName,
//                     style: TextStyle(
//                       color: kPrimaryColor,
//                       fontSize: 34,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     _tagline,
//                     style: const TextStyle(
//                       color: kTextSecondary,
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: LinearProgressIndicator(
//               backgroundColor: kPrimaryColor.withOpacity(0.1),
//               valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
//               minHeight: 4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/backend.dart';
import '../helpers/coolors.dart';
import 'signup.dart';
import 'login.dart';
import 'provider_next_steps_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  final String _appName = 'ServiceBook Pro';
  final String _tagline = 'Your service simplified';

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _logoController.forward();

    // 🔥 Start navigation check after short splash delay
    Timer(const Duration(seconds: 3), _checkUserStatus);
  }

 Future<void> _checkUserStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('userId');
  final role = prefs.getString('role'); // example: 'provider' or 'user'

  // 🟠 First time open → Signup
  if (userId == null || role == null) {
    _navigateTo(SignupScreen());
    return;
  }

  // 🟣 If Provider, check backend status
  if (role == 'provider') {
    try {
      final response = await http.get(
        Uri.parse('${Backend.baseUrl}/provider/status/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final provider = data['provider'];

        final paymentDone = provider['payment_status'] == 'paid';
        final docsDone = provider['documents_uploaded'] == true;

        print("🔍 Provider paymentDone: $paymentDone, docsDone: $docsDone");

        // ✅ Only 2 conditions now: payment & documents
        if (paymentDone && docsDone) {
          print("✅ Both done → Navigate to LoginScreen");
          _navigateTo(LoginScreen());
        } else {
          print("⚠️ Incomplete → Navigate to ProviderNextStepsScreen");
          _navigateTo(ProviderNextStepsScreen(userId: userId));
        }
      } else {
        _navigateTo(SignupScreen());
      }
    } catch (e) {
      print("Error checking provider status: $e");
      _navigateTo(SignupScreen());
    }
  } else {
    // 🟢 Normal user — go to Login
    _navigateTo(LoginScreen());
  }
}


  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final slideTween = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: slideTween.animate(curve),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 700),
    ));
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _logoAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/bglogo.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _appName,
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _tagline,
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: kPrimaryColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
