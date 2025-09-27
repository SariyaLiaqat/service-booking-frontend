
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
              backgroundColor: Color(0xFF0A66C2),
            ),
          );
        } else if (data['token'] != null) {
          await storage.write(key: 'jwt', value: data['token']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful ✅'),
              backgroundColor:  Color(0xFF0A66C2),
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
    fillColor: const Color(0xFFE6F0FA), // Soft light LinkedIn-ish background
    labelStyle: const TextStyle(
      color: Color(0xFF0A66C2), // Dark LinkedIn blue for label
      fontWeight: FontWeight.w600,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF0A66C2), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFB0C4DE), width: 1), // subtle border
    ),
    floatingLabelBehavior: FloatingLabelBehavior.always,
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
                    color: Color(0xFF0A66C2),
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
                  style: const TextStyle(color: Color(0xFF0A66C2),),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter email" : null,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  decoration: _inputDecoration("Password"),
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFF0A66C2),),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter password" : null,
                ),
                const SizedBox(height: 24),

                // Login Button
                isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0A66C2),
                        ),
                      )
                    : SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: login,
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: const Color(0xFF0A66C2), // LinkedIn premium blue
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4, // Slight shadow for premium feel
    ),
    child: const Text(
      "Login",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5, // Premium subtle touch
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
        color: Color(0xFF5C74B1), // Soft light LinkedIn blue
        fontWeight: FontWeight.w500,
        fontSize: 16,
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
          color: Color(0xFF0A66C2), // Dark LinkedIn premium blue
          fontWeight: FontWeight.bold,
          fontSize: 16,
          decoration: TextDecoration.underline,
          decorationColor: Color(0xFF0A66C2),
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
