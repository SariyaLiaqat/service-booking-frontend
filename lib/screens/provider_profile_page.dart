import 'package:flutter/material.dart';
import '../helpers/backend.dart';
import 'chat_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'task_detail_screen.dart';
class ProviderProfilePage extends StatelessWidget {
  final Map<String, dynamic> providerData;
  final int currentUserId;

  const ProviderProfilePage({
    Key? key,
    required this.providerData,
    required this.currentUserId,
  }) : super(key: key);

  String? getProfileImage() {
    if (providerData['profile_image'] != null &&
        providerData['profile_image'] != '') {
      return providerData['profile_image'].startsWith('http')
          ? providerData['profile_image']
          : '${Backend.baseUrl}/${providerData['profile_image']}';
    }
    return null;
  }

  String? getCoverImage() {
    if (providerData['cover_image'] != null &&
        providerData['cover_image'] != '') {
      return providerData['cover_image'].startsWith('http')
          ? providerData['cover_image']
          : '${Backend.baseUrl}/${providerData['cover_image']}';
    }
    return null;
  }

  Future<void> bookService(
      BuildContext context, Map<String, dynamic> service) async {
    try {
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/tasks"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": currentUserId,
          "provider_id": providerData['id'],
          "service_id": service['id'],
          "scheduled_date": DateTime.now().toIso8601String(),
          "notes": "Booking created from mobile app",
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking request sent ✅")),
        );
      } else {
        final resBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Booking failed ❌ ${resBody['error'] ?? ''}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating booking: $e")),
      );
    }
  }

  Future<void> messageProvider(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("${Backend.baseUrl}/conversations"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": currentUserId,
          "provider_id": providerData['id'],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final conversationId = data['conversation_id'];
        final otherUserId = providerData['id'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              conversationId: conversationId,
              currentUserId: currentUserId,
              otherUserId: otherUserId,
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

  @override
  Widget build(BuildContext context) {
    final profileImage = getProfileImage();
    final coverImage = getCoverImage();

    final services = (providerData['services'] as List<dynamic>? ?? [])
        .where((s) =>
            s['title'] != null && s['title'].toString().trim() != '')
        .toList();

    final skills = providerData['skills'] is List
        ? (providerData['skills'] as List).join(', ')
        : providerData['skills'] ?? '';

    final languages = providerData['languages'] is List
        ? (providerData['languages'] as List).join(', ')
        : providerData['languages'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          providerData['name'] ?? 'Provider Profile',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover + Profile
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child: coverImage != null
                      ? Image.network(coverImage, fit: BoxFit.cover)
                      : const Center(
                          child: Text(
                            'No Cover Image',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                ),
                Positioned(
                  bottom: -50,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: profileImage != null
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage == null
                          ? const Icon(Icons.person,
                              size: 56, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 70),

            // Name + Role + Info
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    providerData['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    providerData['role'] ?? 'Service Provider',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // About Section
            if (providerData['bio'] != null &&
                providerData['bio'].toString().trim().isNotEmpty)
              sectionCard("About", providerData['bio']),
            if (skills.isNotEmpty) sectionCard("Skills", skills),
            if (providerData['experience_years'] != null)
              sectionCard("Experience",
                  "${providerData['experience_years']} years"),
            if (languages.isNotEmpty)
              sectionCard("Languages", languages),
            if (providerData['location'] != null)
              sectionCard("Location", providerData['location']),

            // Services Section
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (services.isEmpty)
                    const Text("No services available",
                        style: TextStyle(color: Colors.white70)),
                  ...services
                      .map(
                        (s) => Card(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                            title: Text(
                              s['title'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'PKR ${s['price']} • ${s['description'] ?? ''}',
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TaskDetailPage(
                                      currentUserId:
                                          currentUserId,
                                      providerId:
                                          providerData['id'],
                                      serviceData: s,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8),
                              ),
                              child: const Text('Book Now',
                                  style: TextStyle(
                                      color: Colors.white)),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Message Button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => messageProvider(context),
                  icon: const Icon(Icons.chat_bubble,
                      color: Colors.white),
                  label: const Text('Message',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // helper for clean sections
  Widget sectionCard(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8),
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 6),
              Text(content,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
