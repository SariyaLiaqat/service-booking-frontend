import 'package:flutter/material.dart';
import '../helpers/backend.dart';
import '../models/action_buttons.dart';

class ExternalProfileWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final int currentUserId;

  const ExternalProfileWidget({super.key, required this.userData, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final user = userData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name & Username
        Text(user['name'] ?? 'Unknown', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
        if (user['username'] != null) Text('@${user['username']}', style: const TextStyle(color: Color(0xFF5C74B1))),
        if (user['bio'] != null && (user['bio'] as String).isNotEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(user['bio'], style: const TextStyle(color: Color(0xFF5C74B1)))),

        const SizedBox(height: 12),

        // Action Buttons
        ActionButtonsWidget(
          providerId: user['id'] ?? 0,
          providerName: user['name'] ?? 'Unknown',
          phone: user['phone'] ?? '',
          currentUserId: currentUserId,
          serviceData: (user['services'] != null && (user['services'] as List).isNotEmpty)
              ? (user['services'][0] as Map<String, dynamic>)
              : null,
        ),

        const SizedBox(height: 20),

        // Provider Info
        if (user['role'] == 'provider') ...[
          Text('Experience: ${user['experience_years'] ?? '-'} years', style: const TextStyle(color: Color(0xFF5C74B1))),
          Text('Level: ${user['experience_level'] ?? '-'}', style: const TextStyle(color: Color(0xFF5C74B1))),
          Text('Hourly Rate: PKR ${user['hourly_rate'] ?? '-'}', style: const TextStyle(color: Color(0xFF5C74B1))),
          const SizedBox(height: 10),

          // Languages
          Wrap(
            spacing: 6,
            children: user['languages'] != null
                ? (user['languages'] as List)
                    .map<Widget>((l) => Chip(label: Text(l), backgroundColor: const Color(0xFF2A3A69), labelStyle: const TextStyle(color: Colors.white)))
                    .toList()
                : const [Text('-', style: TextStyle(color: Color(0xFF5C74B1)))],
          ),

          const SizedBox(height: 10),

          // Portfolio Links
          if (user['portfolio_links'] != null && (user['portfolio_links'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Portfolio Links:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
                ... (user['portfolio_links'] as List).map((link) => Text(link, style: const TextStyle(color: Color(0xFF5C74B1)))),
              ],
            ),

          const SizedBox(height: 10),

          // Social Links
          if (user['social_links'] != null && (user['social_links'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Social Links:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
                ... (user['social_links'] as List).map((link) => Text(link, style: const TextStyle(color: Color(0xFF5C74B1)))),
              ],
            ),

          const SizedBox(height: 20),

          // Services
          const Text('Services:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A3A69))),
          if (user['services'] != null && (user['services'] as List).isNotEmpty)
            ... (user['services'] as List).map((s) => Card(
                  color: const Color(0xFFD9E1F0),
                  child: ListTile(
                    title: Text(s['title'], style: const TextStyle(color: Color(0xFF2A3A69))),
                    subtitle: Text('${s['description'] ?? ''} - PKR ${s['price']}', style: const TextStyle(color: Color(0xFF5C74B1))),
                  ),
                ))
          else
            const Text('No services available', style: TextStyle(color: Color(0xFF5C74B1))),
        ],
      ],
    );
  }
}
