
import 'package:flutter/material.dart';
import '../helpers/backend.dart';
import '../screens/chat_page.dart';
import '../screens/task_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/my_colors.dart';
class ActionButtonsWidget extends StatelessWidget {
  final int providerId;               // Provider ka ID (jiske profile par ho)
  final String providerName;          // Provider ka Name
  final String phone;                 // Provider ka Phone
  final int currentUserId;            // Login user ka ID
  final Map<String, dynamic>? serviceData; // Optional service for "Book Now"

  const ActionButtonsWidget({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.phone,
    required this.currentUserId,
    this.serviceData,
  });

  // ---------------- MESSAGE BUTTON LOGIC ----------------
  Future<void> messageProvider(BuildContext context) async {
    try {
      // Backend me conversation create ya fetch
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/conversations"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": currentUserId,   // Login user
          "provider_id": providerId,   // Profile ka provider
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final conversationId = data['conversation_id'] ?? data['id'];

        // ChatPage me correct providerId pass karo
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: conversationId,
              currentUserId: currentUserId,
              otherUserId: providerId,  // Provider ka ID
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to start chat ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error starting chat: $e")),
      );
    }
  }

  // ---------------- BOOK NOW BUTTON LOGIC ----------------
  void bookNow(BuildContext context) {
    if (serviceData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskDetailPage(
            currentUserId: currentUserId,
            providerId: providerId,
            serviceData: serviceData!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a service for booking ❌")),
      );
    }
  }

  // ---------------- WIDGET BUILD ----------------
  @override
Widget build(BuildContext context) {
  return Row(
    children: [
      // Message Button (LinkedIn style solid)
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => messageProvider(context),
          icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 18),
          label: const Text(
            'Message',
            style: TextStyle(
              color: MyColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.primary, // LinkedIn Dark Blue
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
      ),

      const SizedBox(width: 12),

      // Book Now Button (LinkedIn style outline)
      Expanded(
        child: OutlinedButton(
          onPressed: () => bookNow(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(
              color: MyColors.primary, // LinkedIn Dark Blue Border
              width: 2,
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Book Now',
            style: TextStyle(
              color: MyColors.primary, // LinkedIn Dark Blue Text
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ],
  );
}

}
