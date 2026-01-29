// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import '../helpers/my_colors.dart';
// class ForgotPasswordScreen extends StatefulWidget {
//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   Future<void> sendResetLink() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final url = Uri.parse('${Backend.baseUrl}/auth/forgot-password');
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"email": emailController.text.trim()}),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data['message'] ?? 'Password reset link sent ✅'),
//             backgroundColor: const Color(0xFF0A66C2),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data['message'] ?? 'Oops! Something went wrong ❌'),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: ${e.toString()} ❌"),
//         ),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       filled: true,
//       fillColor: const Color(0xFFE6F0FA),
//       labelStyle: const TextStyle(
//         color: Color(0xFF0A66C2),
//         fontWeight: FontWeight.w600,
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFB0C4DE), width: 1),
//       ),
//       floatingLabelBehavior: FloatingLabelBehavior.always,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Forgot Password",style: TextStyle(color: MyColors.buttonText),),
//         backgroundColor: MyColors.background
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Text(
//                   "Enter your registered email and we'll send you a password reset link.",
//                   style: TextStyle(fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: emailController,
//                   decoration: _inputDecoration("Email"),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (val) {
//                     if (val == null || val.isEmpty) return "Please enter your email";
//                     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(val)) {
//                       return "Enter a valid email address";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 isLoading
//                     ? const CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(MyColors.primary),
//                       )
//                     : SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: sendResetLink,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: MyColors.background,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             "Send Reset Link",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: MyColors.buttonText),
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }











import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import '../helpers/coolors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Logic remains untouched as requested
  Future<void> sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${Backend.baseUrl}/auth/forgot-password');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showCustomSnackBar(data['message'] ?? 'Password reset link sent ✅', kSuccessColor);
      } else {
        _showCustomSnackBar(data['message'] ?? 'Oops! Something went wrong ❌', redAccent);
      }
    } catch (e) {
      _showCustomSnackBar("Error: ${e.toString()} ❌", redAccent);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: kTextPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Icon Header for Professional Look
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded, size: 80, color: kPrimaryColor),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Don't worry! Please enter the email address linked with your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: kTextSecondary, height: 1.5),
                ),
                const SizedBox(height: 48),
                // Redesigned Input Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: kTextPrimary),
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    hintText: "example@mail.com",
                    prefixIcon: const Icon(Icons.email_outlined, color: kPrimaryColor),
                    filled: true,
                    fillColor: kCardColor,
                    labelStyle: const TextStyle(color: kTextSecondary),
                    floatingLabelStyle: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                    contentPadding: const EdgeInsets.all(20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: kDividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please enter your email";
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(val)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Modern Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: buttonText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Send Reset Link",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}