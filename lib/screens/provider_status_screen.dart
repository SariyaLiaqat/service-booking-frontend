import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/backend.dart';

class ProviderStatusScreen extends StatefulWidget {
  final int providerId;

  const ProviderStatusScreen({super.key, required this.providerId});

  @override
  State<ProviderStatusScreen> createState() => _ProviderStatusScreenState();
}

class _ProviderStatusScreenState extends State<ProviderStatusScreen> {
  bool isLoading = true;
  String? error;
  Map<String, bool> progress = {
    "signed_up": false,
    "payment_done": false,
    "documents_submitted": false,
    "under_review": false,
    "approved": false,
    "rejected": false,
  };

  @override
  void initState() {
    super.initState();
    fetchProviderStatus();
  }

  Future<void> fetchProviderStatus() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final url = Uri.parse('${Backend.baseUrl}/provider/${widget.providerId}/status');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          progress = {
            "signed_up": data['signed_up'] ?? false,
            "payment_done": data['payment_done'] ?? false,
            "documents_submitted": data['documents_submitted'] ?? false,
            "under_review": data['under_review'] ?? false,
            "approved": data['approved'] ?? false,
            "rejected": data['rejected'] ?? false,
          };
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to fetch status. Try again.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Network error: $e";
        isLoading = false;
      });
    }
  }

  Widget buildTimeline() {
    final steps = [
      {"key": "signed_up", "label": "Signed up"},
      {"key": "payment_done", "label": "Payment"},
      {"key": "documents_submitted", "label": "Documents"},
      {"key": "under_review", "label": "Under review"},
      {"key": "approved", "label": "Approved"},
      {"key": "rejected", "label": "Rejected"},
    ];

    return Column(
      children: steps.map((step) {
        final isDone = progress[step['key']] ?? false;
        final isRejected = step['key'] == "rejected" && progress["rejected"] == true;
        final color = isRejected
            ? Colors.red
            : isDone
                ? Colors.green
                : Colors.grey;

        final icon = isRejected
            ? Icons.cancel
            : isDone
                ? Icons.check_circle
                : Icons.radio_button_unchecked;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(
                step['label']!,
                style: TextStyle(
                  fontWeight: isDone || isRejected ? FontWeight.bold : FontWeight.normal,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool get isApproved => progress["approved"] == true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Provider Status")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTimeline(),
                      const SizedBox(height: 30),
                      if (!isApproved && !progress["rejected"]!)
                        Container(
                          color: Colors.yellow[200],
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            "Awaiting verification — you cannot access provider features until approved.",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            ElevatedButton(
                              onPressed: isApproved ? () => createService() : null,
                              child: const Text("Create Service"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: isApproved ? () => acceptBooking() : null,
                              child: const Text("Accept Bookings"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: isApproved ? () => viewBookings() : null,
                              child: const Text("View Bookings"),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // 🔹 Placeholder navigation functions
  void createService() {}
  void acceptBooking() {}
  void viewBookings() {}
}
