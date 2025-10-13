

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import '../helpers/my_colors.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final response = await http.post(
          Uri.parse("${Backend.baseUrl}/api/contact/submit"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": nameController.text.trim(),
            "email": emailController.text.trim(),
            "phone": phoneController.text.trim(),
            "subject": subjectController.text.trim(),
            "message": messageController.text.trim(),
          }),
        );

        setState(() => isLoading = false);

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: MyColors.surface,
              title: const Text(
                "Request Submitted!",
                style: TextStyle(color: MyColors.textPrimary),
              ),
              content: const Text(
                "Your request has been submitted. We will respond within 24 hours.",
                style: TextStyle(color: MyColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "OK",
                    style: TextStyle(color: MyColors.primary),
                  ),
                )
              ],
            ),
          );
          _formKey.currentState!.reset();
        } else {
          final res = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: MyColors.error,
              content: Text(res['message'] ?? "Failed to submit request"),
            ),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: MyColors.error,
            content: Text("Error: $e"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // New Heading
   // Heading
Padding(
  padding: const EdgeInsets.symmetric(vertical: 40.0), // top & bottom spacing
  child: Column(
    children: [
      Text(
        "Get in touch",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: MyColors.textPrimary,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Text(
        "We'd love to hear from you",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[400],
        ),
      ),
    ],
  ),
),

    SizedBox(height: 35), // spacing below heading

              _buildTextField(nameController, "Name"),
              const SizedBox(height: 16),
              _buildTextField(emailController, "Email", isEmail: true),
              const SizedBox(height: 16),
              _buildTextField(phoneController, "Phone", isPhone: true),
              const SizedBox(height: 16),
              _buildTextField(subjectController, "Subject"),
              const SizedBox(height: 16),
              _buildTextField(messageController, "Message", maxLines: 5),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : submitForm,
                  child: isLoading
                      ? const CircularProgressIndicator(color: MyColors.textPrimary)
                      : const Text(
                          "Submit",
                          style: TextStyle(
                              fontSize: 18, color: MyColors.textPrimary),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isEmail = false, bool isPhone = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: MyColors.textPrimary),
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
              ? TextInputType.phone
              : TextInputType.text,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        if (isEmail &&
            !RegExp(r'^\S+@\S+\.\S+$').hasMatch(value.trim())) {
          return 'Enter a valid email';
        }
        if (isPhone &&
            !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value.trim())) {
          return 'Enter a valid phone number';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: MyColors.textSecondary),
        filled: true,
        fillColor: MyColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MyColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MyColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: MyColors.inputFocusedBorder, width: 2),
        ),
        hintStyle: const TextStyle(color: MyColors.hintText),
      ),
    );
  }
}
