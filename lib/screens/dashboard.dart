// import 'package:flutter/material.dart';
// //import '../models/charts.dart';
// import 'wallet.dart';
// import '../helpers/backend.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DashboardScreen extends StatefulWidget {
//   final int userId; // provider or user id
//   final String role; // 'provider' or 'user'

//   const DashboardScreen({super.key, required this.userId, required this.role});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
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

//   int totalBookings = 0;
//   int completedTasks = 0;
//   int rejectedTasks = 0;
//   int pendingPayments = 0;
//   double totalEarnings = 0.0;
//   double walletBalance = 0.0;
//   double dashboardTotalEarnings = 0.0;
//   List<Map<String, dynamic>> bookingHistory = [];

//   Map<String, dynamic>? provider;
//   Map<String, dynamic>? latestPayment;

//   bool get isProvider => widget.role == 'provider';
//   bool get isApproved => progress["approved"] == true;

//   @override
//   void initState() {
//     super.initState();
//      print("DashboardScreen - userId: ${widget.userId}, role: ${widget.role}");
//     if (isProvider) {
//       fetchProviderDashboard();
//     } else {
//       fetchUserDashboard();
//     }
//   }

//   // ---------------- Provider Dashboard ----------------
//   Future<void> fetchProviderDashboard() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final userId = widget.userId;

//       // Provider Status
//       final statusRes = await http.get(Uri.parse('${Backend.baseUrl}/provider/status/$userId'));
//       if (statusRes.statusCode != 200) throw Exception('Failed to fetch provider status');
//       final statusData = jsonDecode(statusRes.body);
//       provider = statusData['provider'];
//       latestPayment = statusData['payment'];
//       final overallStatus = statusData['overall_status'];

//       // Task Summary
//       final summaryRes = await http.get(Uri.parse('${Backend.baseUrl}/tasks/summary?user_id=$userId'));
//       if (summaryRes.statusCode != 200) throw Exception('Failed to fetch task summary');
//       final summaryData = jsonDecode(summaryRes.body);

//       totalBookings = summaryData['totalTasks'] ?? 0;
//       completedTasks = summaryData['completedTasks'] ?? 0;
//       rejectedTasks = summaryData['rejectedTasks'] ?? 0;
//       pendingPayments = summaryData['pendingTasks'] ?? 0;
//       totalEarnings = double.tryParse(summaryData['totalEarnings'].toString()) ?? 0.0;

//       // Dashboard
//       final dashboardRes = await http.get(Uri.parse('${Backend.baseUrl}/provider/$userId/dashboard'));
//       if (dashboardRes.statusCode != 200) throw Exception('Failed to fetch dashboard');
//       final dashboardData = jsonDecode(dashboardRes.body)['dashboard'];

//       walletBalance = double.tryParse(dashboardData['wallet_balance'].toString()) ?? 0.0;
//       dashboardTotalEarnings = double.tryParse(dashboardData['total_earned'].toString()) ?? 0.0;

//       // Progress
//       progress = {
//         "signed_up": true,
//         "payment_done": latestPayment != null &&
//             (latestPayment!['payment_record_status'] == 'paid' ||
//                 latestPayment!['payment_record_status'] == 'completed'),
//         "documents_submitted": provider?['documents_uploaded'] == true,
//         "under_review": overallStatus == 'under_review',
//         "approved": provider?['provider_status'] == 'approved',
//         "rejected": provider?['provider_status'] == 'rejected',
//       };

//       setState(() => isLoading = false);
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   // ---------------- User Dashboard ----------------
//   Future<void> fetchUserDashboard() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final url = '${Backend.baseUrl}/users/${widget.userId}/dashboard';
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode != 200) throw Exception('Failed to fetch user dashboard');

//       final data = jsonDecode(response.body)['dashboard'];

//       setState(() {
//         totalBookings = data['totalBookings'] ?? 0;
//         completedTasks = data['completedTasks'] ?? 0;
//         rejectedTasks = data['rejectedTasks'] ?? 0;
//         pendingPayments = data['pendingTasks'] ?? 0;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   // ----------------- UI -----------------
//   Widget buildSummaryCards() {
//     return SizedBox(
//       height: 140,
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         children: [
//           if (isProvider)
//             summaryCard("Earnings", "PKR ${totalEarnings.toStringAsFixed(2)}", Icons.attach_money, Colors.green),
//           summaryCard("Completed", "$completedTasks", Icons.check_circle, Colors.blue),
//           summaryCard("Pending", "$pendingPayments", Icons.pending_actions, Colors.orange),
//           summaryCard("Bookings", "$totalBookings", Icons.book_online, Colors.purple),
//         ],
//       ),
//     );
//   }

//   Widget summaryCard(String title, String value, IconData icon, Color color) {
//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 12),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, color: color, size: 28),
//               const SizedBox(height: 8),
//               Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 4),
//               Text(title, style: const TextStyle(fontSize: 14)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTimeline() {
//     if (!isProvider) return const SizedBox.shrink();
//     final steps = [
//       {"key": "signed_up", "label": "Signed Up"},
//       {"key": "payment_done", "label": "Payment"},
//       {"key": "documents_submitted", "label": "Documents"},
//       {"key": "under_review", "label": "Under Review"},
//       {"key": "approved", "label": "Approved"},
//       {"key": "rejected", "label": "Rejected"},
//     ];

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: steps.map((step) {
//             final done = progress[step['key']] ?? false;
//             final isRejected = step['key'] == 'rejected' && progress['rejected'] == true;
//             final color = isRejected ? Colors.red : done ? Colors.green : Colors.grey;
//             final icon = isRejected
//                 ? Icons.cancel
//                 : done
//                     ? Icons.check_circle
//                     : Icons.radio_button_unchecked;
//             return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 6),
//               child: Row(
//                 children: [
//                   Icon(icon, color: color, size: 28),
//                   const SizedBox(width: 12),
//                   Text(
//                     step['label']!,
//                     style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: done || isRejected ? FontWeight.bold : FontWeight.normal,
//                         color: color),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget buildActionButtons() {
//     if (!isProvider) return const SizedBox.shrink();
//     return Column(
//       children: [
//         ElevatedButton.icon(
//             onPressed: isApproved ? () {} : null,
//             icon: const Icon(Icons.add_box_outlined),
//             label: const Text("Create Service")),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//             onPressed: isApproved ? () {} : null,
//             icon: const Icon(Icons.check_circle_outline),
//             label: const Text("Accept Bookings")),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//             onPressed: isApproved ? () {} : null,
//             icon: const Icon(Icons.book_online),
//             label: const Text("View Bookings")),
//         const SizedBox(height: 12),
//         ElevatedButton.icon(
//             onPressed: isApproved
//                 ? () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (_) => ProviderWalletScreen(providerId: widget.userId)));
//                   }
//                 : null,
//             icon: const Icon(Icons.account_balance_wallet_outlined),
//             label: const Text("View Wallet")),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(isProvider ? "Provider Dashboard" : "User Dashboard")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//               ? Center(child: Text(error!))
//               : Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: ListView(
//                     children: [
//                       buildSummaryCards(),
//                       buildTimeline(),
//                       if (isProvider) buildGraphsPlaceholder(),
//                       const SizedBox(height: 16),
//                       buildActionButtons(),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget buildGraphsPlaceholder() {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 12),
//       child: SizedBox(
//         height: 200,
//         child: Center(child: Text("Graphs Placeholder (Earnings/Bookings)")),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'wallet.dart';
import '../helpers/backend.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/charts.dart';
import '../helpers/coolors.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final String role;

  const DashboardScreen({super.key, required this.userId, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Logic remains untouched
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
  int rejectedTasks = 0;
  int pendingPayments = 0;
  double totalEarnings = 0.0;
  double walletBalance = 0.0;
  double dashboardTotalEarnings = 0.0;

  bool get isProvider => widget.role == 'provider';
  bool get isApproved => progress["approved"] == true;

  @override
  void initState() {
    super.initState();
    if (isProvider) {
      fetchProviderDashboard();
    } else {
      fetchUserDashboard();
    }
  }

  // --- Logic Methods (Kept exactly same) ---
  Future<void> fetchProviderDashboard() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final userId = widget.userId;
      final statusRes = await http.get(
        Uri.parse('${Backend.baseUrl}/provider/status/$userId'),
      );
      if (statusRes.statusCode != 200)
        throw Exception('Failed to fetch provider status');
      final statusData = jsonDecode(statusRes.body);
      final provider = statusData['provider'];
      final latestPayment = statusData['payment'];
      final overallStatus = statusData['overall_status'];

      final summaryRes = await http.get(
        Uri.parse('${Backend.baseUrl}/tasks/summary?user_id=$userId'),
      );
      final summaryData = jsonDecode(summaryRes.body);

      totalBookings = summaryData['totalTasks'] ?? 0;
      completedTasks = summaryData['completedTasks'] ?? 0;
      rejectedTasks = summaryData['rejectedTasks'] ?? 0;
      pendingPayments = summaryData['pendingTasks'] ?? 0;
      totalEarnings =
          double.tryParse(summaryData['totalEarnings'].toString()) ?? 0.0;

      final dashboardRes = await http.get(
        Uri.parse('${Backend.baseUrl}/provider/$userId/dashboard'),
      );
      final dashboardData = jsonDecode(dashboardRes.body)['dashboard'];
      walletBalance =
          double.tryParse(dashboardData['wallet_balance'].toString()) ?? 0.0;

      progress = {
        "signed_up": true,
        "payment_done":
            latestPayment != null &&
            (latestPayment['payment_record_status'] == 'paid' ||
                latestPayment['payment_record_status'] == 'completed'),
        "documents_submitted": provider?['documents_uploaded'] == true,
        "under_review": overallStatus == 'under_review',
        "approved": provider?['provider_status'] == 'approved',
        "rejected": provider?['provider_status'] == 'rejected',
      };
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserDashboard() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final url = '${Backend.baseUrl}/users/${widget.userId}/dashboard';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body)['dashboard'];
      setState(() {
        totalBookings = data['totalBookings'] ?? 0;
        completedTasks = data['completedTasks'] ?? 0;
        rejectedTasks = data['rejectedTasks'] ?? 0;
        pendingPayments = data['pendingTasks'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // --- UI Layout Design (Matching Image) ---

  Widget buildSummaryCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          if (isProvider)
            summaryCard(
              "Earnings",
              "PKR\n${totalEarnings.toStringAsFixed(2)}",
              Icons.monetization_on_outlined,
              const Color(0xFF4CAF50),
            ),
          summaryCard(
            "Completed",
            "$completedTasks",
            Icons.check_circle_outline,
            const Color(0xFF42A5F5),
          ),
          summaryCard(
            "Pending",
            "$pendingPayments",
            Icons.arrow_circle_down,
            const Color(0xFFFFA726),
          ),
          summaryCard(
            "Bookings",
            "$totalBookings",
            Icons.menu_book_rounded,
            const Color(0xFF9575CD),
          ),
        ],
      ),
    );
  }

  Widget summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      height: 120,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Icon(icon, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget buildTimeline() {
    if (!isProvider) return const SizedBox.shrink();
    final steps = [
      {"key": "signed_up", "label": "Signed Up"},
      {"key": "payment_done", "label": "Payment"},
      {"key": "documents_submitted", "label": "Documents"},
      {"key": "under_review", "label": "Under Review"},
      {"key": "approved", "label": "Approved"},
    ];

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const Divider(),
            ...steps.map((step) {
              final isDone = progress[step['key']] ?? false;
              final color = isDone ? Colors.green : Colors.grey.shade400;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isDone ? Icons.check_circle : Icons.circle,
                          color: color,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          step['label']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDone
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isDone ? "Approved" : "",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      isDone ? Icons.check_circle_outline : Icons.circle,
                      color: isDone ? Colors.green : Colors.grey.shade300,
                      size: 20,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons() {
    if (!isProvider) return const SizedBox.shrink();
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3.5,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        actionButton(
          "Create Service",
          Icons.add,
          Colors.white,
          Colors.black,
          isApproved,
          () {},
        ),
        actionButton(
          "ElevateButton",
          null,
          const Color(0xFF4CAF50),
          Colors.white,
          isApproved,
          () {},
        ),
        actionButton(
          "Accept Bookings",
          Icons.check_circle_outline,
          Colors.white,
          Colors.black,
          isApproved,
          () {},
        ),
        actionButton(
          "View Bookings",
          null,
          Colors.white,
          Colors.black,
          isApproved,
          () {},
        ),
        actionButton(
          "View Bookings",
          Icons.wallet_travel,
          Colors.white,
          Colors.black,
          isApproved,
          () {},
        ),
        actionButton(
          "View Wallet",
          null,
          const Color(0xFF4CAF50),
          Colors.white,
          isApproved,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProviderWalletScreen(providerId: widget.userId),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget actionButton(
    String label,
    IconData? icon,
    Color bgColor,
    Color textColor,
    bool enabled,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.zero,
      ),
      onPressed: enabled ? onTap : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 5)],
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Light grey background like image
      appBar: AppBar(
        backgroundColor: navbarColor, // Dark header from image
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: Text(
          isProvider ? "Provider Dashboard" : "User Dashboard",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                buildSummaryCards(),
                const SizedBox(height: 10),
                buildTimeline(),
                const SizedBox(height: 10),
                // Graphs Placeholder matching image style
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DashboardGraphs(
                      userId: widget.userId,
                      role: widget.role,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                buildActionButtons(),
              ],
            ),
    );
  }
}
