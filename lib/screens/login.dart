// //////////////////////
// ///
// ///// lib/screens/login.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'home_screen.dart';
// import '../helpers/backend.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final storage = const FlutterSecureStorage();

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool isLoading = false;

//   Future<void> login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final body = {
//         "email": emailController.text.trim(),
//         "password": passwordController.text.trim(),
//       };

//       final url = Uri.parse('${Backend.baseUrl}/auth/login');

//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['token'] != null) {
//         // Store JWT securely
//         await storage.write(key: 'jwt', value: data['token']);

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Login successful ✅')),
//         );

//         // Extended user data for Fiverr-style fields
//         final userData = {
//           ...data['user'],
//           'service_packages': data['user']['service_packages'] ?? [],
//           'portfolio_links': data['user']['portfolio_links'] ?? [],
//           'languages': data['user']['languages'] ?? [],
//           'education': data['user']['education'] ?? '',
//           'hourly_rate': data['user']['hourly_rate'] ?? 0,
//           'social_links': data['user']['social_links'] ?? {},
//         };

//         // Navigate to HomeScreen with extended user data
//         Navigator.pushReplacement(
//   context,
//   MaterialPageRoute(
//     builder: (context) => HomeScreen(
//       role: data['user']['role'],
//       userData: Map<String, dynamic>.from(data['user']), // ✅ cast
//     ),
//   ),
// );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'Invalid credentials ❌')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${e.toString()}")),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Email
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Enter email" : null,
//               ),
//               const SizedBox(height: 10),

//               // Password
//               TextFormField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(labelText: "Password"),
//                 obscureText: true,
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Enter password" : null,
//               ),
//               const SizedBox(height: 20),

//               // Login Button
//               isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: login,
//                       child: const Text("Login"),
//                     ),

//               const SizedBox(height: 20),

//               // Signup navigation
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//                 child: const Text("Don't have an account? Signup"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//////////////////////
//////////////////////
/// login.dart (Production-ready)
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'home_screen.dart';
// import '../helpers/backend.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final storage = const FlutterSecureStorage();

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool isLoading = false;

//   Future<void> login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final body = {
//         "email": emailController.text.trim(),
//         "password": passwordController.text.trim(),
//       };

//       final url = Uri.parse('${Backend.baseUrl}/auth/login');
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final user = data['user'];
//         if (user['is_verified'] != true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   "Your account is not verified yet. Please check your email ✅"),
//             ),
//           );
//         } else if (data['token'] != null) {
//           // Store JWT securely
//           await storage.write(key: 'jwt', value: data['token']);

//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login successful ✅')),
//           );

//           // Navigate to HomeScreen with extended user data
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomeScreen(
//                 role: user['role'],
//                 userData: Map<String, dynamic>.from(user),
//               ),
//             ),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'Invalid credentials ❌')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${e.toString()}")),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Email
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Enter email" : null,
//               ),
//               const SizedBox(height: 10),

//               // Password
//               TextFormField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(labelText: "Password"),
//                 obscureText: true,
//                 validator: (val) =>
//                     val == null || val.isEmpty ? "Enter password" : null,
//               ),
//               const SizedBox(height: 20),

//               // Login Button
//               isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: login,
//                       child: const Text("Login"),
//                     ),

//               const SizedBox(height: 20),

//               // Signup navigation
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/signup');
//                 },
//                 child: const Text("Don't have an account? Signup"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'home_screen.dart';
// import '../helpers/backend.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final storage = const FlutterSecureStorage();

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool isLoading = false;

//   Future<void> login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final body = {
//         "email": emailController.text.trim(),
//         "password": passwordController.text.trim(),
//       };

//       final url = Uri.parse('${Backend.baseUrl}/auth/login');
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final user = data['user'];
//         if (user['is_verified'] != true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   "Your account is not verified yet. Please check your email ✅"),
//             ),
//           );
//         } else if (data['token'] != null) {
//           await storage.write(key: 'jwt', value: data['token']);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Login successful ✅')),
//           );

//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => HomeScreen(
//                 role: user['role'],
//                 userData: Map<String, dynamic>.from(user),
//               ),
//             ),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'Invalid credentials ❌')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: ${e.toString()}")),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF121212), // Dark background
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 // App Logo / Title
//                 const Icon(Icons.lock_outline, size: 80, color: Colors.tealAccent),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Welcome Back",
//                   style: TextStyle(
//                       color: Colors.tealAccent,
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 30),

//                 // Email
//                 TextFormField(
//                   controller: emailController,
//                   decoration: InputDecoration(
//                     labelText: "Email",
//                     filled: true,
//                     fillColor: const Color(0xFF1E1E1E),
//                     labelStyle: const TextStyle(color: Colors.white70),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   style: const TextStyle(color: Colors.white),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (val) =>
//                       val == null || val.isEmpty ? "Enter email" : null,
//                 ),
//                 const SizedBox(height: 16),

//                 // Password
//                 TextFormField(
//                   controller: passwordController,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     filled: true,
//                     fillColor: const Color(0xFF1E1E1E),
//                     labelStyle: const TextStyle(color: Colors.white70),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   style: const TextStyle(color: Colors.white),
//                   obscureText: true,
//                   validator: (val) =>
//                       val == null || val.isEmpty ? "Enter password" : null,
//                 ),
//                 const SizedBox(height: 24),

//                 // Login Button
//                 isLoading
//                     ? const CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent),
//                       )
//                     : SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: login,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: Colors.tealAccent,
//                             foregroundColor: Colors.black,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             "Login",
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                 const SizedBox(height: 20),

//                 // Signup navigation
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Don't have an account?",
//                         style: TextStyle(color: Colors.white70)),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushNamed(context, '/signup');
//                       },
//                       child: const Text(
//                         "Sign Up",
//                         style: TextStyle(
//                           color: Colors.tealAccent,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

/////
///
///
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';
import 'signup.dart';
import '../helpers/backend.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final body = {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      };

      final url = Uri.parse('${Backend.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = data['user'];
        if (user['is_verified'] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Your account is not verified yet. Please check your email ✅",
              ),
              backgroundColor: Color(0xFF2A3A69),
            ),
          );
        } else if (data['token'] != null) {
          await storage.write(key: 'jwt', value: data['token']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful ✅'),
              backgroundColor: Color(0xFF2A3A69),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                role: user['role'],
                userData: Map<String, dynamic>.from(user),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Invalid credentials ❌'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFD9E1F0), // Light Blue
      labelStyle: const TextStyle(color: Color(0xFF2A3A69)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF5C74B1), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Top SVG Image
                SvgPicture.asset('assets/svg/login.svg', height: 150),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Color(0xFF2A3A69),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),

                // Email Field
                TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Email"),
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFF2A3A69)),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter email" : null,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  decoration: _inputDecoration("Password"),
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFF2A3A69)),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter password" : null,
                ),
                const SizedBox(height: 24),

                // Login Button
                isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2A3A69),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF2A3A69),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // Signup navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF5C74B1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => SignupScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Color(0xFF2A3A69),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
