


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
//             backgroundColor: Color(0xFF2A3A69),
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
//     return InputDecoration(
//       labelText: label,
//       filled: true,
//       fillColor: const Color(0xFFD9E1F0),
//       labelStyle: const TextStyle(color: Color(0xFF2A3A69)),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: const BorderSide(color: Color(0xFF5C74B1), width: 2),
//       ),
//     );
//   }

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
//                       color: Color(0xFF2A3A69),
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
//                             style: TextStyle(color: Color(0xFF2A3A69)))),
//                     DropdownMenuItem(
//                         value: "I am a service provider",
//                         child: Text("I am a service provider",
//                             style: TextStyle(color: Color(0xFF2A3A69)))),
//                   ],
//                   dropdownColor: const Color(0xFFD9E1F0),
//                   onChanged: (val) => setState(() => selectedRole = val),
//                   validator: (val) => val == null ? "Select a role" : null,
//                   style: const TextStyle(color: Color(0xFF2A3A69)),
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
//                   DropdownButtonFormField<String>(
//                     value: experienceLevel,
//                     decoration: _inputDecoration("Experience Level"),
//                     items: ["Beginner", "Intermediate", "Expert"]
//                         .map((e) =>
//                             DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                     onChanged: (val) => setState(() => experienceLevel = val),
//                     validator: (val) =>
//                         val == null ? "Select experience level" : null,
//                     dropdownColor: const Color(0xFFD9E1F0),
//                     style: const TextStyle(color: Color(0xFF2A3A69)),
//                   ),
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
//                             AlwaysStoppedAnimation<Color>(Color(0xFF2A3A69)))
//                     : SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: signup,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             backgroundColor: const Color(0xFF2A3A69),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                           child: const Text(
//                             "Sign Up",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account? ",
//                         style: TextStyle(
//                             color: Color(0xFF5C74B1),
//                             fontWeight: FontWeight.w500)),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => LoginScreen()));
//                       },
//                       child: const Text(
//                         "Login",
//                         style: TextStyle(
//                             color: Color(0xFF2A3A69),
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline),
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
  final skillsController = TextEditingController();
  final portfolioController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final languagesController = TextEditingController();
  final educationController = TextEditingController();
  final socialLinksController = TextEditingController();

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
            content: Text('Please enable location services!'),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      });
    } catch (e) {
      print('Location error: $e');
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
        "skills": skillsController.text.isNotEmpty
            ? skillsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
            : [],
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
            backgroundColor:  const Color(0xFF0A66C2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Signup failed ❌'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFE8F0FE), // Soft light blue for premium feel
    labelStyle: const TextStyle(
      color:  const Color(0xFF0A66C2),
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
                SvgPicture.asset(
                  'assets/svg/signup.svg',
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Create Account",
                  style: TextStyle(
                      color: const Color(0xFF0A66C2),
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Full Name"),
                  validator: (val) => val!.isEmpty ? "Enter name" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: usernameController,
                  decoration: _inputDecoration("Username / Display Name"),
                  validator: (val) => val!.isEmpty ? "Enter username" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: _inputDecoration("Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Enter email";
                    final emailRegex =
                        RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                    if (!emailRegex.hasMatch(val)) return "Enter valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  decoration: _inputDecoration("Password"),
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.length < 6)
                      return "Password must be at least 6 characters";
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
                        child: Text("I need a service",
                            style: TextStyle(color: const Color(0xFF0A66C2),))),
                    DropdownMenuItem(
                        value: "I am a service provider",
                        child: Text("I am a service provider",
                            style: TextStyle(color: const Color(0xFF0A66C2),))),
                  ],
                  dropdownColor: const Color(0xFFD9E1F0),
                  onChanged: (val) => setState(() => selectedRole = val),
                  validator: (val) => val == null ? "Select a role" : null,
                  style: const TextStyle(color:  const Color(0xFF0A66C2),),
                ),
                const SizedBox(height: 12),
                if (selectedRole == "I am a service provider") ...[
                  TextFormField(
                    controller: phoneController,
                    decoration: _inputDecoration("Phone"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter phone" : null,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: _inputDecoration("Address"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter address" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: skillsController,
                    decoration: _inputDecoration("Skills (comma separated)"),
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter skills" : null,
                  ),
                  const SizedBox(height: 12),
                 DropdownButtonFormField<String>(
  value: experienceLevel,
  decoration: InputDecoration(
    labelText: "Experience Level",
    filled: true,
    fillColor: const Color(0xFFD9E1F0), // Light background
    labelStyle: const TextStyle(color: const Color(0xFF0A66C2), fontWeight: FontWeight.w600),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
  ),
  items: ["Beginner", "Intermediate", "Expert"]
      .map((e) => DropdownMenuItem(
            value: e,
            child: Text(
              e,
              style: const TextStyle(
                color:  const Color(0xFF0A66C2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ))
      .toList(),
  onChanged: (val) => setState(() => experienceLevel = val),
  validator: (val) => val == null ? "Select experience level" : null,
  dropdownColor: const Color(0xFFD9E1F0),
  style: const TextStyle(
    color: Color(0xFF2A3A69),
    fontWeight: FontWeight.w500,
  ),
  icon: const Icon(Icons.keyboard_arrow_down, color: const Color(0xFF0A66C2),),
),

                  const SizedBox(height: 12),
                  // Optional fields
                  TextFormField(
                    controller: bioController,
                    decoration: _inputDecoration("Short Bio"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: govIdController,
                    decoration: _inputDecoration("Gov ID (CNIC/Passport)"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: hourlyRateController,
                    decoration: _inputDecoration("Hourly Rate (Optional)"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: portfolioController,
                    decoration: _inputDecoration(
                        "Portfolio Links (comma separated)"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: languagesController,
                    decoration:
                        _inputDecoration("Languages (comma separated)"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: educationController,
                    decoration: _inputDecoration(
                        "Education / Certifications (comma separated)"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: socialLinksController,
                    decoration: _inputDecoration(
                        "Social / Website Links (comma separated)"),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF0A66C2),))
                    :SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: signup,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0A66C2), // LinkedIn Dark Blue
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
          color:  const Color(0xFF0A66C2), // Dark LinkedIn blue
          fontWeight: FontWeight.bold,
          fontSize: 16,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF0A66C2),
          decorationThickness: 2,
        ),
      ),
    ),
  ],
)



              ],
            ),
          ),
        ),
      ),
    );
  }
}
