
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../helpers/backend.dart';
// import '../helpers/coolors.dart'; // updated colors
// import 'package:lottie/lottie.dart';

// class ContactUsPage extends StatefulWidget {
//   const ContactUsPage({super.key});

//   @override
//   State<ContactUsPage> createState() => _ContactUsPageState();
// }

// class _ContactUsPageState extends State<ContactUsPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController subjectController = TextEditingController();
//   final TextEditingController messageController = TextEditingController();

//   bool isLoading = false;

//   void submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => isLoading = true);

//       try {
//         final response = await http.post(
//           Uri.parse("${Backend.baseUrl}/api/contact/submit"),
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode({
//             "name": nameController.text.trim(),
//             "email": emailController.text.trim(),
//             "phone": phoneController.text.trim(),
//             "subject": subjectController.text.trim(),
//             "message": messageController.text.trim(),
//           }),
//         );

//         setState(() => isLoading = false);

//         if (response.statusCode == 201) {
//           showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               backgroundColor: kCardColor,
//               title: const Text(
//                 "Request Submitted!",
//                 style: TextStyle(color: kTextPrimary),
//               ),
//               content: const Text(
//                 "Your request has been submitted. We will respond within 24 hours.",
//                 style: TextStyle(color: kTextSecondary),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text(
//                     "OK",
//                     style: TextStyle(color: kPrimaryColor),
//                   ),
//                 ),
//               ],
//             ),
//           );

//           // Clear all fields after successful submit
//           nameController.clear();
//           emailController.clear();
//           phoneController.clear();
//           subjectController.clear();
//           messageController.clear();
//         } else {
//           final res = jsonDecode(response.body);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               backgroundColor: redAccent,
//               content: Text(res['message'] ?? "Failed to submit request"),
//             ),
//           );
//         }
//       } catch (e) {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(backgroundColor: redAccent, content: Text("Error: $e")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Heading
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 40.0),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Get in Touch",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: kTextPrimary,
//                         shadows: [
//                           Shadow(
//                             color: Colors.black26,
//                             offset: Offset(2, 2),
//                             blurRadius: 4,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "We'd love to hear from you",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 16, color: kTextSecondary),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 35),
//               const SizedBox(height: 30),

//               // Mock image below button
//               SizedBox(
//                 height: 200,
//                 child: Lottie.asset(
//                   'assets/lottie/Contact Us.json',
//                   fit: BoxFit.contain,
//                   repeat: true,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Paragraph below image
//               Text(
//                 "We are always here to help you! Whether you have questions, suggestions, or need support, "
//                 "our team is just a message away. Feel free to reach out anytime, and we'll make sure your "
//                 "queries are answered promptly. Your feedback helps us improve and serve you better. "
//                 "Contact us with confidence and let's make great things happen together. "
//                 "We value every message and strive to respond within 24 hours. Thank you for connecting with us!",
//                 style: TextStyle(
//                   color: kTextSecondary,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.justify,
//               ),
//               const SizedBox(height: 40),

//               _buildTextField(nameController, "Name"),
//               const SizedBox(height: 16),
//               _buildTextField(emailController, "Email", isEmail: true),
//               const SizedBox(height: 16),
//               _buildTextField(phoneController, "Phone", isPhone: true),
//               const SizedBox(height: 16),
//               _buildTextField(subjectController, "Subject"),
//               const SizedBox(height: 16),
//               _buildTextField(messageController, "Message", maxLines: 5),
//               const SizedBox(height: 24),

//               SizedBox(
//                 height: 50,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: kPrimaryColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: isLoading ? null : submitForm,
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: buttonText)
//                       : const Text(
//                           "Submit",
//                           style: TextStyle(fontSize: 18, color: buttonText),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label, {
//     bool isEmail = false,
//     bool isPhone = false,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       style: TextStyle(color: kTextPrimary),
//       keyboardType: isEmail
//           ? TextInputType.emailAddress
//           : isPhone
//           ? TextInputType.phone
//           : TextInputType.text,
//       validator: (value) {
//         if (value == null || value.trim().isEmpty) {
//           return '$label is required';
//         }
//         if (isEmail && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(value.trim())) {
//           return 'Enter a valid email';
//         }
//         if (isPhone && !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value.trim())) {
//           return 'Enter a valid phone number';
//         }
//         return null;
//       },
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: kTextSecondary),
//         filled: true,
//         fillColor: kCardColor,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: kDividerColor),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: kDividerColor),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: kPrimaryColor, width: 2),
//         ),
//         hintStyle: TextStyle(color: kTextHint),
//       ),
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/backend.dart';
import '../helpers/coolors.dart';
import 'package:lottie/lottie.dart';

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
          _showSuccessDialog();
          nameController.clear();
          emailController.clear();
          phoneController.clear();
          subjectController.clear();
          messageController.clear();
        } else {
          final res = jsonDecode(response.body);
          _showSnackBar(res['message'] ?? "Failed to submit request", redAccent);
        }
      } catch (e) {
        setState(() => isLoading = false);
        _showSnackBar("Error: $e", redAccent);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kCardColor,
        title: const Text("Message Sent", style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
        content: const Text("Thank you for reaching out. Our team will contact you within 24 hours.", style: TextStyle(color: kTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: color, content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Contact Support", style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 🔹 Lottie Animation Header
              Center(
                child: SizedBox(
                  height: 180,
                  child: Lottie.asset('assets/lottie/Contact Us.json', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),
              
              // 🔹 Professional Intro
              const Text("Get in Touch", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kTextPrimary)),
              const SizedBox(height: 8),
              Text(
                "Have a question or feedback? Fill out the form below and our team will get back to you shortly.",
                style: TextStyle(color: kTextSecondary, fontSize: 14, height: 1.5),
              ),
              
              const SizedBox(height: 30),

              // 🔹 Input Fields
              _buildModernField(nameController, "Full Name", Icons.person_outline),
              const SizedBox(height: 16),
              _buildModernField(emailController, "Email Address", Icons.email_outlined, isEmail: true),
              const SizedBox(height: 16),
              _buildModernField(phoneController, "Phone Number", Icons.phone_android_outlined, isPhone: true),
              const SizedBox(height: 16),
              _buildModernField(subjectController, "Subject", Icons.subject_rounded),
              const SizedBox(height: 16),
              _buildModernField(messageController, "How can we help?", Icons.chat_bubble_outline_rounded, maxLines: 4),

              const SizedBox(height: 32),

              // 🔹 Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLoading ? null : submitForm,
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Send Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isEmail = false,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.w500),
          keyboardType: isEmail ? TextInputType.emailAddress : isPhone ? TextInputType.phone : TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return '$hint is required';
            if (isEmail && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(value.trim())) return 'Enter a valid email';
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
            hintStyle: const TextStyle(color: kTextHint, fontSize: 14),
            filled: true,
            fillColor: kCardColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: kDividerColor.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: kDividerColor.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}