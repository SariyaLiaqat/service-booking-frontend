// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import '../helpers/my_colors.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   final String token; // Token from email link

//   const ResetPasswordScreen({required this.token, super.key});

//   @override
//   _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;

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

//   Future<void> resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);

//     try {
//       final url = Uri.parse('${Backend.baseUrl}/auth/reset-password');
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "token": widget.token,
//           "newPassword": passwordController.text.trim(), // <-- changed key
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data['message'] ?? 'Password updated successfully ✅'),
//             backgroundColor: const Color(0xFF0A66C2),
//           ),
//         );
//         Navigator.pop(context); // Go back to login
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(data['message'] ?? 'Oops! Something went wrong ❌'),
//             backgroundColor: Colors.redAccent,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()} ❌")));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Reset Password",style: TextStyle(color: MyColors.textPrimary),),
//         backgroundColor: MyColors.background,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Text(
//                   "Enter your new password below to reset your account password.",
//                   style: TextStyle(fontSize: 16),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: passwordController,
//                   decoration: _inputDecoration("New Password"),
//                   obscureText: true,
//                   validator: (val) {
//                     if (val == null || val.isEmpty)
//                       return "Please enter a password";
//                     if (val.length < 8)
//                       return "Password must be at least 8 characters";
//                     if (!RegExp(
//                       r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
//                     ).hasMatch(val)) {
//                       return "Include 1 uppercase, 1 number & 1 special character";
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: confirmController,
//                   decoration: _inputDecoration("Confirm Password"),
//                   obscureText: true,
//                   validator: (val) {
//                     if (val == null || val.isEmpty)
//                       return "Please confirm your password";
//                     if (val != passwordController.text)
//                       return "Passwords do not match";
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 isLoading
//                     ? const CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           MyColors.primary,
//                         ),
//                       )
//                     : SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: resetPassword,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: MyColors.background,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             "Reset Password",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: MyColors.buttonText
//                             ),
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

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({required this.token, super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool _isObscure = true; // Added for password visibility toggle

  // Refined Decoration for a "Pro" look
  InputDecoration _customInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kPrimaryColor, size: 22),
      suffixIcon: label.contains("Password") 
        ? IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: kTextSecondary),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          ) 
        : null,
      filled: true,
      fillColor: kCardColor,
      labelStyle: const TextStyle(color: kTextSecondary, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kDividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: redAccent, width: 1),
      ),
    );
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('${Backend.baseUrl}/auth/reset-password');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": widget.token,
          "newPassword": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showStatusSnackBar(data['message'] ?? 'Password updated successfully ✅', kSuccessColor);
        Navigator.pop(context);
      } else {
        _showStatusSnackBar(data['message'] ?? 'Oops! Something went wrong ❌', redAccent);
      }
    } catch (e) {
      _showStatusSnackBar("Error: ${e.toString()} ❌", redAccent);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showStatusSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Premium Visual Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, size: 64, color: kPrimaryColor),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Set New Password",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextPrimary),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your identity has been verified. Choose a strong password to secure your account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: kTextSecondary, height: 1.5),
                ),
                const SizedBox(height: 40),
                
                // New Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: _isObscure,
                  style: const TextStyle(color: kTextPrimary),
                  decoration: _customInputDecoration("New Password", Icons.lock_outline_rounded),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please enter a password";
                    if (val.length < 8) return "Password must be at least 8 characters";
                    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$').hasMatch(val)) {
                      return "Include 1 uppercase, 1 number & 1 special character";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Confirm Password Field
                TextFormField(
                  controller: confirmController,
                  obscureText: _isObscure,
                  style: const TextStyle(color: kTextPrimary),
                  decoration: _customInputDecoration("Confirm Password", Icons.lock_clock_outlined),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Please confirm your password";
                    if (val != passwordController.text) return "Passwords do not match";
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                
                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: buttonText,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                        : const Text(
                            "Update Password",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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