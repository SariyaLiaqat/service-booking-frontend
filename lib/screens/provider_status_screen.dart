// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../helpers/backend.dart';
// import 'wallet.dart';

// class ProviderStatusScreen extends StatefulWidget {
//   final int providerId;

//   const ProviderStatusScreen({super.key, required this.providerId});

//   @override
//   State<ProviderStatusScreen> createState() => _ProviderStatusScreenState();
// }

// class _ProviderStatusScreenState extends State<ProviderStatusScreen> {
//   bool isLoading = true;
//   String? error;
//   Map<String, bool> progress = {
//     "signed_up": false,
//     "payment_done": false,
//     "documents_submitted": false,
//     "under_review": false,
//     "approved": false,
//     "rejected": false,
//   };

//   @override
//   void initState() {
//     super.initState();
//     fetchProviderStatus();
//   }

//   Future<void> fetchProviderStatus() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/provider/status/${widget.providerId}',
//       );
//       print("Fetching URL: $url"); // 🔹 Log URL

//       final response = await http.get(url);
//       print("Status code: ${response.statusCode}"); // 🔹 Log status code
//       print("Response body: ${response.body}"); // 🔹 Log full body

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("Decoded data: $data"); // 🔹 Log parsed JSON

//         setState(() {
//           final provider = data['provider'];
//           final payment = data['payment']; // 🔹 Add this line

//           progress = {
//             "signed_up": true, // signup hamesha true hai agar provider exists
//             "payment_done":
//                 payment != null && payment['payment_record_status'] == 'paid',
//             "documents_submitted": provider['documents_uploaded'] == true,
//             "under_review": data['overall_status'] == 'under_review',
//             "approved": provider['provider_status'] == 'approved',
//             "rejected": provider['provider_status'] == 'rejected',
//           };

//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           error = "Failed to fetch status. Try again.";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Network error: $e"); // 🔹 Log exception
//       setState(() {
//         error = "Network error: $e";
//         isLoading = false;
//       });
//     }
//   }

//   Widget buildTimeline() {
//     final steps = [
//       {"key": "signed_up", "label": "Signed up"},
//       {"key": "payment_done", "label": "Payment"},
//       {"key": "documents_submitted", "label": "Documents"},
//       {"key": "under_review", "label": "Under review"},
//       {"key": "approved", "label": "Approved"},
//       {"key": "rejected", "label": "Rejected"},
//     ];

//     return Column(
//       children: steps.map((step) {
//         final isDone = progress[step['key']] ?? false;
//         final isRejected =
//             step['key'] == "rejected" && progress["rejected"] == true;
//         final color = isRejected
//             ? Colors.red
//             : isDone
//             ? Colors.green
//             : Colors.grey;

//         final icon = isRejected
//             ? Icons.cancel
//             : isDone
//             ? Icons.check_circle
//             : Icons.radio_button_unchecked;

//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8.0),
//           child: Row(
//             children: [
//               Icon(icon, color: color),
//               const SizedBox(width: 12),
//               Text(
//                 step['label']!,
//                 style: TextStyle(
//                   fontWeight: isDone || isRejected
//                       ? FontWeight.bold
//                       : FontWeight.normal,
//                   color: color,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   bool get isApproved => progress["approved"] == true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Provider Status")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//           ? Center(child: Text(error!))
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   buildTimeline(),
//                   const SizedBox(height: 30),
//                   if (!isApproved && !progress["rejected"]!)
//                     Container(
//                       color: Colors.yellow[200],
//                       padding: const EdgeInsets.all(16),
//                       child: const Text(
//                         "Awaiting verification — you cannot access provider features until approved.",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   Expanded(
//                     child: ListView(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       children: [
//                         ElevatedButton(
//                           onPressed: isApproved ? () => createService() : null,
//                           child: const Text("Create Service"),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         ElevatedButton(
//                           onPressed: isApproved ? () => acceptBooking() : null,
//                           child: const Text("Accept Bookings"),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         ElevatedButton(
//                           onPressed: isApproved ? () => viewBookings() : null,
//                           child: const Text("View Bookings"),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 12),
//                         ElevatedButton.icon(
//                           onPressed: isApproved
//                               ? () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (_) => ProviderWalletScreen(
//                                         providerId: widget.providerId,
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               : null,
//                           icon: const Icon(
//                             Icons.account_balance_wallet_outlined,
//                           ),
//                           label: const Text("View Wallet"),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   // 🔹 Placeholder navigation functions
//   void createService() {}
//   void acceptBooking() {}
//   void viewBookings() {}
// }















import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/backend.dart';
import 'wallet.dart';

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

  int totalBookings = 0;
  int completedTasks = 0;
  int pendingPayments = 0;
  double totalEarnings = 0.0;
  double walletBalance = 0.0;
  List<Map<String, dynamic>> bookingHistory = [];

  Map<String, dynamic>? provider;
  Map<String, dynamic>? latestPayment;

  @override
  void initState() {
    super.initState();
    fetchProviderDashboard();
  }




 Future<void> fetchProviderDashboard() async {
  setState(() {
    isLoading = true;
    error = null;
  });

  try {
    // 1️⃣ Fetch provider status (for timeline/progress)
    final statusUrl = '${Backend.baseUrl}/provider/status/${widget.providerId}';
    print("Fetching provider status from: $statusUrl");
    final statusRes = await http.get(Uri.parse(statusUrl));

    print("Status response code: ${statusRes.statusCode}");
    print("Status response body: ${statusRes.body}");

    if (statusRes.statusCode != 200) {
      throw Exception('Failed to fetch provider status');
    }

    final statusData = jsonDecode(statusRes.body);
    print("Decoded statusData: $statusData");

    provider = statusData['provider'];
    latestPayment = statusData['payment'];
    final overallStatus = statusData['overall_status'];

    // 2️⃣ Fetch dashboard summary (wallet + earnings + completed tasks)
    final dashboardUrl = '${Backend.baseUrl}/provider/${widget.providerId}/dashboard';
    print("Fetching dashboard from: $dashboardUrl");
    final dashboardRes = await http.get(Uri.parse(dashboardUrl));

    print("Dashboard response code: ${dashboardRes.statusCode}");
    print("Dashboard response body: ${dashboardRes.body}");

    if (dashboardRes.statusCode != 200) {
      throw Exception('Failed to fetch dashboard');
    }

    final dashboardData = jsonDecode(dashboardRes.body)['dashboard'];
    print("Decoded dashboardData: $dashboardData");

    walletBalance = double.tryParse(dashboardData['wallet_balance'].toString()) ?? 0.0;
totalEarnings = walletBalance; // wallet contains all earnings

completedTasks = int.tryParse(dashboardData['total_tasks'].toString()) ?? 0;


    // 3️⃣ Update other stats
    totalBookings = completedTasks;
    pendingPayments = 0;

    // 4️⃣ Update timeline progress
    progress = {
      "signed_up": true,
      "payment_done": latestPayment != null &&
          (latestPayment!['payment_record_status'] == 'paid' ||
              latestPayment!['payment_record_status'] == 'completed'),
      "documents_submitted": provider!['documents_uploaded'] == true,
      "under_review": overallStatus == 'under_review',
      "approved": provider!['provider_status'] == 'approved',
      "rejected": provider!['provider_status'] == 'rejected',
    };

    setState(() {
      isLoading = false;
    });
  } catch (e, stacktrace) {
    print("Error in fetchProviderDashboard: $e");
    print(stacktrace);
    setState(() {
      error = e.toString();
      isLoading = false;
    });
  }
}







  bool get isApproved => progress["approved"] == true;

  // ----------------- Widgets -----------------

  Widget buildTimeline() {
    final steps = [
      {"key": "signed_up", "label": "Signed Up"},
      {"key": "payment_done", "label": "Payment"},
      {"key": "documents_submitted", "label": "Documents"},
      {"key": "under_review", "label": "Under Review"},
      {"key": "approved", "label": "Approved"},
      {"key": "rejected", "label": "Rejected"},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: steps.map((step) {
            final done = progress[step['key']] ?? false;
            final isRejected = step['key'] == 'rejected' && progress['rejected'] == true;

            final color = isRejected ? Colors.red : done ? Colors.green : Colors.grey;
            final icon = isRejected
                ? Icons.cancel
                : done
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Text(
                    step['label']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: done || isRejected ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildSummaryCards() {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          summaryCard("Earnings", "PKR ${totalEarnings.toStringAsFixed(2)}",
              Icons.attach_money, Colors.green),
          summaryCard("Completed", "$completedTasks", Icons.check_circle, Colors.blue),
          summaryCard("Pending", "$pendingPayments", Icons.pending_actions, Colors.orange),
          summaryCard("Bookings", "$totalBookings", Icons.book_online, Colors.purple),
        ],
      ),
    );
  }

  Widget summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBookingHistory() {
    if (bookingHistory.isEmpty) return const Center(child: Text("No bookings yet"));

    return Column(
      children: bookingHistory.map((b) {
        final isPaid = b['payment_status'].toString().toLowerCase() == 'paid' ||
            b['payment_status'].toString().toLowerCase() == 'completed';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(b['title'] ?? "Task #${b['id']}"),
            subtitle: Text("Date: ${b['scheduled_date']}"),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("PKR ${b['amount'] ?? 0}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  isPaid ? "Paid" : "Pending",
                  style: TextStyle(
                      color: isPaid ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Provider Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildSummaryCards(),
                      const SizedBox(height: 16),
                      buildTimeline(),
                      const SizedBox(height: 20),
                      if (!isApproved && !progress['rejected']!)
                        Container(
                          color: Colors.yellow[200],
                          padding: const EdgeInsets.all(16),
                          child: const Text(
                            "Awaiting verification — you cannot access provider features until approved.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          children: [
                            buildBookingHistory(),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: isApproved ? () {} : null,
                              child: const Text("Create Service"),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: isApproved ? () {} : null,
                              child: const Text("Accept Bookings"),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: isApproved ? () {} : null,
                              child: const Text("View Bookings"),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: isApproved
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProviderWalletScreen(
                                              providerId: widget.providerId),
                                        ),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.account_balance_wallet_outlined),
                              label: const Text("View Wallet"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
