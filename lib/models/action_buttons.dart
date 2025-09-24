import 'package:flutter/material.dart';
import '../helpers/backend.dart';
import '../screens/chat_page.dart';
import '../screens/task_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    return Column(
      children: [
        // Message Button (Teal)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => messageProvider(context),
            icon: const Icon(Icons.chat_bubble, color: Colors.white),
            label: const Text('Message', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Book Now Button (Purple)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => bookNow(context),
            child: const Text('Book Now', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
