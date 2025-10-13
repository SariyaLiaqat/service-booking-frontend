
/////
///
///
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'forgot_password.dart';
import 'home_screen.dart';
import 'signup.dart';
import '../helpers/backend.dart';
import '../helpers/my_colors.dart';
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
bool _obscurePassword = true; // add this at top of your _LoginScreenState

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
    fillColor: MyColors.surface, // same as signup

    labelStyle: const TextStyle(
      color: Colors.white70,
      fontWeight: FontWeight.w500,
      fontSize: 13,
    ),

    // Rounded soft look
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(14),
    ),

    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
 // White background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Top SVG Image
                // SvgPicture.asset('assets/svg/login.svg', height: 150),
                // const SizedBox(height: 20),
               ShaderMask(
  shaderCallback: (bounds) => const LinearGradient(
    colors: [MyColors.primary, Colors.purpleAccent],
  ).createShader(bounds),
  child: const Text(
    "Welcome Back",
    style: TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.8,
    ),
  ),
),

                const SizedBox(height: 25),

                // Email Field
               TextFormField(
  controller: emailController,
  decoration: _inputDecoration("Email"),
  keyboardType: TextInputType.emailAddress,
 style: const TextStyle(color: Colors.white),

  validator: (val) {
    if (val == null || val.isEmpty) {
      return "Enter email";
    }
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(val)) {
      return "Enter a valid email address";
    }
    return null;
  },
),





                const SizedBox(height: 16),

                // Password Field
               TextFormField(
  controller: passwordController,
  decoration: _inputDecoration("Password").copyWith(
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility_off : Icons.visibility,
        color: MyColors.primary,

      ),
      onPressed: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
    ),
  ),
  obscureText: _obscurePassword,
  style: const TextStyle(color: MyColors.textPrimary),

  validator: (val) {
    if (val == null || val.isEmpty) {
      return "Enter password";
    }
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    if (!regex.hasMatch(val)) {
      return "Password must be 8+ chars, include 1 uppercase, 1 number, and 1 special char";
    }
    return null;
  },
),
// Forgot Password link
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
      );
    },
    child: const Text(
  "Forgot Password?",
  style: TextStyle(
    color: MyColors.primary,
    fontWeight: FontWeight.w600,
  ),
),

  ),
),
const SizedBox(height: 16),


                const SizedBox(height: 24),

                // Login Button
                isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          MyColors.primary,
                        ),
                      )
                    : SizedBox(
 width: double.infinity,
  child: ElevatedButton(
  onPressed: login,
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    backgroundColor: MyColors.buttonBackground,
    foregroundColor: Colors.white,
    elevation: 8,
    shadowColor: MyColors.primary.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22), // 👈 smoother round corners
      side: const BorderSide(
        color: MyColors.secondary, // 👈 thin subtle border
        width: 1.2,
      ),
    ),
  ),
  child: const Text(
    "Login",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
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
        color: MyColors.textSecondary, // Soft light LinkedIn blue
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
          color: MyColors.primary, // Dark LinkedIn premium blue
          fontWeight: FontWeight.bold,
          fontSize: 16,
          decoration: TextDecoration.underline,
          decorationColor:MyColors.primary,
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
