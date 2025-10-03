// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'login.dart';
// import '../helpers/backend.dart';
// import 'package:geolocator/geolocator.dart';

// class SignupScreen extends StatefulWidget {
//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final storage = const FlutterSecureStorage();

//   // Controllers
//   final nameController = TextEditingController();
//   final usernameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final phoneController = TextEditingController();
//   final addressController = TextEditingController();
//   final bioController = TextEditingController();
//   final govIdController = TextEditingController();
//   final skillsController = TextEditingController();
//   final portfolioController = TextEditingController();
//   final hourlyRateController = TextEditingController();
//   final languagesController = TextEditingController();
//   final educationController = TextEditingController();
//   final socialLinksController = TextEditingController();

//   String? selectedRole;
//   String? experienceLevel;
//   bool isLoading = false;

//   // 🔹 Location
//   double? currentLatitude;
//   double? currentLongitude;

//   Future<void> _getCurrentLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please enable location services!'),
//           ),
//         );
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) return;
//       }
//       if (permission == LocationPermission.deniedForever) return;

//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       setState(() {
//         currentLatitude = position.latitude;
//         currentLongitude = position.longitude;
//       });
//     } catch (e) {
//       print('Location error: $e');
//     }
//   }

//   Future<void> signup() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     // 🔹 Fetch location if provider
//     if (selectedRole == "I am a service provider") {
//       await _getCurrentLocation();
//     }

//     final Map<String, dynamic> body = {
//       "name": nameController.text.trim(),
//       "username": usernameController.text.trim(),
//       "email": emailController.text.trim(),
//       "password": passwordController.text,
//       "role": selectedRole == "I am a service provider" ? "provider" : "user",
//     };

//     if (selectedRole == "I am a service provider") {
//       body.addAll({
//         "phone": phoneController.text.trim(),
//         "address": addressController.text.trim(),
//         "bio": bioController.text.trim(),
//         "gov_id": govIdController.text.trim(),
//         "experience_level": experienceLevel,
//         "hourly_rate": hourlyRateController.text.isNotEmpty
//             ? double.tryParse(hourlyRateController.text)
//             : null,
//         "skills": skillsController.text.isNotEmpty
//             ? skillsController.text
//                 .split(',')
//                 .map((s) => s.trim())
//                 .where((s) => s.isNotEmpty)
//                 .toList()
//             : [],
//         "portfolio_links": portfolioController.text.isNotEmpty
//             ? portfolioController.text
//                 .split(',')
//                 .map((s) => s.trim())
//                 .where((s) => s.isNotEmpty)
//                 .toList()
//             : [],
//         "languages": languagesController.text.isNotEmpty
//             ? languagesController.text
//                 .split(',')
//                 .map((s) => s.trim())
//                 .where((s) => s.isNotEmpty)
//                 .toList()
//             : [],
//         "education": educationController.text.isNotEmpty
//             ? educationController.text
//                 .split(',')
//                 .map((s) => s.trim())
//                 .where((s) => s.isNotEmpty)
//                 .toList()
//             : [],
//         "social_links": socialLinksController.text.isNotEmpty
//             ? socialLinksController.text
//                 .split(',')
//                 .map((s) => s.trim())
//                 .where((s) => s.isNotEmpty)
//                 .toList()
//             : [],
//         // 🔹 Add location
//         "latitude": currentLatitude,
//         "longitude": currentLongitude,
//       });
//     }

//     try {
//       final url = Uri.parse('${Backend.baseUrl}/auth/signup');
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);
//       setState(() => isLoading = false);

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'Signup successful! ✅ Check your email to verify your account before login.',
//             ),
//             backgroundColor:  const Color(0xFF0A66C2),
//           ),
//         );

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => LoginScreen()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data['message'] ?? 'Signup failed ❌'),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   InputDecoration _inputDecoration(String label) {
//   return InputDecoration(
//     labelText: label,
//     filled: true,
//     fillColor: const Color(0xFFE8F0FE), // Soft light blue for premium feel
//     labelStyle: const TextStyle(
//       color:  const Color(0xFF0A66C2),
//       fontWeight: FontWeight.w600, // Slightly bolder for premium look
//     ),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: const BorderSide(
//         color: Color(0xFF0A66C2), // Premium LinkedIn blue
//         width: 2,
//       ),
//     ),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 SvgPicture.asset(
//                   'assets/svg/signup.svg',
//                   height: 150,
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Create Account",
//                   style: TextStyle(
//                       color: const Color(0xFF0A66C2),
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 25),
//                 TextFormField(
//                   controller: nameController,
//                   decoration: _inputDecoration("Full Name"),
//                   validator: (val) => val!.isEmpty ? "Enter name" : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: usernameController,
//                   decoration: _inputDecoration("Username / Display Name"),
//                   validator: (val) => val!.isEmpty ? "Enter username" : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: emailController,
//                   decoration: _inputDecoration("Email"),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) return "Enter email";
//                     final emailRegex =
//                         RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
//                     if (!emailRegex.hasMatch(val)) return "Enter valid email";
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: passwordController,
//                   decoration: _inputDecoration("Password"),
//                   obscureText: true,
//                   validator: (val) {
//                     if (val == null || val.length < 6)
//                       return "Password must be at least 6 characters";
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 DropdownButtonFormField<String>(
//                   value: selectedRole,
//                   decoration: _inputDecoration("Select Role"),
//                   items: [
//                     DropdownMenuItem(
//                         value: "I need a service",
//                         child: Text("I need a service",
//                             style: TextStyle(color: const Color(0xFF0A66C2),))),
//                     DropdownMenuItem(
//                         value: "I am a service provider",
//                         child: Text("I am a service provider",
//                             style: TextStyle(color: const Color(0xFF0A66C2),))),
//                   ],
//                   dropdownColor: const Color(0xFFD9E1F0),
//                   onChanged: (val) => setState(() => selectedRole = val),
//                   validator: (val) => val == null ? "Select a role" : null,
//                   style: const TextStyle(color:  const Color(0xFF0A66C2),),
//                 ),
//                 const SizedBox(height: 12),
//                 if (selectedRole == "I am a service provider") ...[
//                   TextFormField(
//                     controller: phoneController,
//                     decoration: _inputDecoration("Phone"),
//                     validator: (val) =>
//                         val == null || val.isEmpty ? "Enter phone" : null,
//                     keyboardType: TextInputType.phone,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: addressController,
//                     decoration: _inputDecoration("Address"),
//                     validator: (val) =>
//                         val == null || val.isEmpty ? "Enter address" : null,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: skillsController,
//                     decoration: _inputDecoration("Skills (comma separated)"),
//                     validator: (val) =>
//                         val == null || val.isEmpty ? "Enter skills" : null,
//                   ),
//                   const SizedBox(height: 12),
//                  DropdownButtonFormField<String>(
//   value: experienceLevel,
//   decoration: InputDecoration(
//     labelText: "Experience Level",
//     filled: true,
//     fillColor: const Color(0xFFD9E1F0), // Light background
//     labelStyle: const TextStyle(color: const Color(0xFF0A66C2), fontWeight: FontWeight.w600),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
//     ),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
//   ),
//   items: ["Beginner", "Intermediate", "Expert"]
//       .map((e) => DropdownMenuItem(
//             value: e,
//             child: Text(
//               e,
//               style: const TextStyle(
//                 color:  const Color(0xFF0A66C2),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ))
//       .toList(),
//   onChanged: (val) => setState(() => experienceLevel = val),
//   validator: (val) => val == null ? "Select experience level" : null,
//   dropdownColor: const Color(0xFFD9E1F0),
//   style: const TextStyle(
//     color: Color(0xFF2A3A69),
//     fontWeight: FontWeight.w500,
//   ),
//   icon: const Icon(Icons.keyboard_arrow_down, color: const Color(0xFF0A66C2),),
// ),

//                   const SizedBox(height: 12),
//                   // Optional fields
//                   TextFormField(
//                     controller: bioController,
//                     decoration: _inputDecoration("Short Bio"),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: govIdController,
//                     decoration: _inputDecoration("Gov ID (CNIC/Passport)"),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: hourlyRateController,
//                     decoration: _inputDecoration("Hourly Rate (Optional)"),
//                     keyboardType: TextInputType.number,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: portfolioController,
//                     decoration: _inputDecoration(
//                         "Portfolio Links (comma separated)"),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: languagesController,
//                     decoration:
//                         _inputDecoration("Languages (comma separated)"),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: educationController,
//                     decoration: _inputDecoration(
//                         "Education / Certifications (comma separated)"),
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: socialLinksController,
//                     decoration: _inputDecoration(
//                         "Social / Website Links (comma separated)"),
//                   ),
//                   const SizedBox(height: 12),
//                 ],
//                 const SizedBox(height: 20),
//                 isLoading
//                     ? const CircularProgressIndicator(
//                         valueColor:
//                             AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2),))
//                     :SizedBox(
//   width: double.infinity,
//   child: ElevatedButton(
//     onPressed: signup,
//     style: ElevatedButton.styleFrom(
//       backgroundColor: const Color(0xFF0A66C2), // LinkedIn Dark Blue
//       foregroundColor: Colors.white,
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 4, // subtle shadow for premium look
//     ),
//     child: const Text(
//       "Sign Up",
//       style: TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   ),
// ),
//                 const SizedBox(height: 20),
//                 Row(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//     const Text(
//       "Already have an account? ",
//       style: TextStyle(
//         color: Color(0xFF5C74B1), // Light LinkedIn blue
//         fontWeight: FontWeight.w500,
//         fontSize: 16,
//       ),
//     ),
//     GestureDetector(
//       onTap: () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => LoginScreen()),
//         );
//       },
//       child: const Text(
//         "Login",
//         style: TextStyle(
//           color:  const Color(0xFF0A66C2), // Dark LinkedIn blue
//           fontWeight: FontWeight.bold,
//           fontSize: 16,
//           decoration: TextDecoration.underline,
//           decorationColor: const Color(0xFF0A66C2),
//           decorationThickness: 2,
//         ),
//       ),
//     ),
//   ],
// )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import '../helpers/backend.dart';
import 'package:geolocator/geolocator.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  // Controllers
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final bioController = TextEditingController();
  final govIdController = TextEditingController();
  // final skillsController = TextEditingController();
  final portfolioController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final languagesController = TextEditingController();
  final educationController = TextEditingController();
  final socialLinksController = TextEditingController();
  bool _obscurePassword = true;

  String? selectedRole;
  String? experienceLevel;
  bool isLoading = false;

  // 🔹 Location
  double? currentLatitude;
  double? currentLongitude;

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ Location services are disabled. Please enable GPS to see nearby providers.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(
              content: const Text(
                '📍 Enable location to see nearby providers. Without it, some services may not work.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blueAccent,
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  },
                  child: const Text(
                    'DISMISS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '❌ Location permission permanently denied. Please enable it from app settings.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // ✅ Get location if everything is fine
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Location fetched successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Location error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    // 🔹 Fetch location if provider
    if (selectedRole == "I am a service provider") {
      await _getCurrentLocation();
    }

    final Map<String, dynamic> body = {
      "name": nameController.text.trim(),
      "username": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text,
      "role": selectedRole == "I am a service provider" ? "provider" : "user",
    };

    if (selectedRole == "I am a service provider") {
      body.addAll({
        "phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "bio": bioController.text.trim(),
        "gov_id": govIdController.text.trim(),
        "experience_level": experienceLevel,
        "hourly_rate": hourlyRateController.text.isNotEmpty
            ? double.tryParse(hourlyRateController.text)
            : null,
       
        "portfolio_links": portfolioController.text.isNotEmpty
            ? portfolioController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList()
            : [],
        "languages": languagesController.text.isNotEmpty
            ? languagesController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList()
            : [],
        "education": educationController.text.isNotEmpty
            ? educationController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList()
            : [],
        "social_links": socialLinksController.text.isNotEmpty
            ? socialLinksController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList()
            : [],
        // 🔹 Add location
        "latitude": currentLatitude,
        "longitude": currentLongitude,
      });
    }

    try {
      final url = Uri.parse('${Backend.baseUrl}/auth/signup');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Signup successful! ✅ Check your email to verify your account before login.',
            ),
            backgroundColor: const Color(0xFF0A66C2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        print('Signup failed: ${response.statusCode} - ${data}');

        String backendError =
            data['message'] ?? "Signup failed ❌ Please try again";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    backendError,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Signup exception: $e');
      String errorMsg = "Something went wrong. Please try again.";
      if (e.toString().contains("SocketException")) {
        errorMsg = "No internet connection. Please check your network.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFE8F0FE), // Soft light blue for premium feel
      labelStyle: const TextStyle(
        color: const Color(0xFF0A66C2),
        fontWeight: FontWeight.w600, // Slightly bolder for premium look
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF0A66C2), // Premium LinkedIn blue
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SvgPicture.asset('assets/svg/signup.svg', height: 150),
                const SizedBox(height: 20),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: const Color(0xFF0A66C2),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Full Name"),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Enter full name";
                    }
                    if (val.length < 3) {
                      return "Name must be at least 3 characters";
                    }
                    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
                    if (!nameRegex.hasMatch(val)) {
                      return "Only letters and spaces allowed";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameController,
                  decoration: _inputDecoration("Username / Display Name"),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter name";
                    if (val.length < 3)
                      return "Name must be at least 3 characters";
                    final nameRegex = RegExp(
                      r'^[a-zA-Z\s]+$',
                    ); // only letters and spaces
                    if (!nameRegex.hasMatch(val))
                      return "Only letters and spaces allowed";
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter email";

                    // More robust email regex
                    final emailRegex = RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                    );

                    if (!emailRegex.hasMatch(val)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: passwordController,
                  decoration: _inputDecoration("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF0A66C2),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter password";
                    // min 8 chars, at least 1 uppercase, 1 number and 1 special character
                    final regex = RegExp(
                      r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
                    );
                    if (!regex.hasMatch(val)) {
                      return "Password must be 8+ chars, include 1 uppercase, 1 number and 1 special char";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: _inputDecoration("Select Role"),
                  items: [
                    DropdownMenuItem(
                      value: "I need a service",
                      child: Text(
                        "I need a service",
                        style: TextStyle(color: const Color(0xFF0A66C2)),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "I am a service provider",
                      child: Text(
                        "I am a service provider",
                        style: TextStyle(color: const Color(0xFF0A66C2)),
                      ),
                    ),
                  ],
                  dropdownColor: const Color(0xFFD9E1F0),
                  onChanged: (val) => setState(() => selectedRole = val),
                  validator: (val) => val == null ? "Select a role" : null,
                  style: const TextStyle(color: const Color(0xFF0A66C2)),
                ),
                const SizedBox(height: 12),
                if (selectedRole == "I am a service provider") ...[
                  TextFormField(
                    controller: phoneController,
                    decoration: _inputDecoration("Phone"),
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Enter phone number";

                      // Phone number must be 10–15 digits
                      final phoneRegex = RegExp(r'^[0-9]{10,15}$');

                      if (!phoneRegex.hasMatch(val)) {
                        return "Invalid phone number (10–15 digits required)";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: addressController,
                    decoration: _inputDecoration("Address"),
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Enter address";
                      if (val.length < 5) return "Address too short";
                      return null;
                    },
                  ),

                  //                   const SizedBox(height: 12),
                  //                   TextFormField(
                  //   controller: skillsController,
                  //   decoration: _inputDecoration("Skills (comma separated)"),
                  //   validator: (val) {
                  //     if (val == null || val.isEmpty) return "Enter skills";
                  //     final skills = val
                  //         .split(',')
                  //         .map((s) => s.trim())
                  //         .where((s) => s.isNotEmpty)
                  //         .toList();
                  //     if (skills.isEmpty) return "Enter at least one valid skill";
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: experienceLevel,
                    decoration: InputDecoration(
                      labelText: "Experience Level",
                      filled: true,
                      fillColor: const Color(0xFFD9E1F0), // Light background
                      labelStyle: const TextStyle(
                        color: const Color(0xFF0A66C2),
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF0A66C2),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                    ),
                    items: ["Beginner", "Intermediate", "Expert"]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: const TextStyle(
                                color: const Color(0xFF0A66C2),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => experienceLevel = val),
                    validator: (val) =>
                        val == null ? "Select experience level" : null,
                    dropdownColor: const Color(0xFFD9E1F0),
                    style: const TextStyle(
                      color: Color(0xFF2A3A69),
                      fontWeight: FontWeight.w500,
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF0A66C2),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Optional fields
                  TextFormField(
                    controller: bioController,
                    decoration: _inputDecoration("Short Bio"),
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        if (val.length < 20)
                          return "Bio must be at least 20 characters";
                        if (val.length > 250)
                          return "Bio must be under 250 characters";
                      }
                      return null; // Optional hai, empty bhi allow
                    },
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: govIdController,
                    decoration: _inputDecoration("Gov ID (CNIC/Passport)"),
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Enter CNIC/Passport number";

                      // Pakistan CNIC format check (xxxxx-xxxxxxx-x)
                      final cnicRegex = RegExp(r'^\d{5}-\d{7}-\d$');
                      if (!cnicRegex.hasMatch(val)) {
                        return "Invalid CNIC format (12345-1234567-1)";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: hourlyRateController,
                    decoration: _inputDecoration("Hourly Rate (Optional)"),
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        final rate = double.tryParse(val);
                        if (rate == null || rate <= 0) {
                          return "Enter a valid hourly rate (must be greater than 0)";
                        }
                      }
                      return null; // empty allowed
                    },
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: portfolioController,
                    decoration: _inputDecoration(
                      "Portfolio Links (comma separated)",
                    ),
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        final urls = val
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty);
                        final urlRegex = RegExp(r'^(https?:\/\/[^\s]+)$');
                        for (final url in urls) {
                          if (!urlRegex.hasMatch(url)) {
                            return "Enter valid URLs (http/https)";
                          }
                        }
                      }
                      return null; // empty allowed
                    },
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: languagesController,
                    decoration: _inputDecoration("Languages (comma separated)"),
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        final langs = val
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        if (langs.isEmpty) {
                          return "Enter at least one language";
                        }

                        // Optional: allow only letters and spaces
                        final langRegex = RegExp(r'^[a-zA-Z\s]+$');
                        for (final lang in langs) {
                          if (!langRegex.hasMatch(lang)) {
                            return "Invalid language name: $lang";
                          }
                        }
                      }
                      return null; // empty allowed
                    },
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: educationController,
                    decoration: _inputDecoration(
                      "Education / Certifications (comma separated)",
                    ),
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        final items = val
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        if (items.isEmpty) {
                          return "Enter at least one education/certification";
                        }

                        // Optional: basic validation (letters, numbers, spaces, & - .)
                        final eduRegex = RegExp(r'^[a-zA-Z0-9\s\-\.\&]+$');
                        for (final item in items) {
                          if (!eduRegex.hasMatch(item)) {
                            return "Invalid entry: $item";
                          }
                        }
                      }
                      return null; // optional so empty allowed
                    },
                  ),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: socialLinksController,
                    decoration: _inputDecoration(
                      "Social / Website Links (comma separated)",
                    ),
                    validator: (val) {
                      if (val != null && val.isNotEmpty) {
                        final links = val
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList();

                        if (links.isEmpty) {
                          return "Enter at least one valid link";
                        }

                        // URL regex → allows http:// or https://
                        final urlRegex = RegExp(r'^(https?:\/\/[^\s]+)$');
                        for (final link in links) {
                          if (!urlRegex.hasMatch(link)) {
                            return "Invalid link: $link";
                          }
                        }
                      }
                      return null; // optional so empty allowed
                    },
                  ),

                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0A66C2),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF0A66C2,
                            ), // LinkedIn Dark Blue
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4, // subtle shadow for premium look
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: Color(0xFF5C74B1), // Light LinkedIn blue
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: const Color(0xFF0A66C2), // Dark LinkedIn blue
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF0A66C2),
                          decorationThickness: 2,
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
